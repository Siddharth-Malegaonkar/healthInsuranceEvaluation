import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../widgets/custom_button.dart';
import '../widgets/info_card.dart';
import 'about_screen.dart';
import 'prediction_screen.dart';

/// Home screen — project overview and entry point to the prediction flow.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const List<_FeatureItem> _features = [
    _FeatureItem(
      icon: Icons.dataset_outlined,
      title: 'Real Dataset',
      description: 'Trained on 1,338 real insurance records from Kaggle.',
    ),
    _FeatureItem(
      icon: Icons.auto_graph_rounded,
      title: 'Linear Regression',
      description: 'Scikit-learn model with R² evaluation on a 20% test split.',
    ),
    _FeatureItem(
      icon: Icons.api_rounded,
      title: 'FastAPI Backend',
      description: 'RESTful API serving real-time predictions via HTTP.',
    ),
    _FeatureItem(
      icon: Icons.smartphone_rounded,
      title: 'Flutter Frontend',
      description: 'Cross-platform Material 3 mobile application.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: CustomScrollView(
        slivers: [
          // --- Hero Header ---
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: const Color(0xFF1565C0),
            actions: [
              IconButton(
                tooltip: 'About',
                icon: const Icon(
                  Icons.info_outline_rounded,
                  color: Colors.white,
                ),
                onPressed:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AboutScreen()),
                    ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF0D47A1),
                      Color(0xFF1565C0),
                      Color(0xFF1E88E5),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Icon badge
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.health_and_safety_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          AppConfig.appName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppConfig.appTagline,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // --- Body Content ---
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Introduction card
                InfoCard(
                  title: 'About This Project',
                  icon: Icons.lightbulb_outline_rounded,
                  child: Text(
                    'This end-to-end ML application predicts annual health '
                    'insurance premiums based on patient demographics. Enter your '
                    'details on the next screen to receive an instant estimate '
                    'powered by a trained Linear Regression model.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.6,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Features grid
                InfoCard(
                  title: 'Key Features',
                  icon: Icons.star_outline_rounded,
                  child: Column(
                    children:
                        _features.map((f) => _FeatureTile(item: f)).toList(),
                  ),
                ),

                const SizedBox(height: 28),

                // CTA button
                CustomButton(
                  label: 'Start Prediction',
                  icon: Icons.arrow_forward_rounded,
                  onPressed:
                      () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => PredictionScreen()),
                      ),
                ),

                const SizedBox(height: 12),

                // About link
                Center(
                  child: TextButton.icon(
                    onPressed:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AboutScreen(),
                          ),
                        ),
                    icon: const Icon(Icons.info_outline_rounded, size: 16),
                    label: const Text('About this project'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF1565C0),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Private helpers ---

class _FeatureItem {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({required this.item});

  final _FeatureItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1565C0).withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.icon, size: 18, color: const Color(0xFF1565C0)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    height: 1.4,
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
