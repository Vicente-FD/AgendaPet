import 'package:agenda_pet/core/config/app_config.dart';
import 'package:agenda_pet/features/account/data/account_repository.dart';
import 'package:agenda_pet/features/auth/data/api_auth_repository.dart';
import 'package:agenda_pet/features/auth/data/auth_repository.dart';
import 'package:agenda_pet/features/auth/data/mock_auth_repository.dart';
import 'package:agenda_pet/features/care/data/care_repository.dart';
import 'package:agenda_pet/features/feeding/data/feeding_repository.dart';
import 'package:agenda_pet/features/pets/data/pets_repository.dart';
import 'package:agenda_pet/features/reminders/data/reminders_repository.dart';

/// Localizador de repositorios. Según [AppConfig.useBackend] devuelve la
/// implementación real (API) o la que guarda en memoria.
///
/// Para usar el backend:
///   flutter run --dart-define=USE_BACKEND=true \
///     --dart-define=API_BASE_URL=http://localhost:4000/api
abstract final class Repositories {
  static final AuthRepository auth =
      AppConfig.useBackend ? ApiAuthRepository() : MockAuthRepository();

  static final PetsRepository pets =
      AppConfig.useBackend ? ApiPetsRepository() : MockPetsRepository();

  static final RemindersRepository reminders = AppConfig.useBackend
      ? ApiRemindersRepository()
      : MockRemindersRepository();

  static final CareRepository care =
      AppConfig.useBackend ? ApiCareRepository() : MockCareRepository();

  static final FeedingRepository feeding =
      AppConfig.useBackend ? ApiFeedingRepository() : MockFeedingRepository();

  static final AccountRepository account =
      AppConfig.useBackend ? ApiAccountRepository() : MockAccountRepository();
}
