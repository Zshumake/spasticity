---
title: "refactor: Frontend Polish — Full Audit Implementation"
type: refactor
status: active
date: 2026-04-05
deepened: 2026-04-05
---

## Enhancement Summary

**Deepened on:** 2026-04-05
**Research agents used:** Flutter Performance, Flutter Animations, Flutter Accessibility, Flutter Design System
**Sections enhanced:** All 6 phases

### Key Improvements from Research
1. **BackdropFilter costs 2-8ms GPU per frame** — replace with pseudo-glassmorphism (layered opacity + shadow)
2. **Use `AnimatedSwitcher` not `AnimatedCrossFade`** for mode toggle — CrossFade renders BOTH children always
3. **Use `context.select` instead of `context.watch`** in MuscleCard — eliminates N-1 unnecessary rebuilds per favorite toggle
4. **Use `ThemeExtension<AppColorsExt>`** for custom colors — eliminates all `isDark` ternaries in widget code
5. **Replace `KeyboardListener`** with `Focus` + `onKeyEvent` (deprecated API)

### New Considerations Discovered
- `shrinkWrap: true` GridView builds ALL 50 cards on every rebuild, not just visible ones
- `Semantics.onTap` must be paired with `GestureDetector.onTap` for VoiceOver activation
- macOS VoiceOver requires "interact" step (VO+Shift+Down) to enter Flutter view — expected behavior
- `AnimatedScale` is simpler than `Transform.scale` for press feedback but rebuilds widget tree; use explicit `AnimationController` for grids

---

# Frontend Polish — Full Audit Implementation

## Overview

Implement all 26 findings from the frontend audit of the NeuroInject Flutter macOS app. The audit covered accessibility, performance, design consistency, micro-interactions, and minor polish. This plan organizes the work into 6 phases, each independently shippable.

## Problem Statement

The app is functionally complete but has accumulated frontend inconsistencies: 8 GestureDetectors without Semantics, expensive BackdropFilter on opaque backgrounds, 71 direct GoogleFonts calls bypassing theme tokens, hardcoded colors, no page transitions, no staggered animations, and light-mode color bugs in procedure mode. These issues degrade the perceived quality and accessibility of what is otherwise a well-built medical education tool.

## Proposed Solution

Address all 26 audit items in 6 phases ordered by impact. Each phase is a coherent batch of changes that can be built and verified independently.

---

## Phase 1: Performance (3 items)

### 1.1 Remove BackdropFilter from InfoCard
**File:** `lib/widgets/info_card.dart:23-26`
- Remove `ClipRRect` + `BackdropFilter` wrapper — it blurs nothing (cards sit on opaque backgrounds)
- Keep the card's existing `Container` decoration
- Also check `lib/widgets/dilution_explainer.dart:40-41` for same issue
- **Verification:** Run app, confirm InfoCards render identically, check no jank on detail page scroll

#### Research Insights

**GPU Cost:** BackdropFilter with sigma=12 costs **2-4ms GPU time per frame per card** on Apple M1/M2. With 4-6 InfoCards visible during scroll, this can push frames over the 16ms budget causing visible jank.

**Replace with pseudo-glassmorphism:**
```dart
// BEFORE (expensive — 2.5 billion texture lookups per card per frame):
ClipRRect(
  borderRadius: BorderRadius.circular(16),
  child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
    child: Container(/* ... */),
  ),
)

// AFTER (near-zero GPU cost, visually similar):
Container(
  decoration: BoxDecoration(
    color: isDark
        ? AppTheme.surfaceDark.withAlpha(217)   // 0.85 opacity
        : AppTheme.surfaceLight.withAlpha(230),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: isDark ? Colors.white.withAlpha(8) : Colors.white.withAlpha(51),
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withAlpha(isDark ? 51 : 13),
        blurRadius: 24,
        offset: const Offset(0, 8),
      ),
    ],
  ),
)
```

**How to measure:** Run with `showPerformanceOverlay: true` or `flutter run -d macos --profile` and compare raster thread time before/after.

