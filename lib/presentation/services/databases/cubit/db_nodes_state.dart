import '../../../../feature/monitoring/domain/entities/db_node.dart';

sealed class DbNodesState {}

final class DbNodesInitial extends DbNodesState {}

final class DbNodesLoading extends DbNodesState {}

final class DbNodesLoaded extends DbNodesState {
  DbNodesLoaded(this.nodes);
  final List<DbNode> nodes;
}

final class DbNodesError extends DbNodesState {
  DbNodesError(this.message);
  final String message;
}
