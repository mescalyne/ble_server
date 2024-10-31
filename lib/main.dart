import 'package:ble_server/widgets/advertising.dart';
import 'package:ble_server/widgets/device.dart';
import 'package:flutter/material.dart';

void main() => runApp(const FlutterBlePeripheralWidget());

class FlutterBlePeripheralWidget extends StatefulWidget {
  const FlutterBlePeripheralWidget({super.key});

  @override
  State<FlutterBlePeripheralWidget> createState() =>
      _FlutterBlePeripheralWidgetState();
}

class _FlutterBlePeripheralWidgetState
    extends State<FlutterBlePeripheralWidget> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("BLE Server Emulator"),
        ),
        body: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              AdvertisingWidget(),
              Divider(),
              SizedBox(
                height: 100,
              ),
              DeviceEmulatorWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
