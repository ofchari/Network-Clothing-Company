class Outward {
  String? message;
  List<Datumm>? data;

  Outward({this.message, this.data});

  Outward.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    if (json['data'] != null) {
      data = <Datumm>[];
      json['data'].forEach((v) {
        data!.add(Datumm.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Datumm {
  String? GATEMASID;
  String? CANCEL;
  String? SOURCEID;
  String? MAPNAME;
  String? USERNAME;
  String? MODIFIEDON;
  String? CREATEDBY;
  String? CREATEDON;
  String? WKID;
  String? APP_LEVEL;
  String? APP_DESC;
  String? APP_SLEVEL;
  String? CANCELREMARKS;
  String? WFROLES;
  String? DOCDATE;
  String? DCNO;
  String? STIME;
  String? PARTY;
  double? DELQTY;
  String? JOBCLOSE;
  String? STMUSER;
  String? REMARKS;
  String? JJFORMNO;
  String? DCNOS;
  String? ATIME;
  String? ITIME;
  String? DCDATE;
  String? RECID;
  String? ENAME;
  String? USERID;
  String? FINYEAR;
  String? DOCMAXNO;
  String? DPREFIX;
  String? DOCID;
  String? USCODE;

  Datumm({
    this.GATEMASID,
    this.CANCEL,
    this.SOURCEID,
    this.MAPNAME,
    this.USERNAME,
    this.MODIFIEDON,
    this.CREATEDBY,
    this.CREATEDON,
    this.WKID,
    this.APP_LEVEL,
    this.APP_DESC,
    this.APP_SLEVEL,
    this.CANCELREMARKS,
    this.WFROLES,
    this.DOCDATE,
    this.DCNO,
    this.STIME,
    this.PARTY,
    this.DELQTY,
    this.JOBCLOSE,
    this.STMUSER,
    this.REMARKS,
    this.JJFORMNO,
    this.DCNOS,
    this.ATIME,
    this.ITIME,
    this.DCDATE,
    this.RECID,
    this.ENAME,
    this.USERID,
    this.FINYEAR,
    this.DOCMAXNO,
    this.DPREFIX,
    this.DOCID,
    this.USCODE,
  });

  factory Datumm.fromJson(Map<String, dynamic> json) {
    return Datumm(
      GATEMASID: json['GATEMASID']?.toString(),
      CANCEL: json['CANCEL']?.toString(),
      SOURCEID: json['SOURCEID']?.toString(),
      MAPNAME: json['MAPNAME']?.toString(),
      USERNAME: json['USERNAME']?.toString(),
      MODIFIEDON: json['MODIFIEDON']?.toString(),
      CREATEDBY: json['CREATEDBY']?.toString(),
      CREATEDON: json['CREATEDON']?.toString(),
      WKID: json['WKID']?.toString(),
      APP_LEVEL: json['APP_LEVEL']?.toString(),
      APP_DESC: json['APP_DESC']?.toString(),
      APP_SLEVEL: json['APP_SLEVEL']?.toString(),
      CANCELREMARKS: json['CANCELREMARKS']?.toString(),
      WFROLES: json['WFROLES']?.toString(),
      DOCDATE: json['DOCDATE']?.toString(),
      DCNO: json['DCNO']?.toString(),
      STIME: json['STIME']?.toString(),
      PARTY: json['PARTY']?.toString(),
      DELQTY: json['DELQTY'] != null ? double.tryParse(json['DELQTY'].toString()) : null,
      JOBCLOSE: json['JOBCLOSE']?.toString(),
      STMUSER: json['STMUSER']?.toString(),
      REMARKS: json['REMARKS']?.toString(),
      JJFORMNO: json['JJFORMNO']?.toString(),
      DCNOS: json['DCNOS']?.toString(),
      ATIME: json['ATIME']?.toString(),
      ITIME: json['ITIME']?.toString(),
      DCDATE: json['DCDATE']?.toString(),
      RECID: json['RECID']?.toString(),
      ENAME: json['ENAME']?.toString(),
      USERID: json['USERID']?.toString(),
      FINYEAR: json['FINYEAR']?.toString(),
      DOCMAXNO: json['DOCMAXNO']?.toString(),
      DPREFIX: json['DPREFIX']?.toString(),
      DOCID: json['DOCID']?.toString(),
      USCODE: json['USCODE']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'GATEMASID': GATEMASID,
      'CANCEL': CANCEL,
      'SOURCEID': SOURCEID,
      'MAPNAME': MAPNAME,
      'USERNAME': USERNAME,
      'MODIFIEDON': MODIFIEDON,
      'CREATEDBY': CREATEDBY,
      'CREATEDON': CREATEDON,
      'WKID': WKID,
      'APP_LEVEL': APP_LEVEL,
      'APP_DESC': APP_DESC,
      'APP_SLEVEL': APP_SLEVEL,
      'CANCELREMARKS': CANCELREMARKS,
      'WFROLES': WFROLES,
      'DOCDATE': DOCDATE,
      'DCNO': DCNO,
      'STIME': STIME,
      'PARTY': PARTY,
      'DELQTY': DELQTY,
      'JOBCLOSE': JOBCLOSE,
      'STMUSER': STMUSER,
      'REMARKS': REMARKS,
      'JJFORMNO': JJFORMNO,
      'DCNOS': DCNOS,
      'ATIME': ATIME,
      'ITIME': ITIME,
      'DCDATE': DCDATE,
      'RECID': RECID,
      'ENAME': ENAME,
      'USERID': USERID,
      'FINYEAR': FINYEAR,
      'DOCMAXNO': DOCMAXNO,
      'DPREFIX': DPREFIX,
      'DOCID': DOCID,
      'USCODE': USCODE,
    };
  }
}