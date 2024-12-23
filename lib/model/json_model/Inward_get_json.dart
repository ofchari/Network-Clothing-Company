class Inward {
  String? message;
  List<Data>? data;

  Inward({this.message, this.data});

  Inward.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
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

class Data {
  String? gATEINMASID;
  String? cANCEL;
  String? sOURCEID;
  String? mAPNAME;
  String? uSERNAME;
  String? mODIFIEDON;
  String? cREATEDBY;
  String? cREATEDON;
  String? wKID;
  String? aPPLEVEL;
  String? aPPDESC;
  String? aPPSLEVEL;
  String? cANCELREMARKS;
  String? wFROLES;
  String? dOCDATE;
  String? dELCTRL;
  String? dEPT;
  String? dCNO;
  String? sTIME;
  String? pARTY;
  String? dELQTY;
  String? dUPCHK;
  String? jOBCLOSE;
  String? sTMUSER;
  String? rEMARKS;
  String? eNAME;
  String? dCDATE;
  String? dINWNO;
  String? dINWON;
  String? dINWBY;
  String? tODEPT;
  String? aTIME;
  String? iTIME;
  String? fINYEAR;
  String? dOCID;
  String? sUPP;
  String? jOBCLOSEDBY;
  String? jCLOSEDON;
  String? uSERID;
  String? nPARTY;
  String? pODCCHK;
  String? gST;
  String? gSTYN;
  String? pODC;
  String? rECID;
  String? dOCMAXNO;
  String? dPREFIX;
  String? dOCID1;
  String? uSCODE;
  String? dELREQ;
  String? dOCIDOLD;
  String? pARTY1;
  String? dUPCHK1;

  Data(
      {this.gATEINMASID,
        this.cANCEL,
        this.sOURCEID,
        this.mAPNAME,
        this.uSERNAME,
        this.mODIFIEDON,
        this.cREATEDBY,
        this.cREATEDON,
        this.wKID,
        this.aPPLEVEL,
        this.aPPDESC,
        this.aPPSLEVEL,
        this.cANCELREMARKS,
        this.wFROLES,
        this.dOCDATE,
        this.dELCTRL,
        this.dEPT,
        this.dCNO,
        this.sTIME,
        this.pARTY,
        this.dELQTY,
        this.dUPCHK,
        this.jOBCLOSE,
        this.sTMUSER,
        this.rEMARKS,
        this.eNAME,
        this.dCDATE,
        this.dINWNO,
        this.dINWON,
        this.dINWBY,
        this.tODEPT,
        this.aTIME,
        this.iTIME,
        this.fINYEAR,
        this.dOCID,
        this.sUPP,
        this.jOBCLOSEDBY,
        this.jCLOSEDON,
        this.uSERID,
        this.nPARTY,
        this.pODCCHK,
        this.gST,
        this.gSTYN,
        this.pODC,
        this.rECID,
        this.dOCMAXNO,
        this.dPREFIX,
        this.dOCID1,
        this.uSCODE,
        this.dELREQ,
        this.dOCIDOLD,
        this.pARTY1,
        this.dUPCHK1});

  Data.fromJson(Map<String, dynamic> json) {
    gATEINMASID = json['GATEINMASID'];
    cANCEL = json['CANCEL'];
    sOURCEID = json['SOURCEID'];
    mAPNAME = json['MAPNAME'];
    uSERNAME = json['USERNAME'];
    mODIFIEDON = json['MODIFIEDON'];
    cREATEDBY = json['CREATEDBY'];
    cREATEDON = json['CREATEDON'];
    wKID = json['WKID'];
    aPPLEVEL = json['APP_LEVEL'];
    aPPDESC = json['APP_DESC'];
    aPPSLEVEL = json['APP_SLEVEL'];
    cANCELREMARKS = json['CANCELREMARKS'];
    wFROLES = json['WFROLES'];
    dOCDATE = json['DOCDATE'];
    dELCTRL = json['DELCTRL'];
    dEPT = json['DEPT'];
    dCNO = json['DCNO'];
    sTIME = json['STIME'];
    pARTY = json['PARTY'];
    dELQTY = json['DELQTY'];
    dUPCHK = json['DUPCHK'];
    jOBCLOSE = json['JOBCLOSE'];
    sTMUSER = json['STMUSER'];
    rEMARKS = json['REMARKS'];
    eNAME = json['ENAME'];
    dCDATE = json['DCDATE'];
    dINWNO = json['DINWNO'];
    dINWON = json['DINWON'];
    dINWBY = json['DINWBY'];
    tODEPT = json['TODEPT'];
    aTIME = json['ATIME'];
    iTIME = json['ITIME'];
    fINYEAR = json['FINYEAR'];
    dOCID = json['DOCID'];
    sUPP = json['SUPP'];
    jOBCLOSEDBY = json['JOBCLOSEDBY'];
    jCLOSEDON = json['JCLOSEDON'];
    uSERID = json['USERID'];
    nPARTY = json['NPARTY'];
    pODCCHK = json['PODCCHK'];
    gST = json['GST'];
    gSTYN = json['GSTYN'];
    pODC = json['PODC'];
    rECID = json['RECID'];
    dOCMAXNO = json['DOCMAXNO'];
    dPREFIX = json['DPREFIX'];
    dOCID1 = json['DOCID1'];
    uSCODE = json['USCODE'];
    dELREQ = json['DELREQ'];
    dOCIDOLD = json['DOCIDOLD'];
    pARTY1 = json['PARTY1'];
    dUPCHK1 = json['DUPCHK1'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['GATEINMASID'] = gATEINMASID;
    data['CANCEL'] = cANCEL;
    data['SOURCEID'] = sOURCEID;
    data['MAPNAME'] = mAPNAME;
    data['USERNAME'] = uSERNAME;
    data['MODIFIEDON'] = mODIFIEDON;
    data['CREATEDBY'] = cREATEDBY;
    data['CREATEDON'] = cREATEDON;
    data['WKID'] = wKID;
    data['APP_LEVEL'] = aPPLEVEL;
    data['APP_DESC'] = aPPDESC;
    data['APP_SLEVEL'] = aPPSLEVEL;
    data['CANCELREMARKS'] = cANCELREMARKS;
    data['WFROLES'] = wFROLES;
    data['DOCDATE'] = dOCDATE;
    data['DELCTRL'] = dELCTRL;
    data['DEPT'] = dEPT;
    data['DCNO'] = dCNO;
    data['STIME'] = sTIME;
    data['PARTY'] = pARTY;
    data['DELQTY'] = dELQTY;
    data['DUPCHK'] = dUPCHK;
    data['JOBCLOSE'] = jOBCLOSE;
    data['STMUSER'] = sTMUSER;
    data['REMARKS'] = rEMARKS;
    data['ENAME'] = eNAME;
    data['DCDATE'] = dCDATE;
    data['DINWNO'] = dINWNO;
    data['DINWON'] = dINWON;
    data['DINWBY'] = dINWBY;
    data['TODEPT'] = tODEPT;
    data['ATIME'] = aTIME;
    data['ITIME'] = iTIME;
    data['FINYEAR'] = fINYEAR;
    data['DOCID'] = dOCID;
    data['SUPP'] = sUPP;
    data['JOBCLOSEDBY'] = jOBCLOSEDBY;
    data['JCLOSEDON'] = jCLOSEDON;
    data['USERID'] = uSERID;
    data['NPARTY'] = nPARTY;
    data['PODCCHK'] = pODCCHK;
    data['GST'] = gST;
    data['GSTYN'] = gSTYN;
    data['PODC'] = pODC;
    data['RECID'] = rECID;
    data['DOCMAXNO'] = dOCMAXNO;
    data['DPREFIX'] = dPREFIX;
    data['DOCID1'] = dOCID1;
    data['USCODE'] = uSCODE;
    data['DELREQ'] = dELREQ;
    data['DOCIDOLD'] = dOCIDOLD;
    data['PARTY1'] = pARTY1;
    data['DUPCHK1'] = dUPCHK1;
    return data;
  }
}
