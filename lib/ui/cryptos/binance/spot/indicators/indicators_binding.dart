import 'package:get/get.dart';
import 'indicators_controller.dart';

class IndicatorsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<IndicatorsController>(() => IndicatorsController());
  }
}
