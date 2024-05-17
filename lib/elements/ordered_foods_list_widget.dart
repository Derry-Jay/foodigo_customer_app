import 'package:flutter/material.dart';
import 'package:foodigo_customer_app/controllers/hotel_controller.dart';
import 'package:foodigo_customer_app/elements/circular_loader.dart';
import 'package:foodigo_customer_app/models/order.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class OrderedFoodsListWidget extends StatefulWidget {
  final Order order;
  OrderedFoodsListWidget({Key key, @required this.order}) : super(key: key);
  @override
  OrderedFoodsListWidgetState createState() => OrderedFoodsListWidgetState();
}

class OrderedFoodsListWidgetState extends StateMVC<OrderedFoodsListWidget> {
  HotelController con;
  MediaQueryData get dimensions => MediaQuery.of(context);
  Size get size => dimensions.size;
  double get width => size.width;
  OrderedFoodsListWidgetState() : super(HotelController()) {
    con = controller;
  }

  void getData() async {
    await con.waitForOrderedFood(widget.order.orderID);
  }

  Widget getItemBuilder(BuildContext context, int index) => Container(
      padding: const EdgeInsets.all(10),
      child: Row(children: [
        Container(
          width: width / 1.8,
          child: Text(
              con.orderedFoods[index].food +
                  " x " +
                  con.orderedFoods[index].quantity.toString(),
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.w500)),
        ),
        Text(
            "₹ " +
                ((double.tryParse(con.orderedFoods[index].price ?? "0.0") ??
                            0.0) *
                        con.orderedFoods[index].quantity)
                    .toString(),
            style: TextStyle(color: Colors.black))
      ], mainAxisAlignment: MainAxisAlignment.spaceBetween)
      // padding: EdgeInsets.symmetric(vertical: size.height / 160)
      );

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return con.orderedFoods == null
        ? CircularLoader(
            widthFactor: 10, heightFactor: 10, color: Color(0xffa11414))
        : (con.orderedFoods.isEmpty
            ? Center(child: Text("No Foods found"))
            : ListView.builder(
                itemBuilder: getItemBuilder,
                itemCount: con.orderedFoods.length));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }
}
