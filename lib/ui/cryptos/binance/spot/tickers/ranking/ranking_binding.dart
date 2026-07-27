import 'package:get/get.dart';
import 'ranking_controller.dart';

class TickersRankingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TickersRankingController>(() => TickersRankingController());
  }
}
