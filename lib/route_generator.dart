import 'package:flutter/material.dart';
import 'package:foodigo_customer_app/models/address.dart';
import 'package:foodigo_customer_app/models/cart.dart';
import 'package:foodigo_customer_app/models/category.dart';
import 'package:foodigo_customer_app/models/cuisine.dart';
import 'package:foodigo_customer_app/models/customer.dart';
import 'package:foodigo_customer_app/models/order.dart';
import 'package:foodigo_customer_app/models/route_argument.dart';
import 'package:foodigo_customer_app/pages/add_atm_card_page.dart';
import 'package:foodigo_customer_app/pages/address_add_page.dart';
import 'package:foodigo_customer_app/pages/address_edit_page.dart';
import 'package:foodigo_customer_app/pages/addresses_page.dart';
import 'package:foodigo_customer_app/pages/app_pages.dart';
import 'package:foodigo_customer_app/pages/cart_page.dart';
import 'package:foodigo_customer_app/pages/category_based_hotels_page.dart';
import 'package:foodigo_customer_app/pages/coupons_page.dart';
import 'package:foodigo_customer_app/pages/current_orders_page.dart';
import 'package:foodigo_customer_app/pages/help&support.dart';
import 'package:foodigo_customer_app/pages/hotel_details_page.dart';
import 'package:foodigo_customer_app/pages/mobile_login_page.dart';
import 'package:foodigo_customer_app/pages/offers_page.dart';
import 'package:foodigo_customer_app/pages/order_details_page.dart';
import 'package:foodigo_customer_app/pages/order_tracking_page.dart';
import 'package:foodigo_customer_app/pages/orders_page.dart';
import 'package:foodigo_customer_app/pages/otp_verification_page.dart';
import 'package:foodigo_customer_app/pages/payment_method_page.dart';
import 'package:foodigo_customer_app/pages/profile_update_page.dart';
import 'package:foodigo_customer_app/pages/saved_online_payment_methods_page.dart';
import 'package:foodigo_customer_app/pages/search_hotels_page.dart';
import 'package:foodigo_customer_app/pages/search_locations_page.dart';
import 'package:foodigo_customer_app/pages/sorted_hotels_page.dart';
import 'package:foodigo_customer_app/pages/user_details_page.dart';
import 'package:foodigo_customer_app/pages/user_location_page.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Getting arguments passed in while calling Navigator.pushNamed
    final args = settings.arguments;
    switch (settings.name) {
      case '/login':
        return MaterialPageRoute(builder: (_) => MobileLoginPage());
      case '/pages':
        return MaterialPageRoute(
            builder: (_) => AppPages(args as RouteArgument));
      case '/hotels':
        return MaterialPageRoute(
            builder: (_) => SearchHotelsPage(args as RouteArgument));
      case '/hotelDetails':
        return MaterialPageRoute(
            builder: (_) => HotelDetailsPage(args as RouteArgument));
      case '/cart':
        return MaterialPageRoute(
            builder: (_) => CartPage(args as RouteArgument));
      case '/addLocation':
        return MaterialPageRoute(builder: (_) => AddressAddPage());
      case '/paymentMethod':
        return MaterialPageRoute(
            builder: (_) => PaymentMethodPage(args as RouteArgument));
      case '/searchLocation':
        return MaterialPageRoute(builder: (_) => SearchLocationPage());
      case '/orders':
        return MaterialPageRoute(builder: (_) => OrdersPage());
      case '/catHotels':
        return MaterialPageRoute(
            builder: (_) => CategoryBasedHotelsPage(args as Category));
      case '/profileEdit':
        return MaterialPageRoute(
            builder: (_) => ProfileUpdatePage(args as Customer));
      case '/cuisineHotels':
        return MaterialPageRoute(
            builder: (_) => CuisineBasedHotelsPage(args as Cuisine));
      case '/currentOrders':
        return MaterialPageRoute(
            builder: (_) => CurrentOrdersPage(
                  routePath: args,
                ));
      case '/editAddress':
        return MaterialPageRoute(
            builder: (_) => AddressEditPage(args as WhereAbouts));
      case '/addresses':
        return MaterialPageRoute(builder: (context) => AddressesPage());
      case '/trackOrder':
        return MaterialPageRoute(
            builder: (_) => OrderTrackingPage(args as Order));
      case '/orderDetails':
        return MaterialPageRoute(
            builder: (_) => OrderDetailsPage(args as Order));
      case '/offers':
        return MaterialPageRoute(builder: (_) => OffersPage());
      case '/coupons':
        return MaterialPageRoute(builder: (_) => CouponsPage(args as Cart));
      case '/help':
        return MaterialPageRoute(builder: (_) => HelpandSupport());
      case '/verifyOTP':
        return MaterialPageRoute(
            builder: (_) => OtpPage(args as RouteArgument));
      case '/registerAddress':
        return MaterialPageRoute(
            builder: (_) => UserLocationPage(args as RouteArgument));
      case '/register':
        return MaterialPageRoute(
            builder: (_) => UserDetailsPage(args as RouteArgument));
      case '/savedOnlinePaymentMethods':
        return MaterialPageRoute(
            builder: (_) =>
                SavedOnlinePaymentMethodsPage(rar: args as RouteArgument));
      case '/addCard':
        return MaterialPageRoute(builder: (_) => AddATMCardPage());
      default:
        return MaterialPageRoute(
            builder: (_) => SafeArea(
                    child: Scaffold(
                  body: Text("Route Error"),
                )));
    }
  }
}

// MaterialPageRoute(builder: (_) => Page())
