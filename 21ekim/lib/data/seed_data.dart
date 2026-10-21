import '../models/plant_species.dart';
import '../models/pest_diagnosis.dart';
import '../models/greenhouse.dart';
import '../models/plant.dart';
import '../models/note_and_harvest.dart';

class SeedData {
  static final List<PlantSpecies> plantSpeciesList = [
    PlantSpecies(
      speciesId: 'tomato',
      name: const LocalizedText(tr: 'Domates', en: 'Tomato'),
      scientificName: 'Solanum lycopersicum',
      category: const LocalizedText(tr: 'Sebze / Meyve', en: 'Vegetable / Fruit'),
      wateringIntervalDays: 3,
      wateringAmountMl: 450,
      wateringTip: const LocalizedText(
        tr: 'Toprak yüzeyi kurudukça kök bölgesine su verin; yaprakları ıslatmaktan kaçının.',
        en: 'Water at root zone when topsoil dries; avoid wetting leaves.',
      ),
      fertilizingIntervalDays: 14,
      fertilizingTip: const LocalizedText(
        tr: 'Çiçeklenme öncesi azot, meyve tutumunda potasyum ve kalsiyum ağırlıklı organik gübre verin.',
        en: 'Apply nitrogen before flowering, potassium and calcium during fruit set.',
      ),
      pruningIntervalDays: 21,
      pruningTip: const LocalizedText(
        tr: 'Ana gövde ile yan dal arasındaki koltuk sürgünlerini düzenli temizleyin.',
        en: 'Regularly pinch off suckers between main stem and side branches.',
      ),
      sunlightHours: '6 - 8 Saat / Gün',
      sunlightType: const LocalizedText(tr: 'Doğrudan Güneş Işığı', en: 'Direct Sunlight'),
      idealTempRange: '20°C - 27°C',
      idealHumidity: '%60 - %70',
      expectedHarvestDays: 70,
      icon: '🍅',
    ),
    PlantSpecies(
      speciesId: 'pepper',
      name: const LocalizedText(tr: 'Sivri Biber', en: 'Green Pepper'),
      scientificName: 'Capsicum annuum',
      category: const LocalizedText(tr: 'Sebze', en: 'Vegetable'),
      wateringIntervalDays: 3,
      wateringAmountMl: 350,
      wateringTip: const LocalizedText(
        tr: 'Toprak hafif nemli kalmalı, aşırı sulama kök boğazını çürütür.',
        en: 'Keep soil slightly moist; overwatering can cause stem rot.',
      ),
      fertilizingIntervalDays: 15,
      fertilizingTip: const LocalizedText(
        tr: 'Fosfor ve potasyum desteği verimi artırır. 2 haftada bir sıvı organik gübre uygulayın.',
        en: 'Phosphorus and potassium boost yield. Apply liquid fertilizer every 2 weeks.',
      ),
      pruningIntervalDays: 25,
      pruningTip: const LocalizedText(
        tr: 'İlk çatalın altındaki yaprakları ve zayıf alt sürgünleri temizleyin.',
        en: 'Prune leaves and weak suckers below the first fork.',
      ),
      sunlightHours: '6 - 8 Saat / Gün',
      sunlightType: const LocalizedText(tr: 'Doğrudan Güneş Işığı', en: 'Direct Sunlight'),
      idealTempRange: '22°C - 28°C',
      idealHumidity: '%55 - %65',
      expectedHarvestDays: 75,
      icon: '🫑',
    ),
    PlantSpecies(
      speciesId: 'strawberry',
      name: const LocalizedText(tr: 'Çilek', en: 'Strawberry'),
      scientificName: 'Fragaria × ananassa',
      category: const LocalizedText(tr: 'Meyve', en: 'Fruit'),
      wateringIntervalDays: 2,
      wateringAmountMl: 250,
      wateringTip: const LocalizedText(
        tr: 'Sık fakat az su verin. Meyvelerin ıslanıp çürümemesi için damlama sulama idealdir.',
        en: 'Water frequently with small amounts. Drip irrigation prevents fruit rot.',
      ),
      fertilizingIntervalDays: 14,
      fertilizingTip: const LocalizedText(
        tr: 'Çiçeklenme başladığında potasyum takviyesi yapın, aşırı azottan kaçının.',
        en: 'Boost potassium during flowering; avoid excessive nitrogen.',
      ),
      pruningIntervalDays: 15,
      pruningTip: const LocalizedText(
        tr: 'Gereksiz kol ve sararan dip yaprakları temizleyerek ana kökü güçlendirin.',
        en: 'Trim excess runners and yellowing bottom leaves.',
      ),
      sunlightHours: '5 - 7 Saat / Gün',
      sunlightType: const LocalizedText(tr: 'Doğrudan / Yarı Gölge', en: 'Direct / Partial Shade'),
      idealTempRange: '18°C - 24°C',
      idealHumidity: '%60 - %75',
      expectedHarvestDays: 60,
      icon: '🍓',
    ),
    PlantSpecies(
      speciesId: 'cucumber',
      name: const LocalizedText(tr: 'Salatalık', en: 'Cucumber'),
      scientificName: 'Cucumis sativus',
      category: const LocalizedText(tr: 'Sebze', en: 'Vegetable'),
      wateringIntervalDays: 2,
      wateringAmountMl: 500,
      wateringTip: const LocalizedText(
        tr: 'Yüksek nem ve düzenli su ister. Susuz kalırsa meyveler acılaşır.',
        en: 'Needs consistent moisture. Underwatering causes bitter fruit.',
      ),
      fertilizingIntervalDays: 12,
      fertilizingTip: const LocalizedText(
        tr: 'Hızlı büyüdüğü için 12 günde bir dengeli kompost çayı veya organik gübre verin.',
        en: 'Grows fast; apply balanced compost tea every 12 days.',
      ),
      pruningIntervalDays: 14,
      pruningTip: const LocalizedText(
        tr: 'Sırığa sarılan ana gövdeyi destekleyin, sararmış alt yaprakları budayın.',
        en: 'Support the main vine on stakes and prune bottom leaves.',
      ),
      sunlightHours: '6 - 8 Saat / Gün',
      sunlightType: const LocalizedText(tr: 'Doğrudan Güneş Işığı', en: 'Direct Sunlight'),
      idealTempRange: '22°C - 30°C',
      idealHumidity: '%70 - %80',
      expectedHarvestDays: 55,
      icon: '🥒',
    ),
    PlantSpecies(
      speciesId: 'basil',
      name: const LocalizedText(tr: 'Fesleğen / Reyhan', en: 'Basil'),
      scientificName: 'Ocimum basilicum',
      category: const LocalizedText(tr: 'Aromatik Bitki', en: 'Herb'),
      wateringIntervalDays: 2,
      wateringAmountMl: 200,
      wateringTip: const LocalizedText(
        tr: 'Toprak kurudukça sabah saatlerinde sulayın. Kök çürümesine dikkat edin.',
        en: 'Water in morning when soil feels dry. Watch out for root rot.',
      ),
      fertilizingIntervalDays: 21,
      fertilizingTip: const LocalizedText(
        tr: 'Azot ağırlıklı hafif seyreltilmiş organik gübre yaprak gelişimini coşturur.',
        en: 'Diluted nitrogen-rich liquid fertilizer promotes foliage.',
      ),
      pruningIntervalDays: 10,
      pruningTip: const LocalizedText(
        tr: 'Çiçek tomurcukları belirdiğinde tepeden uç alımı yaparak dallanmayı sağlayın.',
        en: 'Pinch flower buds at top to encourage bushy branch growth.',
      ),
      sunlightHours: '4 - 6 Saat / Gün',
      sunlightType: const LocalizedText(tr: 'Güneşli / Yarı Gölge', en: 'Sunny / Partial Shade'),
      idealTempRange: '18°C - 25°C',
      idealHumidity: '%50 - %65',
      expectedHarvestDays: 40,
      icon: '🌿',
    ),
    PlantSpecies(
      speciesId: 'lettuce',
      name: const LocalizedText(tr: 'Marul', en: 'Lettuce'),
      scientificName: 'Lactuca sativa',
      category: const LocalizedText(tr: 'Yeşillik', en: 'Greens'),
      wateringIntervalDays: 2,
      wateringAmountMl: 300,
      wateringTip: const LocalizedText(
        tr: 'Sığ köklüdür, toprağın üst katmanının kurumasına izin vermeyin.',
        en: 'Shallow rooted; do not allow top layer of soil to dry out.',
      ),
      fertilizingIntervalDays: 20,
      fertilizingTip: const LocalizedText(
        tr: 'Yaprak gelişimi için hafif solucan gübresi veya kompost suyu kafidir.',
        en: 'Worm castings or compost tea provide ideal nutrition.',
      ),
      pruningIntervalDays: 30,
      pruningTip: const LocalizedText(
        tr: 'Dıştaki olgun yaprakları hasat ederek iç göbeğin büyümesini sürdürün.',
        en: 'Harvest outer mature leaves and let heart keep growing.',
      ),
      sunlightHours: '4 - 5 Saat / Gün',
      sunlightType: const LocalizedText(tr: 'Yarı Gölge / Dolaylı Işık', en: 'Partial / Indirect Light'),
      idealTempRange: '15°C - 22°C',
      idealHumidity: '%60 - %70',
      expectedHarvestDays: 45,
      icon: '🥬',
    ),
  ];

