import 'package:bluetooth_low_energy/bluetooth_low_energy.dart';

enum DeviceStatus {
  waiting,
  active,
  pause,
}

abstract class BleService {
  Future<bool> startAdvertising({
    required String serviceUUID,
    required String name,
  });
  Future<bool> stopAdvertising();
}

class BleServiceImpl extends BleService {
  final peripheral = PeripheralManager();

  static List<UUID> commandUUIDs = [
    UUID.fromString('123e4567-e89b-12d3-a001-000000000000'), //START
    UUID.fromString('123e4567-e89b-12d3-a002-000000000000'), //ALIVE
    UUID.fromString('123e4567-e89b-12d3-a003-000000000000'), //PAUSE
    UUID.fromString('123e4567-e89b-12d3-a004-000000000000'), //CONTINUE
    UUID.fromString('123e4567-e89b-12d3-a005-000000000000'), //STOP
  ];

  static UUID commandsUUID =
      UUID.fromString('123e4567-e89b-12d3-a001-000000000000');

  @override
  Future<bool> startAdvertising({
    required String serviceUUID,
    required String name,
  }) async {
    try {
      await peripheral.startAdvertising(
        Advertisement(
          name: name,
          serviceUUIDs: [
            UUID.fromString(serviceUUID),
          ],
        ),
      );

      await peripheral.addService(
        GATTService(
          uuid: UUID.fromString(serviceUUID),
          isPrimary: true,
          includedServices: [],
          characteristics: [
            GATTCharacteristic.mutable(
              uuid: commandUUIDs[0], //START
              properties: [
                GATTCharacteristicProperty.write,
              ],
              descriptors: [
                GATTDescriptor.mutable(
                  uuid: UUID.fromString('123e4567-e89b-12d3-a001-000000000001'),
                  permissions: [],
                ),
                GATTDescriptor.mutable(
                  uuid: UUID.fromString('123e4567-e89b-12d3-a001-000000000002'),
                  permissions: [],
                ),
              ],
              permissions: [],
            ),
            GATTCharacteristic.mutable(
              uuid: commandUUIDs[1], //ALIVE
              properties: [
                GATTCharacteristicProperty.write,
              ],
              descriptors: [],
              permissions: [],
            ),
            GATTCharacteristic.mutable(
              uuid: commandUUIDs[2], //PAUSE
              properties: [
                GATTCharacteristicProperty.write,
              ],
              descriptors: [],
              permissions: [],
            ),
            GATTCharacteristic.mutable(
              uuid: commandUUIDs[3], //CONTINUE
              properties: [
                GATTCharacteristicProperty.write,
              ],
              descriptors: [],
              permissions: [],
            ),
            GATTCharacteristic.mutable(
              uuid: commandUUIDs[4], //STOP
              properties: [
                GATTCharacteristicProperty.write,
              ],
              descriptors: [],
              permissions: [],
            ),
          ],
        ),
      );

      return true;
    } catch (ex) {
      await peripheral.stopAdvertising();
      return false;
    }
  }

  @override
  Future<bool> stopAdvertising() async {
    await peripheral.stopAdvertising();

    return true;
  }
}
