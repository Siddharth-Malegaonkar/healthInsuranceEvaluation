import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../widgets/gradient_app_bar.dart';
import '../widgets/info_card.dart';

/// About screen — project overview, dataset, tech stack, and architecture.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: const GradientAppBar(title: 'About'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          // Project Overview
          InfoCard(
            title: 'Project Overview',
            icon: Icons.folder_special_outlined,
            child: Text(
              'InsurePredict is an end-to-end Machine Learning application that '
              'demonstrates the full ML deployment lifecycle — from data '
              'preprocessing and model training to REST API serving and mobile '
              'UI integration.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
                height: 1.65,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Dataset
          InfoCard(
            title: 'Dataset',
            icon: Icons.dataset_outlined,
            child: Column(
              children: [
                InfoRow(
                  label: 'Source',
                  value: 'Kaggle — Medical Insurance Dataset',
                ),
                const SizedBox(height: 6),
                InfoRow(
                  label: 'Records',
                  value: '${AppConfig.datasetSize} rows',
                ),
                const SizedBox(height: 6),
                const InfoRow(
                  label: 'Features',
                  value: 'Age, Gender, BMI, Children,\nDiscount, Region',
                ),
                const SizedBox(height: 6),
                const InfoRow(label: 'Target', value: 'Annual Medical Expenses'),
                const SizedBox(height: 6),
                const InfoRow(label: 'Split', value: '80% Train / 20% Test'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ML Model
          InfoCard(
            title: 'Machine Learning Model',
            icon: Icons.model_training_rounded,
            child: Column(
              children: [
                InfoRow(
                  label: 'Algorithm',
                  value: AppConfig.modelName,
                  valueColor: const Color(0xFF1565C0),
                ),
                const SizedBox(height: 6),
                const InfoRow(label: 'Library', value: 'Scikit-learn'),
                const SizedBox(height: 6),
                const InfoRow(label: 'Serialization', value: 'Joblib (.pkl)'),
                const SizedBox(height: 6),
                const InfoRow(
                  label: 'Metrics',
                  value: 'R² Score, MAE, RMSE',
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Tech Stack
          InfoCard(
            title: 'Technology Stack',
            icon: Icons.layers_outlined,
            child: Column(
              children: [
                _TechRow(
                  layer: 'Mobile App',
                  tech: 'Flutter 3 · Material 3 · Dart',
                  color: const Color(0xFF0288D1),
                ),
                _TechRow(
                  layer: 'Backend API',
                  tech: 'FastAPI · Uvicorn · Pydantic',
                  color: const Color(0xFF009688),
                ),
                _TechRow(
                  layer: 'ML Pipeline',
                  tech: 'Scikit-learn · Pandas · NumPy',
                  color: const Color(0xFF7B1FA2),
                ),
                _TechRow(
                  layer: 'Language',
                  tech: 'Python 3.11+ · Dart 3',
                  color: const Color(0xFF1565C0),
                  isLast: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Architecture
          InfoCard(
            title: 'Application Architecture',
            icon: Icons.account_tree_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ArchitectureStep(
                  step: '1',
                  label: 'User Input',
                  description: 'Flutter form captures patient details',
                ),
                _ArchitectureArrow(),
                _ArchitectureStep(
                  step: '2',
                  label: 'HTTP Request',
                  description: 'POST /predict to FastAPI backend',
                ),
                _ArchitectureArrow(),
                _ArchitectureStep(
                  step: '3',
                  label: 'Preprocessing',
                  description: 'Categorical encoding & feature alignment',
                ),
                _ArchitectureArrow(),
                _ArchitectureStep(
                  step: '4',
                  label: 'ML Prediction',
                  description: 'Linear Regression model inference',
                ),
                _ArchitectureArrow(),
                _ArchitectureStep(
                  step: '5',
                  label: 'JSON Response',
                  description: 'Predicted premium returned to Flutter',
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Developer Notes
          InfoCard(
            title: 'Developer Notes',
            icon: Icons.notes_rounded,
            child: Text(
              'This project was built as a portfolio demonstration of end-to-end '
              'ML deployment. The codebase follows clean architecture principles — '
              'preprocessing, training, and prediction are fully separated. '
              'The Flutter app communicates with the backend via a typed API '
              'service layer with proper error handling.\n\n'
              'Built with Python ${_pythonVersion} and Flutter ${_flutterVersion}.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
                height: 1.65,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Version badge
          Center(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1565C0).withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '${AppConfig.appName}  v1.0.0',
                style: TextStyle(
                  color: Color(0xFF1565C0),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const String _pythonVersion = '3.11+';
  static const String _flutterVersion = '3.29';
}

// ─── Private sub-widgets ─────────────────────────────────────────────────────

class _TechRow extends StatelessWidget {
  const _TechRow({
    required this.layer,
    required this.tech,
    required this.color,
    this.isLast = false,
  });

  final String layer;
  final String tech;
  final Color color;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 36,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  layer,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  tech,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF1A1A2E),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ArchitectureStep extends StatelessWidget {
  const _ArchitectureStep({
    required this.step,
    required this.label,
    required this.description,
  });

  final String step;
  final String label;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFF1565C0),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            step,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ArchitectureArrow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: 13, top: 2, bottom: 2),
      child: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: Color(0xFF1565C0),
        size: 20,
      ),
    );
  }
}
