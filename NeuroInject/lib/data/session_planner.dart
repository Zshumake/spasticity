import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/muscle.dart';
import '../models/session_item.dart';

/// Holds the clinician's in-progress injection session: a list of muscles
/// with chosen brand, per-side dose, and laterality. Persisted locally (no
/// patient identifiers) so a plan survives an app restart.
class SessionPlanner extends ChangeNotifier {
  List<SessionItem> _items = [];
  final Map<String, List<SessionItem>> _saved = {};
  static const String _storageKey = 'session_plan_v1';
  static const String _savedKey = 'saved_sessions_v1';
  static const String _startedKey = 'session_started_at_v1';

  /// When the live session was started, or null when the plan is not running.
  /// Persisted with the plan: a procedure that outlives a backgrounded app
  /// must come back with its clock and its ticked-off muscles intact.
  int? _startedAtMillis;

  SessionPlanner() {
    _load();
  }

  List<SessionItem> get items => List.unmodifiable(_items);
  int get count => _items.length;
  bool get isEmpty => _items.isEmpty;
  bool get isNotEmpty => _items.isNotEmpty;

  bool contains(String muscleId) => _items.any((i) => i.muscleId == muscleId);

  // ─── Live session ────────────────────────────────────────────

  bool get isRunning => _startedAtMillis != null;
  Duration get elapsed => _startedAtMillis == null
      ? Duration.zero
      : DateTime.now()
          .difference(DateTime.fromMillisecondsSinceEpoch(_startedAtMillis!));

  List<SessionItem> get remaining =>
      _items.where((i) => !i.isDone).toList(growable: false);
  List<SessionItem> get completed =>
      _items.where((i) => i.isDone).toList(growable: false);

  /// The muscle being injected: the first one not yet finished.
  SessionItem? get current => remaining.isEmpty ? null : remaining.first;

  /// Units actually delivered so far, per brand — only finished muscles that
  /// had at least one site logged. A skipped muscle contributes nothing, which
  /// is the difference between this and [brandTotals] (what was planned).
  Map<String, double> get deliveredTotals {
    final totals = <String, double>{};
    for (final it in _items) {
      if (!it.isDone || it.sitesLogged == 0) continue;
      totals[it.brand] = (totals[it.brand] ?? 0) + it.totalUnits;
    }
    return totals;
  }

  void startSession() {
    if (_items.isEmpty || isRunning) return;
    _startedAtMillis = DateTime.now().millisecondsSinceEpoch;
    _save();
    notifyListeners();
  }

  /// Ends the run and clears every muscle's progress, leaving the plan itself
  /// intact so the same list can be run again at the next visit.
  void endSession() {
    _startedAtMillis = null;
    _items = _items
        .map((i) => i.copyWith(sitesLogged: 0, clearCompletedAt: true))
        .toList();
    _save();
    notifyListeners();
  }

  void logSite(String muscleId) =>
      _mutate(muscleId, (i) => i.copyWith(sitesLogged: i.sitesLogged + 1));

  void undoSite(String muscleId) => _mutate(muscleId,
      (i) => i.copyWith(sitesLogged: i.sitesLogged > 0 ? i.sitesLogged - 1 : 0));

  /// Marks a muscle finished. With no sites logged this records a deliberate
  /// skip rather than a completed injection — see [SessionItem.wasSkipped].
  void finishMuscle(String muscleId) => _mutate(muscleId,
      (i) => i.copyWith(
          completedAtMillis: DateTime.now().millisecondsSinceEpoch));

  void reopenMuscle(String muscleId) =>
      _mutate(muscleId, (i) => i.copyWith(clearCompletedAt: true));

  SessionItem? itemFor(String muscleId) {
    for (final i in _items) {
      if (i.muscleId == muscleId) return i;
    }
    return null;
  }

  /// Per-brand total units (bilateral doses counted twice), in the order
  /// brands first appear in the plan.
  Map<String, double> get brandTotals {
    final totals = <String, double>{};
    for (final it in _items) {
      totals[it.brand] = (totals[it.brand] ?? 0) + it.totalUnits;
    }
    return totals;
  }

  /// Add a muscle to the plan, or replace its existing line (one line per
  /// muscle — laterality handles the both-sides case).
  void addOrUpdate(SessionItem item) {
    final idx = _items.indexWhere((i) => i.muscleId == item.muscleId);
    if (idx >= 0) {
      _items[idx] = item;
    } else {
      _items.add(item);
    }
    _save();
    notifyListeners();
  }

  /// Add several muscles at once (replacing any existing line by muscleId),
  /// notifying listeners a single time. Used for "add a whole pattern".
  void addAll(Iterable<SessionItem> newItems) {
    var changed = false;
    for (final item in newItems) {
      final idx = _items.indexWhere((i) => i.muscleId == item.muscleId);
      if (idx >= 0) {
        _items[idx] = item;
      } else {
        _items.add(item);
      }
      changed = true;
    }
    if (!changed) return;
    _save();
    notifyListeners();
  }

