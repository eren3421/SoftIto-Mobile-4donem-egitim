import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paylasimli_yolculuk/core/storage/local_cache_service.dart';
import 'package:paylasimli_yolculuk/core/storage/seed_data_service.dart';
import 'package:paylasimli_yolculuk/features/bookings/data/datasources/booking_remote_datasource.dart';
import 'package:paylasimli_yolculuk/features/bookings/data/repositories/booking_repository_impl.dart';
import 'package:paylasimli_yolculuk/features/bookings/domain/entities/booking_entity.dart';
import 'package:paylasimli_yolculuk/features/bookings/domain/usecases/booking_usecases.dart';
import 'package:paylasimli_yolculuk/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:paylasimli_yolculuk/features/rides/data/datasources/ride_remote_datasource.dart';
import 'package:paylasimli_yolculuk/features/rides/data/models/ride_model.dart';
import 'package:paylasimli_yolculuk/features/rides/data/repositories/ride_repository_impl.dart';
import 'package:paylasimli_yolculuk/features/rides/domain/repositories/ride_repository.dart';
import 'package:paylasimli_yolculuk/features/rides/domain/usecases/ride_usecases.dart';

void main() {
  late Directory tempDir;
  late LocalCacheService localCacheService;
  late SeedDataService seedDataService;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('paylasimli_yolculuk_test_');
    localCacheService = LocalCacheService();
    await localCacheService.init(testPath: tempDir.path);
    seedDataService = SeedDataService(localCacheService);
    await seedDataService.ensureSeeded();
  });

  tearDown(() async {
    await localCacheService.clearAll();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('LocalCacheService Birim Testleri (Hive Kutuları)', () {
    test('box_user_session oturum verisini kaydeder ve okur', () async {
      final sampleUser = {
        'id': 'usr_test_1',
        'email': 'test@universite.edu.tr',
        'fullName': 'Test Kullanıcı',
      };
      await localCacheService.saveUserSession(sampleUser);

      final loaded = localCacheService.getUserSession();
      expect(loaded, isNotNull);
      expect(loaded!['id'], equals('usr_test_1'));
      expect(loaded['fullName'], equals('Test Kullanıcı'));
    });

    test('box_search_history son aramaları kaydeder ve maksimum 10 rota tutar',
        () async {
      await localCacheService.clearSearchHistory();
      for (int i = 1; i <= 12; i++) {
        await localCacheService.addSearchHistory(
          origin: 'Kalkış $i',
          destination: 'Varış $i',
        );
      }

      final history = localCacheService.getSearchHistory();
      expect(history.length, equals(10));
      expect(history.first['origin'], equals('Kalkış 12'));
    });

    test('box_my_rides çevrimdışı kullanım için yolculukları önbelleğe alır',
        () async {
      final cachedRides = localCacheService.getCachedRides();
      expect(cachedRides, isNotEmpty);
      expect(cachedRides.first['origin']['name'], isNotEmpty);
    });
  });

  group('SearchRidesUseCase Birim Testleri', () {
    test('Kalkış ve varış noktasına göre doğru yolculukları filtreler',
        () async {
      final remote = RideRemoteDataSource(
        seedService: seedDataService,
        useMockData: true,
      );
      final repo = RideRepositoryImpl(
        remoteDataSource: remote,
        localCacheService: localCacheService,
        isOffline: false,
      );
      final searchUseCase = SearchRidesUseCase(repo);

      final result = await searchUseCase(
        const RideSearchFilter(
          originQuery: 'Kadıköy',
          destinationQuery: 'İTÜ',
          minSeats: 1,
        ),
      );

      expect(result.isSuccess, isTrue);
      expect(result.data, isNotNull);
      expect(result.data!.length, greaterThanOrEqualTo(1));
      expect(result.data!.first.origin.name, contains('Kadıköy'));
    });

    test('Geçersiz koltuk sayısında (minSeats < 1) ValidationFailure döner',
        () async {
      final remote = RideRemoteDataSource(
        seedService: seedDataService,
        useMockData: true,
      );
      final repo = RideRepositoryImpl(
        remoteDataSource: remote,
        localCacheService: localCacheService,
        isOffline: false,
      );
      final searchUseCase = SearchRidesUseCase(repo);

      final result = await searchUseCase(
        const RideSearchFilter(minSeats: 0),
      );

      expect(result.isFailure, isTrue);
    });
  });

  group('BookSeatUseCase ve Atomik Koltuk Rezervasyonu Testleri', () {
    test(
        'Onaylanan rezervasyonda availableSeats düşer ve sıfırlanınca status full olur',
        () async {
      final bookingRemote = BookingRemoteDataSource(
        seedService: seedDataService,
        useMockData: true,
      );
      final bookingRepo = BookingRepositoryImpl(
        remoteDataSource: bookingRemote,
        localCacheService: localCacheService,
        seedService: seedDataService,
        isOffline: false,
      );
      final bookSeatUseCase = BookSeatUseCase(bookingRepo);
      final approveBookingUseCase = ApproveBookingUseCase(bookingRepo);

      // ride_555666 başlangıçta 2 boş koltuğa sahip
      final targetRide =
          seedDataService.rides.firstWhere((r) => r.id == 'ride_555666');
      expect(targetRide.availableSeats, equals(2));

      final newBooking = BookingEntity(
        id: 'bkg_test_atomic_1',
        rideId: targetRide.id,
        driverId: targetRide.driverId,
        passengerId: 'usr_passenger_test_99',
        passengerSummary: const PassengerSummary(
          fullName: 'Caner Test',
          ratingAvg: 4.9,
        ),
        seatsBooked: 2,
        totalPrice: targetRide.pricePerSeat * 2,
        status: 'pending',
        pickupPoint: targetRide.origin,
        noteToDriver: 'Atomik transaction testi',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 1. Rezervasyon talebi oluştur
      final createRes = await bookSeatUseCase(
        booking: newBooking,
        currentAvailableSeats: targetRide.availableSeats,
      );
      expect(createRes.isSuccess, isTrue);
      expect(createRes.data!.status, equals('pending'));

      // 2. Sürücü talebi onaylasın (Atomik Transaction)
      final approveRes = await approveBookingUseCase(
        rideId: targetRide.id,
        bookingId: newBooking.id,
      );
      expect(approveRes.isSuccess, isTrue);
      expect(approveRes.data!.status, equals('approved'));

      // 3. Yolculuğun boş koltuk sayısı 0 olmalı ve durumu 'full' olarak güncellenmeli
      final updatedRide =
          seedDataService.rides.firstWhere((r) => r.id == 'ride_555666');
      expect(updatedRide.availableSeats, equals(0));
      expect(updatedRide.status, equals('full'));

      // 4. Koltuk kalmadığında yeni rezervasyon engellenmeli (SeatQuotaFailure)
      final overbookAttempt = await bookSeatUseCase(
        booking: newBooking.copyWith(
          id: 'bkg_test_overbook',
          passengerId: 'usr_another_passenger',
          seatsBooked: 1,
        ),
        currentAvailableSeats: updatedRide.availableSeats,
      );
      expect(overbookAttempt.isFailure, isTrue);
    });
  });

  group('Mesajlaşma Bildirimi ve Okunmamış Mesaj Sayacı (1, 2...) Testleri', () {
    test(
        'Mesaj gönderildiğinde karşı tarafın okunmamış mesaj sayısı 1, 2 olarak artar ve okunduğunda sıfırlanır',
        () async {
      final chatRepo = ChatRepositoryImpl(
        localCacheService: localCacheService,
        seedService: seedDataService,
        isOffline: false,
      );

      const chatId = 'chat_555666_111222333';
      const senderId = 'usr_987654321'; // Ahmet
      const receiverId = 'usr_111222333'; // Zeynep

      // Önce karşı tarafın mevcut mesajlarını okundu olarak sıfırlayalım
      await chatRepo.markChatAsRead(chatId: chatId, userId: receiverId);

      // 1. Ahmet Zeynep'e 1. mesajı gönderir -> Zeynep'in okunmamış mesaj sayısı 1 olmalı
      await chatRepo.sendMessage(
        chatId: chatId,
        senderId: senderId,
        text: 'Birinci test mesajı',
      );
      var receiverChats = (await chatRepo.getUserChats(receiverId)).data!;
      var targetChat = receiverChats.firstWhere((c) => c.id == chatId);
      expect(targetChat.unreadCountFor(receiverId), equals(1));

      // 2. Ahmet Zeynep'e 2. mesajı gönderir -> Zeynep'in okunmamış mesaj sayısı 2 olmalı
      await chatRepo.sendMessage(
        chatId: chatId,
        senderId: senderId,
        text: 'İkinci test mesajı',
      );
      receiverChats = (await chatRepo.getUserChats(receiverId)).data!;
      targetChat = receiverChats.firstWhere((c) => c.id == chatId);
      expect(targetChat.unreadCountFor(receiverId), equals(2));

      // 3. Zeynep sohbeti açtığında (markChatAsRead) okunmamış mesaj sayısı 0 olmalı ve mesajlar isRead=true olmalı
      await chatRepo.markChatAsRead(chatId: chatId, userId: receiverId);
      receiverChats = (await chatRepo.getUserChats(receiverId)).data!;
      targetChat = receiverChats.firstWhere((c) => c.id == chatId);
      expect(targetChat.unreadCountFor(receiverId), equals(0));

      final msgs = (await chatRepo.getMessages(chatId)).data!;
      expect(msgs.every((m) => m.isRead), isTrue);
    });

    test(
        'Canlı konum paylaşıldığında ve koordinat güncellendiğinde gerçek zamanlı mesaj verisi güncellenir',
        () async {
      final chatRepo = ChatRepositoryImpl(
        localCacheService: localCacheService,
        seedService: seedDataService,
        isOffline: false,
      );

      const chatId = 'chat_555666_111222333';
      const senderId = 'usr_987654321';

      // 1. Canlı konum mesajı başlat
      final sendRes = await chatRepo.sendMessage(
        chatId: chatId,
        senderId: senderId,
        text: 'Canlı Konum: Kadıköy Rıhtım (40.9901, 29.0234)',
        type: 'location',
        lat: 40.9901,
        lng: 29.0234,
        locationName: 'Kadıköy Rıhtım',
        isLiveLocation: true,
      );
      expect(sendRes.isSuccess, isTrue);
      final liveMsg = sendRes.data!;
      expect(liveMsg.isLiveLocation, isTrue);
      expect(liveMsg.lat, equals(40.9901));

      // 2. Gerçek zamanlı konum güncellemesi gönder
      final updateRes = await chatRepo.updateLiveLocationMessage(
        chatId: chatId,
        messageId: liveMsg.id,
        lat: 41.0422,
        lng: 29.0083,
        locationName: 'Beşiktaş Meydan (Hareket Halinde • 42 km/s)',
        isLiveLocation: true,
      );
      expect(updateRes.isSuccess, isTrue);
      expect(updateRes.data!.lat, equals(41.0422));
      expect(updateRes.data!.lng, equals(29.0083));
      expect(updateRes.data!.isLiveLocation, isTrue);

      // 3. Canlı konum paylaşımını durdur
      final stopRes = await chatRepo.updateLiveLocationMessage(
        chatId: chatId,
        messageId: liveMsg.id,
        lat: 41.0422,
        lng: 29.0083,
        locationName: 'Son Konum (Paylaşım Tamamlandı)',
        isLiveLocation: false,
      );
      expect(stopRes.isSuccess, isTrue);
      expect(stopRes.data!.isLiveLocation, isFalse);
    });
  });

  group('Serbest Klavye ve Harita Konum Seçimi Testleri', () {
    test('Klavyeden girilen özel adres ismini korur ve koordinat üretir', () {
      final customLoc =
          TurkeyLocations.findOrCreate('Moda Sahili Çay Bahçesi Önü No:14');
      expect(customLoc.name, equals('Moda Sahili Çay Bahçesi Önü No:14'));
      expect(customLoc.lat, isNotNull);
      expect(customLoc.lng, isNotNull);
    });

    test('Haritadan dokunulan koordinattan (fromCoordinates) konum oluşturur',
        () {
      final mapPicked = TurkeyLocations.fromCoordinates(
        41.0430,
        29.0070,
        customName: 'Beşiktaş İskele Önü Özel Nokta',
      );
      expect(mapPicked.name, equals('Beşiktaş İskele Önü Özel Nokta'));
      expect(mapPicked.lat, equals(41.0430));
      expect(mapPicked.lng, equals(29.0070));
    });

    test(
        'Klavyeden ESENBOĞA ve ANKARA YHT girildiğinde gerçek Ankara koordinatlarını döndürür',
        () {
      final esenboga = TurkeyLocations.findOrCreate('ESENBOĞA');
      final ankaraYht = TurkeyLocations.findOrCreate('ANKARA YHT');

      // Esenboğa Havalimanı gerçek koordinatları: ~40.1281, 32.9951
      expect(esenboga.lat, closeTo(40.1281, 0.05));
      expect(esenboga.lng, closeTo(32.9951, 0.05));

      // Ankara YHT Garı gerçek koordinatları: ~39.9344, 32.8427
      expect(ankaraYht.lat, closeTo(39.9344, 0.05));
      expect(ankaraYht.lng, closeTo(32.8427, 0.05));
    });

    test(
        '04 dokümanındaki Firestore Timestamp -> ISO-8601 dönüşümü ve cacheJsonList çalışır',
        () async {
      final ts = Timestamp.fromDate(DateTime.utc(2026, 11, 15, 8, 30));
      final firestoreDoc = {
        'id': 'demo_ride_1',
        'driverId': 'demo_driver_1',
        'origin': {'name': 'Kadıköy Rıhtım', 'lat': 40.9901, 'lng': 29.0234},
        'destination': {
          'name': 'İTÜ Ayazağa Kampüsü',
          'lat': 41.1055,
          'lng': 29.0252,
        },
        'departureTime': ts,
        'createdAt': ts,
        'totalSeatsOffered': 3,
        'availableSeats': 2,
        'pricePerSeat': 80.0,
      };

      final model = RideModel.fromJson(firestoreDoc);
      expect(model.departureTime.toUtc().year, equals(2026));

      final jsonForHive = model.toJson();
      expect(jsonForHive['departureTime'], isA<String>());

      await localCacheService.cacheJsonList(
        LocalCacheService.myRidesBoxName,
        'test_firestore_rides',
        [jsonForHive],
      );
      final cachedList = localCacheService.getCachedJsonList(
        LocalCacheService.myRidesBoxName,
        'test_firestore_rides',
      );
      expect(cachedList.length, equals(1));
      expect(cachedList.first['id'], equals('demo_ride_1'));
    });
  });
}