### 1.2 Replace shrinkWrap GridView with CustomScrollView + SliverGrid
**File:** `lib/screens/dashboard_page.dart:220-276`
- Replace outer `ListView` + inner `GridView.builder(shrinkWrap: true)` with `CustomScrollView` containing `SliverToBoxAdapter` (search bar + category header) + `SliverGrid`
- **Verification:** Scroll dashboard, confirm cards render correctly at all viewport widths

#### Research Insights

**Why it matters:** `shrinkWrap: true` forces ALL 50 muscle cards to build and layout on every rebuild, even though only ~9-12 are visible. This defeats Flutter's lazy rendering.

**Migration pattern:**
```dart
Widget _buildMain(List<Muscle> muscles, bool isMobile, bool isDark) {
  return CustomScrollView(
    slivers: [
      SliverToBoxAdapter(child: _buildSearchBar(isMobile, isDark)),
      SliverToBoxAdapter(child: _buildCategoryHeader(muscles, isDark)),
      if (muscles.isNotEmpty)
        SliverPadding(
          padding: EdgeInsets.fromLTRB(isMobile ? 16 : 24, 0, isMobile ? 16 : 24, 24),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(/* ... */),
            delegate: SliverChildBuilderDelegate(
              (ctx, i) => MuscleCard(muscle: muscles[i], isSelected: i == _selectedIndex),
              childCount: muscles.length,
            ),
          ),
        ),
      if (muscles.isEmpty) SliverFillRemaining(hasScrollBody: false, child: _emptyState()),
    ],
  );
}
```

**Use `SliverToBoxAdapter`** for the search bar (not `SliverAppBar`). SliverAppBar brings unwanted elevation/snap behaviors. If you later want pinned search, use `SliverPersistentHeader` with a custom delegate.

### 1.3 Eliminate duplicate filtering logic + Provider rebuild optimization
**File:** `lib/screens/dashboard_page.dart:65-149`
- Merge `_getFiltered()` and `_getFilteredSync()` into a single method
- Replace `context.watch<FavoritesManager>()` with `context.select` in MuscleCard
- **Verification:** Search, category filter, keyboard nav all still work

#### Research Insights

**Current problem:** `_getFiltered()` calls `context.watch` on 3 providers. Toggling ONE favorite rebuilds the ENTIRE page including all 50 MuscleCards.

**Fix in MuscleCard — use `context.select` for surgical rebuilds:**
```dart
// BEFORE: Every card rebuilds when any favorite changes
final favs = context.watch<FavoritesManager>();
final isFav = favs.isFavorite(widget.muscle.id);

// AFTER: Only this card rebuilds when its own favorite status changes
final isFav = context.select<FavoritesManager, bool>(
  (favs) => favs.isFavorite(widget.muscle.id),
);
```

**Fix in DashboardPage:** Use `context.read` instead of `context.watch` for filtering logic (since parent already rebuilds via `setState` on search/category changes). Add `Consumer<FavoritesManager>` only where reactive updates are needed (Favorites category count).

---

## Phase 2: Light-Mode Color Fixes (4 items)

### 2.1 Fix procedure mode helpers using dark-only colors
**File:** `lib/screens/guide/muscle_detail.dart`
- `_procSection`, `_procBullet`, `_procStep` use hardcoded dark-mode colors
- Pass `isDark` parameter and use appropriate variants
- **Verification:** Toggle to light mode, open any muscle in procedure mode, confirm text is visible

### 2.2 Add light-mode amber variant for text
**File:** `lib/theme/app_theme.dart`
- Add `amberDark` constant (e.g., `Color(0xFFD4A017)`) for light-mode amber text
- Yellow-on-white fails WCAG AA — need darker variant for light mode
- **Verification:** Light mode — amber text readable on white/light backgrounds

### 2.3 Fix textTertiary contrast in light mode
**File:** `lib/theme/app_theme.dart`
- `textTertiary` (`0xFF5C524A`) against `bgLight` (`0xFFF5F0EB`) is ~3.3:1 — below WCAG AA 4.5:1
- Darken to `0xFF4A3F36` or similar for 4.5:1+ ratio
- **Verification:** Check hint text, timestamps, and section labels in light mode

#### Research Insights — Contrast Testing

