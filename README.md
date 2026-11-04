# 🎙️ SpeakUp AI - Trợ Lý AI Luyện Phát Âm Tiếng Anh Chuẩn Quốc Tế

> **Đồ án môn học:** Lập trình Thiết bị Di động (Mobile Programming) - Bài Thực Hành TH3  💎  
> **Nền tảng phát triển:** Flutter (Cross-platform: Android, iOS, Windows, macOS, Linux, Web)

---

## 🌟 Giới Thiệu Tổng Quan (Overview)

**SpeakUp AI** là ứng dụng di động thông minh hỗ trợ người học luyện tập và chuẩn hóa phát âm Tiếng Anh thông qua cơ chế phân tích âm vị học chuyên sâu (AI Phoneme Analysis). Ứng dụng được thiết kế nhằm giải quyết triệt để các rào cản và lỗi phát âm phổ biến nhất của người học Việt Nam:

- **Lỗi âm thổi hơi và âm rung:** Nhầm lẫn phụ âm `/θ/` và `/ð/` thành `/t/` hoặc `/d/` (ví dụ: *"think"* thành *"tink"*, *"this"* thành *"dis"*).
- **Nuốt âm đuôi (Dropped Ending Sounds):** Bỏ qua các phụ âm cuối quan trọng như `/s/`, `/z/`, `/t/`, `/d/`, `/ks/` (ví dụ: *"six desks"* bị đọc thành *"si desk"*).
- **Lẫn lộn nguyên âm dài và ngắn:** Cặp âm `/iː/` vs `/ɪ/`, `/uː/` vs `/ʊ/` (ví dụ: *"seat"* vs *"sit"*, *"sheep"* vs *"ship"*).
- **Cụm phụ âm phức tạp (Consonant Clusters):** Khó khăn khi phát âm các cụm như `str`, `spl`, `ŋks`...

Ứng dụng kết hợp cơ chế nhận diện giọng nói thời gian thực (Speech-to-Text), đọc phát âm mẫu bản xứ (Text-to-Speech), thuật toán AI bóc tách âm vị IPA, cùng kiến trúc dữ liệu kép Offline-First (SQLite) kết hợp Cloud Sync (Supabase PostgreSQL).

---

## 🚀 Các Tính Năng Nổi Bật (Key Features)

### 1. 🧠 Bộ Động Cơ Phân Tích Âm Vị Học AI (Phoneme Engine & IPA)
- **Bóc tách âm vị chi tiết (Phoneme-level decomposition):** Phân rã câu nói thành từng từ và từng âm vị IPA tương ứng để so sánh với phát âm chuẩn.
- **Hệ thống đánh giá 4 chiều chuẩn quốc tế:**
  - 🎯 **Overall Score (Điểm tổng thể):** Đánh giá mức độ hoàn thiện phát âm toàn câu theo thang điểm 100.
  - 🔍 **Accuracy Score (Độ chính xác):** Kiểm tra độ chuẩn xác của từng âm tiết, định vị chính xác vị trí bị phát âm sai lệch.
  - 🌊 **Fluency Score (Độ lưu loát):** Phản ánh nhịp điệu, tốc độ nói và tính liền mạch của câu nói.
  - 📏 **Completeness Score (Độ trọn vẹn):** Đánh giá việc nói đủ câu, phát hiện các từ hoặc âm đuôi bị nuốt hoặc bỏ sót.
- **Mã hóa màu trực quan (Color-coded Feedback):**
  - 🟢 **Xanh lá (Excellent - 85-100%):** Phát âm chuẩn xác, tròn vành rõ chữ.
  - 🟡 **Vàng (Acceptable - 60-84%):** Tương đối tốt nhưng còn lệch âm nhẹ hoặc chưa tự nhiên.
  - 🔴 **Đỏ (Needs Work - < 60%):** Phát âm sai âm vị hoặc nuốt âm nghiêm trọng.
- **Bảng Tra Cứu Âm Vị Chi Tiết (Phoneme Inspector Sheet):** Cho phép người học bấm trực tiếp vào từng từ để xem phân tích chi tiết: âm vị mục tiêu, âm vị phát hiện, phân loại nguyên âm/phụ âm, kèm chỉ dẫn khẩu hình môi, vị trí đặt lưỡi và hướng luồng hơi.

