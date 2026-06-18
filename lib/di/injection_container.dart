import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/auth/session_manager.dart';
import '../core/events/favorite_events.dart';
import '../core/events/order_events.dart';
import '../core/network/dio_client.dart';
import '../features/admin/data/datasources/admin_remote_data_source.dart';
import '../features/admin/data/repositories/admin_repository_impl.dart';
import '../features/admin/domain/repositories/admin_repository.dart';
import '../features/admin/presentation/bloc/admin_bloc.dart';
import '../features/auth/data/datasources/auth_remote_data_source.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/usecases/login_usecase.dart';
import '../features/auth/domain/usecases/register_usecase.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/cart/data/datasources/cart_remote_data_source.dart';
import '../features/cart/data/repositories/cart_repository_impl.dart';
import '../features/cart/domain/repositories/cart_repository.dart';
import '../features/cart/domain/usecases/cart_usecases.dart';
import '../features/cart/presentation/bloc/cart_bloc.dart';
import '../features/checkout/data/datasources/checkout_remote_data_source.dart';
import '../features/checkout/data/repositories/checkout_repository_impl.dart';
import '../features/checkout/domain/repositories/checkout_repository.dart';
import '../features/checkout/domain/usecases/place_order_usecase.dart';
import '../features/checkout/presentation/bloc/checkout_bloc.dart';
import '../features/favorites/data/repositories/favorites_repository_impl.dart';
import '../features/favorites/domain/repositories/favorites_repository.dart';
import '../features/favorites/domain/usecases/favorites_usecases.dart';
import '../features/favorites/presentation/bloc/favorites_bloc.dart';
import '../features/home/data/datasources/home_remote_data_source.dart';
import '../features/home/data/repositories/home_repository_impl.dart';
import '../features/home/domain/repositories/home_repository.dart';
import '../features/home/domain/usecases/get_banners_usecase.dart';
import '../features/home/domain/usecases/get_categories_usecase.dart';
import '../features/home/domain/usecases/get_popular_meals_usecase.dart';
import '../features/home/domain/usecases/get_restaurants_usecase.dart';
import '../features/home/presentation/bloc/home_bloc.dart';
import '../features/onboarding/presentation/bloc/onboarding_bloc.dart';
import '../features/orders/data/datasources/order_remote_data_source.dart';
import '../features/orders/data/repositories/order_repository_impl.dart';
import '../features/orders/domain/repositories/order_repository.dart';
import '../features/orders/domain/usecases/order_usecases.dart';
import '../features/orders/presentation/bloc/orders_bloc.dart';
import '../features/notifications/data/datasources/notification_remote_data_source.dart';
import '../features/notifications/data/repositories/notification_repository_impl.dart';
import '../features/notifications/domain/repositories/notification_repository.dart';
import '../features/notifications/domain/usecases/get_notifications_usecase.dart';
import '../features/notifications/domain/usecases/mark_notification_as_read_usecase.dart';
import '../features/notifications/domain/usecases/mark_all_notifications_as_read_usecase.dart';
import '../features/notifications/presentation/bloc/notifications_bloc.dart';
import '../features/profile/data/datasources/user_remote_data_source.dart';
import '../features/profile/data/repositories/user_repository_impl.dart';
import '../features/profile/domain/repositories/user_repository.dart';
import '../features/profile/domain/usecases/profile_usecases.dart';
import '../features/profile/presentation/bloc/profile_bloc.dart';
import '../features/product_details/data/datasources/product_remote_data_source.dart';
import '../features/product_details/data/repositories/product_repository_impl.dart';
import '../features/product_details/domain/repositories/product_repository.dart';
import '../features/product_details/domain/usecases/get_product_details_usecase.dart';
import '../features/product_details/presentation/bloc/product_detail_bloc.dart';
import '../features/restaurant_details/data/datasources/restaurant_remote_data_source.dart';
import '../features/restaurant_details/data/repositories/restaurant_repository_impl.dart';
import '../features/restaurant_details/domain/repositories/restaurant_repository.dart';
import '../features/restaurant_details/domain/usecases/get_restaurant_details_usecase.dart';
import '../features/restaurant_details/domain/usecases/toggle_favorite_usecase.dart';
import '../features/restaurant_details/domain/usecases/submit_review_usecase.dart';
import '../features/restaurant_details/presentation/bloc/restaurant_detail_bloc.dart';
import '../features/splash/presentation/bloc/splash_bloc.dart';
import '../features/delivery/data/datasources/delivery_remote_data_source.dart';
import '../features/delivery/data/repositories/delivery_repository_impl.dart';
import '../features/delivery/domain/repositories/delivery_repository.dart';
import '../features/delivery/domain/usecases/get_assigned_orders_usecase.dart';
import '../features/delivery/domain/usecases/update_delivery_status_usecase.dart';
import '../features/delivery/domain/usecases/update_driver_location_usecase.dart';
import '../features/delivery/domain/usecases/toggle_availability_usecase.dart';
import '../features/delivery/domain/usecases/get_driver_earnings_usecase.dart';
import '../features/delivery/domain/usecases/get_delivery_history_usecase.dart';
import '../features/delivery/domain/usecases/accept_order_usecase.dart';
import '../features/delivery/presentation/bloc/delivery_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Core
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => const FlutterSecureStorage());
  sl.registerLazySingleton(() => SessionManager(secureStorage: sl()));
  sl.registerLazySingleton(() => FavoriteEventBus());
  sl.registerLazySingleton(() => OrderEventBus());
  sl.registerLazySingleton(() => Dio());
  sl.registerLazySingleton(() => DioClient(dio: sl(), secureStorage: sl()));

  // Features
  // Splash
  sl.registerFactory(() => SplashBloc(
        sharedPreferences: sl(),
        secureStorage: sl(),
        getUserProfileUseCase: sl(),
        sessionManager: sl(),
        homeBloc: sl(),
      ));
  
  // Onboarding
  sl.registerFactory(() => OnboardingBloc(sharedPreferences: sl()));
  
  // Auth
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(dioClient: sl()));
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerFactory(() => AuthBloc(
        loginUseCase: sl(),
        registerUseCase: sl(),
        authRepository: sl(),
        sessionManager: sl(),
      ));

  // Home
  sl.registerLazySingleton<HomeRemoteDataSource>(() => HomeRemoteDataSourceImpl(dioClient: sl()));
  sl.registerLazySingleton<HomeRepository>(() => HomeRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton(() => GetBannersUseCase(sl()));
  sl.registerLazySingleton(() => GetCategoriesUseCase(sl()));
  sl.registerLazySingleton(() => GetRestaurantsUseCase(sl()));
  sl.registerLazySingleton(() => GetPopularMealsUseCase(sl()));
  sl.registerLazySingleton(() => HomeBloc(
        getBannersUseCase: sl(),
        getCategoriesUseCase: sl(),
        getRestaurantsUseCase: sl(),
        getPopularMealsUseCase: sl(),
        toggleFavoriteUseCase: sl(),
        favoriteEventBus: sl(),
      ));

  // Restaurant Details
  sl.registerLazySingleton<RestaurantRemoteDataSource>(() => RestaurantRemoteDataSourceImpl(dioClient: sl()));
  sl.registerLazySingleton<RestaurantRepository>(() => RestaurantRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton(() => GetRestaurantDetailsUseCase(sl()));
  sl.registerLazySingleton(() => ToggleFavoriteRestaurantUseCase(sl()));
  sl.registerLazySingleton(() => SubmitReviewUseCase(sl()));
  sl.registerFactory(() => RestaurantDetailBloc(
        getRestaurantDetailsUseCase: sl(),
        toggleFavoriteUseCase: sl(),
        favoriteEventBus: sl(),
      ));

  // Product Details
  sl.registerLazySingleton<ProductRemoteDataSource>(() => ProductRemoteDataSourceImpl(dioClient: sl()));
  sl.registerLazySingleton<ProductRepository>(() => ProductRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton(() => GetProductDetailsUseCase(sl()));
  sl.registerFactory(() => ProductDetailBloc(getProductDetailsUseCase: sl()));

  // Cart
  sl.registerLazySingleton<CartRemoteDataSource>(() => CartRemoteDataSourceImpl(dioClient: sl()));
  sl.registerLazySingleton<CartRepository>(() => CartRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton(() => GetCartUseCase(sl()));
  sl.registerLazySingleton(() => AddToCartUseCase(sl()));
  sl.registerLazySingleton(() => UpdateCartItemUseCase(sl()));
  sl.registerLazySingleton(() => RemoveFromCartUseCase(sl()));
  sl.registerLazySingleton(() => ClearCartUseCase(sl()));
  sl.registerLazySingleton(() => CartBloc(
        getCartUseCase: sl(),
        addToCartUseCase: sl(),
        updateCartItemUseCase: sl(),
        removeFromCartUseCase: sl(),
        clearCartUseCase: sl(),
      ));

  // Checkout
  sl.registerLazySingleton<CheckoutRemoteDataSource>(() => CheckoutRemoteDataSourceImpl(dioClient: sl()));
  sl.registerLazySingleton<CheckoutRepository>(() => CheckoutRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton(() => PlaceOrderUseCase(sl()));
  sl.registerFactory(() => CheckoutBloc(placeOrderUseCase: sl()));

  // Orders
  sl.registerLazySingleton<OrderRemoteDataSource>(() => OrderRemoteDataSourceImpl(dioClient: sl()));
  sl.registerLazySingleton<OrderRepository>(() => OrderRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton(() => GetOrdersUseCase(sl()));
  sl.registerLazySingleton(() => GetOrderDetailsUseCase(sl()));
  sl.registerLazySingleton(() => ReorderUseCase(sl()));
  sl.registerFactory(() => OrdersBloc(
        getOrdersUseCase: sl(),
        getOrderDetailsUseCase: sl(),
        reorderUseCase: sl(),
      ));

  // Notifications
  sl.registerLazySingleton<NotificationRemoteDataSource>(() => NotificationRemoteDataSourceImpl(dioClient: sl()));
  sl.registerLazySingleton<NotificationRepository>(() => NotificationRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton(() => GetNotificationsUseCase(sl()));
  sl.registerLazySingleton(() => MarkNotificationAsReadUseCase(sl()));
  sl.registerLazySingleton(() => MarkAllNotificationsAsReadUseCase(sl()));
  sl.registerFactory(() => NotificationsBloc(
        getNotificationsUseCase: sl(),
        markNotificationAsReadUseCase: sl(),
        markAllNotificationsAsReadUseCase: sl(),
        submitReviewUseCase: sl(),
      ));

  // Favorites
  sl.registerLazySingleton<FavoritesRepository>(() => FavoritesRepositoryImpl(dioClient: sl()));
  sl.registerLazySingleton(() => GetFavoritesUseCase(sl()));
  sl.registerLazySingleton(() => ToggleFavoriteUseCase(sl()));
  sl.registerLazySingleton(() => FavoritesBloc(
        getFavoritesUseCase: sl(),
        toggleFavoriteUseCase: sl(),
        favoriteEventBus: sl(),
      ));

  // Profile
  sl.registerLazySingleton<UserRemoteDataSource>(() => UserRemoteDataSourceImpl(dioClient: sl()));
  sl.registerLazySingleton<UserRepository>(() => UserRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton(() => GetUserProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));
  sl.registerLazySingleton(() => GetAddressesUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => UpdateDeviceTokenUseCase(sl()));
  sl.registerFactory(() => ProfileBloc(
        getUserProfileUseCase: sl(),
        updateProfileUseCase: sl(),
        getAddressesUseCase: sl(),
        logoutUseCase: sl(),
        sessionManager: sl(),
      ));

  // Admin
  sl.registerLazySingleton<AdminRemoteDataSource>(() => AdminRemoteDataSourceImpl(dioClient: sl()));
  sl.registerLazySingleton<AdminRepository>(() => AdminRepositoryImpl(remoteDataSource: sl()));
  sl.registerFactory(() => AdminBloc(repository: sl()));

  // Delivery
  sl.registerLazySingleton<DeliveryRemoteDataSource>(() => DeliveryRemoteDataSourceImpl(dioClient: sl()));
  sl.registerLazySingleton<DeliveryRepository>(() => DeliveryRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton(() => GetAssignedOrdersUseCase(sl()));
  sl.registerLazySingleton(() => UpdateDeliveryStatusUseCase(sl()));
  sl.registerLazySingleton(() => UpdateDriverLocationUseCase(sl()));
  sl.registerLazySingleton(() => ToggleAvailabilityUseCase(sl()));
  sl.registerLazySingleton(() => GetDriverEarningsUseCase(sl()));
  sl.registerLazySingleton(() => GetDeliveryHistoryUseCase(sl()));
  sl.registerLazySingleton(() => AcceptOrderUseCase(sl()));
  sl.registerFactory(() => DeliveryBloc(
        getAssignedOrdersUseCase: sl(),
        updateDeliveryStatusUseCase: sl(),
        updateDriverLocationUseCase: sl(),
        toggleAvailabilityUseCase: sl(),
        getDriverEarningsUseCase: sl(),
        getDeliveryHistoryUseCase: sl(),
        acceptOrderUseCase: sl(),
        sessionManager: sl(),
      ));
}
