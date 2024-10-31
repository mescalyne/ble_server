import 'package:ble_server/services/ble_server.dart';
import 'package:flutter/material.dart';

enum AdvertiseStatus {
  advertising,
  error,
  silence,
  updating,
}

class AdvertisingWidget extends StatefulWidget {
  const AdvertisingWidget({super.key});

  @override
  State<AdvertisingWidget> createState() => _AdvertisingWidgetState();
}

class _AdvertisingWidgetState extends State<AdvertisingWidget> {
  final bleService = BleServiceImpl();

  final TextEditingController nameController =
      TextEditingController(text: 'test');
  final TextEditingController uuidController =
      TextEditingController(text: 'bf27730d-860a-4e09-889c-2d8b6a9e0fe7');

  late AdvertiseStatus advertiseStatus;

  @override
  void initState() {
    advertiseStatus = AdvertiseStatus.silence;
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Advertising Status: $advertiseStatus'),
        TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        TextField(
          controller: uuidController,
          decoration: const InputDecoration(labelText: 'UUID'),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () async {
            if (advertiseStatus != AdvertiseStatus.updating) {
              setState(() => advertiseStatus = AdvertiseStatus.updating);
              await bleService.stopAdvertising();
              final result = await bleService.startAdvertising(
                serviceUUID: uuidController.text,
                name: nameController.text,
              );
              setState(() => advertiseStatus =
                  result ? AdvertiseStatus.advertising : AdvertiseStatus.error);
            }
          },
          child: advertiseStatus == AdvertiseStatus.updating
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(),
                )
              : const Text("Update"),
        ),
      ],
    );
  }
}
