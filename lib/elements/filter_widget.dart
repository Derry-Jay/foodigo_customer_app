import 'package:flutter/material.dart';
import 'package:foodigo_customer_app/elements/filter_item_widget.dart';

typedef ValidateSelectedItem<T> = bool Function(List<T> list, T item);
typedef OnApplyButtonClick<T> = Function(List<T> list);
typedef ChoiceChipBuilder<T> = Widget Function(
    BuildContext context, T item, bool isSelected);
typedef OnItemSearch<T> = List<T> Function(List<T> list, String text);
typedef Label<T> = String Function(T item);

class FilterListWidget<T> extends StatefulWidget {
  final double height, width, borderRadius;
  final List<T> listData, selectedListData;
  final Color closeIconColor,
      headerTextColor,
      backgroundColor,
      applyButtonTextBackgroundColor,
      searchFieldBackgroundColor,
      selectedTextBackgroundColor,
      unselectedTextBackGroundColor;
  final String headlineText, searchFieldHintText;
  final bool hideSelectedTextCount,
      hideSearchField,
      hideCloseIcon,
      hideHeader,
      hideHeaderText,
      enableOnlySingleSelection;
  final TextStyle selectedChipTextStyle,
      unselectedChipTextStyle,
      controlButtonTextStyle,
      applyButtonTextStyle,
      headerTextStyle,
      searchFieldTextStyle;
  final OnApplyButtonClick<T> onApplyButtonClick;
  final ValidateSelectedItem<T> validateSelectedItem;
  final OnItemSearch onItemSearch;
  final Label<T> label;
  final ChoiceChipBuilder choiceChipBuilder;
  const FilterListWidget({
    Key key,
    this.height,
    this.width,
    this.listData,
    @required this.validateSelectedItem,
    @required this.label,
    @required this.onItemSearch,
    this.selectedListData,
    this.borderRadius = 20,
    this.headlineText = "Select",
    this.onApplyButtonClick,
    this.searchFieldHintText = "Search here",
    this.hideSelectedTextCount = false,
    this.hideSearchField = false,
    this.hideCloseIcon = true,
    this.hideHeader = false,
    this.hideHeaderText = false,
    this.closeIconColor = Colors.black,
    this.headerTextColor = Colors.black,
    this.applyButtonTextBackgroundColor = const Color(0xffa11414),
    this.backgroundColor = const Color(0xffF6F6F6),
    this.searchFieldBackgroundColor = const Color(0xfff5f5f5),
    this.selectedTextBackgroundColor = const Color(0xFFbad600),
    this.unselectedTextBackGroundColor = const Color(0xffffffff),
    this.enableOnlySingleSelection = false,
    this.choiceChipBuilder,
    this.selectedChipTextStyle,
    this.unselectedChipTextStyle,
    this.controlButtonTextStyle,
    this.applyButtonTextStyle,
    this.headerTextStyle,
    this.searchFieldTextStyle,
  })  : assert(validateSelectedItem != null, '''
            validateSelectedItem callback can not be null

            Tried to use below callback to ignore error.

             validateSelectedItem: (list, val) {
                  return list.contains(val);
             }
            '''),
        super(key: key);

  @override
  FilterListWidgetState<T> createState() => FilterListWidgetState<T>();
}

class FilterListWidgetState<T> extends State<FilterListWidget<T>> {
  List<T> _listData;
  List<T> _selectedListData = <T>[];
  MediaQueryData get dimensions => MediaQuery.of(context);
  Size get size => dimensions.size;
  double get height => size.height;
  double get width => size.width;
  @override
  void initState() {
    _listData = widget.listData == null ? <T>[] : List.from(widget.listData);
    _selectedListData = widget.selectedListData == null
        ? <T>[]
        : List<T>.from(widget.selectedListData);
    super.initState();
  }

  bool showApplyButton = false;

