import 'package:flutter/material.dart';
import 'package:foodigo_customer_app/controllers/hotel_controller.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker/google_maps_place_picker.dart';
import 'package:location/location.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchLocationPage extends StatefulWidget {
  @override
  SearchLocationPageState createState() => SearchLocationPageState();
}

class SearchLocationPageState extends StateMVC<SearchLocationPage> {
  HotelController con;
  TextEditingController tc = new TextEditingController();
  Future<SharedPreferences> _sharePrefs = SharedPreferences.getInstance();

  SearchLocationPageState() : super(HotelController()) {
    con = controller;
  }

  void getData() async {
    final sharedPrefs = await _sharePrefs;
    print(sharedPrefs.containsKey("cartData"));
// print(rar.heroTag);
  }

  @override
  Widget build(BuildContext context) {
    getData();
    return Scaffold(
        appBar: AppBar(
            title: Text("Success"),
            centerTitle: true,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0),
        body: Center(
            child: Column(children: [
          Text("Your Order was placed",
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
          Text(" Successfully !!!!",
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 32,
                  color: Colors.green)),
          Expanded(
              child: PlacePicker(
            apiKey: "AIzaSyDri0IFhjPdlw4xJk8mT9HHwsaB7nDmdVw",
            initialPosition: con.curLoc,
            useCurrentLocation: true,
            selectInitialPosition: true,

            usePlaceDetailSearch: true,
            onPlacePicked: (result) {
              con.selectedPlace = result;
              // Navigator.of(context).pop();
              // setState(() {});
            },
            //forceSearchOnZoomChanged: true,
            //automaticallyImplyAppBarLeading: false,
            //autocompleteLanguage: "ko",
            //region: 'au',
            //selectInitialPosition: true,
            // selectedPlaceWidgetBuilder: (_, selectedPlace, state, isSearchBarFocused) {
            //   print("state: $state, isSearchBarFocused: $isSearchBarFocused");
            //   return isSearchBarFocused
            //       ? Container()
            //       : FloatingCard(
            //           bottomPosition: 0.0, // MediaQuery.of(context) will cause rebuild. See MediaQuery document for the information.
            //           leftPosition: 0.0,
            //           rightPosition: 0.0,
            //           width: 500,
            //           borderRadius: BorderRadius.circular(12.0),
            //           child: state == SearchingState.Searching
            //               ? Center(child: CircularProgressIndicator())
            //               : RaisedButton(
            //                   child: Text("Pick Here"),
            //                   onPressed: () {
            //                     // IMPORTANT: You MUST manage selectedPlace data yourself as using this build will not invoke onPlacePicker as
            //                     //            this will override default 'Select here' Button.
            //                     print("do something with [selectedPlace] data");
            //                     Navigator.of(context).pop();
            //                   },
            //                 ),
            //         );
            // },
            // pinBuilder: (context, state) {
            //   if (state == PinState.Idle) {
            //     return Icon(Icons.favorite_border);
            //   } else {
            //     return Icon(Icons.favorite);
            //   }
            // },
          ))
        ], mainAxisAlignment: MainAxisAlignment.center)));
  }

  void getCurrentLocation() async {
    try {
      final location = new Location();
      // final permission = await location.hasPermission();
      con.currentLocation = await location.getLocation();
      if (con.currentLocation.latitude != 0.0 &&
          con.currentLocation.longitude != 0.0) {
        print("locationLatitude: ${con.currentLocation.latitude}");
        print("locationLongitude: ${con.currentLocation.longitude}");
        final coordinates = new Coordinates(
            con.currentLocation.latitude, con.currentLocation.longitude);
        final ads =
            await Geocoder.local.findAddressesFromCoordinates(coordinates);
        final ad = ads.first;
        setState(() {
          con.curLoc = LatLng(
              con.currentLocation.latitude, con.currentLocation.longitude);
          con.initialCameraPosition = CameraPosition(
            bearing: 0,
            target: con.curLoc,
            zoom: 17.0,
          );
          // d1 = ad.subLocality == null || ad.subLocality.isEmpty
          //     ? ad.featureName
          //     : ad.subLocality;
          // d2 = (ad.subAdminArea ?? ad.locality) + " - " + ad.postalCode;
          tc.text = ad.addressLine;
        });
      } else
        setState(() => con.initialCameraPosition =
            CameraPosition(target: LatLng(13.0827, 80.2707), zoom: 17));
    } catch (e) {
      print(e);
      con.currentLocation = null;
      setState(() => con.initialCameraPosition =
          CameraPosition(target: LatLng(13.0827, 80.2707), zoom: 17));
      throw e;
    }
  }
}
