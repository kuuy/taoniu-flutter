import 'package:get/get.dart';
import 'gambling_calc_controller.dart';

class GamblingCalcBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GamblingCalcController>(() => GamblingCalcController());
  }
}
