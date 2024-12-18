class Inward {
  Inward({
    required this.message,
    required this.data,
  });

  final String? message;
  final List<Datum> data;

  factory Inward.fromJson(Map<String, dynamic> json){
    return Inward(
      message: json["message"],
      data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": data.map((x) => x.toJson()).toList(),
  };

}

class Datum {
  Datum({
    required this.exporter,
    required this.docid,
    required this.podcno,
    required this.gstno,
    required this.type,
    required this.partyname,
    required this.dcnoanddate,
    required this.time,
    required this.grnqty,
  });

  final String? exporter;
  final String? docid;
  final String? podcno;
  final String? gstno;
  final String? type;
  final String? partyname;
  final String? dcnoanddate;
  final String? time;
  final String? grnqty;

  factory Datum.fromJson(Map<String, dynamic> json){
    return Datum(
      exporter: json["EXPORTER"],
      docid: json["DOCID"],
      podcno: json["PODCNO"],
      gstno: json["GSTNO"],
      type: json["TYPE"],
      partyname: json["PARTYNAME"],
      dcnoanddate: json["DCNOANDDATE"],
      time: json["TIME"],
      grnqty: json["GRNQTY"],
    );
  }

  Map<String, dynamic> toJson() => {
    "EXPORTER": exporter,
    "DOCID": docid,
    "PODCNO": podcno,
    "GSTNO": gstno,
    "TYPE": type,
    "PARTYNAME": partyname,
    "DCNOANDDATE": dcnoanddate,
    "TIME": time,
    "GRNQTY": grnqty,
  };

}
