import 'package:get/get.dart';
import 'scalping_controller.dart';

class TradingsScalpingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TradingsScalpingController>(() => TradingsScalpingController());
  }
}
