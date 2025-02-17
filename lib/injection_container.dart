import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:self_host_group_chat_app/features/data/repositories/create_group_repository.dart';
import 'package:self_host_group_chat_app/features/data/repositories/get_all_group_repository.dart';
import 'package:self_host_group_chat_app/features/data/repositories/get_all_users_repository.dart';
import 'package:self_host_group_chat_app/features/data/repositories/get_create_current_user_repository.dart';
import 'package:self_host_group_chat_app/features/data/repositories/get_current_uid_repository.dart';
import 'package:self_host_group_chat_app/features/data/repositories/get_messages_repository.dart';
import 'package:self_host_group_chat_app/features/data/repositories/get_update_user_repository.dart';
import 'package:self_host_group_chat_app/features/data/repositories/join_group_repository.dart';
import 'package:self_host_group_chat_app/features/data/repositories/send_text_message_repository.dart';
import 'package:self_host_group_chat_app/features/data/repositories/update_group_repository.dart';
import 'package:self_host_group_chat_app/features/presentation/cubit/group/group_cubit.dart';
import 'package:self_host_group_chat_app/features/presentation/cubit/user/user_cubit.dart';
import 'features/data/api/firebase_remote_data_source.dart';
import 'features/data/services/firebase_services.dart';
import 'features/data/repositories/forgot_password_repository.dart';
import 'features/data/repositories/google_sign_in_repository.dart';
import 'features/data/repositories/is_sign_in_repository.dart';
import 'features/data/repositories/sign_in_repository.dart';
import 'features/data/repositories/sign_out_repository.dart';
import 'features/data/repositories/sign_up_repository.dart';
import 'features/presentation/cubit/auth/auth_cubit.dart';
import 'features/presentation/cubit/chat/chat_cubit.dart';
import 'features/presentation/cubit/credential/credential_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //Future bloc
  sl.registerFactory<AuthCubit>(() => AuthCubit(
        isSignInRepository: sl.call(),
        signOutRepository: sl.call(),
        getCurrentUIDRepository: sl.call(),
      ));
  sl.registerFactory<CredentialCubit>(() => CredentialCubit(
      forgotPasswordRepository: sl.call(),
      getCreateCurrentUserRepository: sl.call(),
      signInRepository: sl.call(),
      signUpRepository: sl.call(),
      googleSignInRepository: sl.call()));
  sl.registerFactory<UserCubit>(() => UserCubit(
        getAllUsersRepository: sl.call(),
        getUpdateUserRepository: sl.call(),
      ));

  sl.registerFactory<GroupCubit>(() => GroupCubit(
        getAllGroupsRepository: sl.call(),
        getCreateGroupRepository: sl.call(),
        joinGroupRepository: sl.call(),
        groupRepository: sl.call(),
      ));
  sl.registerFactory<ChatCubit>(() => ChatCubit(
        getMessageRepository: sl.call(),
        sendTextMessageRepository: sl.call(),
      ));

  //Repositorys
  sl.registerLazySingleton<GoogleSignInRepository>(
      () => GoogleSignInRepository(repository: sl.call()));
  sl.registerLazySingleton<ForgotPasswordRepository>(
      () => ForgotPasswordRepository(repository: sl.call()));
  sl.registerLazySingleton<GetCreateCurrentUserRepository>(
      () => GetCreateCurrentUserRepository(repository: sl.call()));
  sl.registerLazySingleton<GetCurrentUIDRepository>(
      () => GetCurrentUIDRepository(repository: sl.call()));
  sl.registerLazySingleton<IsSignInRepository>(
      () => IsSignInRepository(repository: sl.call()));
  sl.registerLazySingleton<SignInRepository>(
      () => SignInRepository(repository: sl.call()));
  sl.registerLazySingleton<SignUpRepository>(
      () => SignUpRepository(repository: sl.call()));
  sl.registerLazySingleton<SignOutRepository>(
      () => SignOutRepository(repository: sl.call()));
  sl.registerLazySingleton<GetAllUsersRepository>(
      () => GetAllUsersRepository(repository: sl.call()));
  sl.registerLazySingleton<GetUpdateUserRepository>(
      () => GetUpdateUserRepository(repository: sl.call()));
  sl.registerLazySingleton<GetCreateGroupRepository>(
      () => GetCreateGroupRepository(repository: sl.call()));
  sl.registerLazySingleton<GetAllGroupsRepository>(
      () => GetAllGroupsRepository(repository: sl.call()));
  sl.registerLazySingleton<JoinGroupRepository>(
      () => JoinGroupRepository(repository: sl.call()));
  sl.registerLazySingleton<UpdateGroupRepository>(
      () => UpdateGroupRepository(repository: sl.call()));
  sl.registerLazySingleton<GetMessageRepository>(
      () => GetMessageRepository(repository: sl.call()));
  sl.registerLazySingleton<SendTextMessageRepository>(
      () => SendTextMessageRepository(repository: sl.call()));

  //Repository
  sl.registerLazySingleton<FirebaseServices>(
      () => FirebaseServices(remoteDataSource: sl.call()));

  //Remote DataSource
  sl.registerLazySingleton<FirebaseRemoteDataSource>(
      () => FirebaseRemoteDataSource(sl.call(), sl.call(), sl.call()));

  //External
  final auth = FirebaseAuth.instance;
  final fireStore = FirebaseFirestore.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  sl.registerLazySingleton(() => auth);
  sl.registerLazySingleton(() => fireStore);
  sl.registerLazySingleton(() => googleSignIn);
}
