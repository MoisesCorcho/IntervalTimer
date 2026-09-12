/// Represents the execution outcome of a purchase or restore transaction.
enum PurchaseStatus {
  success,
  cancelled,
  pending,
  error,
}

/// Inmutable result returned by billing operations.
class PurchaseResult {
  const PurchaseResult({
    required this.status,
    this.errorMessage,
  });

  const PurchaseResult.success()
      : status = PurchaseStatus.success,
        errorMessage = null;

  const PurchaseResult.cancelled()
      : status = PurchaseStatus.cancelled,
        errorMessage = null;

  const PurchaseResult.error([String? message])
      : status = PurchaseStatus.error,
        errorMessage = message;

  final PurchaseStatus status;
  final String? errorMessage;
}
