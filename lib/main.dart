import 'package:datos/model.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:sim_data/sim_data.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:ussd_service/ussd_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final moneyProvider = StateProvider<String?>((_) => null);
final dataProvider = StateProvider<String?>((_) => null);
final bonusProvider = StateProvider<String?>((_) => null);

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

Future<void> getCubacelData() async {
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
  String response2 = "Bono->vence: Datos 553.75 MB->10-11-21. MIN 00:27:11->10-11-21.";

  Cubacel.fromUssd(response, response2);
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

class MyHomePage extends StatelessWidget {
  final String title;

  const MyHomePage({required this.title, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, watch, child) {
      return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(this.title),
        ),
        body: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
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
                    'Internet',
                    style: TextStyle(
                        backgroundColor: Color.fromRGBO(255, 255, 255, 1)),
                  )))
                ],
              ),
              DataTable(
                  headingRowColor:
                      MaterialStateProperty.all(Color.fromRGBO(92, 92, 92, 1)),
                  headingTextStyle: TextStyle(
                      color: Color.fromRGBO(255, 255, 255, 1),
                      fontWeight: FontWeight.bold),
                  columns: [
                    DataColumn(label: Text('Servicio')),
                    DataColumn(label: Text('Valor')),
                    DataColumn(label: Text('Delta'))
                  ],
                  rows: [
                    DataRow(cells: [
                      DataCell(Text('cell 11')),
                      DataCell(Text('cell 12')),
                      DataCell(Text('cell 13'))
                    ]),
                    DataRow(cells: [
                      DataCell(Text('cell 21')),
                      DataCell(Text('cell 22')),
                      DataCell(Text('cell 23'))
                    ]),
                    DataRow(cells: [
                      DataCell(Text('cell 31')),
                      DataCell(Text('cell 32')),
                      DataCell(Text('cell 33'))
                    ])
                  ])
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await getCubacelData();
          },
          tooltip: 'Increment',
          child: Icon(Icons.add),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      );
    });
  }
}
