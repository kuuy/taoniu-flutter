import 'package:get/get.dart';
import 'tradings_controller.dart';

class TradingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TradingsController>(() => TradingsController());
  }
}
