import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../services/database_helper.dart';
import '../services/notification_service.dart';
import '../services/supabase_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  UserProfile? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() => _isLoading = true);
    final user = await DatabaseHelper.instance.getUserProfile();
    if (mounted) {
      setState(() {
        _user = user;
        _isLoading = false;
      });
    }
  }

  void _pickReminderTime() async {
    if (_user == null) return;
    final initial = TimeOfDay(
      hour: _user!.reminderHour,
      minute: _user!.reminderMinute,
    );
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      await NotificationService.instance.updateReminderSettings(
        enabled: _user!.reminderEnabled,
        hour: picked.hour,
        minute: picked.minute,
      );
      _loadUser();
      if (mounted) {
        final timeStr = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF4F46E5),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Đã cài đặt giờ nhắc nhở lúc $timeStr hàng ngày! Hệ thống sẽ tự động nhắc nhở khi đến giờ.',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }
  }

  void _toggleReminder(bool val) async {
    if (_user == null) return;
    await NotificationService.instance.updateReminderSettings(
      enabled: val,
      hour: _user!.reminderHour,
      minute: _user!.reminderMinute,
    );
    _loadUser();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: val ? const Color(0xFF10B981) : const Color(0xFF64748B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Text(
            val ? '🔔 Đã bật nhắc nhở luyện tập hàng ngày' : '🔕 Đã tắt nhắc nhở luyện tập',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      );
    }
  }

  void _triggerTestNotification() {
    NotificationService.instance.triggerScheduledReminder(user: _user, isTest: true);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final reminderTimeFormatted =
        '${_user!.reminderHour.toString().padLeft(2, '0')}:${_user!.reminderMinute.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Cài đặt & Hồ sơ cá nhân',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: const Color(0xFF1E293B),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Personalized User Profile Card (linhdontcare / LDC)
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E1B4B), Color(0xFF312E81)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF312E81).withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // LDC Monogram
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF818CF8), Color(0xFF4F46E5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4F46E5).withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _user!.nickname.isNotEmpty ? _user!.nickname : 'LDC',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 18),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _user!.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.25),
                            ),
                          ),
                          child: Text(
                            'Nickname: ${_user!.nickname} • ${_user!.level}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '🔥 Chuỗi hiện tại: ${_user!.currentStreak} ngày liên tiếp',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Notification / Daily Discipline Section
            const Text(
              'Kỷ luật & Nhắc nhở hàng ngày (Checklist 6):',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text(
                      'Nhắc nhở học tập hàng ngày',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      'Gửi thông báo nhắc ${_user!.nickname} giữ streak phát âm',
                      style: const TextStyle(fontSize: 12),
                    ),
                    value: _user!.reminderEnabled,
                    activeTrackColor: const Color(0xFF4F46E5),
                    onChanged: _toggleReminder,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.access_time,
                        color: Color(0xFF4F46E5),
                        size: 20,
                      ),
                    ),
                    title: const Text(
                      'Thời gian thông báo nhắc',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        reminderTimeFormatted,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4F46E5),
                          fontSize: 14,
                        ),
                      ),
                    ),
                    onTap: _pickReminderTime,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.notification_important,
                        color: Color(0xFFD97706),
                        size: 20,
                      ),
                    ),
                    title: const Text(
                      'Thử nghiệm thông báo ngay',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: const Text(
                      'Kiểm tra hiển thị banner thông báo nhắc nhở',
                      style: TextStyle(fontSize: 12),
                    ),
                    trailing: const Icon(
                      Icons.play_circle_outline,
                      color: Color(0xFFD97706),
                    ),
                    onTap: _triggerTestNotification,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Database & Cache management
            const Text(
              'Cơ sở dữ liệu người dùng (Checklist 1):',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: SupabaseService.instance.isInitialized
                            ? const Color(0xFFD1FAE5)
                            : const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.cloud_done_rounded,
                        color: SupabaseService.instance.isInitialized
                            ? const Color(0xFF10B981)
                            : const Color(0xFF4F46E5),
                        size: 20,
                      ),
                    ),
                    title: const Text(
                      'Hệ thống Cơ sở dữ liệu',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      SupabaseService.instance.isInitialized
                          ? 'Đã kết nối Supabase Cloud (PostgreSQL)'
                          : 'Đang dùng SQLite cục bộ (Sẵn sàng kết nối Supabase)',
                      style: TextStyle(
                        fontSize: 12,
                        color: SupabaseService.instance.isInitialized
                            ? const Color(0xFF047857)
                            : Colors.black54,
                        fontWeight: SupabaseService.instance.isInitialized
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: SupabaseService.instance.isInitialized
                            ? const Color(0xFFD1FAE5)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        SupabaseService.instance.isInitialized
                            ? 'SUPABASE'
                            : 'SQLITE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: SupabaseService.instance.isInitialized
                              ? const Color(0xFF065F46)
                              : Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.delete_sweep,
                        color: Color(0xFFEF4444),
                        size: 20,
                      ),
                    ),
                    title: const Text(
                      'Làm mới lại dữ liệu bài luyện',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: const Text(
                      'Xóa lịch sử và khôi phục về trạng thái khởi tạo',
                      style: TextStyle(fontSize: 12),
                    ),
                    onTap: () async {
                      await DatabaseHelper.instance.clearAllData();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Đã làm mới dữ liệu lịch sử luyện tập.',
                            ),
                          ),
                        );
                      }
                      _loadUser();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // App info
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'SpeakUp AI • Phiên bản 1.0.0 (Cá nhân hóa LDC)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF4F46E5),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Đồ án TH3: Xây dựng ứng dụng học tiếng Anh phân tích phát âm AI',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
