import 'package:flutter/material.dart';
import 'package:foodigo_customer_app/elements/filter_widget.dart';
import 'package:foodigo_customer_app/models/cuisine.dart';

import 'circular_loader.dart';

typedef ValidateSelectedItem<T> = bool Function(List<T> list, T item);
typedef OnApplyButtonClick<T> = Function(List<T> list);
typedef ChoiceChipBuilder<T> = Widget Function(
    BuildContext context, T item, bool isSelected);
typedef OnItemSearch<T> = List<T> Function(List<T> list, String text);
typedef Label<T> = String Function(T item);

class FilterBuilder extends StatelessWidget {
  final List<List> lists;
  final Size size;
  final ValidateSelectedItem validateSelectedItem;
  final OnItemSearch onItemSearch;
  double get height => size.height;
  double get width => size.width;
  FilterBuilder(
      {Key key,
      @required this.lists,
      @required this.size,
      @required this.validateSelectedItem,
      @required this.onItemSearch})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return lists == null || lists.isEmpty
        ? CircularLoader(
            duration: Duration(seconds: 5),
            heightFactor: 16,
            widthFactor: 16,
            color: Color(0xffa11414),
            loaderType: LoaderType.PouringHourGlass)
        : Column(
            children: [
              for (List list in lists)
                Expanded(
                    child: Container(
                  height: height,
                  width: width,
                  color: Colors.transparent,
                  child: FilterListWidget(
                    listData: list,
                    label: (item) =>
                        item is Cuisine ? item.cuisineName : item.tag,
                    width: width,
                    height: height,
                    // hideHeader: hideHeader,
                    // borderRadius: borderRadius,
                    headlineText: list.first.runtimeType.toString() + "s",
                    onItemSearch: onItemSearch,
                    // closeIconColor: closeIconColor,
                    // headerTextStyle: headerTextStyle,
                    // backgroundColor: backgroundColor,
                    // selectedListData: selectedListData,
                    // onApplyButtonClick: onApplyButtonClick,
                    validateSelectedItem: validateSelectedItem,
                    // hideSelectedTextCount: hideSelectedTextCount,
                    // hideCloseIcon: hideCloseIcon,
                    // hideHeaderText: hideHeaderText,
                    // hideSearchField: hideSearchField,
                    // choiceChipBuilder: choiceChipBuilder,
                    // searchFieldHintText: searchFieldHintText,
                    // applyButtonTextStyle: applyButtonTextStyle,
                    // searchFieldTextStyle: searchFieldTextStyle,
                    // selectedChipTextStyle: selectedChipTextStyle,
                    controlButtonTextStyle: TextStyle(color: Color(0xffa11414)),
                    // unselectedChipTextStyle: unselectedChipTextStyle,
                    // enableOnlySingleSelection: enableOnlySingleSelection,
                    // searchFieldBackgroundColor: searchFieldBackgroundColor,
                    // applyButtonTextBackgroundColor:
                    //     applyButtonTextBackgroundColor,
                  ),
                ))
            ],
          );
  }
}
