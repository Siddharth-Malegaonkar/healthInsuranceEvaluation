/// Data model representing a successful prediction response from the API.
class PredictionResult {
  /// Predicted annual health insurance premium (USD).
  final double predictedPremium;

  /// Timestamp recorded at the moment the prediction was received.
  final DateTime timestamp;

  const PredictionResult({
    required this.predictedPremium,
    required this.timestamp,
  });

  /// Constructs a [PredictionResult] from the JSON response body.
  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    return PredictionResult(
      predictedPremium: (json['predicted_premium'] as num).toDouble(),
      timestamp: DateTime.now(),
    );
  }

  /// Formats the premium as a rupee string (e.g. ₹12,345.67).
  String get formattedPremium {
    final formatted = predictedPremium.toStringAsFixed(2);
    // Insert commas for readability
    final parts = formatted.split('.');
    final intPart = parts[0];
    final decPart = parts[1];
    final buffer = StringBuffer();
    for (int i = 0; i < intPart.length; i++) {
      if (i != 0 && (intPart.length - i) % 3 == 0) buffer.write(',');
      buffer.write(intPart[i]);
    }
    return '₹${buffer.toString()}.$decPart';
  }

  @override
  String toString() =>
      'PredictionResult(predictedPremium: $predictedPremium, timestamp: $timestamp)';
}
