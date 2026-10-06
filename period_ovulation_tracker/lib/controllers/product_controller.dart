import 'package:get/get.dart';

class ProductController extends GetxController {
  var productList = [].obs;

  void fetchProducts() {
    // Fetch product logic
    productList.value = [
      {'id': '1', 'name': 'Product 1', 'price': 50.0},
      {'id': '2', 'name': 'Product 2', 'price': 30.0},
    ];
  }
}
