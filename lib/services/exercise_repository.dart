import '../models/exercise.dart';
import 'phoneme_engine.dart';

class ExerciseRepository {
  // Danh sách các câu tự thêm của người dùng
  static final List<Exercise> _customExercises = [];

  static final List<Exercise> sampleExercises = [
    // 1. Phụ âm /θ/ và /ð/ (Th-sounds - lỗi số 1 của người học Việt Nam)
    const Exercise(
      id: 'th_01',
      category: 'Âm khó /θ/ & /ð/',
      title: 'Luyện âm Th thổi hơi',
      targetText: 'I think thirty three thousand people came to the theater',
      phoneticIpa: 'aɪ θɪŋk ˈθɜːti θriː ˈθaʊzənd ˈpiːpl keɪm tuː ðə ˈθɪətər',
      meaningVi: 'Tôi nghĩ ba mươi ba nghìn người đã đến nhà hát',
      difficulty: 'Medium',
      targetPhonemes: ['θ', 'ð'],
      pronunciationTip: 'Đặt đầu lưỡi giữa hai hàm răng, đẩy luồng hơi nhẹ ra ngoài cho âm /θ/. Không dùng âm /t/ hay /s/.',
    ),
    const Exercise(
      id: 'th_02',
      category: 'Âm khó /θ/ & /ð/',
      title: 'Âm Th rung (Voiced Th)',
      targetText: 'They thought that the weather was better together',
      phoneticIpa: 'ðeɪ θɔːt ðæt ðə ˈwɛðər wɒz ˈbɛtər təˈɡɛðər',
      meaningVi: 'Họ nghĩ rằng thời tiết tốt hơn khi ở bên nhau',
      difficulty: 'Hard',
      targetPhonemes: ['ð', 'θ'],
      pronunciationTip: 'Với âm /ð/ trong "they", "that", "weather", đặt lưỡi chạm răng cửa trên và làm rung dây thanh quản.',
    ),
    const Exercise(
      id: 'th_03',
      category: 'Âm khó /θ/ & /ð/',
      title: 'Âm Th trong cụm từ dài',
      targetText: 'Both my father and mother love breathing the fresh air',
      phoneticIpa: 'bəʊθ maɪ ˈfɑːðər ænd ˈmʌðər lʌv ˈbriːðɪŋ ðə frɛʃ eər',
      meaningVi: 'Cả bố và mẹ tôi đều thích hít thở bầu không khí trong lành',
      difficulty: 'Medium',
      targetPhonemes: ['θ', 'ð', 'eər'],
      pronunciationTip: 'Phân biệt "both" kết thúc bằng /θ/ thổi hơi nhẹ, còn "father", "mother", "breathing" là âm /ð/ rung.',
    ),
    const Exercise(
      id: 'th_04',
      category: 'Âm khó /θ/ & /ð/',
      title: 'Luyện câu số thứ tự & Th',
      targetText: 'The third Thursday of this month is Thanksgiving',
      phoneticIpa: 'ðə θɜːd ˈθɜːzdeɪ ɒv ðɪs mʌnθ ɪz ˌθæŋksˈɡɪvɪŋ',
      meaningVi: 'Ngày thứ Năm thứ ba của tháng này là Lễ Tạ Ơn',
      difficulty: 'Hard',
      targetPhonemes: ['θ', 'ð', 'ŋks'],
      pronunciationTip: 'Liên tiếp các âm /θ/ trong "third", "Thursday", "month", "Thanksgiving" đòi hỏi cơ lưỡi linh hoạt.',
    ),

    // 2. Ending Sounds (Âm đuôi - người Việt rất hay nuốt âm đuôi)
    const Exercise(
      id: 'end_01',
      category: 'Âm đuôi (Ending Sounds)',
      title: 'Âm đuôi /s/, /ks/, /t/',
      targetText: 'Six desks and five boxes are on the list',
      phoneticIpa: 'sɪks dɛsks ænd faɪv ˈbɒksɪz ɑːr ɒn ðə lɪst',
      meaningVi: 'Sáu cái bàn và năm cái hộp nằm trong danh sách',
      difficulty: 'Medium',
      targetPhonemes: ['ks', 'sks', 'z', 'st'],
      pronunciationTip: 'Phát âm rõ cụm phụ âm cuối: "desks" kết thúc bằng /sks/, "boxes" có âm /ɪz/, và "list" có /st/.',
    ),
    const Exercise(
      id: 'end_02',
      category: 'Âm đuôi (Ending Sounds)',
      title: 'Đuôi quá khứ -ed (/t/, /d/, /ɪd/)',
      targetText: 'She walked, decided to rest, and called her friend',
      phoneticIpa: 'ʃiː wɔːkt dɪˈsaɪdɪd tuː rɛst ænd kɔːld hɜːr frɛnd',
      meaningVi: 'Cô ấy đã đi bộ, quyết định nghỉ ngơi và đã gọi bạn mình',
      difficulty: 'Medium',
      targetPhonemes: ['kt', 'dɪd', 'ld', 'nd'],
      pronunciationTip: '"walked" phát âm /wɔːkt/, "decided" có đuôi /ɪd/, "called" có đuôi /d/.',
    ),
    const Exercise(
      id: 'end_03',
      category: 'Âm đuôi (Ending Sounds)',
      title: 'Cụm phụ âm đuôi /sks/ và /sts/',
      targetText: 'The host asks the guests to test their skills',
      phoneticIpa: 'ðə həʊst ɑːsks ðə ɡɛsts tuː tɛst ðeər skɪlz',
      meaningVi: 'Người dẫn chương trình yêu cầu các khách mời kiểm tra kỹ năng của họ',
      difficulty: 'Hard',
      targetPhonemes: ['st', 'sks', 'sts', 'lz'],
      pronunciationTip: 'Đừng nuốt âm đuôi: "host" (/st/), "asks" (/sks/), "guests" (/sts/). Giữ hơi để phát âm trọn vẹn.',
    ),
    const Exercise(
      id: 'end_04',
      category: 'Âm đuôi (Ending Sounds)',
      title: 'Âm đuôi bật /pt/ và /kst/',
      targetText: 'He accepted the project and fixed the text',
      phoneticIpa: 'hiː əkˈsɛptɪd ðə ˈprɒdʒɛkt ænd fɪkst ðə tɛkst',
      meaningVi: 'Anh ấy đã nhận dự án và sửa xong phần văn bản',
      difficulty: 'Medium',
      targetPhonemes: ['pt', 'kt', 'kst'],
      pronunciationTip: '"fixed" kết thúc bằng /kst/, "text" kết thúc bằng /kst/. Cần bật rõ âm /t/ sau /ks/.',
    ),

    // 3. Minimal Pairs (Cặp từ dễ nhầm lẫn)
    const Exercise(
      id: 'min_01',
      category: 'Cặp từ tối thiểu (Minimal Pairs)',
      title: 'Phân biệt Vowel /iː/ vs /ɪ/',
      targetText: 'Please sit in this seat and drink green tea',
      phoneticIpa: 'pliːz sɪt ɪn ðɪs siːt ænd drɪŋk ɡriːn tiː',
      meaningVi: 'Xin vui lòng ngồi vào chiếc ghế này và uống trà xanh',
      difficulty: 'Easy',
      targetPhonemes: ['iː', 'ɪ'],
      pronunciationTip: '/iː/ trong "seat" và "tea" là âm i dài căng mép cười; /ɪ/ trong "sit" là âm i ngắn thả lỏng cơ miệng.',
    ),
    const Exercise(
      id: 'min_02',
      category: 'Cặp từ tối thiểu (Minimal Pairs)',
      title: 'Phân biệt /ʃ/ và /s/',
      targetText: 'She sells sea shells on the sea shore',
      phoneticIpa: 'ʃiː sɛlz siː ʃɛlz ɒn ðə siː ʃɔːr',
      meaningVi: 'Cô ấy bán vỏ sò trên bờ biển',
      difficulty: 'Hard',
      targetPhonemes: ['ʃ', 's', 'z'],
      pronunciationTip: '/ʃ/ chu môi tròn như suỵt ai đó im lặng; /s/ kéo khóe môi sang hai bên như cười nhẹ.',
    ),
    const Exercise(
      id: 'min_03',
      category: 'Cặp từ tối thiểu (Minimal Pairs)',
      title: 'Phân biệt âm /p/ và /b/',
      targetText: 'Put the big black pen into the brown bag',
      phoneticIpa: 'pʊt ðə bɪɡ blæk pɛn ˈɪntuː ðə braʊn bæɡ',
      meaningVi: 'Hãy đặt cây bút mực đen lớn vào trong chiếc túi màu nâu',
      difficulty: 'Easy',
      targetPhonemes: ['p', 'b', 'æ', 'ɡ'],
      pronunciationTip: 'Âm /p/ là âm bật hơi không rung dây thanh quản; âm /b/ là âm rung môi dứt khoát.',
    ),
    const Exercise(
      id: 'min_04',
      category: 'Cặp từ tối thiểu (Minimal Pairs)',
      title: 'Phân biệt âm /l/ và /r/',
      targetText: 'Red lorries and yellow rollies drive around the lake',
      phoneticIpa: 'rɛd ˈlɒriz ænd ˈjɛləʊ ˈrəʊliz draɪv əˈraʊnd ðə leɪk',
      meaningVi: 'Những chiếc xe tải màu đỏ và xe lu màu vàng chạy vòng quanh hồ',
      difficulty: 'Hard',
      targetPhonemes: ['r', 'l', 'draɪv'],
      pronunciationTip: '/l/ đầu lưỡi chạm nướu răng trên; /r/ đầu lưỡi cong vào trong vòm họng và không chạm vào đâu.',
    ),

    // 4. Giao tiếp hàng ngày (Everyday Conversation)
    const Exercise(
      id: 'daily_01',
      category: 'Giao tiếp hàng ngày',
      title: 'Tự giới thiệu bản thân',
      targetText: 'Good morning, it is a great pleasure to meet you today',
      phoneticIpa: 'ɡʊd ˈmɔːnɪŋ ɪt ɪz ə ɡreɪt ˈplɛʒər tuː miːt juː təˈdeɪ',
      meaningVi: 'Chào buổi sáng, thật là một niềm vui lớn được gặp bạn hôm nay',
      difficulty: 'Easy',
      targetPhonemes: ['ɡ', 'ʒ', 't', 'd'],
      pronunciationTip: 'Chú ý âm /ʒ/ ở giữa từ "pleasure" phát âm rung mềm mại, và nối âm "it is a" -> /ɪt ɪz ə/.',
    ),
    const Exercise(
      id: 'daily_02',
      category: 'Giao tiếp hàng ngày',
      title: 'Hỏi thăm và chia sẻ',
      targetText: 'Could you please tell me how to get to the coffee shop?',
      phoneticIpa: 'kʊd juː pliːz tɛl miː haʊ tuː ɡɛt tuː ðə ˈkɒfi ʃɒp',
      meaningVi: 'Bạn có thể vui lòng chỉ cho tôi đường đến quán cà phê được không?',
      difficulty: 'Easy',
      targetPhonemes: ['kʊd', 'pl', 'ʃ'],
      pronunciationTip: '"Could you" có thể luyến nhẹ thành /kʊdʒuː/, âm cuối "shop" khép môi dứt khoát /p/.',
    ),
    const Exercise(
      id: 'daily_03',
      category: 'Giao tiếp hàng ngày',
      title: 'Gọi đồ uống tại quán cà phê',
      targetText: 'I would like an iced americano with extra milk, please',
      phoneticIpa: 'aɪ wʊd laɪk ən aɪst əˌmɛrɪˈkɑːnəʊ wɪð ˈɛkstrə mɪlk pliːz',
      meaningVi: 'Cho tôi một ly Americano đá với thêm sữa nhé',
      difficulty: 'Easy',
      targetPhonemes: ['aɪst', 'kstr', 'lk'],
      pronunciationTip: '"iced" kết thúc bằng /st/, nối âm "like an" -> /laɪk ən/, và "extra" bật rõ /kstr/.',
    ),
    const Exercise(
      id: 'daily_04',
      category: 'Giao tiếp hàng ngày',
      title: 'Hẹn giờ ăn trưa cùng đồng nghiệp',
      targetText: 'What time are you available to grab lunch together?',
      phoneticIpa: 'wɒt taɪm ɑːr juː əˈveɪləbl tuː ɡræb lʌntʃ təˈɡɛðər',
      meaningVi: 'Mấy giờ bạn rảnh để chúng mình cùng đi ăn trưa nhỉ?',
      difficulty: 'Easy',
      targetPhonemes: ['eɪləbl', 'tʃ', 'ðər'],
      pronunciationTip: '"available" trọng âm âm tiết 2: ə-VEI-lə-bl. Âm /tʃ/ trong "lunch" bật gọn gàng.',
    ),

    // 5. Tiếng Anh công sở & Công nghệ (Business & Tech)
    const Exercise(
      id: 'biz_01',
      category: 'Tiếng Anh Công sở & CNTT',
      title: 'Thảo luận tiến độ dự án',
      targetText: 'We need to optimize the database query to improve performance',
      phoneticIpa: 'wiː niːd tuː ˈɒptɪmaɪz ðə ˈdeɪtəbeɪs ˈkwɪəri tuː ɪmˈpruːv pəˈfɔːməns',
      meaningVi: 'Chúng ta cần tối ưu hóa truy vấn cơ sở dữ liệu để nâng cao hiệu năng',
      difficulty: 'Hard',
      targetPhonemes: ['ɒp', 'kw', 'pr', 'ns'],
      pronunciationTip: 'Nhấn trọng âm rõ từ: OP-ti-mize, DA-ta-base, im-PROVE, per-FOR-mance.',
    ),
    const Exercise(
      id: 'biz_02',
      category: 'Tiếng Anh Công sở & CNTT',
      title: 'Giao tiếp trong nhóm làm việc',
      targetText: 'Let us schedule a quick meeting to review the project status',
      phoneticIpa: 'lɛt ʌs ˈskɛdʒuːl ə kwɪk ˈmiːtɪŋ tuː rɪˈvjuː ðə ˈprɒdʒɛkt ˈsteɪtəs',
      meaningVi: 'Hãy lên lịch một cuộc họp nhanh để xem lại tình trạng dự án',
      difficulty: 'Medium',
      targetPhonemes: ['sk', 'dʒ', 'kw', 'vj'],
      pronunciationTip: '"schedule" phát âm US là /ˈskɛdʒuːl/, "status" là /ˈsteɪtəs/ hoặc /ˈstætəs/.',
    ),
    const Exercise(
      id: 'biz_03',
      category: 'Tiếng Anh Công sở & CNTT',
      title: 'Triển khai lên môi trường Production',
      targetText: 'We should deploy the updated version to the production server',
      phoneticIpa: 'wiː ʃʊd dɪˈplɔɪ ðə ʌpˈdeɪtɪd ˈvɜːʃn tuː ðə prəˈdʌkʃn ˈsɜːvər',
      meaningVi: 'Chúng ta nên triển khai phiên bản mới cập nhật lên máy chủ thực tế',
      difficulty: 'Hard',
      targetPhonemes: ['plɔɪ', 'vɜːʃn', 'kʃn'],
      pronunciationTip: 'Chú ý đuôi "-tion" trong "production" phát âm là /ʃn/ dứt khoát; "deploy" nhấn âm 2.',
    ),
    const Exercise(
      id: 'biz_04',
      category: 'Tiếng Anh Công sở & CNTT',
      title: 'Báo cáo chỉ số và hiệu suất',
      targetText: 'Our team will present the quarterly performance report tomorrow morning',
      phoneticIpa: 'ˈaʊər tiːm wɪl prɪˈzɛnt ðə ˈkwɔːtəli pəˈfɔːməns rɪˈpɔːt təˈmɒrəʊ ˈmɔːnɪŋ',
      meaningVi: 'Đội của chúng tôi sẽ thuyết trình báo cáo hiệu suất quý vào sáng mai',
      difficulty: 'Hard',
      targetPhonemes: ['zɛnt', 'kwɔː', 'pɔːt'],
      pronunciationTip: 'Động từ "present" nhấn âm 2 /prɪˈzɛnt/. "quarterly" phát âm rõ /ˈkwɔːtəli/.',
    ),
  ];

