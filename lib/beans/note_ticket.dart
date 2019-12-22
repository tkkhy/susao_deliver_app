import 'dart:math';

import 'package:fast_gbk/fast_gbk.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:susao_deliver_app/common/printer.dart';
import 'package:susao_deliver_app/config.dart';
import 'package:susao_deliver_app/pages/shop/note/note_product.dart';
import 'package:susao_deliver_app/utils/http_utils.dart';
import 'package:susao_deliver_app/utils/toast_utils.dart';

class ShopInfo {
  String id;
  String name;
  String address;
  String contact;
  String phoneNumber;

  ShopInfo.fromJson(data) {
    this.id = data['id'].toString();
    this.name = data['name'];
    this.address = data['address'];
    this.contact = data['contact'];
    this.phoneNumber = data['phoneNumber'];
  }
}

class NoteInfo {
  String id;
  String code;
  String noteMsg;
  String totalPrice;
  String actualPrice;
  String bookkeeping;
  String cash;
  String weixin;
  String zhifubao;
  String card;
  int status;
  String createTime;
  Map<String, dynamic> createUser;

  NoteInfo.fromJson(data) {
    this.id = data['id'].toString();
    this.code = data['code'];
    this.noteMsg = data['noteMsg'];
    this.totalPrice = data['totalPrice'];
    this.actualPrice = data['actualPrice'];
    this.bookkeeping = data['bookkeeping'];
    this.cash = data['cash'];
    this.weixin = data['weixin'];
    this.zhifubao = data['zhifubao'];
    this.card = data['card'];
    this.status = data['status'];
    this.createTime = data['create_time'];
    this.createUser = data['createUser'];
  }
}

class NoteTicket {
  ShopInfo shop;
  NoteInfo note;
  List<ShopProduct> products;

  static double tableNameRatio = 0.5;
  static double tablePriceRatio = 0.1;
  static double tableNumRatio = 0.1;
  static double tableTotalRatio = 0.1;
  static double tableCodeRatio = 0.2;

  NoteTicket.fromJson(data) {
    this.note = NoteInfo.fromJson(data['note']);
    this.shop = ShopInfo.fromJson(data['note']['shop']);
    this.products = List<ShopProduct>.generate(data['products'].length, (index){
      return ShopProduct.fromJsonOfNoteProduct(data['products'][index]);
    });
  }

  void _printMsg(String message, int size, int align) {
    var printer = Printer.instance.printer;
    printer.printCustom('', size, align);
    printer.writeBytes(gbk.encode(message));
  }

  // 575像素
  void print() {
    var printer = Printer.instance.printer;
    // 订单id
    _printMsg("${this.shop.id}-${this.note.id}", 0, 0);
    printer.printNewLine();
    // 头部
    _printMsg("徐州苏嫂食品有限公司送货单", 3, 1);
    printer.printNewLine();
    // 客户信息、时间
    _printMsg('客户名称：${this.shop.name}', 0, 0);
    _printMsg('客户地址：${this.shop.address}', 0, 0);
    _printMsg('订单编号：${this.note.code}', 0, 0);
    _printMsg('订单时间：${this.note.createTime}', 0, 0);
    _printMsg('送货人：${(this.note.createUser["last_name"])??""}${(this.note.createUser["first_name"])??""}', 0, 0);
    _printMsg('送货人电话：${(this.note.createUser["moble"])??""}', 0, 0);
    printer.printNewLine();
    // 统计销售、退货、搭赠数量
    List<int> num = [0, 0, 0];
    for (ShopProduct product in products) {
      for (int i=0; i<num.length; ++i) {
        if (product.num[i] > 0) ++num[i];
      }      
    } 
    // 销售订单
    if (num[0] > 0) {
      _printMsg('销售清单：共${num[0]}种', 1, 1);
      _printProducts(0);
    }
    printer.printNewLine();
    // 退货订单
    if (num[1] > 0) {
      _printMsg('退货清单：共${num[1]}种', 1, 1);
      _printProducts(1);
    }
    printer.printNewLine();
    // 销售订单
    if (num[2] > 0) {
      _printMsg('搭赠清单：共${num[2]}种', 1, 1);
      _printProducts(2);
    }
    printer.printNewLine();

    // 订单金额
    _printMsg('合计金额：${note.totalPrice}', 1, 0);
    _printMsg('实收金额：${note.actualPrice}', 1, 0);
    _printMsg('记账金额：${note.bookkeeping}', 1, 0);

    printer.printNewLine();
    printer.printNewLine();
    printer.printCustom("################", 0, 1);
    printer.printNewLine();
    printer.paperCut();
    // 打印
  }

