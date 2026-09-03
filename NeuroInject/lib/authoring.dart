/// Whether this build carries the authoring tools.
///
/// The draw-to-highlight screen and the captures review exist to MAKE the
/// corpus — the owner draws lassos there that tools/refine_highlights.py bakes
/// into masks. They are not part of the product, and the public web build
/// should not ship them. Turn them on for a local authoring build with:
///
///     flutter build web --release --dart-define=AUTHORING=true
///
/// Everything a learner uses (the reference scans, peel, identify, planning,
/// the session) is unaffected by this flag.
const bool kAuthoring = bool.fromEnvironment('AUTHORING');