**Add unit tests for color contrast compliance:**
```dart
class WcagContrast {
  static double relativeLuminance(Color color) {
    double r = _linearize(color.red / 255.0);
    double g = _linearize(color.green / 255.0);
    double b = _linearize(color.blue / 255.0);
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }
  static double _linearize(double c) =>
      c <= 0.04045 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4).toDouble();
  static double contrastRatio(Color fg, Color bg) {
    final l1 = relativeLuminance(fg), l2 = relativeLuminance(bg);
    return (max(l1, l2) + 0.05) / (min(l1, l2) + 0.05);
  }
  static bool meetsAA(Color fg, Color bg) => contrastRatio(fg, bg) >= 4.5;
}
```

### 2.4 Fix search bar focus state not animating
**File:** `lib/screens/dashboard_page.dart:279-310`
- Add `_searchFocusNode.addListener(() => setState(() {}))` in `initState`
- Change search bar `Container` to `AnimatedContainer` with `duration: Duration(milliseconds: 200)`
- **Verification:** Click into search bar — border color animates smoothly

---

## Phase 3: Design Consistency (5 items)

### 3.1 Standardize border radii to theme tokens
- Replace hardcoded `16` with `AppTheme.radiusLg` or add `radiusXl = 16`

### 3.2 Extract hardcoded colors to theme
- Add `AppTheme.orchid = Color(0xFFD980FA)` for "Recent" category

### 3.3 Centralize typography — define named text styles
**File:** `lib/theme/app_theme.dart`
- Define tokens, then migrate incrementally

#### Research Insights — Typography System

**Best pattern: `ThemeData.textTheme` + `BuildContext` extension for font-family access.**

```dart
// lib/theme/app_typography.dart
TextTheme buildTextTheme(Brightness brightness) {
  final onSurface = brightness == Brightness.dark
      ? const Color(0xFFF5F0EB) : const Color(0xFF1A1512);
  return TextTheme(
    displaySmall:   GoogleFonts.sora(fontSize: 28, fontWeight: FontWeight.w800, color: onSurface),
    titleLarge:     GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w800, color: onSurface),
    bodyLarge:      GoogleFonts.sourceSans3(fontSize: 14, height: 1.6, color: onSurface),
    bodyMedium:     GoogleFonts.sourceSans3(fontSize: 13, height: 1.5, color: onSurface),
    labelLarge:     GoogleFonts.ibmPlexMono(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.8),
  );
}

extension AppTypography on BuildContext {
  TextStyle monoStyle(double size) => GoogleFonts.ibmPlexMono(
    fontSize: size, fontWeight: FontWeight.w600, letterSpacing: 1.8,
    color: Theme.of(this).colorScheme.onSurfaceVariant);
}
```

**Why not static getters:** Static getters cannot auto-select dark/light colors. Every call site ends up doing `.copyWith(color: ...)`.

### 3.4 Migrate info_card.dart from AppColors to AppTheme
- Replace legacy `AppColors.bgCard`, etc. with `Theme.of(context).colorScheme` or `context.appColors`

#### Research Insights — ThemeExtension for Custom Colors

**Use `ThemeExtension<AppColorsExt>` to eliminate all `isDark` ternaries:**

```dart
@immutable
class AppColorsExt extends ThemeExtension<AppColorsExt> {
  final Color surfaceElevated, textTertiary, danger, success, amber;
  // ... constructor, copyWith, lerp ...
  static const dark = AppColorsExt(/* dark values */);
  static const light = AppColorsExt(/* light values */);
}

// Register in ThemeData:
extensions: const [AppColorsExt.dark],

// Use in widgets (auto dark/light):
color: context.appColors.surfaceElevated,  // no isDark needed!
```

**Migration strategy:** Add `@Deprecated` annotations to `AppColors`, enable `deprecated_member_use_from_same_package` in analysis_options.yaml, migrate file-by-file, delete when zero references remain.

### 3.5 Standardize padding patterns
- Define `Spacing` and `Insets` constants
- Fix sidebar header hardcoded top padding (52) to use `MediaQuery.of(context).padding.top`

#### Research Insights — Spacing Scale

