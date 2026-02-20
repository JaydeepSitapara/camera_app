import 'package:camera_app/core/services/shared_pref_services.dart';
import 'package:camera_app/features/capture/models/session_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final lastSessionProvider =
AsyncNotifierProvider<LastSessionNotifier, SessionModel?>(
  LastSessionNotifier.new,
);

class LastSessionNotifier extends AsyncNotifier<SessionModel?> {
  @override
  Future<SessionModel?> build() async {
    return SharedPrefServices.getLastSession();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await SharedPrefServices.getLastSession());
  }

  Future<void> clear() async {
    await SharedPrefServices.clearLastSession();
    state = const AsyncData(null);
  }
}