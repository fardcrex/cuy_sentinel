enum DatabaseProvider {
  supabase,
  postgresql;

  String toJson() => name;
}

enum DatabasePhase {
  phase1,
  phase2;

  String toJson() => name;
}

/// Represents a configured database instance (Supabase or self-hosted PostgreSQL).
class DatabaseInstance {
  const DatabaseInstance({
    required this.id,
    required this.name,
    required this.provider,
    required this.phase,
    required this.enabled,
    required this.host,
    required this.port,
    required this.database,
    this.region,
    this.description,
  });

  final String id;
  final String name;
  final DatabaseProvider provider;
  final DatabasePhase phase;
  final bool enabled;

  final String host;
  final int port;
  final String database;

  /// Cloud region (Supabase). Null for self-hosted.
  final String? region;

  final String? description;

  static const passboltSupabase = DatabaseInstance(
    id: 'supabase-phase1',
    name: 'Supabase',
    provider: DatabaseProvider.supabase,
    phase: DatabasePhase.phase1,
    enabled: true,
    host: 'db.[project].supabase.co',
    port: 5432,
    database: 'postgres',
    region: 'us-east-1',
    description: 'Base de datos cloud — Fase 1',
  );

  static const postgresqlPrimary = DatabaseInstance(
    id: 'postgresql-primary-phase2',
    name: 'PostgreSQL Primario',
    provider: DatabaseProvider.postgresql,
    phase: DatabasePhase.phase2,
    enabled: false,
    host: '192.168.1.10',
    port: 5432,
    database: 'cuy_sentinel',
    description: 'Nodo primario auto-hospedado — Fase 2',
  );

  static const postgresqlReplica = DatabaseInstance(
    id: 'postgresql-replica-phase2',
    name: 'PostgreSQL Réplica',
    provider: DatabaseProvider.postgresql,
    phase: DatabasePhase.phase2,
    enabled: false,
    host: '192.168.1.11',
    port: 5432,
    database: 'cuy_sentinel',
    description: 'Réplica streaming WAL — Fase 2',
  );
}
