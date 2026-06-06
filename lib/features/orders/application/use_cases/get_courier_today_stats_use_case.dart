import 'package:smart_laundry_locker/core/errors/failures.dart';
import 'package:smart_laundry_locker/features/orders/domain/entities/courier_today_stats.dart';
import 'package:smart_laundry_locker/features/orders/domain/repositories/order_repository.dart';
import 'package:dartz/dartz.dart';

class GetCourierTodayStatsUseCase {
  final OrderRepository _repository;

  const GetCourierTodayStatsUseCase(this._repository);

  Future<Either<Failure, CourierTodayStats>> call() {
    return _repository.getCourierTodayStats();
  }
}
