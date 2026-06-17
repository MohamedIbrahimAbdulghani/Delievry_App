import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_toastr.dart';
import '../../../../di/injection_container.dart';
import '../../../../core/auth/session_manager.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../profile/domain/repositories/user_repository.dart';
import '../bloc/delivery_state.dart';

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
          _buildSectionHeader('Performance Overview'),
          const SizedBox(height: 10),
          _buildStatisticsList(earnings),
          const SizedBox(height: 24),

          // Settings/Actions List
          _buildSectionHeader('Account Settings'),
          const SizedBox(height: 10),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline_rounded, color: AppColors.primary),
                  title: const Text('Edit Profile Details'),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  onTap: () => _showEditProfileDialog(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.lock_outline_rounded, color: AppColors.primary),
                  title: const Text('Change Password'),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  onTap: () => _showChangePasswordDialog(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.logout_rounded, color: Colors.red),
                  title: const Text('Logout', style: TextStyle(color: Colors.red)),
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

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onBackground),
      ),
    );
  }

  Widget _buildStatisticsList(Map<String, dynamic> earnings) {
    final todayPay = earnings['today_earnings'] ?? 0.0;
    final weeklyPay = earnings['weekly_earnings'] ?? 0.0;
    final monthlyPay = earnings['monthly_earnings'] ?? 0.0;
    final totalPay = earnings['total_earnings'] ?? 0.0;
    final totalDeliveries = earnings['total_deliveries'] ?? 0;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatRow('Total Earnings', '\$${totalPay.toStringAsFixed(2)}', Colors.green),
            const Divider(),
            _buildStatRow('Today\'s Payout', '\$${todayPay.toStringAsFixed(2)}', Colors.green),
            const Divider(),
            _buildStatRow('Weekly Payout', '\$${weeklyPay.toStringAsFixed(2)}', Colors.green),
            const Divider(),
            _buildStatRow('Monthly Payout', '\$${monthlyPay.toStringAsFixed(2)}', Colors.green),
            const Divider(),
            _buildStatRow('Completed Deliveries', '$totalDeliveries Trips', AppColors.primary),
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
        title: const Text('Edit Profile Details'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Full Name'),
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
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
            child: const Text('Save'),
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
        title: const Text('Change Password'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'New Password'),
            validator: (v) => v == null || v.length < 8 ? 'Password must be at least 8 characters' : null,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
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
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out of the Driver Panel?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
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
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