### 2. 🎤 Nhận Diện Giọng Nói & Đọc Mẫu Bản Xứ
- **Speech-to-Text (STT):** Thu âm trực tiếp qua microphone thiết bị với bộ lọc nhiễu và độ trễ cực thấp (`speech_to_text`).
- **Text-to-Speech (TTS):** Phát âm mẫu câu và từ với giọng đọc chuẩn bản xứ US/UK (`flutter_tts`) giúp người học nghe và nhại giọng (Shadowing).

### 3. 🧪 Phòng Thí Nghiệm AI Lab & Giả Lập Đa Ngữ Điệu (Checklist 7)
- **Bộ giả lập Voice Presets (Multi-accent Simulation):** Hỗ trợ kiểm thử và luyện tập qua nhiều tình huống:
  - 🎙️ *Thu âm trực tiếp bằng Micro*
  - 🇺🇸 *Giọng chuẩn Bản xứ (Native Speaker US)*
  - 🇻🇳 *Giọng người Việt (Lỗi âm /θ/, /ð/ -> /t/, /d/)*
  - ⚡ *Lỗi nuốt âm đuôi (Dropped Ending Sounds)*
  - 🔄 *Lỗi nhầm lẫn nguyên âm (/iː/ vs /ɪ/)*
- **Phòng Thí Nghiệm Benchmark Lab:** Màn hình chuyên dụng tự động chạy bộ test suite kiểm tra độ nhạy của thuật toán AI trên các kịch bản thực tế, xác minh ngưỡng điểm kỳ vọng (Score Thresholds).

### 4. 📚 Kho Bài Tập Chuyên Đề & Tự Nhập Câu Tự Do
- Kho bài tập biên soạn kỹ lưỡng theo các nhóm âm khó của người Việt: Âm Th (`think`, `weather`), Âm đuôi (`six desks`, `boxes`), Cụm phụ âm...
- Hỗ trợ **Tự thêm câu luyện tập**: Người dùng có thể nhập bất kỳ câu tiếng Anh nào mình muốn; AI sẽ tự động phân tích và tạo bài luyện tập tức thì.

### 5. 🔥 Duy Trì Thói Quen Học Tập & Streak (Checklist 2)
- **Chuỗi ngày học liên tục (Streak Flame Widget):** Hiển thị hoạt họa ngọn lửa rực sáng theo số ngày học liên tiếp.
- **Quy tắc tính Streak kỷ luật:** Chỉ cộng chuỗi khi hoàn thành mục tiêu ngày (tối thiểu 5 câu hoặc đạt đủ số phút/số câu quy định). Nếu gián đoạn học tập, hệ thống sẽ tự động cập nhật chính xác.
- **Cá nhân hóa học viên:** Thiết lập biệt danh, hình đại diện và cấp bậc (`PRO Scholar 💎`).

### 6. 📊 Trực Quan Hóa Tiến Độ Với Biểu Đồ (Checklist 3)
- Biểu đồ trực quan hóa dữ liệu tuần qua thư viện `fl_chart`.
- Thống kê chi tiết tổng số phút đã học, số câu hoàn thành, điểm trung bình qua từng ngày.
- Lưu trữ lịch sử tất cả các phiên luyện tập (Practice Sessions Log).

### 7. ⏰ Hệ Thống Nhắc Nhở Kỷ Luật (Checklist 6)
- Tích hợp bộ đếm thời gian thực (`NotificationService`).
- Hẹn giờ thông báo học tập hằng ngày giúp duy trì sự bền bỉ.

### 8. ☁️ Kiến Trúc Dữ Liệu Kép Hybrid (Checklist 1)
- **Offline-First SQLite:** Lưu trữ toàn bộ dữ liệu người dùng, bài tập, lịch sử học tập cục bộ trên thiết bị (`sqflite` cho Mobile, `sqflite_common_ffi` cho Windows/Linux).
- **Cloud Supabase PostgreSQL:** Đồng bộ dữ liệu lên đám mây với cơ chế bảo mật hàng ngang (Row Level Security - RLS). Cung cấp sẵn file `supabase_schema.sql`.

---

## 📋 Bảng Đối Chiếu Yêu Cầu Đồ Án (Checklist Compliance)

