import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:foodigo_customer_app/helpers/functions.dart';
import 'package:foodigo_customer_app/helpers/helper.dart';

enum LoaderType {
  Normal,
  RotatingPlain,
  DoubleBounce,
  Wave,
  WanderingCubes,
  FadingFour,
  FadingCube,
  Pulse,
  ChasingDots,
  ThreeBounce,
  Circle,
  CubeGrid,
  FadingCircle,
  RotatingCircle,
  FoldingCube,
  PumpingHeart,
  DualRing,
  HourGlass,
  PouringHourGlass,
  FadingGrid,
  Ring,
  Ripple,
  SpinningCircle,
  SquareCircle
}

class CircularLoader extends StatefulWidget {
  final Duration duration;
  final double heightFactor, widthFactor;
  final LoaderType loaderType;
  final Color color;

  CircularLoader(
      {Key key,
      this.duration,
      this.loaderType,
      @required this.widthFactor,
      @required this.heightFactor,
      @required this.color})
      : assert(!(loaderType == LoaderType.Normal ||
                loaderType == null ||
                duration == null) ||
            (Functions()
                    .xor(loaderType == null, loaderType == LoaderType.Normal) &&
                duration == null)),
        super(key: key);

  @override
  CircularLoaderState createState() => CircularLoaderState();
}

class CircularLoaderState extends State<CircularLoader>
    with SingleTickerProviderStateMixin {
  Animation<double> animation;
  AnimationController animationController;
  Helper get hp => Helper.of(context);
  double get length => hp.radius / (widget.heightFactor + widget.widthFactor);
  Timer get tm =>
      Timer(widget.duration ?? Duration(seconds: 10), moveForwardIfMounted);

  void refreshIfMounted() {
    if (mounted) setState(() {});
  }

  void moveForwardIfMounted() {
    if (mounted) animationController.forward();
  }

  void getData() {
    animationController = AnimationController(
        duration: widget.duration ?? Duration(milliseconds: 300), vsync: this);
    CurvedAnimation curve =
        CurvedAnimation(parent: animationController, curve: Curves.easeOut);
    animation = Tween<double>(begin: hp.height / widget.heightFactor, end: 0)
        .animate(curve)
      ..addListener(refreshIfMounted);
  }

  void assignState() {
    Future.delayed(Duration.zero, getData);
  }

  @override
  Widget build(BuildContext context) {
    final opacity = animation == null
        ? 1.0
        : (animation.value > 100.0 ? 1.0 : animation.value / 100);
    Widget lc;
    switch (widget.loaderType) {
      case LoaderType.ChasingDots:
        lc = SpinKitChasingDots(
            color: widget.color, duration: widget.duration, size: length);
        break;
      case LoaderType.Circle:
        lc = SpinKitCircle(
            color: widget.color,
            duration: widget.duration,
            controller: animationController,
            size: length);
        break;
      case LoaderType.Ring:
        lc = SpinKitRing(
            color: widget.color,
            duration: widget.duration,
            controller: animationController,
            size: length);
        break;
      case LoaderType.CubeGrid:
        lc = SpinKitCubeGrid(
            color: widget.color,
            duration: widget.duration,
            controller: animationController,
            size: length);
        break;
      case LoaderType.DoubleBounce:
        lc = SpinKitDoubleBounce(
            color: widget.color,
            duration: widget.duration,
            controller: animationController,
            size: length);
        break;
      case LoaderType.DualRing:
        lc = SpinKitDualRing(
            color: widget.color,
            duration: widget.duration,
            controller: animationController,
            size: length);
        break;
      case LoaderType.FadingCircle:
        lc = SpinKitFadingCircle(
            color: widget.color,
            duration: widget.duration,
            controller: animationController,
            size: length);
        break;
      case LoaderType.FadingCube:
        lc = SpinKitFadingCube(
            color: widget.color,
            duration: widget.duration,
            controller: animationController,
            size: length);
        break;
      case LoaderType.FadingFour:
        lc = SpinKitFadingFour(
            color: widget.color,
            duration: widget.duration,
            controller: animationController,
            size: length);
        break;
      case LoaderType.FadingGrid:
        lc = SpinKitFadingGrid(
            color: widget.color,
            duration: widget.duration,
            controller: animationController,
            size: length);
        break;
      case LoaderType.FoldingCube:
        lc = SpinKitFoldingCube(
            color: widget.color,
            duration: widget.duration,
            controller: animationController,
            size: length);
        break;
      case LoaderType.HourGlass:
        lc = SpinKitHourGlass(
            color: widget.color,
            duration: widget.duration,
            controller: animationController,
            size: length);
        break;
      case LoaderType.PouringHourGlass:
        lc = SpinKitPouringHourglass(
            color: widget.color,
            duration: widget.duration,
            controller: animationController,
            size: length);
        break;
      case LoaderType.Pulse:
        lc = SpinKitPulse(
            color: widget.color,
            duration: widget.duration,
            controller: animationController,
            size: length);
        break;
      case LoaderType.PumpingHeart:
        lc = SpinKitPumpingHeart(
            color: widget.color,
            duration: widget.duration,
            controller: animationController,
            size: length);
        break;
      case LoaderType.Ripple:
        lc = SpinKitRipple(
            color: widget.color, duration: widget.duration, size: length);
        break;
      case LoaderType.RotatingCircle:
        lc = SpinKitRotatingCircle(
            color: widget.color,
            duration: widget.duration,
            controller: animationController,
            size: length);
        break;
      case LoaderType.RotatingPlain:
        lc = SpinKitRotatingPlain(
            color: widget.color,
            duration: widget.duration,
            controller: animationController,
            size: length);
        break;
      case LoaderType.SpinningCircle:
        lc = SpinKitSpinningCircle(
            color: widget.color,
            duration: widget.duration,
            controller: animationController,
            size: length);
        break;
      case LoaderType.SquareCircle:
        lc = SpinKitSquareCircle(
            color: widget.color,
            duration: widget.duration,
            controller: animationController,
            size: length);
        break;
      case LoaderType.ThreeBounce:
        lc = SpinKitThreeBounce(
            color: widget.color,
            duration: widget.duration,
            controller: animationController,
            size: length);
        break;
      case LoaderType.WanderingCubes:
        lc = SpinKitWanderingCubes(
            color: widget.color, duration: widget.duration, size: length);
        break;
      case LoaderType.Wave:
        lc = SpinKitWave(
            color: widget.color,
            duration: widget.duration,
            controller: animationController,
            size: length);
        break;
      case LoaderType.Normal:
      default:
        lc = CircularProgressIndicator(color: widget.color);
        break;
    }
    return Opacity(
        opacity: opacity,
        child: Center(
            child: lc,
            heightFactor: widget.heightFactor,
            widthFactor: widget.widthFactor));
  }

  @override
  void initState() {
    super.initState();
    assignState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}
