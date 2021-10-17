import 'dart:convert';
import 'models/parsed_value.dart';
import 'models/data_type.dart';

double getMinutes(List<String> minstr){
  double cont = 60;
  double vv;
  double mins = minstr.map((String e) {
    vv = num.parse(e) * cont;
    cont /= 60;
    return vv;
  }).reduce((value, element) =>value + element);

  return mins;
}

List<ParsedValue> getData(String value) {
  if (value.startsWith('Saldo:')) {
    List<String> value_unit = value.split(':')[1].trim().split(' ');

    return [
      ParsedValue(
          unit: value_unit[1],
          fieldName: 'credit_normal',
          value: num.parse(value_unit[0].trim()),
          type: DataType.credit)
    ];
  }

  if (value.startsWith('Datos:')) {
    List<String> dd = value.split(':');
    List<String> value_unit = dd[1].split('+').map((String e) => e.split(' ')[2].trim()).toList();
    List<String> val = dd[1].split('+').map((String e) => e.split(' ')[1].trim()).toList();
    return [
      ParsedValue(
          unit: value_unit[0],
          fieldName: 'all_networks',
          value: num.parse(val[0].trim()),
          type: DataType.internet),
      ParsedValue(
          unit: value_unit[1],
          fieldName: 'lte_bonus',
          value: num.parse(val[1].trim()),
          type: DataType.internet)
    ];
  }

  if (value.startsWith('Voz:')) {
    String value_unit = "MIN";
    List<String> valsp = value.split(':');
    double mins = getMinutes(valsp.getRange(1, valsp.length).toList());

    return [
      ParsedValue(
          unit: value_unit,
          fieldName: 'minutes',
          value: mins,
          type: DataType.other)
    ];
  }

  if (value.startsWith('SMS:')) {
    String value_unit = "SMS";

    return [
      ParsedValue(
          unit: value_unit,
          fieldName: 'sms',
          value: num.parse(value.split(':')[1].trim()),
          type: DataType.other)
    ];
  }

  if (value.startsWith('Dato')) {
    String dd = value.split('->')[0].trim();
    List<String> dat = dd.split(' ');

    return [
      ParsedValue(
          unit: dat[2],
          fieldName: 'promotional_data',
          value: num.parse(dat[1].trim()),
          type: DataType.internet)
    ];
  }

  if (value.startsWith('MIN')) {
    String dd = value.split('->')[0].trim();
    List<String> dat = dd.split(' ');
    double mins = getMinutes(dat[1].trim().split(':'));

    return [
      ParsedValue(
          unit: "MIN",
          fieldName: 'minutes_bonus',
          value: mins,
          type: DataType.other)
    ];
  }

  return [];
}

class Internet {
  final String unit = 'MB';
  final double? only_lte;
  final double? all_networks;
  final double? lte_bonus;
  final double? national_data;
  final double? promotional_data;

  Internet(
      {this.only_lte,
      this.all_networks,
      this.lte_bonus,
      this.national_data,
      this.promotional_data});

  String toJson() {
    var internet = {
      "unit": this.unit,
      'values': {
        'only_lte': this.only_lte,
        'all_networks': this.all_networks,
        'lte_bonus': this.lte_bonus,
        'national_data': this.national_data,
        'promotional_data': this.promotional_data
      }
    };

    return JsonEncoder().convert(internet);
  }

  static Internet fromJson(String data) {
    var internet = JsonDecoder().convert(data);
    return Internet(
        only_lte: internet?.values?.only_lte,
        all_networks: internet?.values?.all_networks,
        lte_bonus: internet?.values?.lte_bonus,
        national_data: internet?.values?.national_data,
        promotional_data: internet?.values?.promotional_data);
  }
}

class Credit {
  final String unit = 'CUC';
  final double? credit_normal;
  final double? credit_bonus;

  Credit({required this.credit_normal, required this.credit_bonus});

  String toJson() {
    var credit = {
      "unit": this.unit,
      'values': {
        'credit_normal': this.credit_normal,
        'credit_bonus': this.credit_bonus,
      }
    };

    return JsonEncoder().convert(credit);
  }

  static Credit fromJson(String data) {
    var credit = JsonDecoder().convert(data);
    return Credit(
        credit_normal: credit?.values?.credit_normal,
        credit_bonus: credit?.values?.credit_bonus);
  }
}

class Others {
  final String? unit = null;
  final double? sms;
  final double? minutes;
  final double? minutes_bonus;

  Others({required this.sms, required this.minutes,required this.minutes_bonus});

  String toJson() {
    var other = {
      "unit": this.unit,
      'values': {
        'sms': {'value': this.sms},
        'minutes': {'value': this.minutes},
        'minutes_bonus':  {'value': this.minutes_bonus},
      }
    };

    return JsonEncoder().convert(other);
  }

  static Others fromJson(String data) {
    var others = JsonDecoder().convert(data);
    return Others(
        sms: others?.values?.sms?.value, minutes: others?.minutes?.value, minutes_bonus: others?.minutes_bonus?.value);
  }
}


class Cubacel {
  final DateTime date;
  final Internet internet;
  final Credit credit;
  final Others others;

  Cubacel({required this.internet, required this.credit, required this.others})
      : date = DateTime.now();

  String toJson() {
    var cuabcel = {
      "date": this.date,
      "internet": this.internet.toJson(),
      "credit": this.credit.toJson(),
      "others": this.others.toJson()
    };

    return JsonEncoder().convert(cuabcel);
  }

  static Cubacel fromJson(String data) {
    var cubacel = JsonDecoder().convert(data);
    final Internet internet = Internet.fromJson(cubacel?.internet);
    final Credit credit = Credit.fromJson(cubacel?.credit);
    final Others others = Others.fromJson(cubacel?.others);
    return Cubacel(internet: internet, credit: credit, others: others);
  }

  static fromUssd(String consult1, String consult2) {
    List<String> data = consult1.split('. ');
    print(data);

    List<String> data2 = consult2.split(':');
    if (data2.length > 1) {
      data2 = data2.getRange(1, data2.length).join(':').trim().split('. ');
      print(data2);
    }

    List<ParsedValue> pData = [];
    List<ParsedValue> ppData = [];

    for(int i=0;i<data.length;i++){
      ppData = getData(data[i].trim());
      pData.addAll(ppData);
    }

    for(int i=0;i<data2.length;i++){
      ppData = getData(data2[i].trim());
      pData.addAll(ppData);

    }

    for(int i=0; i<pData.length;i++){
      print(pData[i].toJson());
    }
  }
}
