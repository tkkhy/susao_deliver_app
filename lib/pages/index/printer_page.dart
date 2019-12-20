import 'package:flutter/services.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:susao_deliver_app/common/printer.dart';
import 'package:susao_deliver_app/utils/toast_utils.dart';

class PrinterPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PrinterPageState();
}

class _PrinterPageState extends State<PrinterPage> {
  List<BluetoothDevice> _devices = [];
  BluetoothDevice _device;
  
  @override
  void initState() {
    super.initState();
    initPrinterList();
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
      ],
    );
  }

}