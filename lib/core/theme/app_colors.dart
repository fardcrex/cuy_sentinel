import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const primaryCyberTeal = Color(0xFF5CE673);
  static const neonShieldGreen = Color(0xFF22F5C7);
  static const deepMonitoringCyan = Color(0xFF00D9B8);

  static const warningAmber = Color(0xFFFFC83D);
  static const criticalOrange = Color(0xFFFF7A1A);
  static const dangerRed = Color(0xFFFF3B3B);

  static const voidBlack = Color(0xFF020507);
  static const darkPanel = Color(0xFF08111A);
  static const serverRackGray = Color(0xFF101C26);
  static const borderTech = Color(0xFF1A2B38);

  static const primaryWhiteMint = Color(0xFFE9FFF8);
  static const secondaryMutedCyan = Color(0xFF9CCFC4);
  static const inactiveGray = Color(0xFF4D6672);

  static const successGlow = Color(0x597DFF8A);
  static const tealGlow = Color(0x4D22F5C7);
  static const warningGlow = Color(0x4DFF7A1A);
  static const criticalGlow = Color(0x59FF3B3B);

  static const chartCpu = primaryCyberTeal;
  static const chartRam = neonShieldGreen;
  static const chartDisk = warningAmber;
  static const chartNetwork = deepMonitoringCyan;
  static const chartErrorRate = dangerRed;

  static const background = voidBlack;
  static const panel = darkPanel;
  static const surface = serverRackGray;
  static const surfaceSoft = darkPanel;
  static const stroke = borderTech;
  static const primary = primaryCyberTeal;
  static const primaryBright = neonShieldGreen;
  static const secondary = deepMonitoringCyan;
  static const warning = warningAmber;
  static const critical = criticalOrange;
  static const danger = dangerRed;
  static const textPrimary = primaryWhiteMint;
  static const textSecondary = secondaryMutedCyan;
  static const textInactive = inactiveGray;
  static const shadow = Color(0x66000000);

  static const mainBrandGradient = LinearGradient(
    colors: [deepMonitoringCyan, primaryCyberTeal],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const successGradient = LinearGradient(
    colors: [primaryCyberTeal, neonShieldGreen],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const warningGradient = LinearGradient(
    colors: [warningAmber, criticalOrange],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const criticalGradient = LinearGradient(
    colors: [criticalOrange, dangerRed],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
