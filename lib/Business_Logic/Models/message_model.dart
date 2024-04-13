class Message {
  String? fromWhom;
  String? toWhom;
  bool? isSentByMe;
  String? message;
  var date;

  Message(
      {this.fromWhom, this.toWhom, this.isSentByMe, this.message, this.date});

  Map<String, dynamic> toMap() {
    return {
      "fromWhom": fromWhom,
      "toWhom": toWhom,
      "isSentByMe": isSentByMe,
      "message": message,
      "date": date
    };
  }

  Message.fromMap(Map<String, dynamic> map)
      : fromWhom = map["fromWhom"],
        toWhom = map["toWhom"],
        isSentByMe = map["isSentByMe"],
        message = map["message"],
        date = map["date"];
}
