enum NoteStatus {
  unpaid,
  complete
}

enum NoteProductType {
  deliver,
  reject,
  gift,
}

Map<int, String> deliverNoteStatus = {
  NoteStatus.unpaid.index: '未盘点',
  NoteStatus.complete.index: '已盘点'
};

Map<int, String> noteProductType = {
  NoteProductType.deliver.index: '送货',
  NoteProductType.reject.index: '退货',
  NoteProductType.gift.index: '搭赠'
};

enum PayType {
  cash,
  weixin,
  zhifubao,
  card,
}

Map<int, String> payType2name = {
  PayType.cash.index: '现金',
  PayType.weixin.index: '微信',
  PayType.zhifubao.index: '支付宝',
  PayType.card.index: '银行卡'
};