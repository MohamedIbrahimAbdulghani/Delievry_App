import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/shimmer_skeletons.dart';
import '../../../../di/injection_container.dart';
import '../../../home/presentation/bloc/home_bloc.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../favorites/presentation/bloc/favorites_bloc.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late ProfileBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = sl<ProfileBloc>()..add(FetchProfile());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _bloc,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text('My Profile', style: TextStyle(color: AppColors.onBackground, fontWeight: FontWeight.bold)),
        ),
        body: BlocConsumer<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state is LogoutSuccess) {
              // بنمسح الـ Singletons بتاعة الـ Blocs عشان بيانات المستخدم القديم متبقاش متسربة للمستخدم الجديد
              sl.resetLazySingleton<HomeBloc>();
              sl.resetLazySingleton<CartBloc>();
              sl.resetLazySingleton<FavoritesBloc>();
              context.go('/login');
            }
          },
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const ProfileSkeleton();
            } else if (state is ProfileLoaded) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    _buildUserHeader(state.user),
                    const SizedBox(height: 24),
                    _buildMenuSection(),
                  ],
                ),
              );
            } else if (state is ProfileError) {
              return Center(child: Text(state.message));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildUserHeader(dynamic user) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: user.imageUrl != null ? NetworkImage(user.imageUrl) : null,
            child: user.imageUrl == null ? const Icon(Icons.person, size: 40) : null,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                Text(user.email, style: const TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.primary),
            onPressed: () => context.push('/edit-profile'),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          _buildMenuTile(Icons.location_on_outlined, 'Delivery Addresses', () => context.push('/addresses')),
          _buildMenuTile(Icons.receipt_long_outlined, 'My Orders', () => context.push('/orders')),
          _buildMenuTile(Icons.favorite_border_outlined, 'Favorites', () => context.push('/favorites')),
          _buildMenuTile(Icons.payment_outlined, 'Payment Methods', () {}),
          _buildMenuTile(Icons.notifications_none_outlined, 'Notifications', () => context.push('/notifications')),
          _buildMenuTile(Icons.settings_outlined, 'Settings', () {}),
          _buildMenuTile(Icons.help_outline, 'Help & Support', () {}),
          const Divider(height: 1),
          _buildMenuTile(Icons.logout, 'Logout', () => _bloc.add(LogoutEvent()), isDestructive: true),
        ],
      ),
    );
  }

  Widget _buildMenuTile(IconData icon, String title, VoidCallback onTap, {bool isDestructive = false}) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: isDestructive ? AppColors.error : AppColors.onBackground),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? AppColors.error : AppColors.onBackground,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, size: 20),
    );
  }
}
