import 'package:smart_laundry_locker/features/orders/domain/entities/order_detail.dart';
import 'package:smart_laundry_locker/features/orders/domain/entities/courier_today_stats.dart';
import 'package:smart_laundry_locker/core/domain/entities/pagination.dart';
import 'package:smart_laundry_locker/core/errors/failures.dart';
import 'package:smart_laundry_locker/features/orders/application/use_cases/get_courier_me_use_case.dart';
import 'package:smart_laundry_locker/features/orders/application/use_cases/get_courier_today_stats_use_case.dart';
import 'package:smart_laundry_locker/features/orders/domain/repositories/order_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

class CourierOrdersProvider extends ChangeNotifier {
  final GetCourierMeUseCase _getCourierMeUseCase;
  final GetCourierTodayStatsUseCase _getStatsUseCase;

  CourierOrdersProvider({
    required GetCourierMeUseCase getCourierMeUseCase,
    required GetCourierTodayStatsUseCase getStatsUseCase,
  }) : _getCourierMeUseCase = getCourierMeUseCase,
       _getStatsUseCase = getStatsUseCase;

  bool _isDisposed = false;
  bool _isLoading = false;
  bool _hasLoaded = false;
  String? _error;
  int _completedToday = 0;
  List<OrderWithDetails> _historyOrders = const [];
  List<OrderWithDetails> _processingOrders = const [];

  bool get isLoading => _isLoading;
  bool get hasLoaded => _hasLoaded;
  String? get error => _error;
  int get completedToday => _completedToday;
  List<OrderWithDetails> get historyOrders => _historyOrders;
  List<OrderWithDetails> get processingOrders => _processingOrders;

  @override
  void notifyListeners() {
    if (!_isDisposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final results = await Future.wait([
      _getStatsUseCase(),
      _getCourierMeUseCase(page: 1, limit: 50),
    ]);

    final statsResult = results[0] as Either<Failure, CourierTodayStats>;
    final historyResult =
        results[1] as Either<Failure, PaginatedResult<OrderWithDetails>>;

    statsResult.fold(
      (failure) => _error = failure.message,
      (stats) => _completedToday = stats.completedToday,
    );

    historyResult.fold(
      (failure) {
        _error ??= failure.message;
      },
      (result) {
        final orders = result.items;
        _historyOrders = orders
            .where((e) => e.order.status.toUpperCase() == 'COMPLETED')
            .toList();
        _processingOrders = orders
            .where((e) => e.order.status.toUpperCase() != 'COMPLETED')
            .toList();
      },
    );

    _isLoading = false;
    _hasLoaded = true;
    notifyListeners();
  }
}
