import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:self_host_group_chat_app/features/data/repositories/get_current_uid_repository.dart';
import 'package:self_host_group_chat_app/features/data/repositories/is_sign_in_repository.dart';
import 'package:self_host_group_chat_app/features/data/repositories/sign_out_repository.dart';
part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final IsSignInRepository isSignInRepository;
  final SignOutRepository signOutRepository;
  final GetCurrentUIDRepository getCurrentUIDRepository;

  AuthCubit(
      {required this.isSignInRepository,
      required this.signOutRepository,
      required this.getCurrentUIDRepository})
      : super(AuthInitial());

  Future<void> appStarted() async {
    try {
      bool isSignIn = await isSignInRepository.call();
      print(isSignIn);
      if (isSignIn == true) {
        final uid = await getCurrentUIDRepository.call();

        emit(Authenticated(uid: uid));
      } else
        emit(UnAuthenticated());
    } catch (_) {
      emit(UnAuthenticated());
    }
  }

  Future<void> loggedIn() async {
    try {
      final uid = await getCurrentUIDRepository.call();
      print("user Id $uid");
      emit(Authenticated(uid: uid));
    } catch (_) {
      print("user Id null");
      emit(UnAuthenticated());
    }
  }

  Future<void> loggedOut() async {
    try {
      await signOutRepository.call();
      emit(UnAuthenticated());
    } catch (_) {
      emit(UnAuthenticated());
    }
  }
}
