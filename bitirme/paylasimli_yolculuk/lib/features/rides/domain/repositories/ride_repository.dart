import '../../../../core/errors/failures.dart';
import '../entities/ride_entity.dart';

/// Yolculuk arama filtre parametreleri.
class RideSearchFilter {
  final String originQuery;
  final String destinationQuery;
  final DateTime? date;
  final int minSeats;
  final double? maxPrice;
  final String statusFilter; // 'all', 'available', 'full', 'completed'

  const RideSearchFilter({
    this.originQuery = '',
    this.destinationQuery = '',
    this.date,
    this.minSeats = 1,
    this.maxPrice,
    this.statusFilter = 'all',
  });

  RideSearchFilter copyWith({
    String? originQuery,
    String? destinationQuery,
    DateTime? date,
    bool clearDate = false,
    int? minSeats,
    double? maxPrice,
    bool clearMaxPrice = false,
    String? statusFilter,
  }) {
    return RideSearchFilter(
      originQuery: originQuery ?? this.originQuery,
      destinationQuery: destinationQuery ?? this.destinationQuery,
      date: clearDate ? null : (date ?? this.date),
      minSeats: minSeats ?? this.minSeats,
      maxPrice: clearMaxPrice ? null : (maxPrice ?? this.maxPrice),
      statusFilter: statusFilter ?? this.statusFilter,
    );
  }
}

/// Yolculuk (Ride) işlemleri için soyut Repository sözleşmesi.
abstract class IRideRepository {
  Future<Result<List<RideEntity>>> searchRides(RideSearchFilter filter);
  Future<Result<RideEntity>> getRideById(String rideId);
  Future<Result<RideEntity>> createRide(RideEntity ride);
  Future<Result<RideEntity>> updateRideStatus({
    required String rideId,
    required String status,
  });
  Future<Result<List<RideEntity>>> getDriverRides(String driverId);
  List<Map<String, dynamic>> getSearchHistory();
  Future<void> clearSearchHistory();
}

