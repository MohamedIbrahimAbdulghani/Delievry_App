import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Events
abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();
  @override List<Object> get props => [];
}
class CompleteOnboarding extends OnboardingEvent {}

// States
abstract class OnboardingState extends Equatable {
  const OnboardingState();
  @override List<Object> get props => [];
}
class OnboardingInitial extends OnboardingState {}
class OnboardingCompleted extends OnboardingState {}

// Bloc
class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final SharedPreferences sharedPreferences;

  OnboardingBloc({required this.sharedPreferences}) : super(OnboardingInitial()) {
    on<CompleteOnboarding>((event, emit) async {
      await sharedPreferences.setBool('has_seen_onboarding', true);
      emit(OnboardingCompleted());
    });
  }
}
