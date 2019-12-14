
import 'dart:math';

import 'package:susao_deliver_app/pages/shop/note/note_product.dart';

class RuleItem {
  String name;
  int ruleType;
  int ruleStatus;

  RuleItem.fromJson(data) {
    this.name = data['name'];
    this.ruleType = data['ruleType'];
    this.ruleStatus = data['ruleStatus'];
  }
}

class ConditionItem {
  String productId;
  String productName;
  double price;
  int num;

  ConditionItem.fromJson(data) {
    this.productId = data['product']['id'].toString();
    this.productName = data['product']['name'];
    this.price = double.parse(data['product']['price']);
    this.num = data['num'];
  }
}

class GiftItem {
  String productId;
  String productName;
  double price;
  int num;

  GiftItem.fromJson(data) {
    this.productId = data['product']['id'].toString();
    this.productName = data['product']['name'];
    this.price = double.parse(data['product']['price']);
    this.num = data['num'];
  }
}

class GiftRule {
  RuleItem rule;
  List<ConditionItem> conditions;
  List<GiftItem> gifts;

  GiftRule.fromJson(data) {
    this.rule = RuleItem.fromJson(data['rule']);

    this.conditions = List.generate(data['conditions'].length, (idx){
      return ConditionItem.fromJson(data['conditions'][idx]);
    });
    this.gifts = List.generate(data['gifts'].length, (idx){
      return GiftItem.fromJson(data['gifts'][idx]);
    });
  }

  int isMatch(Map<String, ShopProduct> id2product) {
    int times;
    for (ConditionItem condition in conditions) {
      ShopProduct product = id2product[condition.productId];
      if (product == null) {
        return 0;
      }
      if (product.num[0] - product.num[1] < condition.num) {
        return 0;
      }
      if (condition.num <=0) {
        times = 1;
      } else {
        int _t = (product.num[0] - product.num[1]) ~/ condition.num;
        times = times == null?_t: min(_t, times);
      }
    }
    return (rule.ruleType == 0?1:times);
  }
}


class GiftRuleUtil {
  List<GiftRule> giftRules;

  GiftRuleUtil.fromJson(data) {
    this.giftRules = List.generate(data.length, (idx){
      return GiftRule.fromJson(data[idx]);
    });
  }

  List<ShopProduct> getGift(List<ShopProduct> inProducts) {
    List<ShopProduct> products = List.from(inProducts);
    Map<String, ShopProduct> id2product = new Map();
    products.forEach((item) {
      item.num[2] = 0;
      id2product[item.productId] = item;
    });

    for (GiftRule rule in this.giftRules) {
      if (rule.rule.ruleStatus == 0) continue;
      int giftTimes = rule.isMatch(id2product);
      if ( 0 >= giftTimes) continue;
      for (GiftItem item in rule.gifts) {
        ShopProduct product = id2product[item.productId];
        if (product == null) {
          products.add(ShopProduct.fromJson({
            // 'shopId': shopId,
            'productId': item.productId,
            // 'shopProductId': shopProductId,
            'productName': item.productName,
            'price': item.price,
            'type': 0,
            'deliverNum': 0,
            'rejectNum': 0,
            'giftNum': item.num * giftTimes,
          }));
        } else {
          product.num[2] += item.num * giftTimes;
        }
      }
    }
    return products;
  }

}