| Checklist | Yêu Cầu Chức Năng | Hiện Thực Trong Source Code | Minh Chứng Kiểm Thử (Unit / Widget Test) |
| :--- | :--- | :--- | :--- |
| **Checklist 1** | Quản lý Cơ sở dữ liệu (SQLite & Cloud Sync) | `DatabaseHelper`, `SupabaseService`, `supabase_schema.sql` | `test/database_checklist1_test.dart` (CRUD Users, Practice Sessions, Daily Stats) |
| **Checklist 2** | User Profile, Streak & Mục tiêu cá nhân | `UserProfile`, `StreakService`, `StreakFlameWidget` | `test/phoneme_and_streak_test.dart` (Serialization, Deserialization, CopyWith, Streak Logic) |
| **Checklist 3** | Giao diện hiện đại, Biểu đồ trực quan hóa | `ProgressScreen`, `fl_chart`, `CircularScoreIndicator`, Material 3 | Giao diện Responsive trên nhiều nền tảng, thiết kế hiện đại |
| **Checklist 4 & 5** | AI Phoneme Engine & Chấm điểm phát âm đa tiêu chí | `PhonemeEngine`, `WordFeedback`, `PhonemeInspectorSheet` | `test/phoneme_and_streak_test.dart` (IPA conversion, Error detection /θ/, Ending sounds) |
| **Checklist 6** | Kỷ luật, Nhắc nhở học tập thời gian thực | `NotificationService`, bộ đếm giờ thực tế, `SettingsScreen` | Khởi chạy timer đếm chu kỳ trong `main.dart` |
| **Checklist 7** | Multi-Accent Simulation & Benchmark Lab | `BenchmarkService`, `BenchmarkLabScreen`, Voice Presets trong `PracticeScreen` | `test/phoneme_and_streak_test.dart` (Suite 5 Benchmark test cases pass 100%) |

---

## 🏗️ Cấu Trúc Thư Mục Dự Án (Project Structure)

```
TH3_SpeakupAI/
├── android/                          # Cấu hình & native code Android
├── ios/                              # Cấu hình & native code iOS
├── windows/ & linux/ & macos/        # Cấu hình Desktop Runners
├── web/                              # Cấu hình Web platform
├── test/                             # Bộ kiểm thử tự động (Unit / Integration Tests)
│   ├── database_checklist1_test.dart # Kiểm thử toàn diện Cơ sở dữ liệu SQLite
│   ├── phoneme_and_streak_test.dart  # Kiểm thử AI Phoneme, Streak & Benchmark Lab
│   └── widget_test.dart              # Kiểm thử giao diện Flutter
├── supabase_schema.sql               # Script khởi tạo Database PostgreSQL trên Supabase
├── pubspec.yaml                      # Cấu hình dependencies và assets
└── lib/
    ├── main.dart                     # Điểm khởi chạy ứng dụng (App Entrypoint)
    ├── models/                       # Các Data Model chính
    │   ├── exercise.dart             # Mô hình bài tập luyện phát âm
    │   ├── practice_session.dart     # Mô hình phiên học và thời lượng
    │   ├── pronunciation_result.dart # Mô hình kết quả chấm điểm AI & phản hồi âm vị
    │   └── user_profile.dart         # Mô hình thông tin học viên, streak, mục tiêu
    ├── screens/                      # Giao diện màn hình ứng dụng
    │   ├── main_navigation_screen.dart # Thanh điều hướng chính (Bottom Navigation)
    │   ├── home_screen.dart          # Màn hình chính: Tổng quan, Streak, Danh sách bài
    │   ├── practice_screen.dart      # Màn hình luyện nói: Micro, STT, TTS, Presets
    │   ├── pronunciation_result_screen.dart # Màn hình kết quả phân tích AI chi tiết
    │   ├── progress_screen.dart      # Màn hình tiến độ, biểu đồ thống kê học tập
    │   ├── benchmark_lab_screen.dart # Phòng thí nghiệm AI Lab, kiểm thử tự động
    │   └── settings_screen.dart      # Cài đặt: Mục tiêu, nhắc nhở, đồng bộ Supabase
    ├── services/                     # Tầng nghiệp vụ xử lý logic và dữ liệu
    │   ├── phoneme_engine.dart       # Thuật toán AI phân tích âm vị học & IPA
    │   ├── exercise_repository.dart  # Kho lưu trữ bài tập mẫu & câu tự tạo
    │   ├── speech_service.dart       # Dịch vụ nhận diện giọng nói (STT)
    │   ├── tts_service.dart          # Dịch vụ phát âm mẫu chuẩn (TTS)
    │   ├── database_helper.dart      # Quản lý SQLite cục bộ (Offline Database)
    │   ├── supabase_service.dart     # Dịch vụ đồng bộ dữ liệu đám mây Supabase
    │   ├── supabase_config.dart      # Cấu hình URL và Anon Key kết nối Supabase
    │   ├── streak_service.dart       # Xử lý logic chuỗi ngày học liên tục (Streak)
    │   ├── notification_service.dart # Quản lý bộ hẹn giờ và nhắc nhở học tập
    │   └── benchmark_service.dart    # Quản lý các test case kiểm định chất giọng
    └── widgets/                      # Các thành phần giao diện dùng chung
        ├── circular_score_indicator.dart # Vòng tròn điểm số với gradient màu sắc
        ├── phoneme_inspector_sheet.dart  # Bảng tra cứu chi tiết âm vị học
        └── streak_flame_widget.dart      # Widget ngọn lửa biểu thị chuỗi Streak
```