```dart
abstract final class Spacing {
  static const double xs = 4, sm = 8, md = 12, lg = 16, xl = 24, xxl = 32;
}
abstract final class Insets {
  static const EdgeInsets allSm = EdgeInsets.all(Spacing.sm);
  static const EdgeInsets allLg = EdgeInsets.all(Spacing.lg);
  static const EdgeInsets card = EdgeInsets.symmetric(horizontal: Spacing.lg, vertical: Spacing.md);
}
```

---

## Phase 4: Micro-Interactions & Motion (7 items)

### 4.1 AnimatedSwitcher for Study/Procedure mode toggle
**File:** `lib/screens/guide/muscle_detail.dart:90`

#### Research Insights

**Use `AnimatedSwitcher`, NOT `AnimatedCrossFade`.** AnimatedCrossFade always renders BOTH children (double build cost). AnimatedSwitcher only keeps the outgoing child during transition, then disposes it.

```dart
AnimatedSwitcher(
  duration: const Duration(milliseconds: 300),
  switchInCurve: Curves.easeOutCubic,
  switchOutCurve: Curves.easeInCubic,
  transitionBuilder: (child, animation) => FadeTransition(
    opacity: animation,
    child: SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 0.02), end: Offset.zero)
          .animate(animation),
      child: child,
    ),
  ),
  child: _procedureMode
      ? _buildProcedureView(key: const ValueKey('procedure'))
      : _buildStudyView(key: const ValueKey('study')),
)
```

### 4.2 Page transition animation for muscle detail
**File:** `lib/router.dart`

```dart
GoRoute(
  path: '/muscle/:id',
  pageBuilder: (context, state) => CustomTransitionPage<void>(
    key: state.pageKey,
    child: MuscleDetailScreen(muscle: muscle),
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 250),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0.05, 0), end: Offset.zero)
              .animate(curved),
          child: child,
        ),
      );
    },
  ),
),
```

**Use `Offset(0.05, 0)` not `Offset(1.0, 0)`.** Full-width slide looks mobile. On desktop, 5% shift + fade feels native (matches macOS Finder transitions).

### 4.3 Staggered reveal on dashboard grid

#### Research Insights

```dart
// Single AnimationController for the stagger timeline
// Each card gets an Interval within it
final double start = count > 1
    ? index / (count - 1) * (1.0 - 0.4)  // 0.4 = card animation window
    : 0.0;
final curvedAnim = CurvedAnimation(
  parent: _controller,
  curve: Interval(start, start + 0.4, curve: Curves.easeOutCubic),
);
```

**Duration:** 600ms total. Cap at ~500ms for 16+ cards. **Curve:** `easeOutCubic` — decelerates smoothly. Reset on category change: `_controller.reset(); _controller.forward();`

### 4.4 Fade transition on US gallery image switch
- Wrap main image in `AnimatedSwitcher` keyed on `_selectedIndex`
- Add `gaplessPlayback: true` on `Image.asset` to prevent white flash between frames
- Pre-cache adjacent images with `precacheImage()` in `didChangeDependencies`

### 4.5 Animate thumbnail selection border
- Change to `AnimatedContainer`, duration 200ms

### 4.6 Add hover state to anatomy diagram panels
- Add `MouseRegion` with hover callback, subtle border glow

### 4.7 Add press feedback on muscle card

#### Research Insights

**Simple pattern using `AnimatedScale`:**
```dart
GestureDetector(
  onTapDown: (_) => setState(() => _isPressed = true),
  onTapUp: (_) { setState(() => _isPressed = false); onTap(); },
  onTapCancel: () => setState(() => _isPressed = false),
  child: AnimatedScale(
    scale: _isPressed ? 0.98 : 1.0,
    duration: const Duration(milliseconds: 100),
    curve: Curves.easeInOut,
    child: /* card content */,
  ),
)
```

**100ms down / 150ms up** — fast enough to feel instant, asymmetry mimics physical button. **0.98 scale** is right for desktop (0.95 is mobile-appropriate).

---

## Phase 5: Accessibility (4 items)

### 5.1 Add Semantics to all GestureDetector widgets

#### Research Insights

**Prefer built-in widgets:** Replace bare `GestureDetector` with `InkWell` where possible — it has built-in semantics, focus, and hover. Only use `Semantics` + `GestureDetector` for truly custom elements.

