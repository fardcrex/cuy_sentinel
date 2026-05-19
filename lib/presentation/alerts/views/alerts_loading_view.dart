import 'package:flutter/material.dart';

class AlertsLoadingView extends StatelessWidget {
  const AlertsLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}
