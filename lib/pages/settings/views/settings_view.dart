// lib/pages/settings/views/settings_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:receipt_keeper/components/appbar.dart';
import 'package:receipt_keeper/components/gap_extension.dart';
import 'package:receipt_keeper/components/loading.dart';
import 'package:receipt_keeper/components/mini_switch.dart';
import 'package:receipt_keeper/pages/settings/controllers/settings_controller.dart';
import 'package:receipt_keeper/utils/theme.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        appBar: const CustomAppBar(
          title: 'Pengaturan',
          theme: 'normal',
        ),
        body: controller.isLoading.value
            ? const LoadingPage()
            : SafeArea(
                child: RefreshIndicator(
                  onRefresh: controller.loadSettings,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      CareraTheme.paddingScaffold.left,
                      16,
                      CareraTheme.paddingScaffold.right,
                      24,
                    ),
                    children: [
                      _buildHeroCard(),
                      16.gap,
                      _buildPreferenceCard(
                        title: 'Keamanan & Garansi',
                        children: [
                          _buildSwitchTile(
                            icon: Icons.fingerprint_outlined,
                            title: 'Biometrik saat buka aplikasi',
                            subtitle:
                                'Aktifkan bila Anda ingin aplikasi mengikuti pengaturan biometrik saat dibuka.',
                            value: controller.biometricOnAppOpen.value,
                            onChanged: controller.toggleBiometric,
                          ),
                          _buildDivider(),
                          _buildValueTile(
                            icon: Icons.verified_outlined,
                            title: 'Durasi garansi default',
                            subtitle:
                                'Dipakai sebagai nilai awal saat Anda menandai item bergaransi.',
                            value: controller.defaultWarrantyLabel,
                            onTap: controller.selectDefaultWarrantyMonths,
                          ),
                        ],
                      ),
                      16.gap,
                      _buildPreferenceCard(
                        title: 'Notifikasi',
                        children: [
                          _buildSwitchTile(
                            icon: Icons.notifications_active_outlined,
                            title: 'Notifikasi garansi',
                            subtitle:
                                'Aktifkan pengingat global untuk fitur garansi.',
                            value: controller.notificationEnabled.value,
                            onChanged: controller.toggleNotificationEnabled,
                          ),
                          _buildDivider(),
                          _buildValueTile(
                            icon: Icons.schedule_outlined,
                            title: 'Pengingat awal',
                            subtitle: controller.notificationEnabled.value
                                ? 'Atur kapan pengingat pertama dikirim sebelum garansi habis.'
                                : 'Aktifkan notifikasi global dulu untuk memakai pengingat ini.',
                            value: 'H-${controller.warrantyReminderDays.value}',
                            onTap: controller.notificationEnabled.value
                                ? controller.selectWarrantyReminderDays
                                : null,
                          ),
                        ],
                      ),
                      16.gap,
                      _buildPreferenceCard(
                        title: 'Scan',
                        children: [
                          _buildSwitchTile(
                            icon: Icons.auto_fix_high_outlined,
                            title: 'OCR otomatis',
                            subtitle:
                                'Jika aktif, OCR langsung berjalan setelah gambar struk dipilih.',
                            value: controller.scanAutoProcessOcr.value,
                            onChanged: controller.toggleScanAutoProcessOcr,
                          ),
                          _buildDivider(),
                          _buildValueTile(
                            icon: Icons.photo_camera_back_outlined,
                            title: 'Sumber scan utama',
                            subtitle:
                                'Atur sumber yang paling sering Anda pakai saat scan struk.',
                            value: controller.scanPreferredSource.value ==
                                    'gallery'
                                ? 'Galeri'
                                : 'Kamera',
                            onTap: controller.selectPreferredSource,
                          ),
                        ],
                      ),
                      16.gap,
                      _buildPreferenceCard(
                        title: 'Aplikasi',
                        children: [
                          _buildValueTile(
                            icon: Icons.info_outline,
                            title: 'Versi aplikasi',
                            subtitle:
                                'Versi build yang sedang terpasang di perangkat Anda.',
                            value: SettingsController.appVersion,
                          ),
                          _buildDivider(),
                          _buildValueTile(
                            icon: Icons.workspace_premium_outlined,
                            title: 'Premium',
                            subtitle:
                                'Buka paket premium untuk fitur yang lebih leluasa.',
                            value: 'Lihat paket',
                            onTap: controller.openPremiumPage,
                          ),
                        ],
                      ),
                      16.gap,
                      _buildHelpCard(),
                    ],
                  ),
                ),
              ),
      );
    });
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            CareraTheme.turquoise20,
            CareraTheme.white,
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: CareraTheme.gray20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: CareraTheme.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: CareraTheme.gray20),
            ),
            child: Text(
              'Preferensi Aplikasi',
              style: AxataTextStyle.textSm.copyWith(
                fontWeight: FontWeight.w700,
                color: CareraTheme.mainColor,
              ),
            ),
          ),
          14.gap,
          Text(
            'Atur Receipt Keeper sesuai kebiasaan Anda',
            style: AxataTextStyle.textXl.copyWith(
              fontWeight: FontWeight.w700,
              color: CareraTheme.black,
              height: 1.25,
            ),
          ),
          8.gap,
          Text(
            'Semua pengaturan inti dirapikan di satu tempat agar lebih mudah dicek dan diubah.',
            style: AxataTextStyle.textSm.copyWith(
              color: CareraTheme.gray70,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CareraTheme.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: CareraTheme.gray20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AxataTextStyle.textBase.copyWith(
              fontWeight: FontWeight.w700,
              color: CareraTheme.black,
            ),
          ),
          12.gap,
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLeadingIcon(icon),
            12.wGap,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AxataTextStyle.textBase.copyWith(
                      fontWeight: FontWeight.w700,
                      color: CareraTheme.black,
                    ),
                  ),
                  4.gap,
                  Text(
                    subtitle,
                    style: AxataTextStyle.textSm.copyWith(
                      color: CareraTheme.gray70,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            12.wGap,
            MiniSwitch(
              value: value,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValueTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    VoidCallback? onTap,
  }) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLeadingIcon(icon),
          12.wGap,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AxataTextStyle.textBase.copyWith(
                    fontWeight: FontWeight.w700,
                    color: CareraTheme.black,
                  ),
                ),
                4.gap,
                Text(
                  subtitle,
                  style: AxataTextStyle.textSm.copyWith(
                    color: CareraTheme.gray70,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          12.wGap,
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: AxataTextStyle.textSm.copyWith(
                  color: CareraTheme.gray70,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (onTap != null) ...[
                6.wGap,
                const Icon(
                  Icons.chevron_right,
                  color: CareraTheme.gray50,
                  size: 20,
                ),
              ],
            ],
          ),
        ],
      ),
    );

    if (onTap == null) {
      return content;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: content,
    );
  }

  Widget _buildLeadingIcon(IconData icon) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: CareraTheme.gray5,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        icon,
        color: CareraTheme.mainColor,
        size: 21,
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Divider(
        height: 1,
        thickness: 1,
        color: CareraTheme.gray20,
      ),
    );
  }

  Widget _buildHelpCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CareraTheme.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: CareraTheme.gray20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bantuan Singkat',
            style: AxataTextStyle.textBase.copyWith(
              fontWeight: FontWeight.w700,
              color: CareraTheme.black,
            ),
          ),
          10.gap,
          _buildHelpPoint(
            'Scan struk dari kamera atau galeri, lalu cek hasil OCR sebelum simpan.',
          ),
          8.gap,
          _buildHelpPoint(
            'Tandai item bergaransi di detail struk agar mudah dipantau dari halaman garansi.',
          ),
          8.gap,
          _buildHelpPoint(
            'Gunakan export PDF saat butuh bukti pembelian untuk klaim atau arsip pribadi.',
          ),
        ],
      ),
    );
  }

  Widget _buildHelpPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Icon(
            Icons.check_circle_outline,
            size: 18,
            color: CareraTheme.mainColor,
          ),
        ),
        10.wGap,
        Expanded(
          child: Text(
            text,
            style: AxataTextStyle.textSm.copyWith(
              color: CareraTheme.gray70,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }
}
