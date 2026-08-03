/// Data model representing a prediction request to the FastAPI backend.
class PredictionRequest {
  final int age;
  final String gender;
  final double bmi;
  final int children;
  final String discountEligibility;
  final String region;

  const PredictionRequest({
    required this.age,
    required this.gender,
    required this.bmi,
    required this.children,
    required this.discountEligibility,
    required this.region,
  });

  /// Converts this request to the JSON format expected by the backend.
  Map<String, dynamic> toJson() => {
        'age': age,
        'gender': gender,
        'bmi': bmi,
        'children': children,
        'discount_eligibility': discountEligibility,
        'region': region,
      };

  @override
  String toString() =>
      'PredictionRequest(age: $age, gender: $gender, bmi: $bmi, '
      'children: $children, discount: $discountEligibility, region: $region)';
}
