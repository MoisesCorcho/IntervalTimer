/// Normalizes user-facing segment / entity names for display and persistence.
///
/// Trims and uppercases so labels like "preparacion", "descanso" and free-text
/// exercise names render consistently in ALL CAPS on the timer.
String formatDisplayName(String raw) => raw.trim().toUpperCase();
