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
  static const String _storageKey = 'session_plan_v1';

  SessionPlanner() {
    _load();
  }

  List<SessionItem> get items => List.unmodifiable(_items);
  int get count => _items.length;
  bool get isEmpty => _items.isEmpty;
  bool get isNotEmpty => _items.isNotEmpty;

  bool contains(String muscleId) => _items.any((i) => i.muscleId == muscleId);

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

  void _mutate(String muscleId, SessionItem Function(SessionItem) update) {
    final idx = _items.indexWhere((i) => i.muscleId == muscleId);
    if (idx < 0) return;
    _items[idx] = update(_items[idx]);
    _save();
    notifyListeners();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw == null) return;
      final list = json.decode(raw) as List<dynamic>;
      _items = list
          .map((e) => SessionItem.fromJson(e as Map<String, dynamic>))
          .toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading session plan: $e');
    }
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _storageKey,
        json.encode(_items.map((i) => i.toJson()).toList()),
      );
    } catch (e) {
      debugPrint('Error saving session plan: $e');
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
