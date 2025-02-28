import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';

class Utils {
  static TextSpan highlightText(String text, String query) {
    if (query.isEmpty) {
      return TextSpan(text: text);
    }

    final normalizedText = removeDiacritics(text);
    final normalizedQuery = removeDiacritics(query);

    final List<TextSpan> spans = [];
    final RegExp regExp = RegExp(
      RegExp.escape(normalizedQuery),
      caseSensitive: false,
    );

    final Iterable<RegExpMatch> matches = regExp.allMatches(normalizedText);

    int start = 0;

    for (final match in matches) {
      if (match.start > start) {
        spans.add(
          TextSpan(
            text: text.substring(start, match.start),
            style: const TextStyle(color: Colors.black54),
          ),
        );
      }

      spans.add(
        TextSpan(
          text: text.substring(match.start, match.end),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      );

      start = match.end;
    }

    if (start < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(start),
          style: const TextStyle(color: Colors.black54),
        ),
      );
    }

    return TextSpan(children: spans);
  }

  static LayoutBuilder layoutBuilder(
    double width,
    String text,
    double fontSize,
    Color? color,
  ) => LayoutBuilder(
    builder: (context, constraints) {
      return SizedBox(
        width: width,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(text, style: TextStyle(fontSize: fontSize, color: color)),
        ),
      );
    },
  );

  static Center error(double width, String str1, String str2) {
    int maxLength = str1.length > str2.length ? str1.length : str2.length;
    if (str1.length < maxLength) {
      str1 = str1.padLeft((maxLength + str1.length) ~/ 2).padRight(maxLength);
    } else if (str2.length < maxLength) {
      str2 = str2.padLeft((maxLength + str2.length) ~/ 2).padRight(maxLength);
    }

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Utils.layoutBuilder(width, str1, 20, Colors.red),
            Utils.layoutBuilder(width, str2, 20, Colors.red),
          ],
        ),
      ),
    );
  }
}
