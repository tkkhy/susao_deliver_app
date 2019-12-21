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
    printer.printCustom("${this.shop.id}-${this.note.id}", 0, 0);
    printer.printNewLine();
    // 头部
    printer.printCustom("nihao", 3, 1);
    printer.printNewLine();
    // // 客户信息、时间
    printer.printCustom('客户名称：${this.shop.name}', 0, 1);
    // printer.printNewLine();
    printer.printCustom('客户地址：${this.shop.address}', 0, 1);
    printer.printNewLine();
    printer.printNewLine();
    printer.paperCut();
    // 打印
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
    Printer.instance.printer.printImage(path);
    Printer.instance.printer.printNewLine();
    Printer.instance.printer.printCustom("###########", 0, 1);
    Printer.instance.printer.printNewLine();
    Printer.instance.printer.printNewLine();
    Printer.instance.printer.paperCut();
  }).catchError((onError){
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