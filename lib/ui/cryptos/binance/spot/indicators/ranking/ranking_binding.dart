import 'package:get/get.dart';
import 'ranking_controller.dart';

class IndicatorsRankingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<IndicatorsRankingController>(() => IndicatorsRankingController());
  }
}
