import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_toastr.dart';
import '../../../../di/injection_container.dart';
import 'package:delievry_app/l10n/app_localizations.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late ProfileBloc _bloc;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _bloc = sl<ProfileBloc>();
    if (_bloc.state is ProfileLoaded) {
      final user = (_bloc.state as ProfileLoaded).user;
      _nameController = TextEditingController(text: user.name);
      _phoneController = TextEditingController(text: user.phone ?? '');
    } else {
      _nameController = TextEditingController();
      _phoneController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
            onPressed: () => context.pop(),
          ),
          title: Text(AppLocalizations.of(context)?.editProfile ?? 'Edit Profile', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
        ),
        body: BlocConsumer<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state is ProfileLoaded) {
              context.showSuccessToast(
                title: 'Profile Updated',
                message: 'Your profile has been updated successfully!',
              );
              context.pop();
            } else if (state is ProfileError) {
              context.showErrorToast(
                title: 'Update Failed',
                message: state.message,
              );
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Stack(
                      children: [
                        const CircleAvatar(radius: 60, child: Icon(Icons.person, size: 60)),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: AppLocalizations.of(context)?.fullName ?? 'Full Name', border: const OutlineInputBorder()),
                      validator: (v) => v!.isEmpty ? 'Enter your name' : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(labelText: AppLocalizations.of(context)?.phoneNumber ?? 'Phone Number', border: const OutlineInputBorder()),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: state is ProfileLoading ? null : _saveProfile,
                        child: state is ProfileLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(AppLocalizations.of(context)?.saveChanges ?? 'Save Changes', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      _bloc.add(UpdateProfileEvent(name: _nameController.text, phone: _phoneController.text));
    }
  }
}
