enum AdRewardStatus {
  rewardEarned,
  userDismissedEarly,
  adNotAvailable,
  rateLimitExceeded,
  error,
}

/// Resultado inmutable devuelto tras la solicitud de un anuncio publicitario.
class AdRewardResult {
  final AdRewardStatus status;
  final String? errorMessage;

  const AdRewardResult.success()
      : status = AdRewardStatus.rewardEarned,
        errorMessage = null;

  const AdRewardResult.failure(this.status, [this.errorMessage]);

  bool get isSuccess => status == AdRewardStatus.rewardEarned;
}
