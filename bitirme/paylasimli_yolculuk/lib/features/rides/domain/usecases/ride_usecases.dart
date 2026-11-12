import '../../../../core/errors/failures.dart';
import '../entities/ride_entity.dart';
import '../repositories/ride_repository.dart';

/// Yolculuk arama iş kuralı (FR-04).
class SearchRidesUseCase {
  final IRideRepository _repository;
  const SearchRidesUseCase(this._repository);

  Future<Result<List<RideEntity>>> call(RideSearchFilter filter) {
    if (filter.minSeats < 1) {
      return Future.value(
        Result.failure(
          const ValidationFailure('En az 1 koltuk seçilmelidir.'),
        ),
      );
    }
    return _repository.searchRides(filter);
  }
}

/// Yeni yolculuk ilanı oluşturma iş kuralı (FR-03).
class CreateRideUseCase {
  final IRideRepository _repository;
  const CreateRideUseCase(this._repository);

  Future<Result<RideEntity>> call(RideEntity ride) {
    if (ride.origin.name.trim().isEmpty ||
        ride.destination.name.trim().isEmpty) {
      return Future.value(
        Result.failure(
          const ValidationFailure('Kalkış ve varış noktaları zorunludur.'),
        ),
      );
    }
    if (ride.totalSeatsOffered < 1 || ride.totalSeatsOffered > 8) {
      return Future.value(
        Result.failure(
          const ValidationFailure('Koltuk sayısı 1 ile 8 arasında olmalıdır.'),
        ),
      );
    }
    if (ride.pricePerSeat < 0) {
      return Future.value(
        Result.failure(
          const ValidationFailure('Koltuk ücreti negatif olamaz.'),
        ),
      );
    }
    return _repository.createRide(ride);
  }
}

class GetRideByIdUseCase {
  final IRideRepository _repository;
  const GetRideByIdUseCase(this._repository);

  Future<Result<RideEntity>> call(String rideId) {
    return _repository.getRideById(rideId);
  }
}

class GetDriverRidesUseCase {
  final IRideRepository _repository;
  const GetDriverRidesUseCase(this._repository);

  Future<Result<List<RideEntity>>> call(String driverId) {
    return _repository.getDriverRides(driverId);
  }
}