---

## 🛠️ Công Nghệ & Thư Viện Sử Dụng (Tech Stack)

| Thư viện (Package) | Phiên bản | Vai trò & Mục đích sử dụng |
| :--- | :--- | :--- |
| **Flutter SDK** | `^3.13.4` | Framework chính phát triển ứng dụng di động đa nền tảng |
| **sqflite** & **sqflite_common_ffi** | `^2.4.5` | Cơ sở dữ liệu SQLite cục bộ (tương thích Mobile & Desktop) |
| **supabase_flutter** | `^2.18.3` | SDK kết nối cơ sở dữ liệu đám mây Supabase Cloud |
| **speech_to_text** | `^7.5.0` | Nhận diện giọng nói của người dùng qua Micro theo thời gian thực |
| **flutter_tts** | `^4.2.5` | Phát âm câu mẫu chuẩn bản xứ tiếng Anh (Text-to-Speech) |
| **fl_chart** | `^1.3.0` | Thư viện vẽ biểu đồ cột và đường trực quan hóa tiến độ học |
| **intl** | `^0.20.3` | Định dạng thời gian, xử lý ngày tháng chuẩn hóa |
| **permission_handler** | `^13.0.2` | Xử lý xin cấp quyền Microphone và thông báo hệ thống |
| **shared_preferences** | `^2.5.6` | Lưu trữ cấu hình ứng dụng nhẹ |

---

## 📥 Hướng Dẫn Cài Đặt & Khởi Chạy (Getting Started)

### 1. Yêu cầu môi trường (Prerequisites)
- Đã cài đặt [Flutter SDK](https://docs.flutter.dev/get-started/install) (phiên bản `>= 3.13.4`).
- Đã cài đặt Android Studio / Xcode / VS Code kèm Flutter Extension.
- Thiết bị thật hoặc máy ảo (Emulator/Simulator) có hỗ trợ Microphone.

### 2. Các bước cài đặt
1. **Clone repository về máy:**
   ```bash
   git clone <URL_REPOSITORY>
   cd TH3_SpeakupAI
   ```

2. **Cài đặt các gói phụ thuộc (Dependencies):**
   ```bash
   flutter pub get
   ```

3. **Cấu hình Cơ sở dữ liệu Supabase (Tùy chọn):**
   - Dự án đã tích hợp sẵn thông tin kết nối Supabase chính thức trong file:  
     `lib/services/supabase_config.dart`.
   - Nếu muốn triển khai cơ sở dữ liệu trên dự án Supabase cá nhân:
     1. Tạo dự án mới tại [supabase.com](https://supabase.com).
     2. Mở tab **SQL Editor** trên Supabase Dashboard và dán toàn bộ nội dung file `supabase_schema.sql` vào rồi nhấn **Run**.
     3. Cập nhật `supabaseUrl` và `supabaseAnonKey` tương ứng trong `lib/services/supabase_config.dart`.

4. **Chạy ứng dụng (Run App):**
   ```bash
   # Chạy trên thiết bị di động / máy ảo mặc định
   flutter run
   
   # Hoặc chạy trên Windows Desktop
   flutter run -d windows
   ```

5. **Chạy bộ kiểm thử tự động (Run Tests):**
   ```bash
   flutter test
   ```

---

## 👨‍💻 Thông Tin Dự Án & Tác Giả

- **Đồ án:** TH3 - Lập trình Thiết bị Di động (Mobile Programming)
- **Mục tiêu học tập hằng ngày:** 15 phút / ngày - 5 bài tập / ngày
- **Cấp bậc hiện tại:** `PRO Scholar 💎`
