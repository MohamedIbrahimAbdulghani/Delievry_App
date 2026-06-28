import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/shimmer_skeletons.dart';
import '../../../../di/injection_container.dart';
import '../../../home/presentation/bloc/home_bloc.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../favorites/presentation/bloc/favorites_bloc.dart';
import '../../../home/presentation/bloc/home_event.dart';
import '../../../cart/presentation/bloc/cart_event.dart';
import '../../../favorites/presentation/bloc/favorites_event.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/settings/presentation/bloc/settings_cubit.dart';
import '../../../../core/settings/presentation/bloc/settings_state.dart';

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
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          elevation: 0,
          title: Text(AppLocalizations.of(context)!.profile, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
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
                    _buildUserHeader(context, state.user),
                    const SizedBox(height: 24),
                    _buildMenuSection(context),
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

  Widget _buildUserHeader(BuildContext context, dynamic user) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
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
                Text(user.name, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                Text(user.email, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
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

  Widget _buildMenuSection(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          _buildMenuTile(context, Icons.location_on_outlined, AppLocalizations.of(context)?.deliveryAddresses ?? 'Delivery Addresses', () => context.push('/addresses')),
          _buildMenuTile(context, Icons.receipt_long_outlined, AppLocalizations.of(context)?.myOrders ?? 'My Orders', () => context.push('/orders')),
          _buildMenuTile(context, Icons.favorite_border_outlined, AppLocalizations.of(context)?.favorites ?? 'Favorites', () => context.push('/favorites')),
          _buildMenuTile(context, Icons.payment_outlined, AppLocalizations.of(context)?.paymentMethods ?? 'Payment Methods', () {}),
          _buildMenuTile(context, Icons.notifications_none_outlined, AppLocalizations.of(context)?.notifications ?? 'Notifications', () => context.push('/notifications')),
          const Divider(height: 1),
          BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, state) {
              return ListTile(
                leading: Icon(Icons.language, color: Theme.of(context).colorScheme.onSurface),
                title: Text(AppLocalizations.of(context)!.language, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                subtitle: Text(
                  state.locale.languageCode == 'ar' ? 'العربية' : 'English',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 12),
                ),
                trailing: Switch(
                  value: state.locale.languageCode == 'ar',
                  activeColor: AppColors.primary,
                  onChanged: (value) {
                    context.read<SettingsCubit>().toggleLocale();
                    sl<HomeBloc>().add(FetchHomeData());
                    sl<FavoritesBloc>().add(FetchFavorites());
                    sl<CartBloc>().add(FetchCart());
                  },
                ),
              );
            },
          ),
          BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, state) {
              return ListTile(
                leading: Icon(Icons.dark_mode_outlined, color: Theme.of(context).colorScheme.onSurface),
                title: Text(AppLocalizations.of(context)!.darkMode, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                trailing: Switch(
                  value: state.themeMode == ThemeMode.dark,
                  activeColor: AppColors.primary,
                  onChanged: (value) {
                    context.read<SettingsCubit>().toggleTheme();
                  },
                ),
              );
            },
          ),
          const Divider(height: 1),
          _buildMenuTile(context, Icons.logout, AppLocalizations.of(context)?.logout ?? 'Logout', () => _bloc.add(LogoutEvent()), isDestructive: true),
        ],
      ),
    );
  }

  Widget _buildMenuTile(BuildContext context, IconData icon, String title, VoidCallback onTap, {bool isDestructive = false}) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: isDestructive ? AppColors.error : Theme.of(context).colorScheme.onSurface),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? AppColors.error : Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(Icons.chevron_right, size: 20, color: Theme.of(context).colorScheme.onSurface),
    );
  }
}
