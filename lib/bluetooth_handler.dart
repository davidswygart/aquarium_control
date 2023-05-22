import 'dart:async';
import 'package:bluetooth_enable_fork/bluetooth_enable_fork.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';

class BlueToothHandler {
  static final BlueToothHandler _instance = BlueToothHandler._internal();
  BlueToothHandler._internal() {
    debugPrint("bluetooth_handler: Created instance");
    //scanForEsp32();
  }
  factory BlueToothHandler() => _instance;

  QualifiedCharacteristic? led;
  late StreamSubscription<ConnectionStateUpdate> stateSubscription;
  DeviceConnectionState state = DeviceConnectionState.disconnected;

  Future<bool> scanForEsp32() async {
    if (await BluetoothEnable.enableBluetooth == "false"){return false;}
    if (await Permission.location.isDenied) {
      PermissionStatus result = await Permission.location.request();
      if(!result.isGranted){return false;}
    }
    debugPrint("bluetoothHandler: starting scan");
    Stream<DiscoveredDevice> scanStream = FlutterReactiveBle().scanForDevices(
      withServices: [ID().advertising],
    );
    DiscoveredDevice esp32 = await scanStream.first;

    stateSubscription = FlutterReactiveBle().connectToAdvertisingDevice(
      id: esp32.id,
      withServices: [],
      prescanDuration: const Duration(seconds: 1),
      connectionTimeout: const Duration(seconds: 2),
    ).listen((info) {
      debugPrint("${info.connectionState}");
      state = info.connectionState;
    }, onError: (dynamic error) {
      throw Exception("unable to connect");
    });

    led = QualifiedCharacteristic(
        serviceId: ID().service,
        characteristicId: ID().led,
        deviceId: esp32.id
    );

    return true;
  }

  Future<void> disconnect() async {
    debugPrint("Attempting disconnect");
    try{await stateSubscription.cancel();}
    catch(error){debugPrint("couldn't disconnect from device. Probably not initialized");}
  }

  bool _stillWriting = false;
  Future<void> writeLED(Color color) async {
    if (led == null){return;}
    if (_stillWriting) {return;}
    _stillWriting = true;

    List<int> intList = [color.red, color.green, color.blue, color.alpha];
    await FlutterReactiveBle().writeCharacteristicWithoutResponse(
        BlueToothHandler().led!, value: intList
    );
    _stillWriting = false;
  }

  bool keepPartying = true;
  Future<void> partyTime() async {
    keepPartying = true;
    while (keepPartying){
      for (int i=100; i<256; i++){
        await writeLED(Color.fromARGB(0, i, 0, 0));
      }

      for (int i=255; i>100; i--){
        await writeLED(Color.fromARGB(0, i, 0, 0));
      }

      for (int i=100; i<256; i++){
        await writeLED(Color.fromARGB(0, 0, i, 0));
      }

      for (int i=255; i>100; i--){
        await writeLED(Color.fromARGB(0, 0, i, 0));
      }

      for (int i=100; i<256; i++){
        await writeLED(Color.fromARGB(0, i, 0, 0));
      }

      for (int i=255; i>100; i--){
        await writeLED(Color.fromARGB(0, i, 0, 0));
      }

      for (int i=100; i<256; i++){
        await writeLED(Color.fromARGB(0, 0, 0, i));
      }

      for (int i=255; i>100; i--){
        await writeLED(Color.fromARGB(0, 0, 0, i));
      }
    }
  }

  void stopParty() {keepPartying = false;}
}

class ID {
  final Uuid advertising = Uuid.parse('aaaaaaaa-151b-11ec-82a8-0242ac130003');
  final Uuid service = Uuid.parse('00000000-151b-11ec-82a8-0242ac130003');
  final Uuid hit = Uuid.parse('00000002-151b-11ec-82a8-0242ac130003');
  final Uuid led = Uuid.parse('00000001-151b-11ec-82a8-0242ac130003');
  final Uuid hitThreshold = Uuid.parse('00000004-151b-11ec-82a8-0242ac130003');
  final Uuid hitTimeout = Uuid.parse('00000005-151b-11ec-82a8-0242ac130003');
  final Uuid hitAcceleration = Uuid.parse('00000006-151b-11ec-82a8-0242ac130003');
}