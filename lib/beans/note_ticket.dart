import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:susao_deliver_app/pages/shop/note/note_product.dart';

class ShopInfo {
  String id;
  String name;
  String address;
  String contact;
  String phoneNumber;

  ShopInfo.fromJson(data) {
    this.id = data['id'];
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
    this.id = data['id'];
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
  void print(BlueThermalPrinter bluetooth) {
    // 订单id
    bluetooth.printCustom("${this.shop.id}-${this.note.id}", 0, 0);
    // 头部
    bluetooth.printCustom("徐州苏嫂食品有限公司送货单", 3, 1);
    bluetooth.printNewLine();
    // 客户信息、时间
    bluetooth.printCustom('客户名称：${this.shop.name}', 0, 1);
    bluetooth.printCustom('客户地址：${this.shop.address}', 0, 1);
    // 打印
  }
}