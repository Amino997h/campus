import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class ExpandableText extends StatefulWidget {
  final String text;
  final int trimLength;
  final TextStyle? style;

  const ExpandableText({
    super.key,
    required this.text,
    this.trimLength = 160,
    this.style,
  });

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final text = widget.text;
    final defaultStyle = widget.style ??
        const TextStyle(fontSize: 14.0, color: AppColors.textDark, height: 1.35);

    if (text.length <= widget.trimLength) {
      return Text(text, style: defaultStyle);
    }

    final displayText =
        _isExpanded ? text : '${text.substring(0, widget.trimLength)}... ';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: defaultStyle,
            children: [
              TextSpan(text: displayText),
              WidgetSpan(
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  child: Text(
                    _isExpanded ? ' Show less' : 'Read more',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
