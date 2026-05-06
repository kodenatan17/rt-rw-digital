// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:firebase_messaging/firebase_messaging.dart' as _i892;
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as _i163;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:pasconnect/core/commons/helper/firebase_analytics_helper.dart'
    as _i137;
import 'package:pasconnect/core/presentation/global_blocs/error/bloc/error_cubit.dart'
    as _i873;
import 'package:pasconnect/core/presentation/global_blocs/internet_connection/internet_connection_cubit.dart'
    as _i400;
import 'package:pasconnect/core/presentation/global_blocs/notification/notification_register/notification_register_device_cubit.dart'
    as _i183;
import 'package:pasconnect/core/presentation/global_blocs/user_session/user_session_cubit.dart'
    as _i367;
import 'package:pasconnect/features/auth/data/datasources/auth_local_datasource.dart'
    as _i527;
import 'package:pasconnect/features/auth/data/datasources/auth_remote_datasource.dart'
    as _i449;
import 'package:pasconnect/features/auth/data/repositories/auth_repository_impl.dart'
    as _i825;
import 'package:pasconnect/features/auth/data/services/dio/auth_ret_network_client.dart'
    as _i230;
import 'package:pasconnect/features/auth/data/services/remote/auth_remote_service.dart'
    as _i928;
import 'package:pasconnect/features/auth/domain/repositories/auth_repository.dart'
    as _i254;
import 'package:pasconnect/features/auth/domain/usecases/check_logged_in/check_logged_in_usecase.dart'
    as _i454;
import 'package:pasconnect/features/auth/domain/usecases/complete_username/do_complete_username_usecase.dart'
    as _i103;
import 'package:pasconnect/features/auth/domain/usecases/current_tokens/get_current_tokens_usecase.dart'
    as _i1043;
import 'package:pasconnect/features/auth/domain/usecases/delete_account/do_delete_account_usecase.dart'
    as _i885;
import 'package:pasconnect/features/auth/domain/usecases/logout/auth_logout_usecase.dart'
    as _i818;
import 'package:pasconnect/features/auth/domain/usecases/refresh_token/do_refresh_token_usecase.dart'
    as _i818;
import 'package:pasconnect/features/auth/domain/usecases/request_otp/do_request_otp_usecase.dart'
    as _i431;
import 'package:pasconnect/features/auth/domain/usecases/submit_otp/do_submit_otp_usecase.dart'
    as _i880;
import 'package:pasconnect/features/auth/presentation/blocs/login/login_bloc.dart'
    as _i314;
import 'package:pasconnect/features/auth/presentation/blocs/logout/logout_bloc.dart'
    as _i619;
import 'package:pasconnect/features/auth/presentation/blocs/splash/splash_cubit.dart'
    as _i599;
import 'package:pasconnect/features/auth/presentation/blocs/submit_username/submit_username_bloc.dart'
    as _i854;
import 'package:pasconnect/features/auth/presentation/blocs/verification_otp/verification_otp_bloc.dart'
    as _i728;
import 'package:pasconnect/features/call/data/datasources/call_remote_datasource.dart'
    as _i904;
import 'package:pasconnect/features/call/data/repositories/agora_call_repository_impl.dart'
    as _i706;
import 'package:pasconnect/features/call/data/repositories/call_repository_impl.dart'
    as _i363;
import 'package:pasconnect/features/call/data/services/dio/call_ret_network_client.dart'
    as _i510;
import 'package:pasconnect/features/call/data/services/remote/call_remote_service.dart'
    as _i97;
import 'package:pasconnect/features/call/domain/repositories/agora_call_repository.dart'
    as _i886;
import 'package:pasconnect/features/call/domain/repositories/call_repository.dart'
    as _i476;
import 'package:pasconnect/features/call/domain/usecases/do_call_action/do_call_action_usecase.dart'
    as _i812;
import 'package:pasconnect/features/call/presentation/bloc/control/video_call_controls_bloc.dart'
    as _i693;
import 'package:pasconnect/features/call/presentation/bloc/control/voice_call_controls_bloc.dart'
    as _i179;
import 'package:pasconnect/features/call/presentation/bloc/status/video_call_status_bloc.dart'
    as _i945;
