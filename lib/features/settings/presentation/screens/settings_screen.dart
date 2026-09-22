import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_top_bar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _db = DatabaseHelper.instance;
  
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _currencyCtrl = TextEditingController();
  
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    
    _nameCtrl.text = await _db.getSetting('restaurant_name') ?? '';
    _phoneCtrl.text = await _db.getSetting('restaurant_phone') ?? '';
    _addressCtrl.text = await _db.getSetting('restaurant_address') ?? '';
    _currencyCtrl.text = await _db.getSetting('currency') ?? AppStrings.currency;
    
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);
    
    await _db.setSetting('restaurant_name', _nameCtrl.text.trim());
    await _db.setSetting('restaurant_phone', _phoneCtrl.text.trim());
    await _db.setSetting('restaurant_address', _addressCtrl.text.trim());
    await _db.setSetting('currency', _currencyCtrl.text.trim());
    
    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.settingsSaved), backgroundColor: AppColors.success),
      );
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _currencyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(title: AppStrings.settingsTitle),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.space32),
              child: Align(
                alignment: Alignment.topRight,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ─── بيانات المطعم ─────────────────────────────────
                      Text(AppStrings.settingsRestaurant, style: AppTypography.titleLarge),
                      const SizedBox(height: AppDimensions.space16),
                      Container(
                        padding: const EdgeInsets.all(AppDimensions.space24),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildField(AppStrings.settingsRestaurantName, _nameCtrl),
                            const SizedBox(height: 16),
                            _buildField(AppStrings.settingsRestaurantPhone, _phoneCtrl),
                            const SizedBox(height: 16),
                            _buildField(AppStrings.settingsRestaurantAddress, _addressCtrl, maxLines: 2),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppDimensions.space32),
                      
                      // ─── إعدادات النظام ────────────────────────────────
                      Text(AppStrings.settingsSystem, style: AppTypography.titleLarge),
                      const SizedBox(height: AppDimensions.space16),
                      Container(
                        padding: const EdgeInsets.all(AppDimensions.space24),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildField(AppStrings.settingsCurrency, _currencyCtrl),
                            const SizedBox(height: 16),
                            Text('سيتم تطبيق التغييرات في النظام بالكامل. برجاء إعادة تشغيل التطبيق في حالة تغيير العملة.', style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: AppDimensions.space32),
                      
                      // زر الحفظ
                      SizedBox(
                        width: 200,
                        height: AppDimensions.buttonHeightLg,
                        child: ElevatedButton.icon(
                          onPressed: _isSaving ? null : _saveSettings,
                          icon: _isSaving 
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.save_rounded),
                          label: Text(AppStrings.btnSave, style: AppTypography.button),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: AppTypography.bodyMedium,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surfaceVariant,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusSm), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }
}
