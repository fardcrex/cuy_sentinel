import 'package:flutter/material.dart';

class MetricsLoadingView extends StatelessWidget {
  const MetricsLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}
