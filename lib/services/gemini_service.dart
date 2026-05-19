import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/quiz_question.dart';
import '../models/analysis_data.dart';

class GeminiService {
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';

  late final Dio _dio;
  late final String _apiKey;

  GeminiService() {
    _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
    ));
  }

  Future<String> _generate(String prompt) async {
    try {
      final response = await _dio.post(
        '$_baseUrl?key=$_apiKey',
        data: {
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 4096,
          }
        },
      );

      final candidates = response.data['candidates'] as List<dynamic>;
      if (candidates.isEmpty) throw Exception('Gemini: Boş yanıt');

      final content = candidates[0]['content'] as Map<String, dynamic>;
      final parts = content['parts'] as List<dynamic>;
      return (parts[0]['text'] as String).trim();
    } on DioException catch (e) {
      throw Exception('Gemini API hatası: ${e.message}');
    }
  }

  String _extractJson(String text) {
    // Markdown code block varsa temizle
    final cleaned = text.replaceAll('```json', '').replaceAll('```', '').trim();
    final jsonStart = cleaned.indexOf('[');
    final jsonEnd = cleaned.lastIndexOf(']');
    if (jsonStart != -1 && jsonEnd != -1) {
      return cleaned.substring(jsonStart, jsonEnd + 1);
    }
    final objStart = cleaned.indexOf('{');
    final objEnd = cleaned.lastIndexOf('}');
    if (objStart != -1 && objEnd != -1) {
      return cleaned.substring(objStart, objEnd + 1);
    }
    return cleaned;
  }

  // ─── ONBOARDING SORULARI (12 Soru, 4 Seçenek) ──────────────────────────

  Future<List<QuizQuestion>> generateOnboardingQuestions() async {
    final randomSeed = DateTime.now().millisecondsSinceEpoch;
    final prompt = '''
Sen yaratıcı bir psikolog ve profil analistisin. Kullanıcının NET film, dizi, oyun, kitap ve ALIŞVERİŞ tercihlerini doğru analiz edebilmek için 12 adet Türkçe SENARYO BAZLI soru üret.

KURALLAR (ÇOK ÖNEMLİ):
1. "Hangi filmi seversin?", "Nelerden hoşlanırsın?" gibi DİREKT SORULAR YASAK! 
2. Sorular tamamen YARATICI SENARYOLAR, PSİKOLOJİK İKİLEMLER veya HİKAYELER olmalı. (Örn: "Bir zombi istilasında nereye saklanırsın?", "Sınırsız paran olsa ilk ne satın alırsın?", "Zaman makinesi buldun nereye gidersin?")
3. Her soru için TAM OLARAK 4 seçenek olmalı.
4. Rastgelelik Tohumu: $randomSeed (Her defasında birbirinden tamamen farklı, çılgın senaryolar bul, asla önceki anketlere benzemesin).
5. 12 sorunun gizli dağılımı şu şekilde olmalı:
   - 3 soru: Film/Dizi zevkini (korku, komedi, fantezi vb.) ölçen senaryolar.
   - 3 soru: Oyun zevkini (strateji, aksiyon, rpg vb.) ölçen karar anları.
   - 3 soru: Kitap/Okuma zevkini (psikoloji, bilim-kurgu, tarih vb.) ölçen atmosferler.
   - 3 soru: Alışveriş/Tüketim tarzını (teknoloji mi, giyim mi, aksesuar mı) ölçen yaşam tarzı veya hayatta kalma ikilemleri.

Kullanılabilecek NET Etiketler (Her seçeneğe en uygun 2-3 tanesini koy):
Film/Dizi: korku, gerilim, aksiyon, macera, bilim-kurgu, fantezi, dram, romantik, komedi, belgesel, suç, gizem, tarih
Oyun: strateji, rpg, aksiyon-oyun, korku-oyun, bulmaca, simülasyon, spor-oyun, indie
Kitap: psikoloji, felsefe, gerilim-kitap, korku-kitap, fantezi-kitap, bilim-kurgu-kitap, romantik-kitap, tarih-kitap, kişisel-gelişim
Alışveriş: shopping-tech (elektronik), shopping-fashion (kıyafet), shopping-jewelery (takı/aksesuar)

JSON formatında SADECE şunu döndür, JSON harici HİÇBİR şey yazma:
[
  {
    "id": "q1",
    "question": "Senaryo bazlı soru metni",
    "subtitle": "Kısa alt başlık",
    "icon": "material_icon_adı",
    "options": [
      {"id": "q1_a", "text": "Seçenek metni", "subtitle": "Açıklama", "icon": "icon", "tags": ["etiket1", "etiket2"]},
      {"id": "q1_b", "text": "Seçenek metni", "subtitle": "Açıklama", "icon": "icon", "tags": ["etiket1"]},
      {"id": "q1_c", "text": "Seçenek metni", "subtitle": "Açıklama", "icon": "icon", "tags": ["etiket1", "etiket2"]},
      {"id": "q1_d", "text": "Seçenek metni", "subtitle": "Açıklama", "icon": "icon", "tags": ["etiket1"]}
    ]
  }
]''';

    final text = await _generate(prompt);
    final jsonStr = _extractJson(text);
    final List<dynamic> data = jsonDecode(jsonStr);
    return data
        .map((e) => QuizQuestion.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ─── HAFTALIK SORULAR ────────────────────────────────────────────────────

  Future<List<QuizQuestion>> generateWeeklyQuestions(
      List<String> existingTags) async {
    final tagsStr = existingTags.take(15).join(', ');
    final randomSeed = DateTime.now().millisecondsSinceEpoch;
    final prompt = '''
Kullanıcının mevcut ilgi profili: $tagsStr

Bu profile göre, kullanıcının o anki ruh halini ve güncel tercihlerini anlamak için 5 YENİ ve YARATICI SENARYO BAZLI Türkçe soru üret.
LÜTFEN SIRADAN SORULARI TEKRAR ETME. "Hangi filmi izlersin", "Nasıl hissedersin" gibi doğrudan sorular YASAK.
Sadece fantastik veya gerçeküstü senaryolar, ilginç yaşam ikilemleri sor. (Örn: "Bir uzay gemisi kapına inse yanına alacağın ilk eşya?", "Sadece tek bir renk olan evrende hangi renk olurdun?")
Rastgelelik Tohumu: $randomSeed (Asla geçmiş testlerle aynı senaryoyu üretme)

Kullanılabilecek Etiketler:
Film/Dizi: korku, gerilim, aksiyon, macera, bilim-kurgu, fantezi, dram, komedi
Oyun: strateji, rpg, aksiyon-oyun, korku-oyun, bulmaca, simülasyon
Kitap: psikoloji, gerilim-kitap, fantezi-kitap, kişisel-gelişim
Alışveriş: shopping-tech, shopping-fashion, shopping-jewelery

JSON formatında SADECE şunu döndür:
[
  {
    "id": "wq1",
    "question": "Soru metni",
    "subtitle": "Alt başlık",
    "icon": "material_icon_adı",
    "isWeekly": true,
    "options": [
      {"id": "wq1_a", "text": "Seçenek", "subtitle": "Açıklama", "icon": "icon", "tags": ["etiket1", "etiket2"]},
      {"id": "wq1_b", "text": "Seçenek", "subtitle": "Açıklama", "icon": "icon", "tags": ["etiket1"]},
      {"id": "wq1_c", "text": "Seçenek", "subtitle": "Açıklama", "icon": "icon", "tags": ["etiket1"]},
      {"id": "wq1_d", "text": "Seçenek", "subtitle": "Açıklama", "icon": "icon", "tags": ["etiket1"]}
    ]
  }
]''';

    final text = await _generate(prompt);
    final jsonStr = _extractJson(text);
    final List<dynamic> data = jsonDecode(jsonStr);
    return data
        .map((e) => QuizQuestion.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ─── KULLANICI PROFİLİ OLUŞTUR ───────────────────────────────────────────

  Future<Map<String, dynamic>> buildUserProfile(
      List<Map<String, dynamic>> questionAnswers,
      int? age,
      String? zodiacSign) async {
    final answersStr = questionAnswers
        .map((qa) =>
            'Soru: ${qa['question']}\nCevap: ${qa['answer']}\nEtiketler: ${(qa['tags'] as List).join(', ')}')
        .join('\n\n');

    final prompt = '''
Kullanıcının Yaşı: ${age ?? 'Bilinmiyor'}
Kullanıcının Burcu: ${zodiacSign ?? 'Bilinmiyor'}

Kullanıcının soru-cevap geçmişi:
$answersStr

Bu cevaplara, kullanıcının yaşına ve burcuna dayanarak içerik tercihlerini ve psikolojik profilini analiz et. Yaşına uygun oyun/film türleri ve burcunun karakteristik özelliklerine uygun etiketler üretmeye özen göster.

ÖNEMLİ: movieGenres, gameGenres ve bookTopics alanları, kullanıcının cevaplarından DOĞRUDAN çıkarılmalı.
Örneğin kullanıcı "korku", "gerilim" cevapladıysa movieGenres = ["korku", "gerilim"] olmalı, asla "romantik" koymamalısın.

Aşağıdaki JSON formatında SADECE döndür:
{
  "tags": ["etiket1", "etiket2", "etiket3", "etiket4", "etiket5"],
  "archetypeLabel": "Türkçe karakter tipi (örn: Gerilim Avcısı, Strateji Dehası, Macera Sever)",
  "archetypeSummary": "2-3 cümlelik Türkçe kişilik özeti",
  "movieGenres": ["korku", "gerilim"],
  "gameGenres": ["strateji", "rpg"],
  "bookTopics": ["psikoloji", "gerilim-kitap"]
}

movieGenres için kullanılabilecek değerler: korku, gerilim, aksiyon, macera, bilim-kurgu, fantezi, dram, romantik, komedi, animasyon, belgesel, suç, gizem, tarih, savaş
gameGenres için: strateji, rpg, aksiyon-oyun, korku-oyun, bulmaca, simülasyon, spor-oyun, indie, macera-oyun
bookTopics için: psikoloji, felsefe, gerilim-kitap, korku-kitap, fantezi-kitap, bilim-kurgu-kitap, romantik-kitap, tarih-kitap, biyografi, kişisel-gelişim, macera-kitap, suç-kitap

SADECE JSON döndür.''';

    final text = await _generate(prompt);
    final jsonStr = _extractJson(text);
    return jsonDecode(jsonStr) as Map<String, dynamic>;
  }

  // ─── ANALİZ EKRANI ────────────────────────────────────────────────────────

  Future<AnalysisData> generateAnalysis(
      List<Map<String, dynamic>> allAnswers, List<String> tags) async {
    final tagsStr = tags.join(', ');
    final answersStr = allAnswers
        .take(20)
        .map((qa) => '${qa['question']}: ${qa['answer']}')
        .join('\n');

    final prompt = '''
Sen uzman bir psikolog ve içerik danışmanısın. Kullanıcının verdiği cevaplar ve profil etiketleri doğrultusunda GERÇEKÇİ, tamamen kişiselleştirilmiş ve her seferinde farklılaşan bir analiz üret.
Lütfen standart veya kalıplaşmış metinler KULLANMA. Kullanıcının tam olarak ne hissettiğini ve neye ihtiyacı olduğunu yansıtan bir yorum yap.

Kullanıcı profil etiketleri: $tagsStr

Kullanıcının testteki cevap geçmişi:
$answersStr

JSON formatında SADECE şunu döndür:
{
  "dimensions": [
    {"label": "Odaklanma İhtiyacı", "value": 75, "color": "#E5EEFF"},
    {"label": "Yaratıcı Enerji", "value": 84, "color": "#D2BFE7"},
    {"label": "Duygusal Derinlik", "value": 90, "color": "#CEF7DE"},
    {"label": "Macera Arzusu", "value": 55, "color": "#A9C9F3"},
    {"label": "Kaçış/Huzur", "value": 88, "color": "#D2BFE7"}
  ],
  "insight": "Kullanıcının cevaplarına dayalı, ona özel, tamamen benzersiz ve biraz derinlikli 3-4 cümlelik Türkçe psikolojik içgörü metni.",
  "quickTip": "Kullanıcının şu anki ruh haline uygun, ona özel pratik bir iyileştirme/izleme önerisi.",
  "archetypeLabel": "Kişilik etiketi (Örn: Melankolik Gezgin, Adrenalin Tutkunu vb.)",
  "insightTags": ["Etiket1", "Etiket2", "Etiket3"]
}

value değerlerini (0-100) kullanıcının cevaplarının tonuna göre hesapla. SADECE JSON döndür.''';

    final text = await _generate(prompt);
    final jsonStr = _extractJson(text);
    final data = jsonDecode(jsonStr) as Map<String, dynamic>;
    return AnalysisData.fromJson(data);
  }



  // ─── TAG → TMDB GENRE ID MAPPING ─────────────────────────────────────────
  // Kullanıcının hem genel interestTags hem de movieGenres'i kullanılır

  List<int> tagsToTmdbGenreIds(List<String> tags) {
    const mapping = <String, int>{
      // Film/dizi türleri (TMDB ID)
      'aksiyon': 28,
      'macera': 12,
      'animasyon': 16,
      'komedi': 35,
      'suç': 80,
      'belgesel': 99,
      'drama': 18,
      'dram': 18,
      'fantezi': 14,
      'aile': 10751,
      'tarih': 36,
      'korku': 27,
      'müzik': 10402,
      'gizem': 9648,
      'romantik': 10749,
      'bilim-kurgu': 878,
      'gerilim': 53,
      'savaş': 10752,
      // aliases
      'thriller': 53,
      'horror': 27,
      'sci-fi': 878,
      'romance': 10749,
      'mystery': 9648,
      'crime': 80,
    };

    final ids = <int>{};
    for (final tag in tags) {
      final id = mapping[tag.toLowerCase()];
      if (id != null) ids.add(id);
    }
    return ids.take(3).toList();
  }

  // ─── TAG → BOOK SUBJECT ───────────────────────────────────────────────────

  String tagsToBookSubjects(List<String> tags) {
    const mapping = <String, String>{
      'psikoloji': 'psychology',
      'felsefe': 'philosophy',
      'strateji': 'strategy',
      'bilim': 'science',
      'tarih': 'history',
      'tarih-kitap': 'history',
      'fantezi': 'fantasy',
      'fantezi-kitap': 'fantasy',
      'bilim-kurgu': 'science+fiction',
      'bilim-kurgu-kitap': 'science+fiction',
      'gizem': 'mystery',
      'gerilim': 'thriller',
      'gerilim-kitap': 'thriller',
      'romantik': 'romance',
      'romantik-kitap': 'romance',
      'korku': 'horror',
      'korku-kitap': 'horror',
      'macera': 'adventure',
      'macera-kitap': 'adventure',
      'biyografi': 'biography',
      'kişisel-gelişim': 'self+help',
      'kişisel gelişim': 'self+help',
      'maneviyat': 'spirituality',
      'huzur': 'mindfulness',
      'suç': 'crime+fiction',
      'suç-kitap': 'crime+fiction',
    };

    // İlk eşleşen tag'ı kullan (önce bookTopics, sonra genel tags)
    for (final tag in tags) {
      final subject = mapping[tag.toLowerCase()];
      if (subject != null) return subject;
    }
    return 'fiction';
  }

  // ─── TAG → GAME GENRE ─────────────────────────────────────────────────────

  String tagsToGameGenres(List<String> tags) {
    const mapping = <String, String>{
      'strateji': 'strategy',
      'macera': 'adventure',
      'macera-oyun': 'adventure',
      'aksiyon': 'action',
      'aksiyon-oyun': 'action',
      'rpg': 'role-playing-games-rpg',
      'korku': 'action', // RAWG'da korku = action kategorisinde
      'korku-oyun': 'action',
      'bulmaca': 'puzzle',
      'spor': 'sports',
      'spor-oyun': 'sports',
      'yarış': 'racing',
      'simülasyon': 'simulation',
      'indie': 'indie',
      'savaş-oyun': 'shooter',
      'gizem': 'puzzle',
    };

    for (final tag in tags) {
      final genre = mapping[tag.toLowerCase()];
      if (genre != null) return genre;
    }
    return 'action';
  }

  // ─── ÇOKLU GAME GENRE ─────────────────────────────────────────────────────

  List<String> tagsToMultipleGameGenres(List<String> tags) {
    const mapping = <String, String>{
      'strateji': 'strategy',
      'macera': 'adventure',
      'macera-oyun': 'adventure',
      'aksiyon': 'action',
      'aksiyon-oyun': 'action',
      'rpg': 'role-playing-games-rpg',
      'korku':
          'action', // RAWG has no horror genre, it's a tag. We use action/adventure for horror-like games.
      'korku-oyun': 'action',
      'gerilim': 'action',
      'bulmaca': 'puzzle',
      'gizem': 'puzzle',
      'spor': 'sports',
      'spor-oyun': 'sports',
      'yarış': 'racing',
      'simülasyon': 'simulation',
      'indie': 'indie',
      'savaş': 'shooter',
      'savaş-oyun': 'shooter',
      'aile': 'family',
      'eğlence': 'casual',
      'komedi': 'indie',
    };

    final genres = <String>{};
    for (final tag in tags) {
      final genre = mapping[tag.toLowerCase()];
      if (genre != null) genres.add(genre);
    }
    return genres.take(3).toList();
  }
}
