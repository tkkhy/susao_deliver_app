import 'dart:io';

import 'package:flutter/services.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:susao_deliver_app/common/printer.dart';
import 'package:susao_deliver_app/utils/toast_utils.dart';

class PrinterPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PrinterPageState();
}

class _PrinterPageState extends State<PrinterPage> {
  List<BluetoothDevice> _devices = [];
  BluetoothDevice _device;
  String pathImage;
  @override
  void initState() {
    super.initState();
    initPrinterList();
    initSavetoPath();
  }

  void initPrinterList() async {
    List<BluetoothDevice> devices = [];
    try {
      devices = await Printer.instance.printer.getBondedDevices();
    } on PlatformException {
      toastError('获取蓝牙设备失败');
    }
    setState(() {
      _devices = devices;
      for (var d in devices) {
        if (Printer.instance.device != null && Printer.instance.device.name == d.name) {
          _device = d;
        }
      }
    });
  }

  initSavetoPath()async{
    //read and write
    //image max 300px X 300px
    final filename = 'yourlogo.png';
    var bytes = await rootBundle.load("assets/images/yourlogo.png");
    String dir = (await getApplicationDocumentsDirectory()).path;
    writeToFile(bytes,'$dir/$filename');
    setState(() {
     pathImage='$dir/$filename';
     print('pathImage: $pathImage');
   });
 }

 //write to app path
 Future<void> writeToFile(ByteData data, String path) {
    final buffer = data.buffer;
    return new File(path).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
 }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('打印机设置${Printer.instance.device==null?"":("~"+Printer.instance.device.name)}'),
      ),
      body: _buildBody(),
    );
  }
  
  Widget _buildBody() {
    return ListView(
      padding: EdgeInsets.all(10.0),
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text('设备列表：'),
            DropdownButton(
              items: List.generate(_devices.length, (index){
                return DropdownMenuItem(
                  child: Text(_devices[index].name),
                  value: _devices[index],
                );
              }),
              onChanged: (value) {
                Printer.instance.setDevice(value).then((onValue){
                  setState(() {
                    _device = value;
                  });
                });
              },
              value: _device,
            )
          ],
        ),
        RaisedButton(
          child: Text('测试打印机'),
          onPressed: Printer.instance.isConnected?Printer.instance.test:null,
        ),
        RaisedButton(
          child: Text('打印图片'),
          onPressed: Printer.instance.isConnected?(){
            Printer.instance.testImage(pathImage);
          }:null,
        ),
      ],
    );
  }

}