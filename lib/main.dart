import 'package:datos/model.dart';
import 'package:datos/models/all.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:sim_data/sim_data.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:ussd_service/ussd_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/all.dart';

final dataProvider = StateProvider<Cubacel>((_) => Cubacel(
    internet: Internet.fromJson({}),
    credit: Credit.fromJson({}),
    others: Others.fromJson({})
));

final prevDataProvider = StateProvider<Cubacel>((_) => Cubacel(
    internet: Internet.fromJson({}),
    credit: Credit.fromJson({}),
    others: Others.fromJson({})
));

Future<int> getSimCardsData() async {
  try {
    SimData simData = await SimDataPlugin.getSimData();
    simData.cards.forEach((SimCard s) {
      print('Serial number: ${s.subscriptionId}');
    });
    return simData.cards.first.subscriptionId;
  } catch (e) {
    print(e);
    return 0;
  }
}

Future<String> makeUSSDRequest(String code, int? subscriptionId) async {
  if (subscriptionId == null) {
    return '';
  }

  try {
    String ussdResponseMessage = await UssdService.makeRequest(
      subscriptionId,
      code,
      Duration(seconds: 10), // timeout (optional) - default is 10 seconds
    );
    print("succes! message: $ussdResponseMessage");
    return ussdResponseMessage;
  } catch (e) {
    print(e);
    return '';
  }
}

Future<Cubacel> getCubacelData() async {
  int subscription;
  /*if (!(await Permission.phone.request().isGranted)) {
    print('Permision denied');
  }*/
// Either the permission was already granted before or the user just granted it.
  //subscription = await getSimCardsData();
  subscription = 0;
  //String response = await makeUSSDRequest("*222#", subscription);
  String response = "Saldo: 435.54 CUP. Datos: 916.89 MB + 504.32 MB LTE. Voz: 00:08:44. SMS: 166. Linea activa hasta 06-09-22 vence 06-10-22.";
  //String response2 = await makeUSSDRequest("*222*266#", subscription);
  String response2 = "Bono->vence: Datos 553.75 MB->10-11-21. MIN 00:27:11->10-11-21. Datos.cu 300.00 MB->10-11-21.";

  Cubacel cubacel = fromUssd(response, response2);

  return cubacel;

}

void main() {
  runApp(
    ProviderScope(child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(
        title: "Datos",
      ),
    );
  }
}

class VarText extends ConsumerWidget {
  final StateProvider<String?> provider;
  const VarText(this.provider, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final String? value = watch(this.provider).state;
    String val;
    if (value == null) {
      val = '';
    } else {
      val = value;
    }
    return Text(val); // Hello world
  }
}

class MyHomePage extends ConsumerWidget {
  final String title;

