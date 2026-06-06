import 'package:smart_laundry_locker/core/errors/failures.dart';
import 'package:smart_laundry_locker/core/network/api_client.dart';
import 'package:smart_laundry_locker/features/transactions/domain/entities/top_up_result.dart';
import 'package:smart_laundry_locker/features/transactions/domain/repositories/top_up_repository.dart';
import 'package:smart_laundry_locker/features/transactions/infrastructure/data_sources/top_up_remote_data_source.dart';
import 'package:smart_laundry_locker/features/transactions/infrastructure/mappers/top_up_mapper.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

class TopUpRepositoryImpl implements TopUpRepository {
  final TopUpRemoteDataSource remoteDataSource;

  TopUpRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, TopUpResult>> createTopUpUrl({
    required int amount,
  }) async {
    try {
      debugPrint('[TOPUP][repo] createTopUpUrl(amount=$amount)');
      final dto = await remoteDataSource.createTopUpUrl(amount: amount);
      debugPrint(
        '[TOPUP][repo] dto.paymentUrl="${dto.paymentUrl}" txnRef="${dto.txnRef}"',
      );
      if (dto.paymentUrl.isEmpty) {
        return const Left(ServerFailure('Không thể tạo link thanh toán.'));
      }
      return Right(TopUpMapper.toEntity(dto));
    } on ServerException catch (e) {
      debugPrint('[TOPUP][repo] ServerException: ${e.message}');
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      debugPrint('[TOPUP][repo] NetworkException: ${e.message}');
      return Left(NetworkFailure(e.message));
    } on Exception catch (e) {
      debugPrint('[TOPUP][repo] UnknownException: $e');
      return Left(UnknownFailure(e.toString()));
    }
  }
}
