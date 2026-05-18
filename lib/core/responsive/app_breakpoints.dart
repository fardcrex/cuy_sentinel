class AppBreakpoints {
  const AppBreakpoints._();

  static const mobile = 768.0;
  static const tablet = 1200.0;
  static const contentMaxWidth = 1440.0;

  static bool isMobile(double width) => width < mobile;
  static bool isTablet(double width) => width >= mobile && width < tablet;
  static bool isDesktop(double width) => width >= tablet;

  static double horizontalPadding(double width) {
    if (isDesktop(width)) return 32;
    if (isTablet(width)) return 24;
    return 16;
  }

  static int metricsColumns(double width) {
    if (width >= 1400) return 4;
    if (width >= 900) return 2;
    return 1;
  }
}
