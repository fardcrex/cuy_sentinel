import '../app_dependencies.dart';
import '../../../feature/auth/infrastructure/in_memory_auth_repository.dart';

AppDependencies buildDevelopmentDependencies() => AppDependencies(
      authRepository: InMemoryAuthRepository(),
    );
