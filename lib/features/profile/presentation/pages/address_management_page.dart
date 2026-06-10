import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../di/injection_container.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

class AddressManagementPage extends StatefulWidget {
  const AddressManagementPage({super.key});

  @override
  State<AddressManagementPage> createState() => _AddressManagementPageState();
}

class _AddressManagementPageState extends State<AddressManagementPage> {
  late ProfileBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = sl<ProfileBloc>()..add(FetchAddresses());
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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.onBackground),
            onPressed: () => context.pop(),
          ),
          title: const Text('My Addresses', style: TextStyle(color: AppColors.onBackground, fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
              icon: const Icon(Icons.add, color: AppColors.primary),
              onPressed: () {},
            ),
          ],
        ),
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            } else if (state is AddressesLoaded) {
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.addresses.length,
                itemBuilder: (context, index) {
                  final address = state.addresses[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: AppColors.primary.withAlpha(26), shape: BoxShape.circle),
                          child: const Icon(Icons.location_on, color: AppColors.primary, size: 20),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(address.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text(address.address, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                            ],
                          ),
                        ),
                        if (address.isDefault)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.green.withAlpha(26), borderRadius: BorderRadius.circular(4)),
                            child: const Text('Default', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
                      ],
                    ),
                  );
                },
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
}