  // Danh sách toàn bộ bài tập (bao gồm cả câu người dùng tự thêm)
  static List<Exercise> get allExercises => [..._customExercises, ...sampleExercises];

  static List<String> get categories => [
        'Tất cả',
        if (_customExercises.isNotEmpty) 'Câu của tôi ✏️',
        'Âm khó /θ/ & /ð/',
        'Âm đuôi (Ending Sounds)',
        'Cặp từ tối thiểu (Minimal Pairs)',
        'Giao tiếp hàng ngày',
        'Tiếng Anh Công sở & CNTT',
      ];

  static List<Exercise> getByCategory(String category) {
    if (category == 'Tất cả') return allExercises;
    if (category == 'Câu của tôi ✏️') return _customExercises;
    return allExercises.where((e) => e.category == category).toList();
  }

  static Exercise getById(String id) {
    return allExercises.firstWhere(
      (e) => e.id == id,
      orElse: () => sampleExercises.first,
    );
  }

  // Phương thức tạo câu tự thêm của học viên với tự động phiên âm IPA
  static Exercise createCustomExercise({
    required String targetText,
    String? meaningVi,
    String difficulty = 'Medium',
  }) {
    final cleanText = targetText.trim();
    final words = cleanText.split(RegExp(r'\s+'));
    final ipaWords = words.map((w) {
      final cleanWord = w.replaceAll(RegExp(r'[^a-zA-Z]'), '').toLowerCase();
      return cleanWord.isNotEmpty ? PhonemeEngine.instance.wordToIpa(cleanWord) : '';
    }).where((s) => s.isNotEmpty).join(' ');

    final newExercise = Exercise(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      category: 'Câu của tôi ✏️',
      title: cleanText.length > 32 ? '${cleanText.substring(0, 30)}...' : cleanText,
      targetText: cleanText,
      phoneticIpa: ipaWords.isNotEmpty ? ipaWords : cleanText,
      meaningVi: (meaningVi != null && meaningVi.trim().isNotEmpty)
          ? meaningVi.trim()
          : 'Câu luyện tập tự tạo của học viên',
      difficulty: difficulty,
      targetPhonemes: const [],
      pronunciationTip: 'Luyện tập phát âm tự nhiên, ngắt nghỉ đúng cụm và nhấn rõ trọng âm câu.',
    );

    _customExercises.insert(0, newExercise);
    return newExercise;
  }
}
