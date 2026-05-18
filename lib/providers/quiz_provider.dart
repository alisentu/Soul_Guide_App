import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/quiz_question.dart';
import '../services/gemini_service.dart';
import '../services/storage_service.dart';
import 'user_provider.dart';

final onboardingQuestionsProvider =
    FutureProvider<List<QuizQuestion>>((ref) async {
  final gemini = ref.watch(geminiServiceProvider);
  try {
    return await gemini.generateOnboardingQuestions();
  } catch (e) {
    return _fallbackOnboardingQuestions();
  }
});

final weeklyQuestionsProvider =
    FutureProvider<List<QuizQuestion>>((ref) async {
  final gemini = ref.watch(geminiServiceProvider);
  final profile = ref.watch(userProfileProvider);
  final tags = profile?.interestTags ?? [];
  try {
    return await gemini.generateWeeklyQuestions(tags);
  } catch (e) {
    return _fallbackWeeklyQuestions();
  }
});

final quizSessionProvider =
    StateNotifierProvider<QuizSessionNotifier, QuizSessionState>((ref) {
  return QuizSessionNotifier(
    ref.watch(storageServiceProvider),
    ref.watch(geminiServiceProvider),
    ref,
  );
});

class QuizSessionState {
  final List<QuizQuestion> questions;
  final int currentIndex;
  final Map<String, String> answers;
  final bool isCompleted;
  final bool isLoading;
  final String? error;

  const QuizSessionState({
    this.questions = const [],
    this.currentIndex = 0,
    this.answers = const {},
    this.isCompleted = false,
    this.isLoading = false,
    this.error,
  });

  QuizQuestion? get currentQuestion =>
      currentIndex < questions.length ? questions[currentIndex] : null;

  bool get hasNext => currentIndex < questions.length - 1;
  bool get hasPrev => currentIndex > 0;
  double get progress =>
      questions.isEmpty ? 0 : (currentIndex + 1) / questions.length;

  String? get selectedOptionId => currentQuestion != null
      ? answers[currentQuestion!.id]
      : null;

  QuizSessionState copyWith({
    List<QuizQuestion>? questions,
    int? currentIndex,
    Map<String, String>? answers,
    bool? isCompleted,
    bool? isLoading,
    String? error,
  }) {
    return QuizSessionState(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      answers: answers ?? this.answers,
      isCompleted: isCompleted ?? this.isCompleted,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class QuizSessionNotifier extends StateNotifier<QuizSessionState> {
  final StorageService _storage;
  final GeminiService _gemini;
  final Ref _ref;

  QuizSessionNotifier(this._storage, this._gemini, this._ref)
      : super(const QuizSessionState());

  void loadQuestions(List<QuizQuestion> questions) {
    state = state.copyWith(
      questions: questions,
      currentIndex: 0,
      answers: {},
      isCompleted: false,
    );
  }

  void selectOption(String questionId, String optionId) {
    final newAnswers = Map<String, String>.from(state.answers);
    newAnswers[questionId] = optionId;
    state = state.copyWith(answers: newAnswers);
  }

  void nextQuestion() {
    if (state.hasNext) {
      state = state.copyWith(currentIndex: state.currentIndex + 1);
    }
  }

  void prevQuestion() {
    if (state.hasPrev) {
      state = state.copyWith(currentIndex: state.currentIndex - 1);
    }
  }

  Future<void> completeSession() async {
    state = state.copyWith(isLoading: true);
    try {
      final answersData = <Map<String, dynamic>>[];
      for (final question in state.questions) {
        final optionId = state.answers[question.id];
        if (optionId == null) continue;
        final option = question.options.firstWhere(
          (o) => o.id == optionId,
          orElse: () => question.options.first,
        );
        answersData.add({
          'question': question.question,
          'answer': option.text,
          'tags': option.tags,
        });
      }

      await _storage.saveAnswers(answersData);

      final session = QuizSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        questions: state.questions,
        answers: state.answers,
        startedAt: DateTime.now(),
        completedAt: DateTime.now(),
        isWeekly: state.questions.any((q) => q.isWeekly),
      );
      await _storage.saveQuizSession(session);

      try {
        final profile = _ref.read(userProfileProvider);
        final aiProfile = await _gemini.buildUserProfile(answersData, profile?.age, profile?.zodiacSign);
        await _ref.read(userProfileProvider.notifier).updateWithAiProfile(aiProfile);
        await _ref.read(userProfileProvider.notifier).incrementCompletedTests();
        final newTags = List<String>.from(aiProfile['tags'] ?? []);
        await _ref.read(userProfileProvider.notifier).updateTags(newTags);
      } catch (_) {
        await _ref.read(userProfileProvider.notifier).incrementCompletedTests();
      }

      state = state.copyWith(isCompleted: true, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Profil oluşturulurken hata oluştu: $e',
      );
    }
  }

  void reset() {
    state = const QuizSessionState();
  }
}

final quizSessionsProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return storage.getQuizSessions();
});

