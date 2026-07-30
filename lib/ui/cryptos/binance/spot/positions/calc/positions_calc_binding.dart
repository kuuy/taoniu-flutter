import 'package:get/get.dart';
import 'positions_calc_controller.dart';

class PositionsCalcBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PositionsCalcController>(() => PositionsCalcController());
  }
}