  Widget _body() {
    return Container(
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              widget.hideHeader ? SizedBox() : _header(),
              widget.hideSelectedTextCount
                  ? SizedBox()
                  : Padding(
                      padding: EdgeInsets.only(top: 5),
                      child: Text(
                        '${_selectedListData.length} selected items',
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ),
              Expanded(
                  child: Container(
                padding: EdgeInsets.only(top: 0, bottom: 0, left: 5, right: 5),
                child: SingleChildScrollView(
                  child: Wrap(
                    children: _buildChoiceList(),
                  ),
                ),
              )),
            ],
          ),
          _controlButtonSection()
        ],
      ),
    );
  }

  Widget _header() {
    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        boxShadow: <BoxShadow>[
          BoxShadow(
            offset: Offset(0, 5),
            blurRadius: 15,
            color: Color(0x12000000),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Container(),
                ),
                Expanded(
                  flex: 6,
                  child: widget.hideHeaderText
                      ? Container()
                      : Text(
                          widget.headlineText.toUpperCase(),
                          style: widget.headerTextStyle ??
                              Theme.of(context).textTheme.headline4.copyWith(
                                  fontSize: 12.8,
                                  color: widget.headerTextColor),
                        ),
                ),
                Expanded(
                  flex: 1,
                  child: InkWell(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    onTap: () {
                      Navigator.pop(context, null);
                    },
                    child: widget.hideCloseIcon
                        ? SizedBox()
                        : Container(
                            height: 25,
                            width: 25,
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: widget.closeIconColor),
                                shape: BoxShape.circle),
                            child: Icon(
                              Icons.close,
                              color: widget.closeIconColor,
                            ),
                          ),
                  ),
                ),
              ],
            ),
            widget.hideSearchField
                ? SizedBox()
                : SizedBox(
                    height: 10,
                  )
          ],
        ),
      ),
    );
  }

  List<Widget> _buildChoiceList() {
    List<Widget> choices = [];
    _listData.forEach(
      (item) {
        var selectedText = widget.validateSelectedItem(_selectedListData, item);
        choices.add(
          ChoiceChipWidget(
            size: size,
            choiceChipBuilder: widget.choiceChipBuilder,
            item: item,
            onSelected: (value) {
              setState(
                () {
                  if (widget.enableOnlySingleSelection) {
                    _selectedListData.clear();
                    _selectedListData.add(item);
                  } else {
                    selectedText
                        ? _selectedListData.remove(item)
                        : _selectedListData.add(item);
                  }
                },
              );
            },
            selected: selectedText,
            selectedTextBackgroundColor: widget.selectedTextBackgroundColor,
            unselectedTextBackgroundColor: widget.unselectedTextBackGroundColor,
            selectedChipTextStyle: widget.selectedChipTextStyle,
            unselectedChipTextStyle: widget.unselectedChipTextStyle,
            text: widget.label(item),
          ),
        );
      },
    );
    choices.add(
      SizedBox(
        height: 70,
        width: width,
      ),
    );
    return choices;
  }

  Widget _controlButton({
    String label,
    Function onPressed,
    Color backgroundColor = Colors.transparent,
    double elevation = 0,
    TextStyle textStyle,
  }) {
    return TextButton(
      style: ButtonStyle(
          shape: MaterialStateProperty.all(RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(25)),
          )),
          backgroundColor: MaterialStateProperty.all(backgroundColor),
          elevation: MaterialStateProperty.all(elevation),
          foregroundColor:
              MaterialStateProperty.all(Theme.of(context).buttonColor)),
      onPressed: onPressed,
      clipBehavior: Clip.antiAlias,
      child: Text(
        label,
        style: textStyle,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _controlButtonSection() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 45,
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        alignment: Alignment.center,
        child: Container(
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.all(Radius.circular(25)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                offset: Offset(0, 5),
                blurRadius: 15,
                color: Color(0x12000000),
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _controlButton(
                label: "All",
                onPressed: widget.enableOnlySingleSelection
                    ? null
                    : () {
                        setState(() {
                          _selectedListData = List.from(_listData);
                        });
                      },
                // textColor:
                textStyle: widget.controlButtonTextStyle ??
                    Theme.of(context).textTheme.bodyText2.copyWith(
                        fontSize: 20,
                        color: widget.enableOnlySingleSelection
                            ? Theme.of(context).dividerColor
                            : Theme.of(context).primaryColor),
              ),
              _controlButton(
                label: "Reset",
                onPressed: () {
                  setState(() {
                    _selectedListData.clear();
                  });
                },
                textStyle: widget.controlButtonTextStyle ??
                    Theme.of(context).textTheme.bodyText2.copyWith(
                        fontSize: 20, color: Theme.of(context).primaryColor),
              ),
              _controlButton(
                label: "Apply",
                onPressed: () {
                  if (widget.onApplyButtonClick != null) {
                    widget.onApplyButtonClick(_selectedListData);
                  } else {
                    Navigator.pop(context, _selectedListData);
                  }
                },
                elevation: 5,
                backgroundColor: widget.applyButtonTextBackgroundColor,
                textStyle: widget.applyButtonTextStyle ??
                    Theme.of(context).textTheme.bodyText2.copyWith(
                        fontSize: 20,
                        color: widget.enableOnlySingleSelection
                            ? Theme.of(context).dividerColor
                            : Theme.of(context).buttonColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(widget.borderRadius)),
        child: Container(
          height: widget.height,
          width: widget.width,
          color: widget.backgroundColor,
          child: Stack(
            children: <Widget>[
              _body(),
            ],
          ),
        ),
      ),
    );
  }
}
