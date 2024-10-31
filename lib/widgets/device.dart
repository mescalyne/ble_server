import 'dart:async';

import 'package:ble_server/services/ble_server.dart';
import 'package:bluetooth_low_energy/bluetooth_low_energy.dart';
import 'package:flutter/material.dart';

class DeviceEmulatorWidget extends StatefulWidget {
  const DeviceEmulatorWidget({super.key});

  @override
  State<DeviceEmulatorWidget> createState() => _DeviceEmulatorWidgetState();
}

class _DeviceEmulatorWidgetState extends State<DeviceEmulatorWidget> {
  final peripheral = PeripheralManager();
  late bool isSwitcherOn;
  late DeviceStatus deviceStatus;
  List<String> lastRecieved = [];

  UUID? clientId;
  int? maxTimeout;
  int? pauseTimeout;
  Timer? _timer;

  @override
  void initState() {
    subscribeDeviceUpdate();
    isSwitcherOn = false;
    deviceStatus = DeviceStatus.waiting;
    super.initState();
  }

  void _resetClient() {
    clientId = null;
    maxTimeout = null;
    pauseTimeout = null;
  }

  void _startTimeoutTimer() {
    _resetTimer();
    if (maxTimeout != null) {
      _timer = Timer(Duration(milliseconds: maxTimeout!), () {
        setState(() {
          deviceStatus = DeviceStatus.waiting;
        });

        _resetTimer();
      });
    }
  }

  void _startPauseTimer() {
    _resetTimer();
    if (pauseTimeout != null) {
      _timer = Timer(Duration(milliseconds: pauseTimeout!), () {
        setState(() {
          deviceStatus = DeviceStatus.waiting;
          _resetClient();
        });

        _resetTimer();
      });
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void subscribeDeviceUpdate() {
    peripheral.characteristicWriteRequested.listen(
      (data) {
        data.central.uuid;
        final commandId = data.characteristic.uuid.toString();
        data.request.value;

        setState(() {
          lastRecieved.add(data.central.uuid.toString());

          lastRecieved.add(commandId);
          lastRecieved
              .add(data.characteristic.descriptors.map((el) => el).toString());
          lastRecieved.add(
              data.characteristic.properties.map((el) => el.index).toString());

          lastRecieved.add(data.request.value.toString());
        });
        switch (commandId) {
          case '123e4567-e89b-12d3-a001-000000000000': //START
            if (deviceStatus == DeviceStatus.waiting) {
              setState(() {
                clientId = data.central.uuid;
                maxTimeout = data.request.value[0];
                pauseTimeout = data.request.value[0];
                deviceStatus = DeviceStatus.active;
              });
            }
            break;
          case '123e4567-e89b-12d3-a002-000000000000': //ACTIVE
            if (clientId == data.central.uuid) {
              _startTimeoutTimer();
            }
          case '123e4567-e89b-12d3-a003-000000000000': //PAUSE
            if (clientId == data.central.uuid) {
              setState(() {
                isSwitcherOn = false;
                deviceStatus = DeviceStatus.pause;
                _startPauseTimer();
              });
            }
          case '123e4567-e89b-12d3-a004-000000000000': //CONTINUE
            if (clientId == data.central.uuid &&
                deviceStatus == DeviceStatus.pause) {
              _resetTimer();
              setState(() {
                isSwitcherOn = true;
                deviceStatus = DeviceStatus.active;
              });
            }
            break;
          case '123e4567-e89b-12d3-a005-000000000000': //STOP
            if (clientId == data.central.uuid &&
                deviceStatus != DeviceStatus.waiting) {
              setState(() {
                isSwitcherOn = false;
                deviceStatus = DeviceStatus.waiting;
                _startPauseTimer();
              });
            }
          default:
            break;
        }
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Device Status: $deviceStatus'),
        Switch(
          value: isSwitcherOn,
          onChanged: (value) {
            if (deviceStatus == DeviceStatus.active) {
              setState(() {
                isSwitcherOn = value;
              });
            }
          },
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            itemCount: lastRecieved.length,
            itemBuilder: (context, index) {
              return Text(lastRecieved[index]);
            },
          ),
        ),
      ],
    );
  }
}
