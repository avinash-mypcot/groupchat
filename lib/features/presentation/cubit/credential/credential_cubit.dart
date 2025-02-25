import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:group_chat/features/data/models/user_entity.dart';
import 'package:group_chat/features/data/repositories/forgot_password_repository.dart';
import 'package:group_chat/features/data/repositories/get_create_current_user_repository.dart';
import 'package:group_chat/features/data/repositories/google_sign_in_repository.dart';
import 'package:group_chat/features/data/repositories/sign_in_repository.dart';
import 'package:group_chat/features/data/repositories/sign_up_repository.dart';

part 'credential_state.dart';

class CredentialCubit extends Cubit<CredentialState> {
  final SignUpRepository signUpRepository;
  final SignInRepository signInRepository;
  final ForgotPasswordRepository forgotPasswordRepository;
  final GetCreateCurrentUserRepository getCreateCurrentUserRepository;
  final GoogleSignInRepository googleSignInRepository;

  CredentialCubit(
      {required this.googleSignInRepository,
      required this.signUpRepository,
      required this.signInRepository,
      required this.forgotPasswordRepository,
      required this.getCreateCurrentUserRepository})
      : super(CredentialInitial());

  Future<void> forgotPassword({required String email}) async {
    try {
      await forgotPasswordRepository.call(email);
    } on SocketException catch (_) {
      emit(CredentialFailure());
    } catch (_) {
      emit(CredentialFailure());
    }
  }

  Future<void> signInSubmit({
    required String email,
    required String password,
  }) async {
    emit(CredentialLoading());
    try {
      await signInRepository.call(UserEntity(email: email, password: password));
      emit(CredentialSuccess());
      
    } on SocketException catch (_) {
      emit(CredentialFailure());
    } catch (_) {
      emit(CredentialFailure());
    }
  }

  Future<void> googleAuthSubmit() async {
    emit(CredentialLoading());
    try {
      await googleSignInRepository.call();
      emit(CredentialSuccess());
    } on SocketException catch (_) {
      emit(CredentialFailure());
    } catch (_) {
      emit(CredentialFailure());
    }
  }

  Future<void> signUpSubmit({required UserEntity user}) async {
    emit(CredentialLoading());
    try {
      await signUpRepository
          .call(UserEntity(email: user.email, password: user.password));
      await getCreateCurrentUserRepository.call(user);
      emit(CredentialSuccess());
    } on SocketException catch (_) {
      emit(CredentialFailure());
    } catch (_) {
      emit(CredentialFailure());
    }
  }
}
