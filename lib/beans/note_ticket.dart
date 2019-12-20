import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/cupertino.dart';
import 'package:susao_deliver_app/common/printer.dart';
import 'package:susao_deliver_app/pages/shop/note/note_product.dart';
import 'package:susao_deliver_app/utils/http_utils.dart';

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
  String noteMsg;
  String totalPrice;
  String actualPrice;
  String bookkeeping;
  String cash;
  String weixin;
  String zhifubao;
  String card;
  int status;
  String noteTime;

  NoteInfo.fromJson(data) {
    this.id = data['id'].toString();
    this.noteMsg = data['noteMsg'];
    this.totalPrice = data['totalPrice'];
    this.actualPrice = data['actualPrice'];
    this.bookkeeping = data['bookkeeping'];
    this.cash = data['cash'];
    this.weixin = data['weixin'];
    this.zhifubao = data['zhifubao'];
    this.card = data['card'];
    this.status = data['status'];
    this.noteTime = data['noteTime'];
  }
}

class NoteTicket {
  ShopInfo shop;
  NoteInfo note;
  List<ShopProduct> products;

  NoteTicket.fromJson(data) {
    this.note = NoteInfo.fromJson(data['note']);
    this.shop = ShopInfo.fromJson(data['note']['shop']);
    this.products = List<ShopProduct>.generate(data['products'].length, (index){
      return ShopProduct.fromJsonOfNoteProduct(data['products'][index]);
    });
  }

  // 575像素
  void print() {
    

    var printer = Printer.instance.printer;
    // 订单id
    // printer.printCustom("${this.shop.id}-${this.note.id}", 0, 0);
    // printer.printNewLine();
    // 头部
    printer.printCustom("徐州苏嫂食品有限公司送货单", 3, 1);
    // printer.printNewLine();
    // // 客户信息、时间
    // printer.printCustom('客户名称：${this.shop.name}', 0, 1);
    // printer.printNewLine();
    // printer.printCustom('客户地址：${this.shop.address}', 0, 1);
    printer.printNewLine();
    printer.printNewLine();
    printer.paperCut();
    // 打印
  }
}

void printNoteTicket(BuildContext context, String noteId) {
    HttpUtil().get(context, '/note/api/note', {'noteId': "$noteId"},
      (rj) {
        NoteTicket nt = NoteTicket.fromJson(rj.result);
        nt.print();
      },
      null,
      null,
      null);   
  
}