  int _calcSpace(String text, int size, double ratio) {
    int width = (Printer.instance.width * ratio).floor();
    int textWidth = text.length * Printer.instance.textSize(size);
    int spaceWidth = ((width - textWidth) / Printer.instance.textSize(size)).floor();
    return max(0, spaceWidth);
  }

  String _genSpace(int size) {
    String text = '';
    for (int i=0; i<(size ~/ 2); ++i) text += ' ';
    return text;
  }

  String _genTextCenter(List<String> texts, List<int> spaces) {
    String text = '';
    for (int i=0; i<texts.length; ++i) {
      text += _genSpace(spaces[i] ~/ 2);
      text += texts[i];
      if (i != texts.length-1) {
        text += _genSpace(spaces[i] ~/ 2);
      }
    }
    return text;
  }

  String _genTextLeft(List<String> texts, List<int> spaces) {
    String text = '';
    for (int i=0; i<texts.length; ++i) {
      text += texts[i];
      if (i != texts.length-1) {
        text += _genSpace(spaces[i]);
      }
    }
    return text;
  }

  void _printTableHeader() {
    List<int> spaces = [_calcSpace('商品名称', 1, tableNameRatio),
                        _calcSpace('单价', 1, tableNameRatio),
                        _calcSpace('数量', 1, tableNameRatio),
                        _calcSpace('金额', 1, tableNameRatio),
                        _calcSpace('编码', 1, tableNameRatio),];
    String text = _genTextCenter(['商品名称', '单价', '数量', '金额', '编码'], spaces);
    _printMsg(text, 1, 1);
  }

  void _printProduct(typeIndex, productIndex) {
    if (products[productIndex].num[typeIndex] <=0 ) return;
    int maxNameSize = 12;
    ShopProduct product = products[productIndex];
    String name = '$productIndex.${product.productName}';
    int nameLines = (name.length + maxNameSize - 1) ~/ maxNameSize;
    
    for (int lineNo=0; lineNo<nameLines; ++lineNo) {
      int len = (lineNo == nameLines-1)?(name.length%maxNameSize):maxNameSize;
      String text = name.substring(lineNo*maxNameSize, len);
      if (lineNo == 0) {
        List<String> texts = [
          text, '${product.price}/${product.unit}',
          '${product.num[typeIndex]}${product.unit}',
          '${(product.num[typeIndex] * product.price).toStringAsFixed(2)}',
          '${product.code??""}'
        ];
        List<int> spaces = [_calcSpace(texts[0], 0, tableNameRatio),
                            _calcSpace(texts[1], 0, tableNameRatio),
                            _calcSpace(texts[2], 0, tableNameRatio),
                            _calcSpace(texts[3], 0, tableNameRatio),
                            _calcSpace(texts[4], 0, tableNameRatio),];
        text = _genTextLeft(texts, spaces);
      }
      _printMsg(text, 0, 0);
      // if (!ObjectUtil.isEmptyString(product.code)) {
      //   _printMsg('${product.code??""}', 0, 0);
      // }
    }
  }

  void _printProducts(typeIndex) {
    _printTableHeader();
    for (int i=0; i<products.length; ++i) {
      _printProduct(typeIndex, i);
    }
  }
}

Future<void> printNoteTicketRemote(BuildContext context, String ticketUrl) async{
  if (ticketUrl == null || ticketUrl == '') {
    toastError('无法打印');
    return;
  }

  ImageDownloader.downloadImage('${Config.baseUrl}$ticketUrl',
    headers: HttpUtil().getToken()
  ).then((imageId){
    return ImageDownloader.findPath(imageId);
  }).then((path){
    // Printer.instance.printer.printCustom("###########", 0, 1);
    return Printer.instance.printer.printImage(path);
    // return Printer.instance.printer.printCustom('message', 0, 1);
  }).then((onValue){
    Printer.instance.printer.printNewLine();
    Printer.instance.printer.printCustom("###########", 0, 1);
    Printer.instance.printer.printNewLine();
    Printer.instance.printer.printNewLine();
    Printer.instance.printer.paperCut();
  })
  .catchError((onError){
    toastError('打印失败');
  });
}

void printNoteTicketLocal(BuildContext context, String noteId) {
    HttpUtil().get(context, '/note/api/note', {'noteId': "$noteId"},
      (rj) {
        NoteTicket note = NoteTicket.fromJson(rj.result);
        note.print();
      },
      null,
      null,
      null);   

}