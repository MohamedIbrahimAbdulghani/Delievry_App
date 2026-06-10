import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/auth/session_manager.dart';
import '../../domain/usecases/profile_usecases.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetUserProfileUseCase getUserProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final GetAddressesUseCase getAddressesUseCase;
  final LogoutUseCase logoutUseCase;
  final SessionManager sessionManager;

  ProfileBloc({
    required this.getUserProfileUseCase,
    required this.updateProfileUseCase,
    required this.getAddressesUseCase,
    required this.logoutUseCase,
    required this.sessionManager,
  }) : super(ProfileInitial()) {
    on<FetchProfile>(_onFetchProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<FetchAddresses>(_onFetchAddresses);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onFetchProfile(FetchProfile event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    final result = await getUserProfileUseCase();
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (user) => emit(ProfileLoaded(user)),
    );
  }

  Future<void> _onUpdateProfile(UpdateProfileEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    final result = await updateProfileUseCase(name: event.name, phone: event.phone, imageUrl: event.imageUrl);
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (user) => emit(ProfileLoaded(user)),
    );
  }

  Future<void> _onFetchAddresses(FetchAddresses event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    final result = await getAddressesUseCase();
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (addresses) => emit(AddressesLoaded(addresses)),
    );
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    final result = await logoutUseCase();
    await sessionManager.clear();
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (success) => emit(LogoutSuccess()),
    );
  }
}
