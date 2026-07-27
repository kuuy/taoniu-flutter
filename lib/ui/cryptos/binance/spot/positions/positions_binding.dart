import 'package:get/get.dart';
import 'positions_controller.dart';

class PositionsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PositionsController>(() => PositionsController());
  }
}
