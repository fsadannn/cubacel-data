import 'package:intl/intl.dart';

import 'models/all.dart';

Cubacel getEmptyData() {
  return Cubacel(
      internet: Internet.fromJson({}),
      credit: Credit.fromJson({}),
      others: Others.fromJson({}));
}

String dateToString(DateTime date) {
  // TODO: add internationalization
  var format = DateFormat('MMMd yyyy hh:mm a', 'es_ES');
  return format.format(date.toLocal());
}

String internetToString(num value) {
  // asume value is in MB
  num gb = value.abs() / 1024.0;
  if (gb > 1) {
    return '${value < 0 ? '-' : ''}${gb.toStringAsFixed(2)} GB';
  }

  return '${value.toStringAsFixed(2).toString()} MB';
}

String minutesToString(num minutes) {
  num pminutes = minutes.abs();

  num hour = pminutes / 60;
  if (hour < 1) {
    hour = 0;
  }
  num seconds = ((pminutes - pminutes.floor()) * 60).round();
  return '${minutes < 0 ? '-' : ''}${hour.toInt()}:${pminutes.floor() % 60 < 10 ? '0' : ''}${pminutes.floor() % 60}:${seconds < 10 ? '0' : ''}${seconds}';
}

num getMinutes(List<String> minstr) {
  num cont = 60;
  num vv;
  num mins = minstr.map((String e) {
    vv = num.parse(e) * cont;
    cont /= 60;
    return vv;
  }).reduce((value, element) => value + element);

  return mins;
}

num toMB(num value, String unit) {
  if (unit == "GB") {
    return value * 1024.0;
  }
  if (unit == "KB") {
    return value / 1024.0;
  }

  if (unit == "B") {
    return 0;
  }

  return value;
}

List<ParsedValue> getData(String value) {
  // TODO: parse credit bonus
  print(value);

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
    // TODO: test the case when only one of the network type exist like only LTE
    List<String> dd = value.split(':');
    List<String> value_unit =
        dd[1].split('+').map((String e) => e.split(' ')[2].trim()).toList();
    List<String> val =
        dd[1].split('+').map((String e) => e.split(' ')[1].trim()).toList();

    if (val.length == 1) {
      if (dd[1].contains("LTE")) {
        val = ['0', val[0]];
      } else {
        val = [val[0], '0'];
      }
      value_unit = [value_unit[0], value_unit[0]];
    }

    return [
      ParsedValue(
          unit: value_unit[0],
          fieldName: 'all_networks',
          value: num.parse(val[0].trim()),
          type: DataType.internet),
      ParsedValue(
          unit: value_unit[1],
          fieldName: 'only_lte',
          value: num.parse(val[1].trim()),
          type: DataType.internet)
    ];
  }

  if (value.startsWith('Voz:')) {
    String value_unit = "MIN";
    List<String> valsp = value.split(':');
    num mins = getMinutes(valsp.getRange(1, valsp.length).toList());

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
    List<String> dat = value.split(':');
    List<String> dat2 = value.split(':')[1].trim().split(' ');
    num sms = 0;
    String fieldName = 'sms';

    if (dat2.length < 3) {
      sms = num.parse(dat[1].trim());
    } else {
      sms = num.parse(dat2[0].trim());
      fieldName = 'sms_bonus';
    }

    return [
      ParsedValue(
          unit: value_unit,
          fieldName: fieldName,
          value: sms,
          type: DataType.other)
    ];
  }

  if (value.startsWith('Datos')) {
    String dd = value.split('->')[0].trim();
    List<String> dat = dd.split(' ');

    return [
      ParsedValue(
          unit: dat[2],
          fieldName: value.startsWith('Datos.cu')
              ? 'national_data'
              : 'promotional_data',
          value: num.parse(dat[1].trim()),
          type: DataType.internet)
    ];
  }

  if (value.startsWith('LTE')) {
    String dd = value.split('->')[0].trim();
    List<String> dat = dd.split(' ');

    return [
      ParsedValue(
          unit: dat[2],
          fieldName: 'promotional_data_lte',
          value: num.parse(dat[1].trim()),
          type: DataType.internet)
    ];
  }

  if (value.startsWith('MIN')) {
    String dd = value.split('->')[0].trim();
    List<String> dat = dd.split(' ');
    num mins = getMinutes(dat[1].trim().split(':'));

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

Cubacel fromUssd(String consult1, String consult2) {
  print(consult1);
  print(consult2);

  List<String> data = consult1.split('. ');

  List<String> data2 = consult2.split(':');
  if (data2.length > 1) {
    data2 = data2.getRange(1, data2.length).join(':').trim().split('. ');
  }

  List<ParsedValue> pData = [];
  List<ParsedValue> ppData = [];

  for (String datav in data) {
    ppData = getData(datav.trim());
    pData.addAll(ppData);
  }

  for (String datav in data2) {
    ppData = getData(datav.trim());
    pData.addAll(ppData);
  }

  Map<String, num> internetFields = {};
  Map<String, num> otherFields = {};
  Map<String, num> creditFields = {};

  for (ParsedValue val in pData) {
    switch (val.type) {
      case DataType.internet:
        num value = toMB(val.value, val.unit);
        internetFields[val.fieldName] = value;
        break;
      case DataType.other:
        otherFields[val.fieldName] = val.value;
        break;
      case DataType.credit:
        creditFields[val.fieldName] = val.value;
        break;
    }
  }

  print(otherFields);

  Cubacel cubacel = Cubacel.fromJson({
    'internet': internetFields,
    'credit': creditFields,
    'others': otherFields
  });

  return cubacel;
}

Cubacel computeDelta(Cubacel now, Cubacel prev) {
  Map<String, num> iNow = Map<String, num>.from(now.internet.toJson());
  Map<String, num> iPrev = Map<String, num>.from(prev.internet.toJson());

  for (String key in iNow.keys) {
    iNow[key] = iNow[key]! - iPrev[key]!;
  }

  Map<String, num> oNow = Map<String, num>.from(now.others.toJson());
  Map<String, num> oPrev = Map<String, num>.from(prev.others.toJson());

  for (String key in oNow.keys) {
    oNow[key] = oNow[key]! - oPrev[key]!;
  }

  Map<String, num> cNow = Map<String, num>.from(now.credit.toJson());
  Map<String, num> cPrev = Map<String, num>.from(prev.credit.toJson());

  for (String key in cNow.keys) {
    cNow[key] = cNow[key]! - cPrev[key]!;
  }

  Cubacel delta =
      Cubacel.fromJson({'internet': iNow, 'credit': cNow, 'others': oNow});

  return delta;
}
