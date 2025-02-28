import 'package:flutter/material.dart';

class Font_FM {
  static const String defaultFont = 'KantumruyPro-Regular';

  // Define global colors
  static const Color primaryText = Colors.black;
  static const Color secondaryText = Color(0xFF083E68);
  static const Color titleText = Color(0xFF107BCE);
  static const Color accentText = Color.fromARGB(255, 179, 25, 25);
  static const Color calendarWeekendText = Color.fromARGB(255, 145, 17, 8);
  static const Color calendarTodayBg = Color(0xFF107BCE);
  static const Color calendarSelectedBg = Color(0xFF2196F3);

  static var titleLarge;

  static ThemeData get light {
    return ThemeData(
      fontFamily: defaultFont,
      textTheme: ThemeData.light()
          .textTheme
          .apply(
            fontFamily: defaultFont,
            // Remove these lines as they override our custom colors
            // bodyColor: primaryText,
            // displayColor: titleText,
          )
          .copyWith(
            titleLarge: TextStyle(
                color: const Color.fromARGB(255, 0, 0, 0), fontSize: 16),
            titleMedium: TextStyle(color: secondaryText, fontSize: 16),
            bodyLarge: TextStyle(
                color: const Color.fromARGB(255, 0, 0, 0),
                fontSize: 16,
                fontWeight: FontWeight.bold),
            bodyMedium: TextStyle(color: primaryText, fontSize: 15),
            labelLarge: TextStyle(color: accentText, fontSize: 15),
            // Calendar specific styles
            displaySmall: TextStyle(
                color: primaryText, fontSize: 16, fontWeight: FontWeight.bold),
            headlineSmall: TextStyle(
                color: calendarWeekendText,
                fontSize: 16,
                fontWeight: FontWeight.bold),
            titleSmall: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
    );
  }
}
