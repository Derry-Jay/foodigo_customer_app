// import 'dart:math';
import 'package:flutter/material.dart';
import 'package:foodigo_customer_app/elements/filter_widget.dart';

class ChoiceChipWidget<T> extends StatelessWidget {
  final String text;
  final bool selected;
  final Size size;
  final Function(bool) onSelected;
  final Color unselectedTextBackgroundColor, selectedTextBackgroundColor;
  final TextStyle selectedChipTextStyle, unselectedChipTextStyle;
  final T item;
  final ChoiceChipBuilder choiceChipBuilder;
  const ChoiceChipWidget(
      {Key key,
      this.text,
      @required this.size,
      this.item,
      this.selected,
      this.onSelected,
      this.unselectedTextBackgroundColor,
      this.selectedTextBackgroundColor,
      this.choiceChipBuilder,
      this.selectedChipTextStyle,
      this.unselectedChipTextStyle})
      : super(key: key);

  TextStyle getSelectedTextStyle(BuildContext context) {
    return selected
        ? selectedChipTextStyle ??
            TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.w500)
        : unselectedChipTextStyle ??
            TextStyle(color: Colors.black, fontWeight: FontWeight.w500);
  }

  @override
  Widget build(BuildContext context) {
    return choiceChipBuilder != null
        ? GestureDetector(
            onTap: () {
              onSelected(true);
            },
            child: choiceChipBuilder(context, item, selected),
          )
        : Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ChoiceChip(
              backgroundColor: selected
                  ? selectedTextBackgroundColor
                  : unselectedTextBackgroundColor,
              selectedColor: selected
                  ? selectedTextBackgroundColor
                  : unselectedTextBackgroundColor,
              label: Text(
                '$text',
                style: getSelectedTextStyle(context),
              ),
              selected: selected,
              onSelected: onSelected,
            ),
          );
  }
}