  static final List<PestDiagnosis> pestDiagnosisList = [
    const PestDiagnosis(
      id: 'aphids',
      name: LocalizedText(tr: 'Yaprak Biti (Afidler)', en: 'Aphids'),
      category: 'pest',
      severity: 'medium',
      symptoms: [
        'yaprak_kivrilmasi',
        'yapiskan_yuzey',
        'tomurcuk_kumesi',
        'yaprak_sararmasi',
      ],
      symptomLabels: {
        'tr': [
          'Yapraklarda içe doğru kıvrılma',
          'Yapışkan tatlımsı tabaka (Balımsı madde)',
          'Taze sürgün ve tomurcuklarda kümeleşme',
          'Yapraklarda sararma ve cılızlaşma'
        ],
        'en': [
          'Inward leaf curling',
          'Sticky honeydew residue',
          'Clusters on young shoots and buds',
          'Yellowing and stunted leaves'
        ],
      },
      diagnosisSummary: LocalizedText(
        tr: 'Bitkinin taze filiz ve yaprak özsuyunu emerek beslenirler; şekil bozukluğuna ve mantar oluşumuna yol açarlar.',
        en: 'Feeds on tender shoot sap causing deformities and honeydew mold.',
      ),
      organicTreatment: LocalizedText(
        tr: '1 litre suya 1 yemek kaşığı sıvı Arap sabunu ve 1 tatlı kaşığı Neem (tesbih ağacı) yağı karıştırıp 3 gün arayla yaprak altlarına püskürtün.',
        en: 'Mix 1 tbsp mild liquid soap and 1 tsp neem oil in 1L water; spray under leaves every 3 days.',
      ),
      preventionTips: LocalizedText(
        tr: 'Uğur böcekleri doğal avcısıdır. Fazla azotlu gübrelemeden kaçının.',
        en: 'Ladybugs are natural predators. Avoid excessive nitrogen fertilizers.',
      ),
    ),
    const PestDiagnosis(
      id: 'whitefly',
      name: LocalizedText(tr: 'Beyaz Sinek (Aleyrodidae)', en: 'Whitefly'),
      category: 'pest',
      severity: 'high',
      symptoms: [
        'yaprak_alti_beyaz_bocek',
        'yaprak_sararmasi',
        'yapiskan_yuzey',
      ],
      symptomLabels: {
        'tr': [
          'Yaprak altlarında uçuşan minik beyaz sinekler',
          'Genel yaprak sararması ve kuruma',
          'Yaprak üstünde yapışkan tabaka'
        ],
        'en': [
          'Tiny white flying insects under leaves',
          'Leaf yellowing and drying',
          'Sticky honeydew residue'
        ],
      },
      diagnosisSummary: LocalizedText(
        tr: 'Bitkinin özsuyunu sömürerek yaprakların dökülmesine ve virüs hastalıklarının yayılmasına neden olur.',
        en: 'Sucks plant sap causing leaf drop and vectoring viral infections.',
      ),
      organicTreatment: LocalizedText(
        tr: 'Seraya sarı yapışkan tuzaklar asın. Neem yağı ve sarımsak özü karışımını haftada 2 kez akşam saatlerinde yaprak altlarına uygulayın.',
        en: 'Hang yellow sticky cards. Spray neem oil and garlic extract twice weekly in the evening.',
      ),
      preventionTips: LocalizedText(
        tr: 'Sera havalandırmasını sineklik tülü ile koruyun, yabancı otları temizleyin.',
        en: 'Use insect mesh on greenhouse vents and clean weeds thoroughly.',
      ),
    ),
    const PestDiagnosis(
      id: 'spider_mites',
      name: LocalizedText(tr: 'Kırmızı Örümcek (Akar)', en: 'Red Spider Mite'),
      category: 'pest',
      severity: 'high',
      symptoms: [
        'orumcek_agi',
        'nokta_sararma',
        'bronzlasma',
      ],
      symptomLabels: {
        'tr': [
          'Yaprak sapı ve altında ince örümcek ağları',
          'Yaprak yüzeyinde sarı-beyaz minik benekler',
          'Yaprakların pas rengine/bronza dönmesi'
        ],
        'en': [
          'Fine webbings under leaves and stems',
          'Tiny pale stippling spots on leaves',
          'Leaves turning bronze or rusty brown'
        ],
      },
      diagnosisSummary: LocalizedText(
        tr: 'Kuru ve sıcak havalarda hızla çoğalır. Yaprak hücrelerini delerek bitkiyi fotosentez yapamaz hale getirir.',
        en: 'Thrives in dry, warm conditions. Pierces leaf cells and degrades photosynthesis.',
      ),
      organicTreatment: LocalizedText(
        tr: 'Sera nemini artırın. Kükürtlü solüsyon veya biberiye/nane yağı karışımı püskürtün.',
        en: 'Increase humidity. Spray diluted wettable sulfur or rosemary/peppermint oil solution.',
      ),
      preventionTips: LocalizedText(
        tr: 'Kuru hava akımını engelleyin, bitki yapraklarını periyodik olarak nemlendirin.',
        en: 'Avoid arid dry draft; mist surrounding air regularly.',
      ),
    ),
    const PestDiagnosis(
      id: 'powdery_mildew',
      name: LocalizedText(tr: 'Külleme Hastalığı (Mantar)', en: 'Powdery Mildew'),
      category: 'disease',
      severity: 'medium',
      symptoms: [
        'beyaz_leke',
        'unsu_tabaka',
        'yaprak_kurumasi',
      ],
      symptomLabels: {
        'tr': [
          'Yaprak üstünde beyaz pudra/un gibi toz tabakası',
          'Lekelerin birleşerek yaprağı kaplaması',
          'Yaprakların kıvrılıp zamanından önce kuruması'
        ],
        'en': [
          'White flour-like powdery spots on top of leaves',
          'Patches joining together covering leaf surface',
          'Premature drying and leaf curling'
        ],
      },
      diagnosisSummary: LocalizedText(
        tr: 'Havasız ve gölge seralarda oluşan fungal bir hastalıktır. Yaprakların güneş ışığı almasını engeller.',
        en: 'Fungal infection caused by poor aeration and low light. Blocks sunlight from leaves.',
      ),
      organicTreatment: LocalizedText(
        tr: '1 litre suya 1 tatlı kaşığı karbonat (kabartma tozu) ve yarım çay kaşığı sıvı sabun ekleyip haftada 1 kez püskürtün.',
        en: 'Mix 1 tsp baking soda and 1/2 tsp soap in 1L water; spray once weekly.',
      ),
      preventionTips: LocalizedText(
        tr: 'Sera fanlarını çalıştırın, bitkiler arasındaki dikim mesafesini artırın, yaprakları ıslatmayın.',
        en: 'Improve airflow, maintain wide plant spacing, avoid overhead watering.',
      ),
    ),
    const PestDiagnosis(
      id: 'root_rot',
      name: LocalizedText(tr: 'Kök Çürüklüğü (Fusarium/Pythium)', en: 'Root Rot'),
      category: 'disease',
      severity: 'high',
      symptoms: [
        'kok_kararmasi',
        'solgunluk',
        'yaprak_sararmasi',
      ],
      symptomLabels: {
        'tr': [
          'Gövde dip kısmında ve köklerde kararma/çürüme',
          'Toprak ıslak olmasına rağmen bitkide solgunluk',
          'Alt yapraklardan başlayan sararma'
        ],
        'en': [
          'Stem base and roots turning brown/mushy',
          'Wilting despite soil being wet',
          'Yellowing starting from lower leaves'
        ],
      },
      diagnosisSummary: LocalizedText(
        tr: 'Aşırı sulama ve kötü drenaj sonucu köklerin oksijensiz kalarak mantar kapmasıdır; tedavi edilmezse bitki ölür.',
        en: 'Excess watering suffocates roots allowing fungus to attack; fatal if left untreated.',
      ),
      organicTreatment: LocalizedText(
        tr: 'Sulamayı derhal kesin, toprağın kurumasını bekleyin. Çürümüş kökleri kesip temizleyin, drenaj deliklerini açın.',
        en: 'Stop watering immediately. Trim rotten roots, repot in fresh aerated soil.',
      ),
      preventionTips: LocalizedText(
        tr: 'Perlit ve torf karışımı süzek toprak kullanın, saksı tabağında su bekletmeyin.',
        en: 'Use well-draining soil with perlite; never leave standing water in saucers.',
      ),
    ),
    const PestDiagnosis(
      id: 'caterpillars_slugs',
      name: LocalizedText(tr: 'Yaprak Tırtılı ve Salyangoz', en: 'Caterpillars & Slugs'),
      category: 'pest',
      severity: 'medium',
      symptoms: [
        'yaprak_delik',
        'kemirilmis_kenar',
        'parlak_iz',
      ],
      symptomLabels: {
        'tr': [
          'Yapraklarda düzensiz büyük delikler',
          'Yaprak kenarlarının tamamen kemirilmesi',
          'Gümüşi parlak sümüksü salya izleri'
        ],
        'en': [
          'Irregular holes chewed into leaves',
          'Leaf edges scalloped and eaten',
          'Silvery shiny slime trails'
        ],
      },
      diagnosisSummary: LocalizedText(
        tr: 'Gece saatlerinde yaprakları oburca tüketirler; genç fideleri tamamen yok edebilirler.',
        en: 'Nocturnal feeders chewing foliage voraciously; can destroy seedlings.',
      ),
      organicTreatment: LocalizedText(
        tr: 'Bitki diplerine ezilmiş yumurta kabuğu veya odun külü dökerek bariyer yapın. Gece elle toplayın veya Bacillus thuringiensis uygulayın.',
        en: 'Create barriers using crushed eggshells or wood ash. Handpick at night or use Bt spray.',
      ),
      preventionTips: LocalizedText(
        tr: 'Nemli tahta ve tuğla altlarını temiz tutun, malç tabakasını kontrol edin.',
        en: 'Remove hiding spots like damp boards and bricks near greenhouse beds.',
      ),
    ),
  ];

