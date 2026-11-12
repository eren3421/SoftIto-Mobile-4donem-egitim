import '../../../../core/errors/failures.dart';
import '../entities/booking_entity.dart';
import '../repositories/booking_repository.dart';

/// Yolcunun boş koltuklar için rezervasyon talebi oluşturması (`BookSeatUseCase`).
class BookSeatUseCase {
  final IBookingRepository _repository;
  const BookSeatUseCase(this._repository);

  Future<Result<BookingEntity>> call({
    required BookingEntity booking,
    required int currentAvailableSeats,
    bool instantApprove = false,
  }) async {
    if (booking.seatsBooked <= 0) {
      return Result.failure(
        const ValidationFailure('En az 1 koltuk talep edilmelidir.'),
      );
    }
    if (booking.driverId == booking.passengerId) {
      return Result.failure(
        const ValidationFailure(
          'Sürücü kendi açtığı yolculuğa yolcu olarak rezervasyon yapamaz.',
        ),
      );
    }
    if (currentAvailableSeats < booking.seatsBooked) {
      return Result.failure(
        const SeatQuotaFailure('Yeterli boş koltuk kalmadı.'),
      );
    }
    return _repository.createBooking(
      booking: booking,
      instantApprove: instantApprove,
    );
  }
}

/// Sürücünün rezervasyon talebini atomik transaction ile onaylaması (`ApproveBookingUseCase`).
class ApproveBookingUseCase {
  final IBookingRepository _repository;
  const ApproveBookingUseCase(this._repository);

  Future<Result<BookingEntity>> call({
    required String rideId,
    required String bookingId,
  }) {
    return _repository.approveBooking(rideId: rideId, bookingId: bookingId);
  }
}

class RejectBookingUseCase {
  final IBookingRepository _repository;
  const RejectBookingUseCase(this._repository);

  Future<Result<BookingEntity>> call(String bookingId) {
    return _repository.rejectBooking(bookingId: bookingId);
  }
}

class CancelBookingUseCase {
  final IBookingRepository _repository;
  const CancelBookingUseCase(this._repository);

  Future<Result<BookingEntity>> call({
    required String bookingId,
    required bool byDriver,
  }) {
    return _repository.cancelBooking(bookingId: bookingId, byDriver: byDriver);
  }
}

