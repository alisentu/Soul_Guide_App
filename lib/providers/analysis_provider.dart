import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/analysis_data.dart';
import '../services/gemini_service.dart';
import '../services/storage_service.dart';
import 'user_provider.dart';

final analysisProvider =
    StateNotifierProvider<AnalysisNotifier, AsyncValue<AnalysisData?>>((ref) {
  return AnalysisNotifier(
    ref.watch(geminiServiceProvider),
    ref.watch(storageServiceProvider),
    ref,
  );
});

class AnalysisNotifier extends StateNotifier<AsyncValue<AnalysisData?>> {
  final GeminiService _gemini;
  final StorageService _storage;
  final Ref _ref;

  AnalysisNotifier(this._gemini, this._storage, this._ref)
      : super(const AsyncValue.data(null));

  AnalysisData _calculateLocalAnalysis(List<Map<String, dynamic>> allAnswers, List<String> tags) {
    double odak = 0.5;
    double creativity = 0.5;
    double empati = 0.5;
    double resilience = 0.5;
    double huzur = 0.5;

    // Her bir cevabın etiketlerini analiz et
    for (final qa in allAnswers) {
      final qTags = List<String>.from(qa['tags'] ?? []);
      for (final tag in qTags) {
        final t = tag.toLowerCase();
        
        // Odak (Conscientiousness, logic, focus)
        if (const ['strateji', 'bulmaca', 'dedektiflik', 'zeka-oyunu', 'belgesel', 'teknoloji', 'pratik', 'gerçekçi', 'tarih', 'liderlik', 'fayda'].contains(t)) {
          odak += 0.08;
        } else if (const ['spontane', 'aksiyon', 'parti-oyunu', 'hızlı-tüketim', 'arcade', 'macera', 'komedi'].contains(t)) {
          odak -= 0.04;
        }

        // Yaratıcılık (Creativity, openness, arts, imagination)
        if (const ['indie', 'fantezi', 'bilim-kurgu', 'diy', 'tasarım', 'estetik', 'alternatif', 'sanat', 'felsefe', 'kişiselleştirilmiş', 'deneyim', 'macera', 'fantezi-kitap', 'bilim-kurgu-kitap'].contains(t)) {
          creativity += 0.08;
        } else if (const ['klasik', 'garanti', 'geleneksel', 'popüler', 'sitcom'].contains(t)) {
          creativity -= 0.04;
        }

        // Empati (Extraversion, social, emotion, drama)
        if (const ['romantik', 'romantik-dram', 'dram', 'sosyal', 'aile', 'psikoloji', 'psikolojik', 'parti-oyunu', 'kişiselleştirilmiş', 'romantik-kitap', 'dram-kitap'].contains(t)) {
          empati += 0.08;
        } else if (const ['solo-oyun', 'rekabetçi', 'souls-like', 'hızlı-tüketim', 'pratik'].contains(t)) {
          empati -= 0.04;
        }

        // Dayanıklılık (Emotional stability, survival, resilience)
        if (const ['hayatta-kalma', 'souls-like', 'strateji', 'liderlik', 'gerçekçi', 'pratik', 'huzur', 'spor'].contains(t)) {
          resilience += 0.08;
        } else if (const ['korku', 'gerilim', 'psikolojik-gerilim', 'mood_bad', 'hızlı-tüketim', 'korku-oyun'].contains(t)) {
          resilience -= 0.04;
        }

        // Huzur (Calmness, peace, cozy)
        if (const ['cozy-oyun', 'slice-of-life', 'huzur', 'doğa', 'nature', 'komedi', 'sitcom', 'casual-oyun', 'aile'].contains(t)) {
          huzur += 0.08;
        } else if (const ['korku', 'gerilim', 'aksiyon', 'rekabetçi', 'hız', 'hack-slash', 'distopik', 'souls-like', 'hızlı-tüketim', 'adrenalin', 'korku-oyun', 'korku-kitap'].contains(t)) {
          huzur -= 0.04;
        }
      }
    }

    // Ek olarak genel profil etiketlerini de hesaba kat
    for (final tag in tags) {
      final t = tag.toLowerCase();
      if (const ['strateji', 'bulmaca', 'teknoloji'].contains(t)) odak += 0.05;
      if (const ['fantezi', 'indie', 'sanat'].contains(t)) creativity += 0.05;
      if (const ['dram', 'romantik', 'sosyal'].contains(t)) empati += 0.05;
      if (const ['hayatta-kalma', 'spor', 'liderlik'].contains(t)) resilience += 0.05;
      if (const ['huzur', 'cozy', 'komedi'].contains(t)) huzur += 0.05;
    }

    // Değerleri [0.25, 0.98] arasına sınırla (clamp)
    odak = odak.clamp(0.25, 0.98);
    creativity = creativity.clamp(0.25, 0.98);
    empati = empati.clamp(0.25, 0.98);
    resilience = resilience.clamp(0.25, 0.98);
    huzur = huzur.clamp(0.25, 0.98);

    // Insight (içgörü) metnini dinamik olarak baskın özelliklere göre seçelim
    String dominantArchetype = 'Denge Arayışçısı';
    String insight = 'Zihninin ve ruhunun derinliklerinde harika bir denge yatıyor. Kendine zaman ayırarak gücünü besliyorsun.';
    String quickTip = 'Bugün kendine 10 dakika ayırıp sessizce kahveni yudumlamayı dene.';
    List<String> insightTags = ['Dengeli', 'Farkındalık'];

    // En yüksek skoru bul
    final scores = {
      'Odak': odak,
      'Yaratıcılık': creativity,
      'Empati': empati,
      'Dayanıklılık': resilience,
      'Huzur': huzur,
    };
    final sorted = scores.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final dominant = sorted.first.key;

    if (dominant == 'Odak') {
      dominantArchetype = 'Strateji Dehası';
      insight = 'Analitik zekan ve odaklanma yeteneğin mükemmel düzeyde. Detayları yakalama konusunda üstüne yok. Zihnini karmaşık bulmacalarla beslemeyi seviyorsun.';
      quickTip = 'Zihnini biraz dinlendirmek için bugün stratejik plan yapmayı bir kenara bırakıp sakinleştirici bir müzik dinleyebilirsin.';
      insightTags = ['Analitik', 'Odaklanmış', 'Kararlı'];
    } else if (dominant == 'Yaratıcılık') {
      dominantArchetype = 'Hayalperest Sanatçı';
      insight = 'Hayal gücün ve yaratıcılığın sınır tanımıyor. Sıradanlıktan uzak, özgün ve sanatsal deneyimler ruhunu besliyor. Yeni fikirler üretmek en büyük gücün.';
      quickTip = 'Bugün aklına gelen sıra dışı bir fikri veya hayali küçük bir kağıda not al, ileride ilham kaynağın olabilir.';
      insightTags = ['Yaratıcı', 'Özgün', 'Hayalperest'];
    } else if (dominant == 'Empati') {
      dominantArchetype = 'Duygusal Rezonans Lideri';
      insight = 'İnsanların duygularını derinlemesine hissedebiliyor ve güçlü empati kurabiliyorsun. İlişkilerindeki sıcaklık ve samimiyet etrafına ışık saçıyor.';
      quickTip = 'Başkalarının enerjisini toplarken kendi ruhunu yormamaya dikkat et. Bugün biraz yalnız kalıp kendine odaklanabilirsin.';
      insightTags = ['Empatik', 'Duyarlı', 'Sıcakkanlı'];
    } else if (dominant == 'Dayanıklılık') {
      dominantArchetype = 'Hayatta Kalan Savaşçı';
      insight = 'Karşılaştığın zorluklar karşısında asla pes etmeyen, yüksek duygusal dayanıklılığa sahip bir yapın var. Kriz anlarında soğukkanlı kalıp en doğru kararları alabiliyorsun.';
      quickTip = 'Güçlü olmak harika ama bazen dinlenmek de dayanıklılığın bir parçasıdır. Kendine biraz şefkat göster.';
      insightTags = ['Dayanıklı', 'Güçlü', 'Soğukkanlı'];
    } else if (dominant == 'Huzur') {
      dominantArchetype = 'Zen Ustası';
      insight = 'Hayatın gürültüsü içinde sakinliğini korumayı ve iç huzurunu bulmayı başaran ender insanlardansın. Dingin, minimalist ve cozy ortamlar sana enerji veriyor.';
      quickTip = 'Huzurlu yapını korumak için doğayla iç içe geçireceğin kısa bir yürüyüş ruhuna çok iyi gelecektir.';
      insightTags = ['Huzurlu', 'Dingin', 'Sakin'];
    }

    return AnalysisData(
      dimensions: [
        RadarDimension(label: 'Odak', value: odak, color: '#E5EEFF'),
        RadarDimension(label: 'Yaratıcılık', value: creativity, color: '#D2BFE7'),
        RadarDimension(label: 'Empati', value: empati, color: '#CEF7DE'),
        RadarDimension(label: 'Dayanıklılık', value: resilience, color: '#A9C9F3'),
        RadarDimension(label: 'Huzur', value: huzur, color: '#D2BFE7'),
      ],
      insight: insight,
      quickTip: quickTip,
      insightTags: insightTags,
      generatedAt: DateTime.now(),
    );
  }

