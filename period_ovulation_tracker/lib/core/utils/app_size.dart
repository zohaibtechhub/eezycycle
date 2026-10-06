import 'package:get/get.dart';

class AppSize {
  // Method to get screen height percentages dynamically
  static double getHeight(double percentage) {
    return Get.height * (percentage / 100);
  }

  // Method to get screen width percentages dynamically
  static double getWidth(double percentage) {
    return Get.width * (percentage / 100);
  }

  // Example getter methods for predefined percentages
  static double get h1 => getHeight(1);
  static double get h2 => getHeight(2);
  static double get h3 => getHeight(3);
  static double get h4 => getHeight(4);
  static double get h5 => getHeight(5);
  static double get h6 => getHeight(6);
  static double get h7 => getHeight(7);
  static double get h8 => getHeight(8);
  static double get h9 => getHeight(9);
  static double get h10 => getHeight(10);

  static double get w1 => getWidth(1);
  static double get w2 => getWidth(2);
  static double get w3 => getWidth(3);
  static double get w4 => getWidth(4);
  static double get w5 => getWidth(5);
  static double get w6 => getWidth(6);
  static double get w7 => getWidth(7);
  static double get w8 => getWidth(8);
  static double get w9 => getWidth(9);
  static double get w10 => getWidth(10);

  // Additional spacing constants
  static double get h0_5 => getHeight(0.5);
  static double get h1_5 => getHeight(1.5);
  static double get w1_5 => getWidth(1.5);
}
