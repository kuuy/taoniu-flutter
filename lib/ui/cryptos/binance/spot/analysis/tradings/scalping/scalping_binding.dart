import 'package:get/get.dart';
import 'scalping_controller.dart';

class AnalysisTradingsScalpingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AnalysisTradingsScalpingController>(() => AnalysisTradingsScalpingController());
  }
}
