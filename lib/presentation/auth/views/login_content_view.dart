import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/assets/app_assets.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/responsive/app_breakpoints.dart';
import '../widgets/login_form_card.dart';
import '../widgets/login_illustration_panel.dart';
import '../widgets/login_matrix_background.dart';
import 'package:go_router/go_router.dart';

class LoginContentView extends StatelessWidget {
  const LoginContentView({
    super.key,
    required this.bgProgress,
    required this.matrixTone,
    required this.matrixAccent,
    required this.bgStart,
    required this.bgEnd,
    required this.formKey,
    required this.userController,
    required this.passwordController,
    required this.obscurePassword,
    required this.isSubmitting,
    required this.hasError,
    required this.onTogglePassword,
    required this.onSubmit,
  });

  final ValueListenable<double> bgProgress;
  final Color matrixTone;
  final Color matrixAccent;
  final Color bgStart;
  final Color bgEnd;
  final GlobalKey<FormState> formKey;
  final TextEditingController userController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final bool isSubmitting;
  final bool hasError;
  final VoidCallback onTogglePassword;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [bgStart, bgEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: ValueListenableBuilder<double>(
                  valueListenable: bgProgress,
                  builder: (_, progress, _) => CustomPaint(
                    painter: LoginMatrixBackgroundPainter(
                      progress: progress,
                      density: 0.8,
                      toneColor: matrixTone,
                      accentToneColor: matrixAccent,
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 20,
                ),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => context.go(AppRoutes.welcome),
                    child: Image.asset(
                      AppAssets.logoHorizontalPrimary,
                      height: 34,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop =
                      AppBreakpoints.isDesktop(constraints.maxWidth);
                  final form = LoginFormCard(
                    formKey: formKey,
                    userController: userController,
                    passwordController: passwordController,
                    obscurePassword: obscurePassword,
                    isSubmitting: isSubmitting,
                    onTogglePassword: onTogglePassword,
                    onSubmit: onSubmit,
                  );

                  if (isDesktop) {
                    return Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1100),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppBreakpoints.horizontalPadding(
                              constraints.maxWidth,
                            ),
                            vertical: 80,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 5,
                                child: LoginIllustrationPanel(
                                  hasError: hasError,
                                ),
                              ),
                              const SizedBox(width: 56),
                              Expanded(flex: 4, child: form),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  final keyboardInset =
                      MediaQuery.viewInsetsOf(context).bottom;
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppBreakpoints.horizontalPadding(
                        constraints.maxWidth,
                      ),
                    ),
                    child: SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: 80,
                            bottom: 80 + keyboardInset,
                          ),
                          child: Center(child: form),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