// ─── FALLBACK SORULAR (API 429 hatası durumunda) ──────────────────────────

List<QuizQuestion> _fallbackOnboardingQuestions() => [
      QuizQuestion(
        id: 'q1', question: 'Tüm hafta sonun boşaldı ve planın yok. İlk tepkin?',
        subtitle: 'Sosyal Enerji & Düzen', icon: 'weekend', isWeekly: false,
        options: [
          QuizOption(id: 'q1_a', text: 'Spontane dışarı çıkarım', subtitle: 'Arkadaşlarımla plan yaparım', icon: 'group', tags: ['sosyal', 'popüler', 'aksiyon']),
          QuizOption(id: 'q1_b', text: 'Hikayeli filme/oyuna gömülürüm', subtitle: 'Tek başıma derinleşirim', icon: 'movie', tags: ['rpg', 'psikolojik-gerilim', 'dram']),
          QuizOption(id: 'q1_c', text: 'Yeni bir hobi/belgesel araştırırım', subtitle: 'Evde ama keşifte', icon: 'explore', tags: ['belgesel', 'strateji', 'diy']),
          QuizOption(id: 'q1_d', text: 'Tanıdık bir rutinde dinlenirim', subtitle: 'Comfort binge zamanı', icon: 'self_improvement', tags: ['sitcom', 'casual-oyun', 'komedi']),
        ],
      ),
      QuizQuestion(
        id: 'q2', question: 'Karakterin hangi seçimi yapması seni tatmin eder?',
        subtitle: 'Karar Alma (Mantık vs Duygu)', icon: 'psychology', isWeekly: false,
        options: [
          QuizOption(id: 'q2_a', text: 'Mantıklı olanı yapması', subtitle: 'Çoğunluğun faydası için', icon: 'architecture', tags: ['bilim-kurgu', 'strateji', 'polisiye']),
          QuizOption(id: 'q2_b', text: 'Sevdiği uğruna her şeyi riske atması', subtitle: 'Duygusal ve tutkulu', icon: 'favorite', tags: ['romantik-dram', 'hikaye-odaklı']),
          QuizOption(id: 'q2_c', text: 'Zekice üçüncü bir yol bulması', subtitle: 'Kuralları esneten çözüm', icon: 'lightbulb', tags: ['suç', 'zeka-oyunu', 'gizem']),
          QuizOption(id: 'q2_d', text: 'Güvenliği ve huzuru seçmesi', subtitle: 'Zorluklardan uzaklaşmak', icon: 'shield', tags: ['cozy-oyun', 'aile', 'slice-of-life']),
        ],
      ),
      QuizQuestion(
        id: 'q3', question: 'Yeni bir yapıma başlarken en çekici unsur nedir?',
        subtitle: 'Uyarılma & Deneyime Açıklık', icon: 'local_fire_department', isWeekly: false,
        options: [
          QuizOption(id: 'q3_a', text: 'Sürekli tehlike ve yüksek tempo', subtitle: 'Adrenalin dolu anlar', icon: 'bolt', tags: ['korku', 'aksiyon', 'rekabetçi']),
          QuizOption(id: 'q3_b', text: 'Sürreal ve fantastik bir evren', subtitle: 'Görülmemiş tasarımlar', icon: 'auto_awesome', tags: ['fantezi', 'indie', 'macera']),
          QuizOption(id: 'q3_c', text: 'Tarihi ve bilimsel gerçeklik', subtitle: 'Detaylı ve mantıklı', icon: 'history_edu', tags: ['tarih', 'simülasyon', 'biyografi']),
          QuizOption(id: 'q3_d', text: 'İçimi ısıtan ve güldüren', subtitle: 'Stresten uzaklaştıran', icon: 'sentiment_very_satisfied', tags: ['komedi', 'animasyon', 'romantik']),
        ],
      ),
      QuizQuestion(
        id: 'q4', question: 'Sanal/Gerçek alışverişte nasıl bir yol izlersin?',
        subtitle: 'Düzen & Alışveriş Alışkanlığı', icon: 'shopping_bag', isWeekly: false,
        options: [
          QuizOption(id: 'q4_a', text: 'Araştırır ve F/P ürününü alırım', subtitle: 'Mantıklı ve planlı', icon: 'search', tags: ['teknoloji', 'stratejik', 'fayda']),
          QuizOption(id: 'q4_b', text: 'Görseline aşık olur, anında alırım', subtitle: 'Estetik ve spontane', icon: 'color_lens', tags: ['tasarım', 'estetik', 'moda']),
          QuizOption(id: 'q4_c', text: 'Yıllardır güvendiğim markalardan şaşmam', subtitle: 'Geleneksel ve güvenilir', icon: 'verified', tags: ['klasik', 'garanti', 'geleneksel']),
          QuizOption(id: 'q4_d', text: 'Kimsenin bilmediği niş ürünleri keşfederim', subtitle: 'Farklı ve yenilikçi', icon: 'explore', tags: ['indie', 'aksesuar', 'alternatif']),
        ],
      ),
      QuizQuestion(
        id: 'q5', question: 'Bir labirentte kayboldun, çıkışı nasıl bulursun?',
        subtitle: 'Problem Çözme & Baskı Altı', icon: 'map', isWeekly: false,
        options: [
          QuizOption(id: 'q5_a', text: 'İşaret koyar, harita çıkarırım', subtitle: 'Sistematik ve analitik', icon: 'architecture', tags: ['bulmaca', 'dedektiflik', 'strateji']),
          QuizOption(id: 'q5_b', text: 'İçgüdülerime güvenip koşarım', subtitle: 'Hızlı ve duygusal tepki', icon: 'directions_run', tags: ['aksiyon', 'macera', 'hız']),
          QuizOption(id: 'q5_c', text: 'Duvarlara tırmanır, kural bozarım', subtitle: 'Kestirme ve yaratıcı', icon: 'construction', tags: ['hack-slash', 'distopik', 'bilim-kurgu']),
          QuizOption(id: 'q5_d', text: 'Oturur, en güvenli anı beklerim', subtitle: 'Sakin ve temkinli', icon: 'self_improvement', tags: ['hayatta-kalma', 'drama', 'psikolojik']),
        ],
      ),
      QuizQuestion(
        id: 'q6', question: 'Bir kitap veya dizinin sonu nasıl bitmeli?',
        subtitle: 'Beklenti & Tatmin', icon: 'menu_book', isWeekly: false,
        options: [
          QuizOption(id: 'q6_a', text: 'Gerçekçi ama acı verici', subtitle: 'Hayatın içinden', icon: 'nature', tags: ['dram', 'belgesel', 'psikoloji']),
          QuizOption(id: 'q6_b', text: 'Mutlu ve umut verici', subtitle: 'İyi hissettiren', icon: 'favorite_border', tags: ['romantik', 'aile', 'komedi']),
          QuizOption(id: 'q6_c', text: 'Ucu açık ve beyin yakan', subtitle: 'Üzerine düşündüren', icon: 'psychology_alt', tags: ['bilim-kurgu', 'gizem', 'gerilim']),
          QuizOption(id: 'q6_d', text: 'Büyük bir şaşırtmaca (plot twist) ile', subtitle: 'Beklenmedik', icon: 'cyclone', tags: ['suç', 'polisiye', 'macera']),
        ],
      ),
      QuizQuestion(
        id: 'q7', question: 'Sosyal bir etkinlikte genelde hangi roldesin?',
        subtitle: 'Sosyal Dinamikler', icon: 'people', isWeekly: false,
        options: [
          QuizOption(id: 'q7_a', text: 'Eğlencenin merkezi', subtitle: 'Herkesi güldüren', icon: 'celebration', tags: ['sosyal', 'komedi', 'parti-oyunu']),
          QuizOption(id: 'q7_b', text: 'Plan yapan ve yöneten', subtitle: 'Programı ayarlayan', icon: 'edit_calendar', tags: ['strateji', 'liderlik', 'tarih']),
          QuizOption(id: 'q7_c', text: 'Köşede derin sohbet eden', subtitle: 'Birebir iletişim', icon: 'chat', tags: ['psikoloji', 'romantik', 'indie']),
          QuizOption(id: 'q7_d', text: 'Sadece izleyen', subtitle: 'Erken kalkan', icon: 'visibility', tags: ['solo-oyun', 'kitap', 'huzur']),
        ],
      ),
      QuizQuestion(
        id: 'q8', question: 'Ani bir kriz anında ilk tepkin ne olur?',
        subtitle: 'Stres Yönetimi', icon: 'warning', isWeekly: false,
        options: [
          QuizOption(id: 'q8_a', text: 'Duygusallaşır, destek ararım', subtitle: 'İçini dökmek', icon: 'support', tags: ['dram', 'romantik', 'aile']),
          QuizOption(id: 'q8_b', text: 'Adrenalinle harekete geçerim', subtitle: 'Risk alıp çözerim', icon: 'bolt', tags: ['aksiyon', 'macera', 'hayatta-kalma']),
          QuizOption(id: 'q8_c', text: 'Geri çekilir, mantıklı plan yaparım', subtitle: 'Analiz etmek', icon: 'analytics', tags: ['strateji', 'bulmaca', 'bilim-kurgu']),
          QuizOption(id: 'q8_d', text: 'Görmezden gelir, dikkatimi dağıtırım', subtitle: 'Uzaklaşmak', icon: 'flight_takeoff', tags: ['komedi', 'casual-oyun', 'fantezi']),
        ],
      ),
      QuizQuestion(
        id: 'q9', question: 'Yeni bir hobi edinecek olsan hangisini seçersin?',
        subtitle: 'İlgi Alanları', icon: 'palette', isWeekly: false,
        options: [
          QuizOption(id: 'q9_a', text: 'Ekstrem sporlar / Dövüş', subtitle: 'Hareket ve heyecan', icon: 'sports_martial_arts', tags: ['aksiyon', 'spor', 'rekabetçi']),
          QuizOption(id: 'q9_b', text: 'Karmaşık bir enstrüman / Satranç', subtitle: 'Zihinsel meydan okuma', icon: 'piano', tags: ['strateji', 'zeka', 'belgesel']),
          QuizOption(id: 'q9_c', text: 'Yaratıcı yazarlık / Resim', subtitle: 'Kendini ifade etme', icon: 'draw', tags: ['sanat', 'fantezi', 'indie']),
          QuizOption(id: 'q9_d', text: 'Yemek pişirme / Bahçecilik', subtitle: 'Üretmek ve huzur', icon: 'restaurant', tags: ['simülasyon', 'cozy', 'doğa']),
        ],
      ),
      QuizQuestion(
        id: 'q10', question: 'Bir oyunda yenildiğinde nasıl hissedersin?',
        subtitle: 'Rekabet & Tepki', icon: 'sports_esports', isWeekly: false,
        options: [
          QuizOption(id: 'q10_a', text: 'Hırslanır, kazanana kadar denerim', subtitle: 'Pes etmem', icon: 'emoji_events', tags: ['rekabetçi', 'souls-like', 'aksiyon']),
          QuizOption(id: 'q10_b', text: 'Sinirlenir, hemen bırakırım', subtitle: 'Sabırsız ve anlık', icon: 'mood_bad', tags: ['hızlı-tüketim', 'arcade']),
          QuizOption(id: 'q10_c', text: 'Hatamı analiz eder, strateji değiştiririm', subtitle: 'Mantıklı yaklaşım', icon: 'psychology', tags: ['strateji', 'bulmaca', 'tarih']),
          QuizOption(id: 'q10_d', text: 'Umursamam, benim için sadece eğlence', subtitle: 'Rahat tavır', icon: 'sentiment_satisfied', tags: ['casual', 'parti-oyunları', 'komedi']),
        ],
      ),
      QuizQuestion(
        id: 'q11', question: 'Zaman algın nasıldır?',
        subtitle: 'Geçmiş & Gelecek', icon: 'schedule', isWeekly: false,
        options: [
          QuizOption(id: 'q11_a', text: 'Anı yaşarım, geleceği dert etmem', subtitle: 'Carpe diem', icon: 'flame', tags: ['macera', 'indie', 'spontane']),
          QuizOption(id: 'q11_b', text: 'Geçmişin nostaljisini severim', subtitle: 'Romantik ve eski', icon: 'history', tags: ['tarih', 'romantik', 'retro']),
          QuizOption(id: 'q11_c', text: 'Geleceği adım adım planlarım', subtitle: 'Kontrolcü', icon: 'event', tags: ['bilim-kurgu', 'teknoloji', 'strateji']),
          QuizOption(id: 'q11_d', text: 'Sürekli olasılıkları sorgularım', subtitle: 'Felsefik', icon: 'all_inclusive', tags: ['felsefe', 'gizem', 'psikoloji']),
        ],
      ),
      QuizQuestion(
        id: 'q12', question: 'Birine hediye alırken neye dikkat edersin?',
        subtitle: 'Değer Yargıları', icon: 'card_giftcard', isWeekly: false,
        options: [
          QuizOption(id: 'q12_a', text: 'Pratik ve hayat kolaylaştıran bir şey', subtitle: 'Kullanışlı', icon: 'build', tags: ['teknoloji', 'pratik', 'gerçekçi']),
          QuizOption(id: 'q12_b', text: 'El yapımı veya manevi değeri olan', subtitle: 'Kişisel ve duyarlı', icon: 'favorite', tags: ['sanat', 'kişiselleştirilmiş', 'dram']),
          QuizOption(id: 'q12_c', text: 'Birlikte yapılacak eğlenceli bir aktivite', subtitle: 'Deneyim odaklı', icon: 'celebration', tags: ['deneyim', 'sosyal', 'macera']),
          QuizOption(id: 'q12_d', text: 'Bilindik ve kaliteli bir marka', subtitle: 'Garantili ve güvenli', icon: 'verified', tags: ['klasik', 'moda', 'popüler']),
        ],
      ),
    ];

