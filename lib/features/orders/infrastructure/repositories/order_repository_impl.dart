import 'package:smart_laundry_locker/core/errors/failures.dart';
import 'package:smart_laundry_locker/core/network/api_client.dart';
import 'package:smart_laundry_locker/features/orders/domain/entities/courier_order.dart';
import 'package:smart_laundry_locker/features/orders/domain/entities/courier_today_stats.dart';
import 'package:smart_laundry_locker/features/orders/domain/entities/order.dart';
import 'package:smart_laundry_locker/features/orders/domain/entities/order_detail.dart';
import 'package:smart_laundry_locker/core/domain/entities/pagination.dart';
import 'package:smart_laundry_locker/features/orders/domain/repositories/order_repository.dart';
import 'package:smart_laundry_locker/features/orders/infrastructure/data_sources/order_remote_data_source.dart';
import 'package:smart_laundry_locker/features/locker/domain/repositories/locker_repository.dart';
import 'package:dartz/dartz.dart' hide Order;

/// Implementation của OrderRepository
/// Chuyển đổi từ infrastructure models sang domain entities.
class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource _remoteDataSource;
  final LockerRepository _lockerRepository;

  OrderRepositoryImpl(this._remoteDataSource, this._lockerRepository);

  @override
  Future<Either<Failure, PaginatedResult<Order>>> getMyOrders({
    int page = 1,
    int limit = 10,
    String? status,
    String? orderCode,
    String? userId,
    String? search,
    String? orderBy,
    String? orderDirection,
    String? orderType,
  }) async {
    try {
      final response = await _remoteDataSource.getMyOrders(
        page: page,
        limit: limit,
        status: status,
        orderCode: orderCode,
        userId: userId,
        search: search,
        orderBy: orderBy,
        orderDirection: orderDirection,
        orderType: orderType,
      );

      final orders = response.orders.map((m) => m.toDomain()).toList();
      final pagination = Pagination(
        total: response.pagination.total,
        page: response.pagination.page,
        limit: response.pagination.limit,
      );

      return Right(PaginatedResult(items: orders, pagination: pagination));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrderWithDetails>> getMyOrderDetail(String id) async {
    try {
      final response = await _remoteDataSource.getMyOrderDetail(id);

      final order = response.order.toDomain();
      final details = response.orderDetails.map((m) => m.toDomain()).toList();

      return Right(OrderWithDetails(order: order, orderDetails: details));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Order>>> getMyActiveOrders() async {
    try {
      final models = await _remoteDataSource.getMyActiveOrders();
      final orders = models.map((m) => m.toDomain()).toList();
      return Right(orders);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> payOverdueFee(String orderId) async {
    try {
      final amountPaid = await _remoteDataSource.payOverdueFee(orderId);
      return Right(amountPaid);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CourierOrder>>> getCourierOrderHistory({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _remoteDataSource.getCourierOrderHistory(
        page: page,
        limit: limit,
      );

      final cache = <String, String>{};
      Future<String> resolveCabinetName(String? cabinetId) async {
        if (cabinetId == null || cabinetId.isEmpty) return 'Không xác định';
        if (cache.containsKey(cabinetId)) return cache[cabinetId]!;

        final cabinetEither = await _lockerRepository.getCabinetById(cabinetId);
        final name = cabinetEither.fold(
          (_) => cabinetId.length > 8
              ? '${cabinetId.substring(0, 8)}...'
              : cabinetId,
          (cabinet) => cabinet.locationName?.trim().isNotEmpty == true
              ? cabinet.locationName!
              : (cabinet.name.isNotEmpty ? cabinet.name : cabinetId),
        );
        cache[cabinetId] = name;
        return name;
      }

      final enriched = <CourierOrder>[];
      for (final item in response.items) {
        final originName = await resolveCabinetName(item.originCabinetId);
        final destinationName = await resolveCabinetName(
          item.destinationCabinetId,
        );
        enriched.add(
          CourierOrder(
            orderId: item.orderId,
            dispatchId: item.dispatchId,
            orderCode: item.orderCode,
            status: item.status,
            originName: originName,
            destinationName: destinationName,
            originCabinetId: item.originCabinetId,
            destinationCabinetId: item.destinationCabinetId,
            time: item.updatedAt,
            income: item.accumulatedFee,
          ),
        );
      }

      return Right(enriched);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CourierTodayStats>> getCourierTodayStats() async {
    try {
      final response = await _remoteDataSource.getCourierTodayStats();
      return Right(
        CourierTodayStats(
          completedToday: response.completedToday,
          deliveringToday: response.deliveringToday,
        ),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaginatedResult<OrderWithDetails>>> getCourierMe({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    try {
      final response = await _remoteDataSource.getCourierOrders(
        page: page,
        limit: limit,
        status: status,
      );

      final List<OrderWithDetails> items = [];
      for (final model in response.orders) {
        final order = model.order.toDomain();
        final details = model.orderDetails.map((d) => d.toDomain()).toList();
        items.add(OrderWithDetails(order: order, orderDetails: details));
      }

      return Right(
        PaginatedResult(
          items: items,
          pagination: Pagination(
            total: response.pagination.total,
            page: response.pagination.page,
            limit: response.pagination.limit,
          ),
        ),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> recreateAccessCode(String orderDetailId) async {
    try {
      final success = await _remoteDataSource.recreateAccessCode(orderDetailId);
      return Right(success);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrderWithDetails>> getCourierOrderDetail(
    String id,
  ) async {
    try {
      final response = await _remoteDataSource.getCourierOrderDetail(id);

      return Right(
        OrderWithDetails(
          order: response.order.toDomain(),
          orderDetails: response.orderDetails.map((e) => e.toDomain()).toList(),
        ),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Order>> courierCancelOrder({
    required String orderId,
    required String reason,
  }) async {
    try {
      final model = await _remoteDataSource.courierCancelOrder(
        orderId: orderId,
        reason: reason,
      );
      return Right(model.toDomain());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
