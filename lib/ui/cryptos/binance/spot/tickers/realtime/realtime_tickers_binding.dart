import 'package:get/get.dart';
import 'realtime_tickers_controller.dart';

class RealtimeTickersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RealtimeTickersController>(() => RealtimeTickersController());
  }
}