**When Semantics is needed:**
```dart
Semantics(
  button: true,
  label: 'Toggle favorite',
  toggled: isFav,
  onTap: () => toggleFavorite(),  // Required for VoiceOver activation
  child: GestureDetector(
    onTap: toggleFavorite,
    child: /* star icon */,
  ),
)
```

**Key:** `Semantics.onTap` must be set alongside `GestureDetector.onTap` — VoiceOver uses the semantics handler, not the gesture handler.

### 5.2 Add ExcludeSemantics to decorative elements
- Does NOT affect focus order — only removes from semantic tree
- Never wrap interactive elements in ExcludeSemantics

### 5.3 Fix full-image viewer ignoring title parameter
- Bug: receives `title` param but hardcodes `'${muscle.name} — US View'`

### 5.4 Replace deprecated KeyboardListener

#### Research Insights

**Migration path:**
```dart
// BEFORE (deprecated):
KeyboardListener(
  focusNode: _pageFocusNode,
  autofocus: true,
  onKeyEvent: _handleKey,
  child: /* ... */,
)

// AFTER:
Focus(
  focusNode: _pageFocusNode,
  autofocus: true,
  onKeyEvent: (node, event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    // ... same key handling logic ...
    return KeyEventResult.handled; // or .ignored
  },
  child: /* ... */,
)
```

For app-wide shortcuts (/, Cmd+K), use `Shortcuts` + `Actions` with custom `Intent` classes.

---

## Phase 6: Minor Polish (3 items)

### 6.1 Use GoRouter for full-image viewer
### 6.2 Add missing const constructors
### 6.3 Fix BackdropFilter consistency (moot if removed in Phase 1)

---

## Acceptance Criteria

- [ ] All 26 audit items addressed
- [ ] App builds successfully on macOS (`flutter build macos`)
- [ ] Light mode and dark mode both render correctly
- [ ] No regression in existing functionality (search, navigation, calculator, favorites)
- [ ] `flutter analyze` produces no new warnings
- [ ] All interactive elements have Semantics labels
- [ ] Page transitions animate smoothly
- [ ] Dashboard grid uses lazy layout (no shrinkWrap)

## Success Metrics

- Performance: Detail page scroll smooth with 4+ InfoCards (no BackdropFilter jank)
- Performance: Toggling favorite rebuilds only 1 card, not 50
- Visual: Category switching shows staggered card reveal
- Accessibility: VoiceOver can navigate all interactive elements
- Consistency: No hardcoded colors or radii outside theme tokens

## Dependencies & Risks

- **Low risk:** All changes are UI-only with no data model changes
- **Phase 3.3** (typography tokens) is foundational — do it before Phase 4 animations for cleaner code
- **Phase 3.4** (ThemeExtension) should precede Phase 2 procedure-mode fixes for cleaner migration
- **Phase 4.3** (staggered grid) is the most complex animation — may need iteration
- **Phase 6.1** (GoRouter for image viewer) may require a new route definition

## Recommended Duration Summary

| Animation | Duration | Curve |
|---|---|---|
| Staggered grid reveal | 600ms total | easeOutCubic |
| Page transition (GoRouter) | 300ms in / 250ms out | easeOutCubic / easeInCubic |
| Mode toggle (AnimatedSwitcher) | 300ms | easeOutCubic |
| Image gallery crossfade | 250ms | easeOut |
| Press scale feedback | 100ms down / 150ms up | easeInOut |
| Search bar focus | 200ms | default |
| Thumbnail border | 200ms | default |

## Sources & References

- Frontend audit conducted 2026-04-05 by flutter-expert agent
- Performance research: BackdropFilter GPU analysis, SliverGrid migration patterns
- Animation research: Staggered grid, AnimatedSwitcher vs AnimatedCrossFade, GoRouter CustomTransitionPage
- Accessibility research: Semantics patterns, WCAG contrast utils, KeyboardListener migration, VoiceOver testing
- Design system research: ThemeExtension, typography tokens, spacing scale, migration strategy
- Flutter accessibility docs: https://docs.flutter.dev/ui/accessibility-and-internationalization/accessibility
