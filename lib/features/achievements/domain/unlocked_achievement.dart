/// Persisted unlock record (F13). Immutable once written.
class UnlockedAchievement {
  const UnlockedAchievement({
    required this.achievementId,
    required this.unlockedAt,
  });

  final String achievementId;
  final DateTime unlockedAt;
}
