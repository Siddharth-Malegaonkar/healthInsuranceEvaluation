import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/prediction_request.dart';
import '../services/api_service.dart';
import '../widgets/gradient_app_bar.dart';
import '../widgets/custom_button.dart';

/// Prediction screen — collects user inputs and triggers the API call.
///
/// Each field is validated before the request is sent. A loading spinner
/// is shown during the API round-trip. Errors are shown in user-friendly dialogs.
class PredictionScreen extends StatefulWidget {
  const PredictionScreen({super.key});

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bmiController = TextEditingController(text: '25.0');

  int _age = 30;
  String _gender = 'male';
  int _children = 0;
  String _discountEligibility = 'no';
  String _region = 'northeast';
  bool _isLoading = false;

  final _apiService = ApiService();

  static const List<String> _genders = ['male', 'female'];
  static const List<String> _regions = [
    'northeast',
    'northwest',
    'southeast',
    'southwest',
  ];
  static const List<String> _discountOptions = ['no', 'yes'];

  @override
  void dispose() {
    _bmiController.dispose();
    super.dispose();
  }

  // ----------------------------------------------------------------
  // Prediction Logic
  // ----------------------------------------------------------------

  Future<void> _submitPrediction() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final request = PredictionRequest(
        age: _age,
        gender: _gender,
        bmi: double.parse(_bmiController.text),
        children: _children,
        discountEligibility: _discountEligibility,
        region: _region,
      );

      final result = await _apiService.getPrediction(request);

      if (mounted) {
        Navigator.pushNamed(context, '/result', arguments: result);
      }
    } on NetworkException catch (e) {
      _showErrorDialog('Connection Error', e.message);
    } on ServerException catch (e) {
      _showErrorDialog('Server Error', e.message);
    } catch (e) {
      _showErrorDialog(
        'Unexpected Error',
        'Something went wrong. Please try again.\n\nDetails: $e',
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.error_outline_rounded,
                color: Color(0xFFE53935), size: 22),
            const SizedBox(width: 8),
            Text(title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ],
        ),
        content: Text(message,
            style: const TextStyle(fontSize: 14, color: Color(0xFF4B5563))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK',
                style: TextStyle(
                    color: Color(0xFF1565C0), fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------------
  // Build
  // ----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: const GradientAppBar(title: 'Enter Your Details'),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildAgeSection(),
              const SizedBox(height: 16),
              _buildPersonalInfoSection(),
              const SizedBox(height: 16),
              _buildHealthSection(),
              const SizedBox(height: 16),
              _buildDiscountSection(),
              const SizedBox(height: 28),
              CustomButton(
                label: 'Calculate Premium',
                icon: Icons.calculate_rounded,
                isLoading: _isLoading,
                onPressed: _submitPrediction,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------------------
  // Section Builders
  // ----------------------------------------------------------------

  Widget _buildAgeSection() {
    return _SectionCard(
      title: 'Age',
      icon: Icons.cake_outlined,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$_age years',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1565C0),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1565C0).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '18 – 100',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF1565C0),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF1565C0),
              inactiveTrackColor: const Color(0xFF1565C0).withOpacity(0.15),
              thumbColor: const Color(0xFF1565C0),
              overlayColor: const Color(0xFF1565C0).withOpacity(0.12),
              trackHeight: 4,
            ),
            child: Slider(
              value: _age.toDouble(),
              min: 18,
              max: 100,
              divisions: 82,
              onChanged: (v) => setState(() => _age = v.round()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return _SectionCard(
      title: 'Personal Information',
      icon: Icons.person_outline_rounded,
      child: Column(
        children: [
          _buildDropdown(
            label: 'Gender',
            value: _gender,
            items: _genders,
            displayLabels: const {'male': 'Male', 'female': 'Female'},
            onChanged: (v) => setState(() => _gender = v!),
          ),
          const SizedBox(height: 14),
          _buildDropdown(
            label: 'Region',
            value: _region,
            items: _regions,
            displayLabels: const {
              'northeast': 'Northeast',
              'northwest': 'Northwest',
              'southeast': 'Southeast',
              'southwest': 'Southwest',
            },
            onChanged: (v) => setState(() => _region = v!),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthSection() {
    return _SectionCard(
      title: 'Health Details',
      icon: Icons.monitor_heart_outlined,
      child: Column(
        children: [
          // BMI field
          TextFormField(
            controller: _bmiController,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            decoration: _inputDecoration(
              label: 'Body Mass Index (BMI)',
              hint: 'e.g. 24.8',
              suffix: 'kg/m²',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'BMI is required.';
              final bmi = double.tryParse(value);
              if (bmi == null) return 'Enter a valid number.';
              if (bmi < 10 || bmi > 60) return 'BMI must be between 10 and 60.';
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Children counter
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Number of Children',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF374151),
                  ),
                ),
              ),
              _ChildrenCounter(
                value: _children,
                onDecrement: _children > 0
                    ? () => setState(() => _children--)
                    : null,
                onIncrement: _children < 10
                    ? () => setState(() => _children++)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDiscountSection() {
    return _SectionCard(
      title: 'Discount Eligibility',
      icon: Icons.discount_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Are you eligible for a health insurance discount?',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: _discountOptions.map((option) {
              final isSelected = _discountEligibility == option;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                      right: option == 'no' ? 8 : 0,
                      left: option == 'yes' ? 8 : 0),
                  child: GestureDetector(
                    onTap: () =>
                        setState(() => _discountEligibility = option),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF1565C0)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF1565C0)
                              : const Color(0xFFD1D5DB),
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF1565C0)
                                      .withOpacity(0.25),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                )
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          option == 'yes' ? 'Yes' : 'No',
                          style: TextStyle(
                            color:
                                isSelected ? Colors.white : const Color(0xFF374151),
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------------
  // Helper Builders
  // ----------------------------------------------------------------

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Map<String, String> displayLabels,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: _inputDecoration(label: label),
      items: items
          .map(
            (item) => DropdownMenuItem(
              value: item,
              child: Text(displayLabels[item] ?? item),
            ),
          )
          .toList(),
      onChanged: onChanged,
      validator: (v) => v == null ? 'Please select $label.' : null,
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    String? hint,
    String? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      suffixText: suffix,
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: Color(0xFF1565C0), width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE53935)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: Color(0xFFE53935), width: 1.8),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}

// ----------------------------------------------------------------
// Private sub-widgets
// ----------------------------------------------------------------

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: const Color(0xFF1565C0).withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1565C0).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(icon, size: 18, color: const Color(0xFF1565C0)),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1, color: Color(0xFFEEF2FF)),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _ChildrenCounter extends StatelessWidget {
  const _ChildrenCounter({
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
  });

  final int value;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CounterButton(
          icon: Icons.remove_rounded,
          onPressed: onDecrement,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '$value',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
            ),
          ),
        ),
        _CounterButton(
          icon: Icons.add_rounded,
          onPressed: onIncrement,
        ),
      ],
    );
  }
}

class _CounterButton extends StatelessWidget {
  const _CounterButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: onPressed != null
          ? const Color(0xFF1565C0).withOpacity(0.08)
          : Colors.grey.shade100,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            size: 20,
            color: onPressed != null
                ? const Color(0xFF1565C0)
                : Colors.grey.shade400,
          ),
        ),
      ),
    );
  }
}
