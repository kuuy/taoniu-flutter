import 'package:get/get.dart';
import 'plans_controller.dart';

class PlansBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BinanceSpotPlansController>(() => BinanceSpotPlansController());
  }
}
