import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../entities/vehicle_entity.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileUseCase {
  final IProfileRepository _repository;
  const UpdateProfileUseCase(this._repository);

  Future<Result<UserEntity>> call(UserEntity updatedUser) {
    return _repository.updateProfile(updatedUser);
  }
}

class GetUserVehiclesUseCase {
  final IProfileRepository _repository;
  const GetUserVehiclesUseCase(this._repository);

  Future<Result<List<VehicleEntity>>> call(String ownerId) {
    return _repository.getUserVehicles(ownerId);
  }
}

class AddVehicleUseCase {
  final IProfileRepository _repository;
  const AddVehicleUseCase(this._repository);

  Future<Result<VehicleEntity>> call(VehicleEntity vehicle) {
    return _repository.addVehicle(vehicle);
  }
}

