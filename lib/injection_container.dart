import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:group_chat/features/data/repositories/create_group_repository.dart';
import 'package:group_chat/features/data/repositories/get_all_group_repository.dart';
import 'package:group_chat/features/data/repositories/get_all_users_repository.dart';
import 'package:group_chat/features/data/repositories/get_create_current_user_repository.dart';
import 'package:group_chat/features/data/repositories/get_current_uid_repository.dart';
import 'package:group_chat/features/data/repositories/get_messages_repository.dart';
import 'package:group_chat/features/data/repositories/get_update_user_repository.dart';
import 'package:group_chat/features/data/repositories/join_group_repository.dart';
import 'package:group_chat/features/data/repositories/send_text_message_repository.dart';
import 'package:group_chat/features/data/repositories/update_group_repository.dart';
import 'package:group_chat/features/presentation/cubit/group/group_cubit.dart';
import 'package:group_chat/features/presentation/cubit/user/user_cubit.dart';
import 'core/services/network/bloc/network_bloc.dart';
import 'core/services/notification/awesome_notification_service.dart' show FirebaseCloudMessaging;
import 'core/services/notification/local_notification_service.dart';
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

final serviceLocator = GetIt.instance;

Future<void> init() async {
  serviceLocator.registerLazySingleton<FirebaseCloudMessaging>(
      () => FirebaseCloudMessaging());
  await serviceLocator<FirebaseCloudMessaging>().getFirebaseNotification();
  await serviceLocator<FirebaseCloudMessaging>().setupAwesomeNotifications();
  serviceLocator.registerFactory(
    () => NetworkBloc(),
  );
  //Future bloc
  serviceLocator.registerFactory<AuthCubit>(() => AuthCubit(
        isSignInRepository: serviceLocator.call(),
        signOutRepository: serviceLocator.call(),
        getCurrentUIDRepository: serviceLocator.call(),
      ));
  serviceLocator.registerFactory<CredentialCubit>(() => CredentialCubit(
      forgotPasswordRepository: serviceLocator.call(),
      getCreateCurrentUserRepository: serviceLocator.call(),
      signInRepository: serviceLocator.call(),
      signUpRepository: serviceLocator.call(),
      googleSignInRepository: serviceLocator.call()));
  serviceLocator.registerFactory<UserCubit>(() => UserCubit(
        getAllUsersRepository: serviceLocator.call(),
        getUpdateUserRepository: serviceLocator.call(),
      ));

  serviceLocator.registerFactory<GroupCubit>(() => GroupCubit(
        getAllGroupsRepository: serviceLocator.call(),
        getCreateGroupRepository: serviceLocator.call(),
        joinGroupRepository: serviceLocator.call(),
        groupRepository: serviceLocator.call(),
      ));
  serviceLocator.registerFactory<ChatCubit>(() => ChatCubit(
        getMessageRepository: serviceLocator.call(),
        sendTextMessageRepository: serviceLocator.call(),
      ));

  //Repositorys
  serviceLocator.registerLazySingleton<GoogleSignInRepository>(
      () => GoogleSignInRepository(repository: serviceLocator.call()));
  serviceLocator.registerLazySingleton<ForgotPasswordRepository>(
      () => ForgotPasswordRepository(repository: serviceLocator.call()));
  serviceLocator.registerLazySingleton<GetCreateCurrentUserRepository>(
      () => GetCreateCurrentUserRepository(repository: serviceLocator.call()));
  serviceLocator.registerLazySingleton<GetCurrentUIDRepository>(
      () => GetCurrentUIDRepository(repository: serviceLocator.call()));
  serviceLocator.registerLazySingleton<IsSignInRepository>(
      () => IsSignInRepository(repository: serviceLocator.call()));
  serviceLocator.registerLazySingleton<SignInRepository>(
      () => SignInRepository(repository: serviceLocator.call()));
  serviceLocator.registerLazySingleton<SignUpRepository>(
      () => SignUpRepository(repository: serviceLocator.call()));
  serviceLocator.registerLazySingleton<SignOutRepository>(
      () => SignOutRepository(repository: serviceLocator.call()));
  serviceLocator.registerLazySingleton<GetAllUsersRepository>(
      () => GetAllUsersRepository(repository: serviceLocator.call()));
  serviceLocator.registerLazySingleton<GetUpdateUserRepository>(
      () => GetUpdateUserRepository(repository: serviceLocator.call()));
  serviceLocator.registerLazySingleton<GetCreateGroupRepository>(
      () => GetCreateGroupRepository(repository: serviceLocator.call()));
  serviceLocator.registerLazySingleton<GetAllGroupsRepository>(
      () => GetAllGroupsRepository(repository: serviceLocator.call()));
  serviceLocator.registerLazySingleton<JoinGroupRepository>(
      () => JoinGroupRepository(repository: serviceLocator.call()));
  serviceLocator.registerLazySingleton<UpdateGroupRepository>(
      () => UpdateGroupRepository(repository: serviceLocator.call()));
  serviceLocator.registerLazySingleton<GetMessageRepository>(
      () => GetMessageRepository(repository: serviceLocator.call()));
  serviceLocator.registerLazySingleton<SendTextMessageRepository>(
      () => SendTextMessageRepository(repository: serviceLocator.call()));

  //Repository
  serviceLocator.registerLazySingleton<FirebaseServices>(
      () => FirebaseServices(remoteDataSource: serviceLocator.call()));

  //Remote DataSource
  serviceLocator.registerLazySingleton<FirebaseRemoteDataSource>(() =>
      FirebaseRemoteDataSource(
          serviceLocator.call(), serviceLocator.call(), serviceLocator.call()));

  //External
  final auth = FirebaseAuth.instance;
  final fireStore = FirebaseFirestore.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  serviceLocator.registerLazySingleton(() => auth);
  serviceLocator.registerLazySingleton(() => fireStore);
  serviceLocator.registerLazySingleton(() => googleSignIn);
}
