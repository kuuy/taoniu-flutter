import 'package:get/get.dart';
import 'scalping_controller.dart';

class ScalpingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ScalpingController>(() => ScalpingController());
  }
}
