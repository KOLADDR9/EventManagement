import 'package:flutter/material.dart';

class Font_FM {
  static const String defaultFont = 'KantumruyPro-Regular';

  static ThemeData get light {
    return ThemeData(
      fontFamily: defaultFont,
      textTheme: ThemeData.light().textTheme.apply(
        fontFamily: defaultFont,
      ),
    );
  }
}
