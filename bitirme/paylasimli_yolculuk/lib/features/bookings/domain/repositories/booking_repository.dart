import '../../../../core/errors/failures.dart';
import '../entities/booking_entity.dart';

/// Rezervasyon ve atomik koltuk yönetimi soyut sözleşmesi (FR-05, NFR-02).
abstract class IBookingRepository {
  Future<Result<BookingEntity>> createBooking({
    required BookingEntity booking,
    bool instantApprove = false,
  });

  Future<Result<BookingEntity>> approveBooking({
    required String rideId,
    required String bookingId,
  });

  Future<Result<BookingEntity>> rejectBooking({
    required String bookingId,
  });

  Future<Result<BookingEntity>> cancelBooking({
    required String bookingId,
    required bool byDriver,
  });

  Future<Result<List<BookingEntity>>> getBookingsForPassenger(
    String passengerId,
  );

  Future<Result<List<BookingEntity>>> getBookingsForRide(String rideId);

  Future<Result<List<BookingEntity>>> getBookingsForDriver(String driverId);
}

