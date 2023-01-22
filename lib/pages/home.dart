import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  String name = "Nenhum";
  String services = "Nenhum";
  late BluetoothDevice device;
  @override
  void initState() {
    super.initState();
    checkDevices();
  }

  checkDevices() async {
    // if (await Permission.bluetooth.request().isGranted) {
    flutterBlue.startScan(timeout: Duration(seconds: 4));

    // Listen to scan results
    var subscription = flutterBlue.scanResults.listen(
      (results) {
        // do something with scan results
        setState(() {
          name = "";
        });
        for (ScanResult r in results) {
          print('${r.device.id} found! rssi: ${r.rssi}');
          if (r.device.id.toString() != "" || r.device.name == "") {
            setState(() {
              name = name + " \n " + r.device.id.toString();
              name = name + " \n " + r.device.type.name;
              name = name + " \n " + r.device.name;
              name = name + " \n " + r.device.id.id;
            });
            device = r.device;
            deviceConnect();
          }
        }
      },
    );

    // Stop scanning
    flutterBlue.stopScan();

    // }
  }

  deviceConnect() async {
    await device.connect();
    listServicesDevice();
  }

  listServicesDevice() async {
    String sevices = "Services\n";
    List<BluetoothService> services = await device.discoverServices();
    services.forEach((service) async {
      var characteristics = service.characteristics;
      for (BluetoothCharacteristic c in characteristics) {
        List<int> value = await c.read();
        print(value);
        sevices += value.toString();
      }
    });
    return sevices;
  }

  seguirTag() {
    Timer.periodic(Duration(seconds: 1), (_) async {
      var distance = await device.readRssi();

      setState(() {
        services = "$distance";
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Location Test BLE"),
      ),
      body: ListView(
        children: [
          Text(
              "Teste de conexão com bluetooth, calculando localização estimada."),
          Text(name),
          Text(services),
          ElevatedButton(
              onPressed: () async {
                await listServicesDevice();
              },
              child: Text("Ver serviços")),
          ElevatedButton(
              onPressed: () async {
                for (var element in await flutterBlue.connectedDevices) {
                  device = element;
                  seguirTag();
                }
              },
              child: Text("conectados")),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.bluetooth),
        onPressed: () => checkDevices(),
      ),
    );
  }
}