List<QuizQuestion> _fallbackWeeklyQuestions() => [
      QuizQuestion(
        id: 'wq1', question: 'Bu hafta ne izlemek istiyorsun?',
        subtitle: 'Ruh haline göre seç', icon: 'tv', isWeekly: true,
        options: [
          QuizOption(id: 'wq1_a', text: 'Gerilim/korku bir şey', subtitle: 'Heyecan istiyorum', icon: 'bolt', tags: ['korku', 'gerilim']),
          QuizOption(id: 'wq1_b', text: 'Rahatlatıcı dizi', subtitle: 'Sakin bir şey', icon: 'self_improvement', tags: ['komedi', 'dram']),
          QuizOption(id: 'wq1_c', text: 'Aksiyon/macera', subtitle: 'Enerji istiyorum', icon: 'sports_martial_arts', tags: ['aksiyon', 'macera']),
          QuizOption(id: 'wq1_d', text: 'Belgesel/bilgi', subtitle: 'Öğrenmek istiyorum', icon: 'menu_book', tags: ['belgesel', 'tarih']),
        ],
      ),
      QuizQuestion(
        id: 'wq2', question: 'Bu hafta hangi oyun türünü seçersin?',
        subtitle: 'İçgüdüsel cevap', icon: 'sports_esports', isWeekly: true,
        options: [
          QuizOption(id: 'wq2_a', text: 'Strateji/bulmaca', subtitle: 'Beyin çalıştırmak', icon: 'psychology', tags: ['strateji', 'bulmaca']),
          QuizOption(id: 'wq2_b', text: 'RPG/hikaye odaklı', subtitle: 'Dünyaya dalmak', icon: 'auto_stories', tags: ['rpg']),
          QuizOption(id: 'wq2_c', text: 'Korku/hayatta kalma', subtitle: 'Heyecan aramak', icon: 'bolt', tags: ['korku-oyun']),
          QuizOption(id: 'wq2_d', text: 'Aksiyon/shooter', subtitle: 'Boşalmak için', icon: 'sports_martial_arts', tags: ['aksiyon-oyun']),
        ],
      ),
      QuizQuestion(
        id: 'wq3', question: 'Bu hafta nasıl geçti?',
        subtitle: 'Genel ruh halin', icon: 'psychology', isWeekly: true,
        options: [
          QuizOption(id: 'wq3_a', text: 'Yoğun ve stresli', subtitle: 'Gerilim hissediyorum', icon: 'bolt', tags: ['korku', 'gerilim']),
          QuizOption(id: 'wq3_b', text: 'Sakin ve huzurlu', subtitle: 'Dengede hissediyorum', icon: 'self_improvement', tags: ['kişisel-gelişim', 'psikoloji']),
          QuizOption(id: 'wq3_c', text: 'Enerjik ve verimli', subtitle: 'Bir şeyler başardım', icon: 'trending_up', tags: ['strateji', 'aksiyon']),
          QuizOption(id: 'wq3_d', text: 'Duygusal ve düşünceli', subtitle: 'İçe dönük hissediyorum', icon: 'favorite', tags: ['dram', 'psikoloji']),
        ],
      ),
      QuizQuestion(
        id: 'wq4', question: 'Bu hafta hangi kitabı seçerdin?',
        subtitle: 'Anlık tercih', icon: 'menu_book', isWeekly: true,
        options: [
          QuizOption(id: 'wq4_a', text: 'Gerilim/suç romanı', subtitle: 'Sayfa döndürmek', icon: 'search', tags: ['gerilim-kitap', 'suç-kitap']),
          QuizOption(id: 'wq4_b', text: 'Fantezi/macera', subtitle: 'Kaçmak istiyorum', icon: 'auto_awesome', tags: ['fantezi-kitap', 'macera-kitap']),
          QuizOption(id: 'wq4_c', text: 'Kişisel gelişim', subtitle: 'Kendimi geliştirmek', icon: 'trending_up', tags: ['kişisel-gelişim']),
          QuizOption(id: 'wq4_d', text: 'Tarih/biyografi', subtitle: 'Gerçek hikaye', icon: 'history_edu', tags: ['tarih-kitap', 'biyografi']),
        ],
      ),
      QuizQuestion(
        id: 'wq5', question: 'Bu hafta seni en iyi ne tanımlar?',
        subtitle: 'En yakın his', icon: 'person', isWeekly: true,
        options: [
          QuizOption(id: 'wq5_a', text: 'Meraklı & araştırmacı', subtitle: 'Yeni şeyler keşfettim', icon: 'explore', tags: ['bilim-kurgu', 'belgesel']),
          QuizOption(id: 'wq5_b', text: 'Duygusal & bağlantılı', subtitle: 'İnsanlarla vakit geçirdim', icon: 'favorite', tags: ['romantik', 'dram']),
          QuizOption(id: 'wq5_c', text: 'Rekabetçi & odaklı', subtitle: 'Hedefime yöneldim', icon: 'sports_martial_arts', tags: ['strateji', 'aksiyon-oyun']),
          QuizOption(id: 'wq5_d', text: 'Kaçış modunda', subtitle: 'Her şeyden uzaklaşmak istedim', icon: 'bolt', tags: ['korku', 'gerilim', 'fantezi']),
        ],
      ),
    ];
