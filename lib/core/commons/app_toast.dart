
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AppToast {
  AppToast._();

  static Future<bool?> show(
    String message, {
    ToastGravity gravity = ToastGravity.BOTTOM,
    Toast length = Toast.LENGTH_LONG,
    Color backgroundColor = const Color.fromARGB(255, 0, 0, 0),
    Color textColor = Colors.white,
  }) {
    return Fluttertoast.showToast(
      msg: message,
      gravity: gravity,
      toastLength: length,
      backgroundColor: backgroundColor,
      textColor: textColor,
    );
  }

  static Future<bool?> success(
    String message, {
    ToastGravity gravity = ToastGravity.BOTTOM,
    Toast length = Toast.LENGTH_SHORT,
  }) {
    return show(
      message,
      gravity: gravity,
      length: length,
      backgroundColor: const Color(0xFF1E7A4A),
    );
  }

  static Future<bool?> error(
    String message, {
    ToastGravity gravity = ToastGravity.BOTTOM,
    Toast length = Toast.LENGTH_LONG,
  }) {
    return show(
      message,
      gravity: gravity,
      length: length,
      backgroundColor: const Color(0xFFC0392B),
    );
  }

  static Future<bool?> info(
    String message, {
    ToastGravity gravity = ToastGravity.BOTTOM,
    Toast length = Toast.LENGTH_SHORT,
  }) {
    return show(
      message,
      gravity: gravity,
      length: length,
      backgroundColor: const Color(0xFF1F5AA6),
    );
  }
}
