import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// Home tab title
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Cart tab title
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cart;

  /// Favorites tab title
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// Orders tab title
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// Profile tab title
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Settings section title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Language setting
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Dark mode setting
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @featuredRestaurants.
  ///
  /// In en, this message translates to:
  /// **'Featured Restaurants'**
  String get featuredRestaurants;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @specialOffer.
  ///
  /// In en, this message translates to:
  /// **'Special Offer'**
  String get specialOffer;

  /// No description provided for @get50Off.
  ///
  /// In en, this message translates to:
  /// **'Get 50% off on your first order'**
  String get get50Off;

  /// No description provided for @deliverTo.
  ///
  /// In en, this message translates to:
  /// **'Deliver to'**
  String get deliverTo;

  /// No description provided for @min.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get min;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @registerHere.
  ///
  /// In en, this message translates to:
  /// **'Register here'**
  String get registerHere;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @loginHere.
  ///
  /// In en, this message translates to:
  /// **'Login here'**
  String get loginHere;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchForMeals.
  ///
  /// In en, this message translates to:
  /// **'Search for meals...'**
  String get searchForMeals;

  /// No description provided for @searchForRestaurantsOrMeals.
  ///
  /// In en, this message translates to:
  /// **'Search for restaurants or meals...'**
  String get searchForRestaurantsOrMeals;

  /// No description provided for @mealNotFound.
  ///
  /// In en, this message translates to:
  /// **'The meal you are searching for does not exist.'**
  String get mealNotFound;

  /// No description provided for @searchFavoriteFood.
  ///
  /// In en, this message translates to:
  /// **'Search for your favorite food!'**
  String get searchFavoriteFood;

  /// No description provided for @noFavoritesYet.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet.'**
  String get noFavoritesYet;

  /// No description provided for @addFavoritesMsg.
  ///
  /// In en, this message translates to:
  /// **'Add your favorite meals here to order them quickly.'**
  String get addFavoritesMsg;

  /// No description provided for @activeOrders.
  ///
  /// In en, this message translates to:
  /// **'Active Orders'**
  String get activeOrders;

  /// No description provided for @pastOrders.
  ///
  /// In en, this message translates to:
  /// **'Past Orders'**
  String get pastOrders;

  /// No description provided for @orderId.
  ///
  /// In en, this message translates to:
  /// **'Order ID'**
  String get orderId;

  /// No description provided for @trackOrder.
  ///
  /// In en, this message translates to:
  /// **'Track Order'**
  String get trackOrder;

  /// No description provided for @orderDetails.
  ///
  /// In en, this message translates to:
  /// **'Order Details'**
  String get orderDetails;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @deliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'Delivery Address'**
  String get deliveryAddress;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get items;

  /// No description provided for @totalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get totalAmount;

  /// No description provided for @searchPastTrips.
  ///
  /// In en, this message translates to:
  /// **'Search past trips...'**
  String get searchPastTrips;

  /// No description provided for @noOrdersFound.
  ///
  /// In en, this message translates to:
  /// **'No orders found.'**
  String get noOrdersFound;

  /// No description provided for @myCart.
  ///
  /// In en, this message translates to:
  /// **'My Cart'**
  String get myCart;

  /// No description provided for @checkout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @deliveryFee.
  ///
  /// In en, this message translates to:
  /// **'Delivery Fee'**
  String get deliveryFee;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @placeOrder.
  ///
  /// In en, this message translates to:
  /// **'Place Order'**
  String get placeOrder;

  /// No description provided for @cartEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get cartEmpty;

  /// No description provided for @addItemsToCart.
  ///
  /// In en, this message translates to:
  /// **'Add some items to your cart to checkout.'**
  String get addItemsToCart;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @myOrders.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get myOrders;

  /// No description provided for @paymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Payment Methods'**
  String get paymentMethods;

  /// No description provided for @deliveryAddresses.
  ///
  /// In en, this message translates to:
  /// **'Delivery Addresses'**
  String get deliveryAddresses;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No Notifications'**
  String get noNotifications;

  /// No description provided for @youHaveNoNotifications.
  ///
  /// In en, this message translates to:
  /// **'You have no notifications at this time.'**
  String get youHaveNoNotifications;

  /// No description provided for @searchPastOrders.
  ///
  /// In en, this message translates to:
  /// **'Search past orders...'**
  String get searchPastOrders;

  /// No description provided for @orderSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Order Submitted'**
  String get orderSubmitted;

  /// No description provided for @orderSubmittedDesc.
  ///
  /// In en, this message translates to:
  /// **'Waiting for restaurant approval.'**
  String get orderSubmittedDesc;

  /// No description provided for @preparingOrder.
  ///
  /// In en, this message translates to:
  /// **'Preparing your order'**
  String get preparingOrder;

  /// No description provided for @preparingOrderDesc.
  ///
  /// In en, this message translates to:
  /// **'The restaurant is preparing your food.'**
  String get preparingOrderDesc;

  /// No description provided for @headingToRestaurant.
  ///
  /// In en, this message translates to:
  /// **'Heading to Restaurant'**
  String get headingToRestaurant;

  /// No description provided for @headingToRestaurantDesc.
  ///
  /// In en, this message translates to:
  /// **'A delivery partner is heading to pick up your order.'**
  String get headingToRestaurantDesc;

  /// No description provided for @orderPickedUp.
  ///
  /// In en, this message translates to:
  /// **'Order Picked Up'**
  String get orderPickedUp;

  /// No description provided for @orderPickedUpDesc.
  ///
  /// In en, this message translates to:
  /// **'Driver has collected your food and is preparing delivery.'**
  String get orderPickedUpDesc;

  /// No description provided for @outForDelivery.
  ///
  /// In en, this message translates to:
  /// **'Out for Delivery'**
  String get outForDelivery;

  /// No description provided for @outForDeliveryDesc.
  ///
  /// In en, this message translates to:
  /// **'Driver is on the way to your location.'**
  String get outForDeliveryDesc;

  /// No description provided for @orderDelivered.
  ///
  /// In en, this message translates to:
  /// **'Order Delivered'**
  String get orderDelivered;

  /// No description provided for @orderDeliveredDesc.
  ///
  /// In en, this message translates to:
  /// **'Enjoy your meal!'**
  String get orderDeliveredDesc;

  /// No description provided for @deliveryFailed.
  ///
  /// In en, this message translates to:
  /// **'Delivery Failed'**
  String get deliveryFailed;

  /// No description provided for @deliveryFailedDesc.
  ///
  /// In en, this message translates to:
  /// **'There was an issue delivering your order.'**
  String get deliveryFailedDesc;

  /// No description provided for @orderCancelled.
  ///
  /// In en, this message translates to:
  /// **'Order Cancelled'**
  String get orderCancelled;

  /// No description provided for @orderCancelledDesc.
  ///
  /// In en, this message translates to:
  /// **'This order was cancelled.'**
  String get orderCancelledDesc;

  /// No description provided for @noItemsInMenu.
  ///
  /// In en, this message translates to:
  /// **'No items available in the menu.'**
  String get noItemsInMenu;

  /// No description provided for @exploreRestaurants.
  ///
  /// In en, this message translates to:
  /// **'Explore Restaurants'**
  String get exploreRestaurants;

  /// No description provided for @goShopping.
  ///
  /// In en, this message translates to:
  /// **'Go Shopping'**
  String get goShopping;

  /// No description provided for @clearBtn.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearBtn;

  /// No description provided for @rateRestaurant.
  ///
  /// In en, this message translates to:
  /// **'Rate Restaurant'**
  String get rateRestaurant;

  /// No description provided for @ratedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Rated successfully'**
  String get ratedSuccessfully;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @loginToYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Login to your account.'**
  String get loginToYourAccount;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @notificationDeliveredBody.
  ///
  /// In en, this message translates to:
  /// **'Your order has arrived successfully. Please rate your experience and leave a review.'**
  String get notificationDeliveredBody;

  /// No description provided for @deliveryInfo.
  ///
  /// In en, this message translates to:
  /// **'Delivery Info'**
  String get deliveryInfo;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @reviewsCount.
  ///
  /// In en, this message translates to:
  /// **'({count} reviews)'**
  String reviewsCount(int count);

  /// No description provided for @reviewsTab.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviewsTab;

  /// No description provided for @menuTab.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menuTab;

  /// No description provided for @noReviewsYet.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet.'**
  String get noReviewsYet;

  /// No description provided for @choiceOfSize.
  ///
  /// In en, this message translates to:
  /// **'Choice of size'**
  String get choiceOfSize;

  /// No description provided for @frequentlyBoughtTogether.
  ///
  /// In en, this message translates to:
  /// **'Frequently bought together'**
  String get frequentlyBoughtTogether;

  /// No description provided for @specialInstructions.
  ///
  /// In en, this message translates to:
  /// **'Special Instructions'**
  String get specialInstructions;

  /// No description provided for @specialInstructionsHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. No onions, please.'**
  String get specialInstructionsHint;

  /// No description provided for @addToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to Cart'**
  String get addToCart;

  /// No description provided for @popularMeals.
  ///
  /// In en, this message translates to:
  /// **'Popular Meals'**
  String get popularMeals;

  /// No description provided for @signUpToGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Sign up to get started.'**
  String get signUpToGetStarted;

  /// No description provided for @tax.
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get tax;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success!'**
  String get success;

  /// No description provided for @orderPlacedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Your order has been placed successfully.'**
  String get orderPlacedSuccessfully;

  /// No description provided for @viewMyOrders.
  ///
  /// In en, this message translates to:
  /// **'View My Orders'**
  String get viewMyOrders;

  /// No description provided for @addNoteToOrder.
  ///
  /// In en, this message translates to:
  /// **'Add a note to your order...'**
  String get addNoteToOrder;

  /// No description provided for @myAddresses.
  ///
  /// In en, this message translates to:
  /// **'My Addresses'**
  String get myAddresses;

  /// No description provided for @defaultAddress.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultAddress;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @adminDashboard.
  ///
  /// In en, this message translates to:
  /// **'Admin Dashboard'**
  String get adminDashboard;

  /// No description provided for @taxRate.
  ///
  /// In en, this message translates to:
  /// **'Tax Rate'**
  String get taxRate;

  /// No description provided for @applicationName.
  ///
  /// In en, this message translates to:
  /// **'Application Name'**
  String get applicationName;

  /// No description provided for @currencySettings.
  ///
  /// In en, this message translates to:
  /// **'Currency Settings'**
  String get currencySettings;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @searchUsers.
  ///
  /// In en, this message translates to:
  /// **'Search users...'**
  String get searchUsers;

  /// No description provided for @searchOrders.
  ///
  /// In en, this message translates to:
  /// **'Search orders...'**
  String get searchOrders;

  /// No description provided for @deliveryPartner.
  ///
  /// In en, this message translates to:
  /// **'Delivery Partner'**
  String get deliveryPartner;

  /// No description provided for @editProfileDetails.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile Details'**
  String get editProfileDetails;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @confirmLogout.
  ///
  /// In en, this message translates to:
  /// **'Confirm Logout'**
  String get confirmLogout;

  /// No description provided for @logoutConfirmationText.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logoutConfirmationText;

  /// No description provided for @acceptDelivery.
  ///
  /// In en, this message translates to:
  /// **'Accept Delivery'**
  String get acceptDelivery;

  /// No description provided for @updateStatus.
  ///
  /// In en, this message translates to:
  /// **'Update Status'**
  String get updateStatus;

  /// No description provided for @navigate.
  ///
  /// In en, this message translates to:
  /// **'Navigate'**
  String get navigate;

  /// No description provided for @trackNavigate.
  ///
  /// In en, this message translates to:
  /// **'Track / Navigate'**
  String get trackNavigate;

  /// No description provided for @mealDetails.
  ///
  /// In en, this message translates to:
  /// **'Meal Details'**
  String get mealDetails;

  /// No description provided for @restaurantDetails.
  ///
  /// In en, this message translates to:
  /// **'Restaurant Details'**
  String get restaurantDetails;

  /// No description provided for @shareExperience.
  ///
  /// In en, this message translates to:
  /// **'Share details of your experience...'**
  String get shareExperience;

  /// No description provided for @howWasYourOrder.
  ///
  /// In en, this message translates to:
  /// **'How was your order?'**
  String get howWasYourOrder;

  /// No description provided for @feedbackHelpsImprove.
  ///
  /// In en, this message translates to:
  /// **'Your feedback helps us and the restaurant improve your next dining experience.'**
  String get feedbackHelpsImprove;

  /// No description provided for @writeReviewOptional.
  ///
  /// In en, this message translates to:
  /// **'Write a Review (Optional)'**
  String get writeReviewOptional;

  /// No description provided for @ratingStars.
  ///
  /// In en, this message translates to:
  /// **'Rating: {rating} / 5 Stars'**
  String ratingStars(int rating);

  /// No description provided for @small.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get small;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @large.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get large;

  /// No description provided for @extraCheese.
  ///
  /// In en, this message translates to:
  /// **'Extra Cheese'**
  String get extraCheese;

  /// No description provided for @bacon.
  ///
  /// In en, this message translates to:
  /// **'Bacon'**
  String get bacon;

  /// No description provided for @avocado.
  ///
  /// In en, this message translates to:
  /// **'Avocado'**
  String get avocado;

  /// No description provided for @demoCity.
  ///
  /// In en, this message translates to:
  /// **'Demo City'**
  String get demoCity;

  /// No description provided for @cairo.
  ///
  /// In en, this message translates to:
  /// **'Cairo'**
  String get cairo;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Discover Gourmet Food'**
  String get onboardingTitle1;

  /// No description provided for @onboardingDesc1.
  ///
  /// In en, this message translates to:
  /// **'Explore the best restaurants and premium food near you.'**
  String get onboardingDesc1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Fast Delivery'**
  String get onboardingTitle2;

  /// No description provided for @onboardingDesc2.
  ///
  /// In en, this message translates to:
  /// **'Get your favorite food delivered directly to your doorstep.'**
  String get onboardingDesc2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Live Tracking'**
  String get onboardingTitle3;

  /// No description provided for @onboardingDesc3.
  ///
  /// In en, this message translates to:
  /// **'Track your order in real-time on a premium map.'**
  String get onboardingDesc3;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @continueText.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueText;

  /// No description provided for @tabDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get tabDashboard;

  /// No description provided for @tabOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get tabOrders;

  /// No description provided for @tabRestaurants.
  ///
  /// In en, this message translates to:
  /// **'Restaurants'**
  String get tabRestaurants;

  /// No description provided for @tabMeals.
  ///
  /// In en, this message translates to:
  /// **'Meals'**
  String get tabMeals;

  /// No description provided for @tabCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get tabCategories;

  /// No description provided for @tabUsers.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get tabUsers;

  /// No description provided for @tabAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get tabAnalytics;

  /// No description provided for @tabSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get tabSettings;

  /// No description provided for @addRestaurant.
  ///
  /// In en, this message translates to:
  /// **'Add Restaurant'**
  String get addRestaurant;

  /// No description provided for @addMeal.
  ///
  /// In en, this message translates to:
  /// **'Add Meal'**
  String get addMeal;

  /// No description provided for @addCategory.
  ///
  /// In en, this message translates to:
  /// **'Add Category'**
  String get addCategory;

  /// No description provided for @addUser.
  ///
  /// In en, this message translates to:
  /// **'Add User'**
  String get addUser;

  /// No description provided for @saveSettings.
  ///
  /// In en, this message translates to:
  /// **'Save Settings'**
  String get saveSettings;

  /// No description provided for @sendBroadcast.
  ///
  /// In en, this message translates to:
  /// **'Send Broadcast'**
  String get sendBroadcast;

  /// No description provided for @searchOrders2.
  ///
  /// In en, this message translates to:
  /// **'Search orders by ID, restaurant, or address...'**
  String get searchOrders2;

  /// No description provided for @searchUsers2.
  ///
  /// In en, this message translates to:
  /// **'Search users by name, email, phone, or role...'**
  String get searchUsers2;

  /// No description provided for @statTotalRevenue.
  ///
  /// In en, this message translates to:
  /// **'Total Revenue'**
  String get statTotalRevenue;

  /// No description provided for @statTotalOrders.
  ///
  /// In en, this message translates to:
  /// **'Total Orders'**
  String get statTotalOrders;

  /// No description provided for @statPendingOrders.
  ///
  /// In en, this message translates to:
  /// **'Pending Orders'**
  String get statPendingOrders;

  /// No description provided for @statRestaurants.
  ///
  /// In en, this message translates to:
  /// **'Restaurants'**
  String get statRestaurants;

  /// No description provided for @statMealsAvailable.
  ///
  /// In en, this message translates to:
  /// **'Meals Available'**
  String get statMealsAvailable;

  /// No description provided for @statCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get statCategories;

  /// No description provided for @statActiveDrivers.
  ///
  /// In en, this message translates to:
  /// **'Active Drivers'**
  String get statActiveDrivers;

  /// No description provided for @statUsersRegistered.
  ///
  /// In en, this message translates to:
  /// **'Users Registered'**
  String get statUsersRegistered;

  /// No description provided for @latestOrders.
  ///
  /// In en, this message translates to:
  /// **'Latest Orders'**
  String get latestOrders;

  /// No description provided for @topRestaurants.
  ///
  /// In en, this message translates to:
  /// **'Top Restaurants'**
  String get topRestaurants;

  /// No description provided for @noOrdersYet.
  ///
  /// In en, this message translates to:
  /// **'No orders yet.'**
  String get noOrdersYet;

  /// No description provided for @noPerformanceData.
  ///
  /// In en, this message translates to:
  /// **'No performance data.'**
  String get noPerformanceData;

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusLabel;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing'**
  String get statusPreparing;

  /// No description provided for @statusHeadingToRestaurant.
  ///
  /// In en, this message translates to:
  /// **'Heading to Restaurant'**
  String get statusHeadingToRestaurant;

  /// No description provided for @statusPickedUp.
  ///
  /// In en, this message translates to:
  /// **'Picked Up'**
  String get statusPickedUp;

  /// No description provided for @statusOutForDelivery.
  ///
  /// In en, this message translates to:
  /// **'Out for Delivery'**
  String get statusOutForDelivery;

  /// No description provided for @statusDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get statusDelivered;

  /// No description provided for @statusFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get statusFailed;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @allStatuses.
  ///
  /// In en, this message translates to:
  /// **'All Statuses'**
  String get allStatuses;

  /// No description provided for @filterStatus.
  ///
  /// In en, this message translates to:
  /// **'Filter Status'**
  String get filterStatus;

  /// No description provided for @noMatchingOrders.
  ///
  /// In en, this message translates to:
  /// **'No matching orders found.'**
  String get noMatchingOrders;

  /// No description provided for @orderDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Order #{id} Details'**
  String orderDetailsTitle(Object id);

  /// No description provided for @restaurantLabel.
  ///
  /// In en, this message translates to:
  /// **'Restaurant'**
  String get restaurantLabel;

  /// No description provided for @customerAddress.
  ///
  /// In en, this message translates to:
  /// **'Customer Address'**
  String get customerAddress;

  /// No description provided for @itemsLabel.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get itemsLabel;

  /// No description provided for @notesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesLabel;

  /// No description provided for @activeStatus.
  ///
  /// In en, this message translates to:
  /// **'Active Status'**
  String get activeStatus;

  /// No description provided for @simulateImageUpload.
  ///
  /// In en, this message translates to:
  /// **'Simulate Image Upload'**
  String get simulateImageUpload;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @restaurantImage.
  ///
  /// In en, this message translates to:
  /// **'Restaurant Image'**
  String get restaurantImage;

  /// No description provided for @driverDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get driverDashboard;

  /// No description provided for @driverOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get driverOrders;

  /// No description provided for @driverHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get driverHistory;

  /// No description provided for @driverProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get driverProfile;

  /// No description provided for @acceptDeliveryBtn.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get acceptDeliveryBtn;

  /// No description provided for @rejectBtn.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get rejectBtn;

  /// No description provided for @markPickedUp.
  ///
  /// In en, this message translates to:
  /// **'Mark as Picked Up'**
  String get markPickedUp;

  /// No description provided for @markDelivered.
  ///
  /// In en, this message translates to:
  /// **'Mark as Delivered'**
  String get markDelivered;

  /// No description provided for @markFailed.
  ///
  /// In en, this message translates to:
  /// **'Mark as Failed'**
  String get markFailed;

  /// No description provided for @assignedOrders.
  ///
  /// In en, this message translates to:
  /// **'Assigned Orders'**
  String get assignedOrders;

  /// No description provided for @deliveryHistory.
  ///
  /// In en, this message translates to:
  /// **'Delivery History'**
  String get deliveryHistory;

  /// No description provided for @noAssignedOrders.
  ///
  /// In en, this message translates to:
  /// **'No assigned orders.'**
  String get noAssignedOrders;

  /// No description provided for @noDeliveryHistory.
  ///
  /// In en, this message translates to:
  /// **'No delivery history yet.'**
  String get noDeliveryHistory;

  /// No description provided for @totalDeliveries.
  ///
  /// In en, this message translates to:
  /// **'Total Deliveries'**
  String get totalDeliveries;

  /// No description provided for @successRate.
  ///
  /// In en, this message translates to:
  /// **'Success Rate'**
  String get successRate;

  /// No description provided for @totalEarnings.
  ///
  /// In en, this message translates to:
  /// **'Total Earnings'**
  String get totalEarnings;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @order.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get order;

  /// No description provided for @analyticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analyticsTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @broadcastTitle.
  ///
  /// In en, this message translates to:
  /// **'Send Broadcast Notification'**
  String get broadcastTitle;

  /// No description provided for @enterMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter notification message here...'**
  String get enterMessage;

  /// No description provided for @selectStatus.
  ///
  /// In en, this message translates to:
  /// **'Select Status'**
  String get selectStatus;

  /// No description provided for @assignDriver.
  ///
  /// In en, this message translates to:
  /// **'Assign Driver'**
  String get assignDriver;

  /// No description provided for @noDriverAvailable.
  ///
  /// In en, this message translates to:
  /// **'No driver available'**
  String get noDriverAvailable;

  /// No description provided for @updateOrder.
  ///
  /// In en, this message translates to:
  /// **'Update Order'**
  String get updateOrder;

  /// No description provided for @todayPayout.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Payout'**
  String get todayPayout;

  /// No description provided for @weeklyPayout.
  ///
  /// In en, this message translates to:
  /// **'Weekly Payout'**
  String get weeklyPayout;

  /// No description provided for @monthlyPayout.
  ///
  /// In en, this message translates to:
  /// **'Monthly Payout'**
  String get monthlyPayout;

  /// No description provided for @completedDeliveries.
  ///
  /// In en, this message translates to:
  /// **'Completed Deliveries'**
  String get completedDeliveries;

  /// No description provided for @tripsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Trips'**
  String tripsCount(int count);

  /// No description provided for @performanceOverview.
  ///
  /// In en, this message translates to:
  /// **'Performance Overview'**
  String get performanceOverview;

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettings;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get requiredField;

  /// No description provided for @markAllAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllAsRead;

  /// No description provided for @noNotificationsYet.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotificationsYet;

  /// No description provided for @delivryHub.
  ///
  /// In en, this message translates to:
  /// **'Delivry Hub'**
  String get delivryHub;

  /// No description provided for @platformControl.
  ///
  /// In en, this message translates to:
  /// **'Platform Control'**
  String get platformControl;

  /// No description provided for @manageRestaurants.
  ///
  /// In en, this message translates to:
  /// **'Manage Restaurants'**
  String get manageRestaurants;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @selectUploadImage.
  ///
  /// In en, this message translates to:
  /// **'Select / Upload Image'**
  String get selectUploadImage;

  /// No description provided for @uploadingFile.
  ///
  /// In en, this message translates to:
  /// **'Uploading File...'**
  String get uploadingFile;

  /// No description provided for @chooseFromPremiumPresets.
  ///
  /// In en, this message translates to:
  /// **'Choose from Premium Presets:'**
  String get chooseFromPremiumPresets;

  /// No description provided for @orEnterCustomImageUrl.
  ///
  /// In en, this message translates to:
  /// **'Or Enter Custom Image URL:'**
  String get orEnterCustomImageUrl;

  /// No description provided for @applyUrl.
  ///
  /// In en, this message translates to:
  /// **'Apply URL'**
  String get applyUrl;

  /// No description provided for @mockLocalFileUpload.
  ///
  /// In en, this message translates to:
  /// **'Mock Local File Upload'**
  String get mockLocalFileUpload;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirmDelete;

  /// No description provided for @areYouSureYouWantToDeleteThisEntityThisActionIsDestructiveAndCannotBeUndone.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this entity? This action is destructive and cannot be undone.'**
  String
  get areYouSureYouWantToDeleteThisEntityThisActionIsDestructiveAndCannotBeUndone;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @manageMeals.
  ///
  /// In en, this message translates to:
  /// **'Manage Meals'**
  String get manageMeals;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @restaurantRestname.
  ///
  /// In en, this message translates to:
  /// **'Restaurant: {restName}'**
  String restaurantRestname(String restName);

  /// No description provided for @mealImage.
  ///
  /// In en, this message translates to:
  /// **'Meal Image'**
  String get mealImage;

  /// No description provided for @availableStatus.
  ///
  /// In en, this message translates to:
  /// **'Available Status'**
  String get availableStatus;

  /// No description provided for @manageCategories.
  ///
  /// In en, this message translates to:
  /// **'Manage Categories'**
  String get manageCategories;

  /// No description provided for @visible.
  ///
  /// In en, this message translates to:
  /// **'Visible'**
  String get visible;

  /// No description provided for @categoryImage.
  ///
  /// In en, this message translates to:
  /// **'Category Image'**
  String get categoryImage;

  /// No description provided for @selectPhoto.
  ///
  /// In en, this message translates to:
  /// **'Select Photo'**
  String get selectPhoto;

  /// No description provided for @visibleOnAppHome.
  ///
  /// In en, this message translates to:
  /// **'Visible on App Home'**
  String get visibleOnAppHome;

  /// No description provided for @assignRestaurantsToCategory.
  ///
  /// In en, this message translates to:
  /// **'Assign Restaurants to Category'**
  String get assignRestaurantsToCategory;

  /// No description provided for @noRestaurantsRegisteredToAssign.
  ///
  /// In en, this message translates to:
  /// **'No restaurants registered to assign.'**
  String get noRestaurantsRegisteredToAssign;

  /// No description provided for @usersManagement.
  ///
  /// In en, this message translates to:
  /// **'Users Management'**
  String get usersManagement;

  /// No description provided for @filterRole.
  ///
  /// In en, this message translates to:
  /// **'Filter Role'**
  String get filterRole;

  /// No description provided for @noUsersMatchingTheFilters.
  ///
  /// In en, this message translates to:
  /// **'No users matching the filters.'**
  String get noUsersMatchingTheFilters;

  /// No description provided for @deactivated.
  ///
  /// In en, this message translates to:
  /// **'Deactivated'**
  String get deactivated;

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'(You)'**
  String get you;

  /// No description provided for @userProfileDetails.
  ///
  /// In en, this message translates to:
  /// **'User Profile Details'**
  String get userProfileDetails;

  /// No description provided for @roleRoledisplay.
  ///
  /// In en, this message translates to:
  /// **'Role: {roleDisplay}'**
  String roleRoledisplay(String roleDisplay);

  /// No description provided for @customer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customer;

  /// No description provided for @driver.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get driver;

  /// No description provided for @admin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admin;

  /// No description provided for @analyticsPerformanceReports.
  ///
  /// In en, this message translates to:
  /// **'Analytics & Performance Reports'**
  String get analyticsPerformanceReports;

  /// No description provided for @revenueReportsLast7Days.
  ///
  /// In en, this message translates to:
  /// **'Revenue Reports (Last 7 Days)'**
  String get revenueReportsLast7Days;

  /// No description provided for @noRevenueDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No revenue data available.'**
  String get noRevenueDataAvailable;

  /// No description provided for @topSellingMeals.
  ///
  /// In en, this message translates to:
  /// **'Top Selling Meals'**
  String get topSellingMeals;

  /// No description provided for @noSalesRecords.
  ///
  /// In en, this message translates to:
  /// **'No sales records.'**
  String get noSalesRecords;

  /// No description provided for @systemConfigurations.
  ///
  /// In en, this message translates to:
  /// **'System Configurations'**
  String get systemConfigurations;

  /// No description provided for @broadcastNotification.
  ///
  /// In en, this message translates to:
  /// **'Broadcast Notification'**
  String get broadcastNotification;

  /// No description provided for @sendAnInstantBroadcastPushNotificationToAllActiveCustomerDevices.
  ///
  /// In en, this message translates to:
  /// **'Send an instant broadcast push notification to all active customer devices.'**
  String get sendAnInstantBroadcastPushNotificationToAllActiveCustomerDevices;

  /// No description provided for @enterNotificationMessageHere.
  ///
  /// In en, this message translates to:
  /// **'Enter notification message here...'**
  String get enterNotificationMessageHere;

  /// No description provided for @deliveryFeeLabel.
  ///
  /// In en, this message translates to:
  /// **'Delivery Fee'**
  String get deliveryFeeLabel;

  /// No description provided for @priceLabel.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get priceLabel;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// No description provided for @restaurantLabel2.
  ///
  /// In en, this message translates to:
  /// **'Restaurant'**
  String get restaurantLabel2;

  /// No description provided for @visibilityLabel.
  ///
  /// In en, this message translates to:
  /// **'Visibility'**
  String get visibilityLabel;

  /// No description provided for @assignedRestaurantsLabel.
  ///
  /// In en, this message translates to:
  /// **'Assigned Restaurants'**
  String get assignedRestaurantsLabel;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneLabel;

  /// No description provided for @roleLabel.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get roleLabel;

  /// No description provided for @unitsSoldLabel.
  ///
  /// In en, this message translates to:
  /// **'Units Sold'**
  String get unitsSoldLabel;

  /// No description provided for @visibleStatus.
  ///
  /// In en, this message translates to:
  /// **'Visible'**
  String get visibleStatus;

  /// No description provided for @hiddenStatus.
  ///
  /// In en, this message translates to:
  /// **'Hidden'**
  String get hiddenStatus;

  /// No description provided for @naLabel.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get naLabel;

  /// No description provided for @inactiveStatus.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactiveStatus;

  /// No description provided for @yesLabel.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yesLabel;

  /// No description provided for @noLabel.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get noLabel;

  /// No description provided for @accountStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Account Status'**
  String get accountStatusLabel;

  /// No description provided for @allFilter.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allFilter;

  /// No description provided for @orderLabel.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get orderLabel;

  /// No description provided for @activateUser.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get activateUser;

  /// No description provided for @deactivateUser.
  ///
  /// In en, this message translates to:
  /// **'Deactivate'**
  String get deactivateUser;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
