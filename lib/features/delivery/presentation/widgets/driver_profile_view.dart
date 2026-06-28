import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_toastr.dart';
import '../../../../di/injection_container.dart';
import '../../../../core/auth/session_manager.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../profile/domain/repositories/user_repository.dart';
import '../bloc/delivery_state.dart';
import 'package:delievry_app/l10n/app_localizations.dart';
import '../../../../core/utils/data_localization_helper.dart';

class DriverProfileView extends StatelessWidget {
  final DeliveryLoaded state;

  const DriverProfileView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final driver = state.driver;
    final earnings = state.earnings;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Profile Details Header
          const SizedBox(height: 10),
          const CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=driver'),
            backgroundColor: Colors.white,
          ),
          const SizedBox(height: 12),
          Text(
            driver.name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            driver.email,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),

          // Statistics Summary
          _buildSectionHeader(context, AppLocalizations.of(context)?.performanceOverview ?? 'Performance Overview'),
          const SizedBox(height: 10),
          _buildStatisticsList(context, earnings),
          const SizedBox(height: 24),

          // Settings/Actions List
          _buildSectionHeader(context, AppLocalizations.of(context)?.accountSettings ?? 'Account Settings'),
          const SizedBox(height: 10),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline_rounded, color: AppColors.primary),
                  title: Text(AppLocalizations.of(context)?.editProfileDetails ?? 'Edit Profile Details'),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  onTap: () => _showEditProfileDialog(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.lock_outline_rounded, color: AppColors.primary),
                  title: Text(AppLocalizations.of(context)?.changePassword ?? 'Change Password'),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  onTap: () => _showChangePasswordDialog(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.logout_rounded, color: Colors.red),
                  title: Text(AppLocalizations.of(context)?.logout ?? 'Logout', style: const TextStyle(color: Colors.red)),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  onTap: () => _showLogoutConfirmation(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onBackground),
      ),
    );
  }

  Widget _buildStatisticsList(BuildContext context, Map<String, dynamic> earnings) {
    final todayPay = (earnings['today_earnings'] as num? ?? 0.0).toDouble();
    final weeklyPay = (earnings['weekly_earnings'] as num? ?? 0.0).toDouble();
    final monthlyPay = (earnings['monthly_earnings'] as num? ?? 0.0).toDouble();
    final totalPay = (earnings['total_earnings'] as num? ?? 0.0).toDouble();
    final totalDeliveries = earnings['total_deliveries'] ?? 0;
    final l = AppLocalizations.of(context);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatRow(l?.totalEarnings ?? 'Total Earnings', DataLocalizationHelper.formatCurrency(context, totalPay), Colors.green),
            const Divider(),
            _buildStatRow(l?.todayPayout ?? "Today's Payout", DataLocalizationHelper.formatCurrency(context, todayPay), Colors.green),
            const Divider(),
            _buildStatRow(l?.weeklyPayout ?? 'Weekly Payout', DataLocalizationHelper.formatCurrency(context, weeklyPay), Colors.green),
            const Divider(),
            _buildStatRow(l?.monthlyPayout ?? 'Monthly Payout', DataLocalizationHelper.formatCurrency(context, monthlyPay), Colors.green),
            const Divider(),
            _buildStatRow(l?.completedDeliveries ?? 'Completed Deliveries', l?.tripsCount(totalDeliveries) ?? (Localizations.localeOf(context).languageCode == 'ar' ? '${DataLocalizationHelper.formatNumber(context, totalDeliveries)} رحلات' : '$totalDeliveries Trips'), AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 16),
        ),
      ],
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: state.driver.name);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)?.editProfileDetails ?? 'Edit Profile Details'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: nameController,
            decoration: InputDecoration(labelText: AppLocalizations.of(context)?.fullName ?? 'Full Name'),
            validator: (v) => v == null || v.isEmpty ? AppLocalizations.of(context)?.requiredField ?? 'Required' : null,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel')),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                // In a real application, call profile update API. Here we just update local session
                sl<SessionManager>().setCurrentUser(
                  (state.driver as UserModel).copyWith(name: nameController.text),
                );
                Navigator.pop(ctx);
                context.showSuccessToast(
                  title: 'Profile Updated',
                  message: 'Profile updated successfully (locally)',
                );
              }
            },
            child: Text(AppLocalizations.of(context)?.save ?? 'Save'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)?.changePassword ?? 'Change Password'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(labelText: AppLocalizations.of(context)?.password ?? 'New Password'),
            validator: (v) => v == null || v.length < 8 ? 'Password must be at least 8 characters' : null,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel')),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx);
                context.showSuccessToast(
                  title: 'Password Updated',
                  message: 'Password updated successfully!',
                );
              }
            },
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)?.confirmLogout ?? 'Confirm Logout'),
        content: Text(AppLocalizations.of(context)?.logoutConfirmationText ?? 'Are you sure you want to log out of the Driver Panel?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel', style: const TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await sl<UserRepository>().logout();
              } catch (_) {}
              await sl<SessionManager>().clear();
              if (context.mounted) {
                context.go('/login');
              }
            },
            child: Text(AppLocalizations.of(context)?.logout ?? 'Logout', style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
