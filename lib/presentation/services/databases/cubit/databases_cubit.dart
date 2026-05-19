import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../feature/databases/application/get_database_health_use_case.dart';
import '../../../../feature/databases/domain/entities/database_health.dart';
import 'databases_state.dart';

class DatabasesCubit extends Cubit<DatabasesState> {
  DatabasesCubit({
    required WatchDatabaseHealthUseCase watchHealth,
    required GetTableStatsUseCase getTableStats,
  })  : _watchHealth = watchHealth,
        _getTableStats = getTableStats,
        super(DatabasesInitial());

  final WatchDatabaseHealthUseCase _watchHealth;
  final GetTableStatsUseCase _getTableStats;

  StreamSubscription<DatabaseHealth>? _sub;

  static const _instanceId = 'supabase-phase1';

  Future<void> load() async {
    emit(DatabasesLoading());
    try {
      final tableStats = await _getTableStats.execute(_instanceId);
      _sub = _watchHealth.execute(_instanceId).listen(
        (health) => emit(DatabasesLoaded(health: health, tableStats: tableStats)),
        onError: (e) => emit(DatabasesError(e.toString())),
      );
    } catch (e) {
      emit(DatabasesError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
