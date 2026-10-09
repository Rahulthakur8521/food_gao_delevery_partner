
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class DirectionAndDurationController extends GetxController {

  Rx<String?> pickup = Rx<String?>(null);
  Rx<String?> destination = Rx<String?>(null);
  Rx<String?> pickupAddress = Rx<String?>(null);
  Rx<String?> travelDuration = Rx<String?>(null);
  Rx<String?> travelDistance = Rx<String?>(null);

  void updatePickupAddress(String? address) {
    pickup.value = address;
  }

  void updateDestinationAddress(String? address) {
    destination.value = address;
  }


  void setTravelDuration(String? duration) {
    travelDuration.value = duration;
  }


  void setTravelDistance(String? distance) {
    travelDistance.value = distance;
  }


  void clearAll() {
    pickup.value = null;
    destination.value = null;
    travelDuration.value = null;
    travelDistance.value = null;
  }

  Future<void> calculateDirections(
      {required String pickupAddress, required String destinationAddress})async{
  }
}