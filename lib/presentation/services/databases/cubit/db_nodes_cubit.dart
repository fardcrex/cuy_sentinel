import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../feature/monitoring/application/fetch_db_nodes_use_case.dart';
import 'db_nodes_state.dart';

class DbNodesCubit extends Cubit<DbNodesState> {
  DbNodesCubit({required FetchDbNodesUseCase fetch})
      : _fetch = fetch,
        super(DbNodesInitial());

  final FetchDbNodesUseCase _fetch;
  Timer? _timer;
  bool _active = false;

  Future<void> activate() async {
    _active = true;
    // Cancel any orphaned timer from a previous activate that completed
    // after deactivate() had already run.
    _timer?.cancel();
    _timer = null;

    if (state is! DbNodesLoaded) emit(DbNodesLoading());
    await _refresh();

    // Only arm the timer if we're still active (not deactivated mid-fetch).
    if (_active && !isClosed) {
      _timer = Timer.periodic(const Duration(seconds: 15), (_) => _refresh());
    }
  }

  Future<void> deactivate() async {
    _active = false;
    _timer?.cancel();
    _timer = null;
  }

  Future<void> refresh() => _refresh();

  Future<void> _refresh() async {
    if (!_active || isClosed) return;
    try {
      final nodes = await _fetch.execute();
      if (!isClosed) emit(DbNodesLoaded(nodes));
    } catch (e) {
      if (!isClosed) emit(DbNodesError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
