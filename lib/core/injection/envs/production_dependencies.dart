import '../app_dependencies.dart';
import '../../../feature/auth/infrastructure/supabase_auth_repository.dart';

AppDependencies buildProductionDependencies() => AppDependencies(
      authRepository: SupabaseAuthRepository(),
    );