  const MyHomePage({required this.title, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
      final Cubacel currentData = watch(dataProvider).state;
      final Cubacel prevData = watch(prevDataProvider).state;
      final Cubacel delta = computeDelta(currentData, prevData);
      final TextStyle textTableStyle = TextStyle(fontWeight: FontWeight.w600);

      return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(this.title),
        ),
        body: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: SingleChildScrollView(
          child: Column(
            // Column is also a layout widget. It takes a list of children and
            // arranges them vertically. By default, it sizes itself to fit its
            // children horizontally, and tries to be as tall as its parent.
            //
            // Invoke "debug painting" (press "p" in the console, choose the
            // "Toggle Debug Paint" action from the Flutter Inspector in Android
            // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
            // to see the wireframe for each widget.
            //
            // Column has various properties to control how it sizes itself and
            // how it positions its children. Here we use mainAxisAlignment to
            // center the children vertically; the main axis here is the vertical
            // axis because Columns are vertical (the cross axis would be
            // horizontal).
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Flex(
                direction: Axis.horizontal,
                children: [
                  Expanded(
                      child: Center(
                          child: Text(
                    'Internet (MB)',
                    style: TextStyle(
                        backgroundColor: Color.fromRGBO(255, 255, 255, 1),
                        fontSize: 18,
                      fontWeight: FontWeight.bold
                    )
                  )))
                ],
              ),
              DataTable(
                  headingRowColor:
                      MaterialStateProperty.all(Color.fromRGBO(92, 92, 92, 1)),
                  headingTextStyle: TextStyle(
                      color: Color.fromRGBO(255, 255, 255, 1),
                      fontWeight: FontWeight.bold,
                    fontSize: 16
                  ),
                  columns: [
                    DataColumn(label: Text('Servicio')),
                    DataColumn(label: Text('Valor')),
                    DataColumn(label: Text('Delta'))
                  ],
                  rows: [
                    DataRow(cells: [
                      DataCell(Text('Datos',style: textTableStyle,)),
                      DataCell(Text(currentData.internet.all_networks.toString(),style: textTableStyle)),
                      DataCell(Text((currentData.internet.all_networks!-prevData.internet.all_networks!).toString(),style: textTableStyle))
                    ]),
                    DataRow(cells: [
                      DataCell(Text('LTE',style: textTableStyle)),
                      DataCell(Text(currentData.internet.only_lte.toString(),style: textTableStyle)),
                      DataCell(Text((currentData.internet.only_lte!-prevData.internet.only_lte!).toString(),style: textTableStyle))
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Bono Datos',style: textTableStyle)),
                      DataCell(Text(currentData.internet.promotional_data.toString(),style: textTableStyle)),
                      DataCell(Text((currentData.internet.promotional_data!-prevData.internet.promotional_data!).toString(),style: textTableStyle))
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Datos.cu',style: textTableStyle)),
                      DataCell(Text(currentData.internet.national_data.toString(),style: textTableStyle)),
                      DataCell(Text((currentData.internet.national_data!-prevData.internet.national_data!).toString(),style: textTableStyle))
                    ])
                  ]),
              SizedBox(height: 20),
              Flex(
                direction: Axis.horizontal,
                children: [
                  Expanded(
                      child: Center(
                          child: Text(
                              'Saldo, Voz y Minutos',
                              style: TextStyle(
                                  backgroundColor: Color.fromRGBO(255, 255, 255, 1),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold
                              )
                          )))
                ],
              ),
              DataTable(
                  headingRowColor:
                  MaterialStateProperty.all(Color.fromRGBO(92, 92, 92, 1)),
                  headingTextStyle: TextStyle(
                      color: Color.fromRGBO(255, 255, 255, 1),
                      fontWeight: FontWeight.bold,
                      fontSize: 16
                  ),
                  columns: [
                    DataColumn(label: Text('Servicio')),
                    DataColumn(label: Text('Valor')),
                    DataColumn(label: Text('Delta'))
                  ],
                  rows: [
                    DataRow(cells: [
                      DataCell(Text('Saldo',style: textTableStyle,)),
                      DataCell(Text(currentData.credit.credit_normal.toString(),style: textTableStyle)),
                      DataCell(Text((currentData.credit.credit_normal!-prevData.credit.credit_normal!).toString(),style: textTableStyle))
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Saldo Bono',style: textTableStyle)),
                      DataCell(Text(currentData.credit.credit_bonus.toString(),style: textTableStyle)),
                      DataCell(Text((currentData.credit.credit_bonus!-prevData.credit.credit_bonus!).toString(),style: textTableStyle))
                    ]),
                    DataRow(cells: [
                      DataCell(Text('SMS',style: textTableStyle)),
                      DataCell(Text(currentData.others.sms.toString(),style: textTableStyle)),
                      DataCell(Text((currentData.others.sms!-prevData.others.sms!).toString(),style: textTableStyle))
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Minutos',style: textTableStyle)),
                      DataCell(Text(minutesToString(currentData.others.minutes!),style: textTableStyle)),
                      DataCell(Text(minutesToString((currentData.others.minutes!-prevData.others.minutes!)),style: textTableStyle))
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Bono Minutos',style: textTableStyle)),
                      DataCell(Text(minutesToString(currentData.others.minutes_bonus!),style: textTableStyle)),
                      DataCell(Text(minutesToString((currentData.others.minutes_bonus!-prevData.others.minutes_bonus!)),style: textTableStyle))
                    ])
                  ])
            ],
          ),
          )
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            Cubacel cData = await getCubacelData();
            context.read(dataProvider).state = cData;
            context.read(prevDataProvider).state = currentData;
          },
          tooltip: 'Increment',
          child: Icon(Icons.add),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      );

  }
}