  static List<Greenhouse> getInitialGreenhouses() {
    final now = DateTime.now();
    return [
      Greenhouse(
        id: 'gh_01',
        userId: 'user_default',
        name: 'Kışlık Domates ve Biber Serası',
        photoUrl: '',
        icon: '🍅',
        createdAt: now.subtract(const Duration(days: 35)),
      ),
      Greenhouse(
        id: 'gh_02',
        userId: 'user_default',
        name: 'Balkon Çilek & Fesleğen',
        photoUrl: '',
        icon: '🍓',
        createdAt: now.subtract(const Duration(days: 20)),
      ),
    ];
  }

  static List<Plant> getInitialPlants() {
    final now = DateTime.now();
    return [
      Plant(
        id: 'plt_101',
        greenhouseId: 'gh_01',
        speciesId: 'tomato',
        customName: 'Pembe Domates #1',
        // 46 gün önce ekilmiş, 70 günlük hasat periyodu (24 gün kaldı)
        plantedAt: now.subtract(const Duration(days: 46)),
        // Domates sulama periyodu 3 gün: 4 gün önce sulanmış -> 1 GÜN GECİKTİ (KIRMIZI UYARI)
        lastWateredAt: now.subtract(const Duration(days: 4)),
        // Gübreleme periyodu 14 gün: 14 gün önce -> BUGÜN YAPILMALI (SARI UYARI)
        lastFertilizedAt: now.subtract(const Duration(days: 14)),
        // Budama periyodu 21 gün: 12 gün önce -> 9 GÜN SONRA (YEŞİL GÜVENDE)
        lastPrunedAt: now.subtract(const Duration(days: 12)),
        locationNote: 'Kuzey cephe sırık sırası No: 1',
      ),
      Plant(
        id: 'plt_102',
        greenhouseId: 'gh_01',
        speciesId: 'pepper',
        customName: 'Sivri Biber #2',
        plantedAt: now.subtract(const Duration(days: 37)),
        // 2 gün önce sulandı -> 1 gün kaldı (Sarı)
        lastWateredAt: now.subtract(const Duration(days: 2)),
        lastFertilizedAt: now.subtract(const Duration(days: 5)),
        lastPrunedAt: now.subtract(const Duration(days: 10)),
        locationNote: 'Orta yatak güney bölümü',
      ),
      Plant(
        id: 'plt_201',
        greenhouseId: 'gh_02',
        speciesId: 'strawberry',
        customName: 'Yediveren Çilek',
        plantedAt: now.subtract(const Duration(days: 25)),
        lastWateredAt: now, // Bugün sulandı -> Yeşil
        lastFertilizedAt: now.subtract(const Duration(days: 3)),
        lastPrunedAt: now.subtract(const Duration(days: 5)),
        locationNote: 'Asılı saksı #3',
      ),
      Plant(
        id: 'plt_202',
        greenhouseId: 'gh_02',
        speciesId: 'basil',
        customName: 'İtalyan Fesleğen',
        plantedAt: now.subtract(const Duration(days: 15)),
        lastWateredAt: now,
        lastFertilizedAt: now.subtract(const Duration(days: 2)),
        lastPrunedAt: now.subtract(const Duration(days: 1)),
        locationNote: 'Güneş gören pencere önü',
      ),
    ];
  }

  static List<NoteAndHarvest> getInitialNotes() {
    final now = DateTime.now();
    return [
      NoteAndHarvest(
        id: 'log_01',
        greenhouseId: 'gh_01',
        plantId: 'plt_101',
        type: 'harvest',
        title: 'İlk Salkım Hasadı',
        content: 'İlk salkımdan 4 adet iri ve lezzetli pembe domates hasat edildi.',
        harvestAmountGrams: 620,
        qualityRating: 5,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      NoteAndHarvest(
        id: 'log_02',
        greenhouseId: 'gh_01',
        type: 'note',
        title: 'Sera Havalandırma Notu',
        content: 'Hafta sonu sıcaklıklar 28 dereceyi aştığı için yan pencereler açıldı.',
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      NoteAndHarvest(
        id: 'log_03',
        greenhouseId: 'gh_02',
        plantId: 'plt_201',
        type: 'treatment',
        title: 'Organik Neem Yağı Tedavisi',
        content: 'Yaprak altlarında hafif afid belirtisi görüldü; sabunlu neem yağı spreyi uygulandı.',
        createdAt: now.subtract(const Duration(days: 7)),
      ),
    ];
  }
}
