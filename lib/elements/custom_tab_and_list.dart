import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

const Duration _kScrollDuration = const Duration(milliseconds: 150);

class MyScrollableListTabView extends StatefulWidget {
  final MediaQueryData dimensions;
  final List<MyScrollableListTab> tabs;
  final Curve tabAnimationCurve, bodyAnimationCurve;
  final Duration tabAnimationDuration, bodyAnimationDuration;
  MyScrollableListTabView(
      {Key key,
      @required this.dimensions,
      @required this.tabs,
      this.tabAnimationDuration = _kScrollDuration,
      this.bodyAnimationDuration = _kScrollDuration,
      this.tabAnimationCurve = Curves.decelerate,
      this.bodyAnimationCurve = Curves.decelerate})
      : assert(tabAnimationDuration != null, bodyAnimationDuration != null),
        assert(tabAnimationCurve != null, bodyAnimationCurve != null),
        assert(tabs != null),
        assert(dimensions != null),
        super(key: key);
  @override
  MyScrollableListTabViewState createState() => MyScrollableListTabViewState();
}

class MyScrollableListTabViewState extends State<MyScrollableListTabView> {
  double get height => widget.dimensions.size.height;
  double get width => widget.dimensions.size.width;
  double get size => sqrt(pow(height, 2) + pow(width, 2));
  final ValueNotifier<int> _index = ValueNotifier<int>(0);

  final ItemScrollController _bodyScrollController = ItemScrollController();
  final ItemPositionsListener _bodyPositionsListener =
      ItemPositionsListener.create();
  final ItemScrollController _tabScrollController = ItemScrollController();

  @override
  void initState() {
    super.initState();
    _bodyPositionsListener.itemPositions.addListener(_onInnerViewScrolled);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
            height: height / 25,
            color: Color(0xffF7F7F7),
            child: ScrollablePositionedList.builder(
              itemCount: widget.tabs.length,
              scrollDirection: Axis.horizontal,
              itemScrollController: _tabScrollController,
              itemBuilder: (context, index) {
                var tab = widget.tabs[index].tab;
                return ValueListenableBuilder<int>(
                    valueListenable: _index,
                    builder: (_, i, __) {
                      var selected = index == i;
                      return InkWell(
                          child: Container(
                              decoration: BoxDecoration(
                                  border: BorderDirectional(
                                      bottom: BorderSide(
                                          color: selected
                                              ? tab.activeBackgroundColor
                                              : Colors.transparent))),
                              child: _buildTab(index, selected),
                              padding:
                                  EdgeInsets.symmetric(horizontal: width / 50),
                              margin:
                                  EdgeInsets.symmetric(horizontal: width / 50)),
                          onTap: () => _onTabPressed(index));
                    });
              },
            ),
            padding: EdgeInsets.only(top: height / 125)),
        Expanded(
          child: ScrollablePositionedList.builder(
            itemScrollController: _bodyScrollController,
            itemPositionsListener: _bodyPositionsListener,
            itemCount: widget.tabs.length,
            itemBuilder: (_, index) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: width / 28.8230376151711744,
                      vertical: height / 50),
                  child: _buildInnerTab(index),
                ),
                Flexible(
                  child: widget.tabs[index].body,
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInnerTab(int index) {
    var tab = widget.tabs[index].tab;
    var textStyle = Theme.of(context)
        .textTheme
        .bodyText1
        .copyWith(fontWeight: FontWeight.w500);
    final label = Text(tab.label.toUpperCase(),
        style: TextStyle(
            fontWeight: FontWeight.w700, fontSize: 16, color: Colors.black));
    return Builder(
      builder: (_) {
        if (tab.icon == null) return label;
        if (!tab.showIconOnList)
          return DefaultTextStyle(style: textStyle, child: Text(tab.label));
        return DefaultTextStyle(
          style: Theme.of(context)
              .textTheme
              .bodyText1
              .copyWith(fontWeight: FontWeight.w500),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [tab.icon, label],
          ),
        );
      },
    );
  }

  Widget _buildTab(int index, bool flag) {
    var tab = widget.tabs[index].tab;
    if (tab.icon == null)
      return Text(
        tab.label,
        style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: flag ? Color(0xffa11414) : Color(0xff717171)),
      );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        tab.icon,
        Text(
          tab.label,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        )
      ],
    );
  }

  void _onInnerViewScrolled() async {
    var positions = _bodyPositionsListener.itemPositions.value;

    /// Target [ScrollView] is not attached to any views and/or has no listeners.
    if (positions == null || positions.isEmpty) return;

    /// Capture the index of the first [ItemPosition]. If the saved index is same
    /// with the current one do nothing and return.
    var firstIndex =
        _bodyPositionsListener.itemPositions.value.elementAt(0).index;
    if (_index.value == firstIndex) return;

    /// A new index has been detected.
    await _handleTabScroll(firstIndex);
  }

  Future<void> _handleTabScroll(int index) async {
    _index.value = index;
    await _tabScrollController.scrollTo(
        index: _index.value,
        duration: widget.tabAnimationDuration,
        curve: widget.tabAnimationCurve);
  }

  /// When a new tab has been pressed both [_tabScrollController] and
  /// [_bodyScrollController] should notify their views.
  void _onTabPressed(int index) async {
    await _tabScrollController.scrollTo(
        index: index,
        duration: widget.tabAnimationDuration,
        curve: widget.tabAnimationCurve);
    await _bodyScrollController.scrollTo(
        index: index,
        duration: widget.bodyAnimationDuration,
        curve: widget.bodyAnimationCurve);
    _index.value = index;
  }

  @override
  void dispose() {
    _bodyPositionsListener.itemPositions.removeListener(_onInnerViewScrolled);
    return super.dispose();
  }
}

class MyScrollableListTab {
  final MyListTab tab;
  final ScrollView body;
  MyScrollableListTab({this.tab, this.body})
      : assert(tab != null, body != null),
        assert(body.shrinkWrap && body.physics is NeverScrollableScrollPhysics);
}

class MyListTab {
  /// Create a new [ListTab]
  MyListTab(
      {Key key,
      @required this.label,
      this.icon,
      this.activeBackgroundColor = const Color(0xffa11414),
      this.inactiveBackgroundColor = const Color(0xff717171),
      this.showIconOnList = false,
      this.borderColor = Colors.transparent})
      : assert(label != null),
        assert(activeBackgroundColor != null),
        assert(inactiveBackgroundColor != null),
        assert(showIconOnList != null),
        assert(borderColor != null);
  final String label;
  final Icon icon;
  final Color activeBackgroundColor, inactiveBackgroundColor, borderColor;
  final bool showIconOnList;
}
