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
  int count = 0;
  String services = "";
  List<String> total = [];
  late BluetoothDevice device;
  @override
  void initState() {
    super.initState();
    checkDevices();
    Timer.periodic(Duration(seconds: 10), (timer) {
      checkDevices();
    });
  }

  checkDevices() async {
    flutterBlue.startScan(timeout: Duration(seconds: 7));

    var subscription = flutterBlue.scanResults.listen(
      (results) {
  
        setState(() {
          name = "";
        });
        for (ScanResult r in results) {
          print('${r.device.id} found! rssi: ${r.rssi}');
          String atual = r.device.id.toString();
          setState(() {
            name = name + " \n " + atual;
          });
          if (!total.contains(atual)) {
            total.add(atual);
          }
          device = r.device;
        }
        setState(() {
          count = results.length;
        });
      },
    );

    flutterBlue.stopScan();

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
        title: Text("Kallas - Escaneamento de dispositivos"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Número de pessoas passando agora:",
            style: TextStyle(
              fontSize: 20,
            ),
            textAlign: TextAlign.center,
          ),
          Container(
            color: Color.fromARGB(255, 204, 204, 204),
            padding: EdgeInsets.all(8),
            margin: EdgeInsets.all(18),
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: 50,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Text(
            "Total de visualizações únicas:",
            style: TextStyle(
              fontSize: 20,
            ),
            textAlign: TextAlign.center,
          ),
          Container(
            color: Color.fromARGB(255, 204, 204, 204),
            padding: EdgeInsets.all(8),
            margin: EdgeInsets.all(18),
            child: Text(
              total.length.toString(),
              style: TextStyle(
                fontSize: 50,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Text(
            "Lista de dispositivos encontrados agora",
            style: TextStyle(fontSize: 20),
            textAlign: TextAlign.center,
          ),
          Text(name),

        ],
      ),

    );
  }
}
