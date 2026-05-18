import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/models/locker.dart';
import '../../../../core/services/locker_service.dart';

part 'lockers_provider.g.dart';

@riverpod
class LockersNotifier extends _$LockersNotifier {
  @override
  FutureOr<List<Locker>> build() async {
    return _fetchLockers();
  }

  Future<List<Locker>> _fetchLockers({String? search, int? storeId}) async {
    try {
      final response = await LockerService.getLockers(
        search: search,
        storeId: storeId,
        size: 50, // Arbitrary large number to load all for now
      );
      return response.data.content;
    } catch (e) {
      // Return empty list or throw error depending on UI needs
      rethrow;
    }
  }

  Future<void> searchLockers(String query) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchLockers(search: query));
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchLockers());
  }
}

@riverpod
Future<List<Box>> lockerBoxes(LockerBoxesRef ref, int lockerId) async {
  final response = await LockerService.getLockerBoxes(lockerId);
  return response.data;
}
