import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/storage/local_cache_service.dart';
import '../../../../core/storage/seed_data_service.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../models/vehicle_model.dart';

/// Single Source of Truth = Cloud Firestore, Cache = Hive (`LocalCacheService`).
class ProfileRepositoryImpl implements IProfileRepository {
  final LocalCacheService localCacheService;
  final SeedDataService seedService;
  final bool useMockData;
  final bool isOffline;

  ProfileRepositoryImpl({
    required this.localCacheService,
    required this.seedService,
    required this.useMockData,
    required this.isOffline,
  });

  @override
  Future<Result<UserEntity>> updateProfile(UserEntity updatedUser) async {
    try {
      final model = UserModel.fromEntity(
        updatedUser.copyWith(updatedAt: DateTime.now()),
      );

      // 1. Önce FirebaseFirestore üzerine yaz (Single Source of Truth)
      if (!isOffline) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(model.id)
            .set(model.toFirestore(), SetOptions(merge: true));
        debugPrint('✅ Profil Firestore `users/${model.id}` belgesine yazıldı.');
      }

      // 2. Hemen ardından aynı ID ile Hive yerel kutusuna kaydet
      await localCacheService.saveUserSession(model.toJson());
      await localCacheService.saveUserById(model.id, model.toJson());

      return Result.success(model);
    } catch (e) {
      return Result.failure(ServerFailure('Profil güncellenemedi: $e'));
    }
  }

  @override
  Future<Result<List<VehicleEntity>>> getUserVehicles(String ownerId) async {
    try {
      // İnternet yokken doğrudan Hive'dan oku
      if (isOffline) {
        final cached = localCacheService
            .getCachedVehicles()
            .map(VehicleModel.fromJson)
            .where((v) => v.ownerId == ownerId)
            .toList();
        return Result.success(cached);
      }

      // İnternet varken FirebaseFirestore'dan çek ve Hive önbelleğinin üzerine yaz
      final snapshot = await FirebaseFirestore.instance
          .collection('vehicles')
          .where('ownerId', isEqualTo: ownerId)
          .get();
      final firestoreVehicles = snapshot.docs
          .map((d) => VehicleModel.fromJson({...d.data(), 'id': d.id}))
          .toList();

      // Diğer kullanıcıların önbellekteki araçlarını koruyarak bu kullanıcının araçlarını Hive'da güncelle
      final otherCached = localCacheService
          .getCachedVehicles()
          .map(VehicleModel.fromJson)
          .where((v) => v.ownerId != ownerId)
          .toList();
      final combined = [...otherCached, ...firestoreVehicles];
      await localCacheService.cacheVehicles(
        combined.map((v) => v.toJson()).toList(),
      );

      return Result.success(firestoreVehicles);
    } catch (e) {
      // Bağlantı hatası durumunda Hive'dan oku
      final cached = localCacheService
          .getCachedVehicles()
          .map(VehicleModel.fromJson)
          .where((v) => v.ownerId == ownerId)
          .toList();
      return Result.success(cached);
    }
  }

  @override
  Future<Result<VehicleEntity>> addVehicle(VehicleEntity vehicle) async {
    try {
      // 1. Belge ID'sini tek bir kez belirle
      final docRef = vehicle.id.trim().isNotEmpty
          ? FirebaseFirestore.instance
              .collection('vehicles')
              .doc(vehicle.id.trim())
          : FirebaseFirestore.instance.collection('vehicles').doc();

      final model = VehicleModel(
        id: docRef.id,
        ownerId: vehicle.ownerId,
        brand: vehicle.brand,
        model: vehicle.model,
        year: vehicle.year,
        color: vehicle.color,
        licensePlate: vehicle.licensePlate,
        totalSeats: vehicle.totalSeats,
        isVerified: vehicle.isVerified,
        createdAt: vehicle.createdAt,
      );

      // 2. Önce FirebaseFirestore üzerine yaz
      if (!isOffline) {
        await docRef.set(model.toFirestore());
        debugPrint('✅ Araç Firestore `vehicles/${model.id}` belgesine yazıldı.');
      }

      // 3. Hemen ardından aynı ID ile Hive kutusuna kaydet
      final currentCached = localCacheService
          .getCachedVehicles()
          .map(VehicleModel.fromJson)
          .where((v) => v.id != model.id)
          .toList();
      currentCached.add(model);
      await localCacheService.cacheVehicles(
        currentCached.map((v) => v.toJson()).toList(),
      );

      return Result.success(model);
    } catch (e) {
      return Result.failure(ServerFailure('Araç kaydedilemedi: $e'));
    }
  }

  @override
  Future<Result<void>> deleteVehicle(String vehicleId) async {
    try {
      // 1. Önce FirebaseFirestore üzerinden sil
      if (!isOffline) {
        await FirebaseFirestore.instance
            .collection('vehicles')
            .doc(vehicleId)
            .delete();
      }

      // 2. Hemen ardından Hive kutusundan sil
      final currentCached = localCacheService
          .getCachedVehicles()
          .map(VehicleModel.fromJson)
          .where((v) => v.id != vehicleId)
          .toList();
      await localCacheService.cacheVehicles(
        currentCached.map((v) => v.toJson()).toList(),
      );

      return Result.success(null);
    } catch (e) {
      return Result.failure(ServerFailure('Araç silinemedi: $e'));
    }
  }
}
