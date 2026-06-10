/// transaction_status.dart
abstract class TransactionStatus {
  static const int confirmed = 0;  // Mali etkili, varsayılan
  static const int skipped   = 2;  // Kullanıcı pas geçti, bakiyeden düşülür
}