  void remove(String muscleId) {
    _items.removeWhere((i) => i.muscleId == muscleId);
    _save();
    notifyListeners();
  }

  void setDose(String muscleId, double dose) =>
      _mutate(muscleId, (i) => i.copyWith(dose: dose < 0 ? 0 : dose));

  void setSide(String muscleId, InjectionSide side) =>
      _mutate(muscleId, (i) => i.copyWith(side: side));

  void setBrand(String muscleId, String brand, double dose) =>
      _mutate(muscleId, (i) => i.copyWith(brand: brand, dose: dose));

  void clear() {
    if (_items.isEmpty) return;
    _items = [];
    _save();
    notifyListeners();
  }

  // ─── Named sessions (recurring-visit save/reload) ────────────
  // Stored locally on-device only. Names are free text — clinicians can use
  // non-identifying labels (e.g. "LUE flexor pattern") to avoid storing PHI.

  /// Names of saved sessions, most-recently-saved last.
  List<String> get savedNames => _saved.keys.toList();
  bool get hasSaved => _saved.isNotEmpty;
  int savedCount(String name) => _saved[name]?.length ?? 0;

  /// Snapshot the current plan under [name], overwriting an existing name.
  void saveCurrentAs(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty || _items.isEmpty) return;
    // Re-insert at the end so the most recent save sorts last.
    _saved.remove(trimmed);
    _saved[trimmed] = List<SessionItem>.from(_items);
    _saveSaved();
    notifyListeners();
  }

  /// Replace the current plan with the saved session [name].
  void loadSaved(String name) {
    final saved = _saved[name];
    if (saved == null) return;
    _items = List<SessionItem>.from(saved);
    _save();
    notifyListeners();
  }

  void deleteSaved(String name) {
    if (_saved.remove(name) != null) {
      _saveSaved();
      notifyListeners();
    }
  }

  void _mutate(String muscleId, SessionItem Function(SessionItem) update) {
    final idx = _items.indexWhere((i) => i.muscleId == muscleId);
    if (idx < 0) return;
    _items[idx] = update(_items[idx]);
    _save();
    notifyListeners();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();

    // Load the active plan and the saved named sessions independently, so a
    // corrupt blob in one can't suppress the other (they are unrelated data).
    try {
      final raw = prefs.getString(_storageKey);
      if (raw != null) {
        _items = (json.decode(raw) as List<dynamic>)
            .map((e) => SessionItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      // A start time with nothing to inject is meaningless state, so it is
      // dropped rather than resumed against an empty plan.
      _startedAtMillis = _items.isEmpty ? null : prefs.getInt(_startedKey);
    } catch (e) {
      debugPrint('Error loading active session plan: $e');
    }

    try {
      final savedRaw = prefs.getString(_savedKey);
      if (savedRaw != null) {
        final map = json.decode(savedRaw) as Map<String, dynamic>;
        _saved.clear();
        map.forEach((name, list) {
          _saved[name] = (list as List<dynamic>)
              .map((e) => SessionItem.fromJson(e as Map<String, dynamic>))
              .toList();
        });
      }
    } catch (e) {
      debugPrint('Error loading saved sessions: $e');
    }

    notifyListeners();
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _storageKey,
        json.encode(_items.map((i) => i.toJson()).toList()),
      );
      final started = _startedAtMillis;
      if (started == null) {
        await prefs.remove(_startedKey);
      } else {
        await prefs.setInt(_startedKey, started);
      }
    } catch (e) {
      debugPrint('Error saving session plan: $e');
    }
  }

  Future<void> _saveSaved() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final map = _saved.map(
        (name, items) => MapEntry(name, items.map((i) => i.toJson()).toList()),
      );
      await prefs.setString(_savedKey, json.encode(map));
    } catch (e) {
      debugPrint('Error saving named sessions: $e');
    }
  }
}

/// Brands (in display preference order) that [m] has a dose for.
List<String> availableBrandsFor(Muscle m) {
  final d = m.dosage;
  if (d == null) return const [];
  return [
    if (d.botox != null) 'Botox',
    if (d.xeomin != null) 'Xeomin',
    if (d.dysport != null) 'Dysport',
  ];
}

/// Midpoint dose for [brand] from a muscle's per-brand range, or null.
double? doseForBrand(Muscle m, String brand) {
  final d = m.dosage;
  if (d == null) return null;
  final range = switch (brand) {
    'Botox' => d.botox,
    'Xeomin' => d.xeomin,
    'Dysport' => d.dysport,
    _ => null,
  };
  return range == null ? null : midpointOfDoseRange(range);
}

/// A default session line for [m]: first available brand at its midpoint
/// dose, right side. Returns null if the muscle has no brand dose.
SessionItem? defaultSessionItem(Muscle m) {
  final brands = availableBrandsFor(m);
  if (brands.isEmpty) return null;
  final brand = brands.first;
  return SessionItem(
    muscleId: m.id,
    muscleName: m.name,
    group: m.group,
    brand: brand,
    dose: doseForBrand(m, brand) ?? 0,
  );
}