import 'package:pasconnect/features/call/presentation/bloc/status/voice_call_status_bloc.dart'
    as _i41;
import 'package:pasconnect/features/notification/data/data_sources/notification_local_data_source.dart'
    as _i811;
import 'package:pasconnect/features/notification/data/data_sources/notification_remote_data_source.dart'
    as _i602;
import 'package:pasconnect/features/notification/data/repositories/notification_repository_impl.dart'
    as _i280;
import 'package:pasconnect/features/notification/data/services/dio/notification_ret_network_client.dart'
    as _i562;
import 'package:pasconnect/features/notification/data/services/remote/notification_remote_service.dart'
    as _i847;
import 'package:pasconnect/features/notification/domain/repository/notification_repository.dart'
    as _i887;
import 'package:pasconnect/features/notification/domain/usecase/notification_store/notification_store_token_usecase.dart'
    as _i390;
import 'package:pasconnect/features/notification/presentation/bloc/notification_cubit.dart'
    as _i742;
import 'package:pasconnect/features/services/dio/base_dio_error_handler.dart'
    as _i363;
import 'package:pasconnect/features/user/data/datasources/user_remote_data_sources.dart'
    as _i124;
import 'package:pasconnect/features/user/data/repositories/user_repository_impl.dart'
    as _i147;
import 'package:pasconnect/features/user/data/services/dio/user_ret_network_client.dart'
    as _i439;
import 'package:pasconnect/features/user/data/services/remote/user_remote_service.dart'
    as _i423;
import 'package:pasconnect/features/user/domain/repositories/user_repository.dart'
    as _i864;
import 'package:pasconnect/features/user/domain/usecases/delete_account/do_delete_account_usecase.dart'
    as _i990;
import 'package:pasconnect/features/user/domain/usecases/get_profile/get_profile_usecase.dart'
    as _i1046;
import 'package:pasconnect/features/user/domain/usecases/history_call/get_history_call_usecase.dart'
    as _i1000;
import 'package:pasconnect/features/user/domain/usecases/logout/do_logout_usecase.dart'
    as _i159;
import 'package:pasconnect/features/user/presentation/history/bloc/history_call/history_call_bloc.dart'
    as _i507;
import 'package:pasconnect/features/user/presentation/home/bloc/home_cubit.dart'
    as _i620;
import 'package:pasconnect/features/user/presentation/profile/bloc/deactive_account/deactivate_account_cubit.dart'
    as _i312;