  Future<void> generateAnalysis() async {
    state = const AsyncValue.loading();
    try {
      final profile = _ref.read(userProfileProvider);
      final tags = profile?.interestTags ?? [];
      final allAnswers = _storage.getAllAnswers();

      if (allAnswers.isEmpty && tags.isEmpty) {
        // Henüz test çözülmemiş, demo veri göster
        state = AsyncValue.data(AnalysisData(
          dimensions: [
            const RadarDimension(label: 'Odak', value: 0.62, color: '#E5EEFF'),
            const RadarDimension(label: 'Yaratıcılık', value: 0.84, color: '#D2BFE7'),
            const RadarDimension(label: 'Empati', value: 0.73, color: '#CEF7DE'),
            const RadarDimension(label: 'Dayanıklılık', value: 0.55, color: '#A9C9F3'),
            const RadarDimension(label: 'Huzur', value: 0.68, color: '#D2BFE7'),
          ],
          insight: 'Henüz yeterli veri yok. İlk testini çözüp analizinin derinleşmesini sağla!',
          quickTip: 'Ana menüdeki haftalık testi çözerek profilini güçlendir.',
          insightTags: ['Başlangıç', 'Test Çöz'],
          generatedAt: DateTime.now(),
        ));
        return;
      }

      // Gemini API'yi dene
      final analysis = await _gemini.generateAnalysis(allAnswers, tags);
      state = AsyncValue.data(analysis);
    } catch (e, st) {
      // API Hatası durumunda yerel olarak dinamik analiz hesapla
      try {
        final profile = _ref.read(userProfileProvider);
        final tags = profile?.interestTags ?? [];
        final allAnswers = _storage.getAllAnswers();
        
        final localAnalysis = _calculateLocalAnalysis(allAnswers, tags);
        state = AsyncValue.data(localAnalysis);
      } catch (innerError) {
        state = AsyncValue.error(e, st);
      }
    }
  }
}
