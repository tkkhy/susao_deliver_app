import 'package:blue_thermal_printer/blue_thermal_printer.dart';
// import 'package:gbk2utf8/gbk2utf8.dart';
import 'package:susao_deliver_app/utils/toast_utils.dart';

/// 打印机
class Printer {
  BlueThermalPrinter _bluetooth = BlueThermalPrinter.instance;
  BluetoothDevice _device;
  bool _connected;  // 连接成功
  bool _connecting; // 正在连接
  Printer._(){
    _connected = false;
    _connecting = false;  
    _bluetooth.onStateChanged().listen((state) {
     switch (state) {
        case BlueThermalPrinter.CONNECTED:
          _connected = true;
          _connecting = false;
         break;
        case BlueThermalPrinter.DISCONNECTED:
          _connected = false;
          _connecting = false;
         break;
        default:
          print(state);
          break;
     }
    }); 
  }

  static Printer _instance = new Printer._();
  static Printer get instance => _instance;
  BluetoothDevice get device => _device;
  BlueThermalPrinter get printer => _bluetooth;
  bool get isConnected => _connected;
  bool get isConnection => _connecting;

  Future<bool> _connect(BluetoothDevice _d) async {
    return printer.connect(_d).then((onValue){
        _device = _d;
        toastSuccess('成功连接到${_d.name}');
        return true;
      }).catchError((onError) {
        toastError('无法连接到${_d.name}');
        return false;
      }).whenComplete((){
          _connecting = false;
        }
      );
  }

  Future<bool> setDevice(BluetoothDevice _d) async {
    _connecting = true;
    if (_device == null) {
      return _connect(_d);
    } else {
      return printer.isConnected.then((isConnected) {
        if (isConnected) {
          return printer.disconnect().then((onValue){
            return _connect(_d);
          }).catchError((onError){
            toastError('断开当前连接失败${_device.name}');
            return false;
          }).whenComplete((){
            _connecting = false;
          });
        } else {
          return _connect(_d);
        }
      }).catchError((onError){
        toastError("连接异常，请重启APP");
        _device = null;
        return false;
      }).whenComplete((){
        _connecting = false;
      });
    }
  }
  
  void _test() async {
    //SIZE
    // 0- normal size text
    // 1- only bold text
   // 2- bold with medium text
   // 3- bold with large text
   //ALIGN
   // 0- ESC_ALIGN_LEFT
   // 1- ESC_ALIGN_CENTER
    // 2- ESC_ALIGN_RIGHT
    printer.isConnected.then((isConnected) {
      if (isConnected) {
        printer.printCustom("HEADER",3,1);
        printer.printNewLine();
        printer.printLeftRight("LEFT", "RIGHT",0);
        printer.printLeftRight("LEFT", "RIGHT",1);
        printer.printNewLine();
        printer.printLeftRight("LEFT", "RIGHT",2);
        printer.printCustom("Body left",1,0);
        printer.printCustom("Body right",0,2);
        printer.printNewLine();
        printer.printCustom("Terimakasih",2,1);
        printer.printNewLine();
        printer.printQRcode("Insert Your Own Text to Generate", 0, 0, 0);
        printer.printNewLine();
        printer.printNewLine();
        printer.paperCut();
      }
   });
  }

  
  void test() async {
    //SIZE
    // 0- normal size text
    // 1- only bold text
   // 2- bold with medium text
   // 3- bold with large text
   //ALIGN
   // 0- ESC_ALIGN_LEFT
   // 1- ESC_ALIGN_CENTER
    // 2- ESC_ALIGN_RIGHT
    printer.isConnected.then((isConnected) {
      if (isConnected) {
        String text = "0.你好";
        // List<int> gbk_byteCodes = gbk.encode(text);
        // String hex = '';
        // gbk_byteCodes.forEach((i) {hex += i.toRadixString(16)+ ' ';});
        printer.printCustom(text,3,1);
        // printer.printNewLine();
        // printer.printQRcode("1.", 0, 0, 0);
        printer.printNewLine();
        printer.printNewLine();
        printer.paperCut();
      }
   });
  }
}