import 'package:pasconnect/features/user/presentation/profile/bloc/get_profile/profile_cubit.dart'
    as _i558;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final notificationModule = _$NotificationModule();
    final callRetrofitInjectableModule = _$CallRetrofitInjectableModule();
    final authRetrofitInjectableModule = _$AuthRetrofitInjectableModule();
    final userRetrofitInjectableModule = _$UserRetrofitInjectableModule();
    final notificationRetrofitInjectableModule =
        _$NotificationRetrofitInjectableModule();
    gh.factory<_i137.FirebaseAnalyticsHelper>(
        () => _i137.FirebaseAnalyticsHelper());
    gh.factory<_i620.HomeCubit>(() => _i620.HomeCubit());
    gh.factory<_i179.VoiceCallControlsBloc>(
        () => _i179.VoiceCallControlsBloc());
    gh.factory<_i693.VideoCallControlsBloc>(
        () => _i693.VideoCallControlsBloc());
    gh.singleton<_i400.InternetConnectionCubit>(
        () => _i400.InternetConnectionCubit());
    gh.singleton<_i367.UserSessionCubit>(() => _i367.UserSessionCubit());
    gh.singleton<_i230.AuthRetApiDio>(() => _i230.AuthRetApiDio());
    gh.singleton<_i562.NotificationRetApiDio>(
        () => _i562.NotificationRetApiDio());
    gh.singleton<_i163.FlutterLocalNotificationsPlugin>(
        () => notificationModule.notificationsPlugin);
    gh.singleton<_i439.UserRetApiDio>(() => _i439.UserRetApiDio());
    gh.singleton<_i510.CallRetApiDio>(() => _i510.CallRetApiDio());
    gh.singleton<_i363.BaseDioErrorHandler>(() => _i363.BaseDioErrorHandler());
    gh.lazySingleton<_i873.GlobalErrorCubit>(() => _i873.GlobalErrorCubit());
    gh.lazySingleton<_i892.FirebaseMessaging>(
        () => notificationModule.firebaseMessaging);
    gh.factory<_i97.CallRemoteService>(() => callRetrofitInjectableModule
        .getCallRemoteService(gh<_i510.CallRetApiDio>()));
    gh.lazySingleton<_i811.NotificationLocalDataSource>(
        () => _i811.NotificationLocalDataSourceImpl());
    gh.lazySingleton<_i886.AgoraCallRepository>(
        () => _i706.AgoraCallRepositoryImpl());
    gh.lazySingleton<_i527.AuthLocalDataSource>(
        () => _i527.AuthLocalDataSourceImpl());
    gh.lazySingleton<_i904.CallRemoteDataSource>(
        () => _i904.CallRemoteDataSourceImpl(gh<_i97.CallRemoteService>()));
    gh.factory<_i742.NotificationCubit>(
        () => _i742.NotificationCubit(gh<_i892.FirebaseMessaging>()));
    gh.factory<_i928.AuthRemoteService>(() => authRetrofitInjectableModule
        .getAuthRemoteService(gh<_i230.AuthRetApiDio>()));
    gh.lazySingleton<_i476.CallRepository>(() => _i363.CallRepositoryImpl(
          gh<_i904.CallRemoteDataSource>(),
          gh<_i363.BaseDioErrorHandler>(),
        ));
    gh.factory<_i423.UserRemoteService>(() => userRetrofitInjectableModule
        .getUserRemoteService(gh<_i439.UserRetApiDio>()));
    gh.lazySingleton<_i449.AuthRemoteDataSource>(
        () => _i449.AuthRemoteDataSourceImpl(gh<_i928.AuthRemoteService>()));
    gh.factory<_i847.NotificationRemoteService>(() =>
        notificationRetrofitInjectableModule
            .getNotificationRemoteService(gh<_i562.NotificationRetApiDio>()));
    gh.lazySingleton<_i602.NotificationRemoteDataSource>(() =>
        _i602.NotificationRemoteDataSourceImpl(
            gh<_i847.NotificationRemoteService>()));
    gh.lazySingleton<_i254.AuthRepository>(() => _i825.AuthRepositoryImpl(
          gh<_i449.AuthRemoteDataSource>(),
          gh<_i363.BaseDioErrorHandler>(),
          gh<_i527.AuthLocalDataSource>(),
        ));
    gh.lazySingleton<_i887.NotificationRepository>(
        () => _i280.NotificationRepositoryImpl(
              gh<_i602.NotificationRemoteDataSource>(),
              gh<_i811.NotificationLocalDataSource>(),
              gh<_i363.BaseDioErrorHandler>(),
            ));
    gh.factory<_i390.NotificationStoreTokenUseCase>(() =>
        _i390.NotificationStoreTokenUseCase(
            gh<_i887.NotificationRepository>()));
    gh.lazySingleton<_i124.UserRemoteDataSource>(
        () => _i124.UserRemoteDataSourceImpl(gh<_i423.UserRemoteService>()));
    gh.lazySingleton<_i812.DoCallActionUsecase>(
        () => _i812.DoCallActionUsecase(gh<_i476.CallRepository>()));
    gh.lazySingleton<_i103.DoCompleteUsernameUsecase>(
        () => _i103.DoCompleteUsernameUsecase(gh<_i254.AuthRepository>()));
    gh.lazySingleton<_i818.DoRefreshTokenUseCase>(
        () => _i818.DoRefreshTokenUseCase(gh<_i254.AuthRepository>()));
    gh.lazySingleton<_i885.DoDeleteAccountUseCase>(
        () => _i885.DoDeleteAccountUseCase(gh<_i254.AuthRepository>()));
    gh.lazySingleton<_i880.DoSubmitOtpUsecase>(
        () => _i880.DoSubmitOtpUsecase(gh<_i254.AuthRepository>()));
    gh.lazySingleton<_i431.DoRequestOtpUsecase>(
        () => _i431.DoRequestOtpUsecase(gh<_i254.AuthRepository>()));
    gh.lazySingleton<_i818.AuthLogoutUseCase>(
        () => _i818.AuthLogoutUseCase(gh<_i254.AuthRepository>()));
    gh.lazySingleton<_i454.CheckLoggedInUseCase>(
        () => _i454.CheckLoggedInUseCase(gh<_i254.AuthRepository>()));
    gh.factory<_i183.NotificationRegisterDeviceCubit>(
        () => _i183.NotificationRegisterDeviceCubit(
              gh<_i390.NotificationStoreTokenUseCase>(),
              gh<_i892.FirebaseMessaging>(),
            ));
    gh.lazySingleton<_i1043.GetCurrentTokensUseCase>(
        () => _i1043.GetCurrentTokensUseCase(gh<_i254.AuthRepository>()));
    gh.factory<_i854.SubmitUsernameBloc>(
        () => _i854.SubmitUsernameBloc(gh<_i103.DoCompleteUsernameUsecase>()));
    gh.factory<_i314.LoginBloc>(
        () => _i314.LoginBloc(gh<_i431.DoRequestOtpUsecase>()));
    gh.lazySingleton<_i864.UserRepository>(() => _i147.UserRepositoryImpl(
          gh<_i124.UserRemoteDataSource>(),
          gh<_i363.BaseDioErrorHandler>(),
        ));
    gh.factory<_i41.VoiceCallStatusBloc>(
        () => _i41.VoiceCallStatusBloc(gh<_i812.DoCallActionUsecase>()));
    gh.factory<_i945.VideoCallStatusBloc>(
        () => _i945.VideoCallStatusBloc(gh<_i812.DoCallActionUsecase>()));
    gh.factory<_i312.DeactivateAccountCubit>(
        () => _i312.DeactivateAccountCubit(gh<_i885.DoDeleteAccountUseCase>()));
    gh.factory<_i728.VerificationOtpBloc>(
        () => _i728.VerificationOtpBloc(gh<_i880.DoSubmitOtpUsecase>()));
    gh.factory<_i619.LogoutBloc>(() => _i619.LogoutBloc(
          gh<_i818.AuthLogoutUseCase>(),
          gh<_i1043.GetCurrentTokensUseCase>(),
        ));
    gh.lazySingleton<_i1046.GetProfileUsecase>(
        () => _i1046.GetProfileUsecase(gh<_i864.UserRepository>()));
    gh.lazySingleton<_i1000.GetHistoryCallUsecase>(
        () => _i1000.GetHistoryCallUsecase(gh<_i864.UserRepository>()));
    gh.lazySingleton<_i990.DoDeleteAccountUsecase>(
        () => _i990.DoDeleteAccountUsecase(gh<_i864.UserRepository>()));
    gh.lazySingleton<_i159.DoLogoutUsecase>(
        () => _i159.DoLogoutUsecase(gh<_i864.UserRepository>()));
    gh.factory<_i599.SplashCubit>(() => _i599.SplashCubit(
          gh<_i1046.GetProfileUsecase>(),
          gh<_i454.CheckLoggedInUseCase>(),
          gh<_i1043.GetCurrentTokensUseCase>(),
        ));
    gh.factory<_i558.ProfileCubit>(
        () => _i558.ProfileCubit(gh<_i1046.GetProfileUsecase>()));
    gh.factory<_i507.HistoryCallBloc>(
        () => _i507.HistoryCallBloc(gh<_i1000.GetHistoryCallUsecase>()));
    return this;
  }
}

class _$NotificationModule extends _i742.NotificationModule {}

class _$CallRetrofitInjectableModule
    extends _i510.CallRetrofitInjectableModule {}

class _$AuthRetrofitInjectableModule
    extends _i230.AuthRetrofitInjectableModule {}

class _$UserRetrofitInjectableModule
    extends _i439.UserRetrofitInjectableModule {}

class _$NotificationRetrofitInjectableModule
    extends _i562.NotificationRetrofitInjectableModule {}
