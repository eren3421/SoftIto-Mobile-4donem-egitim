import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../entities/vehicle_entity.dart';

/// Profil ve Sürücü Araç yönetimi soyut sözleşmesi.
abstract class IProfileRepository {
  Future<Result<UserEntity>> updateProfile(UserEntity updatedUser);
  Future<Result<List<VehicleEntity>>> getUserVehicles(String ownerId);
  Future<Result<VehicleEntity>> addVehicle(VehicleEntity vehicle);
  Future<Result<void>> deleteVehicle(String vehicleId);
}

