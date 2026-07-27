import 'package:get/get.dart';
import 'strategies_controller.dart';

class StrategiesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StrategiesController>(() => StrategiesController());
  }
}
