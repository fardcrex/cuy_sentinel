import 'package:flutter_bloc/flutter_bloc.dart';

enum NavGlassStyle { dark, teal }

class NavStyleCubit extends Cubit<NavGlassStyle> {
  NavStyleCubit() : super(NavGlassStyle.dark);

  void toggle() => emit(
    state == NavGlassStyle.dark ? NavGlassStyle.teal : NavGlassStyle.dark,
  );
}
