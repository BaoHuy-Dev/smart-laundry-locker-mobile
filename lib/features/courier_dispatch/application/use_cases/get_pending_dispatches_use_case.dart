import 'package:smart_laundry_locker/features/courier_dispatch/domain/entities/pending_dispatch.dart';
import 'package:smart_laundry_locker/features/courier_dispatch/domain/repositories/courier_dispatch_repository.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';

class GetPendingDispatchesUseCase {
  final CourierDispatchRepository _repository;

  GetPendingDispatchesUseCase(this._repository);

  Future<Either<Failure, List<PendingDispatch>>> call() async {
    try {
      final dispatches = await _repository.getPendingDispatches();
      return Right(dispatches);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
