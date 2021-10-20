import 'package:datos/model.dart';
import 'package:datos/models/all.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path/path.dart' as dPath;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:sim_data/sim_data.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:ussd_service/ussd_service.dart';

import 'models/all.dart';

Database? cubacelDb;
Database? cacheCubacelDb;
var store = StoreRef.main();
final String dataKey = 'last';
final String prevDataKey = 'plast';
final String dbName = 'cubacel.db';
final String cacheDbName = 'cacheCubacel.db';

final dataProvider = StateProvider<Cubacel>((_) => throw UnimplementedError());

final prevDataProvider =
    StateProvider<Cubacel>((_) => throw UnimplementedError());

final loadingProvider = StateProvider<bool>((_) => false);

Future<int> getSimCardsData() async {
  try {
    SimData simData = await SimDataPlugin.getSimData();
    /*simData.cards.forEach((SimCard s) {
      print('Serial number: ${s.subscriptionId}');
    });*/
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
    //print("succes! message: $ussdResponseMessage");
    return ussdResponseMessage;
  } catch (e) {
    print(e);
    return '';
  }
}

Future<Cubacel> getCubacelData() async {
  int subscription;
  if (!(await Permission.phone.request().isGranted)) {
    print('Permision denied');
  }
// Either the permission was already granted before or the user just granted it.
  subscription = await getSimCardsData();
  //subscription = 0;
  String response = await makeUSSDRequest("*222#", subscription);
  String response2 = await makeUSSDRequest("*222*266#", subscription);

  /*String response =
      "Saldo: 435.54 CUP. Datos: 1.3 GB + 404.32 MB LTE. Voz: 00:08:44. SMS: 150. Linea activa hasta 06-09-22 vence 06-10-22.";
  String response2 =
      "Bono->vence: Datos 453.75 MB->10-11-21. MIN 00:27:11->10-11-21. Datos.cu 100.00 MB->10-11-21.";*/

  Cubacel cubacel = fromUssd(response, response2);

  return cubacel;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('es_ES', null);

  var appDocDir = await getApplicationDocumentsDirectory();
  //print(appDocDir);
  String appDocPath = appDocDir.path;

  String dbPath = dPath.join(appDocPath, dbName);
  DatabaseFactory dbFactory = databaseFactoryIo;

  Database db = await dbFactory.openDatabase(dbPath);
  cubacelDb = db;

  dbPath = dPath.join(appDocPath, cacheDbName);
  db = await dbFactory.openDatabase(dbPath);
  cacheCubacelDb = db;

  var r = await store.record(dataKey).get(db);
  r ??= getEmptyData().toJson();
  r = Cubacel.fromJson(r);

  var r2 = await store.record(prevDataKey).get(db);
  r2 ??= getEmptyData().toJson();
  r2 = Cubacel.fromJson(r2);

  runApp(
    ProviderScope(child: MyApp(), overrides: [
      dataProvider.overrideWithProvider(StateProvider<Cubacel>((_) => r)),
      prevDataProvider.overrideWithProvider(StateProvider<Cubacel>((_) => r2))
    ]),
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

class MyHomePage extends ConsumerWidget {
  final String title;
  final TextStyle textTableStyle = TextStyle(fontWeight: FontWeight.w600);
  final TextStyle headTextStyle = TextStyle(
      color: Color.fromRGBO(60, 60, 60, 1),
      backgroundColor: Color.fromRGBO(255, 255, 255, 1),
      fontSize: 18,
      fontWeight: FontWeight.bold);

  MyHomePage({required this.title, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final bool loading = watch(loadingProvider).state;
    final Cubacel currentData = watch(dataProvider).state;
    final Cubacel prevData = watch(prevDataProvider).state;
    final Cubacel delta = computeDelta(currentData, prevData);

    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(this.title),
      ),
      body: RefreshIndicator(
          child: Center(
            // Center is a layout widget. It takes a single child and positions it
            // in the middle of the parent.
            child: loading
                ? CircularProgressIndicator()
                : buildDataTabllesWidget(
                    context, currentData, delta, prevData.date),
          ),
          onRefresh: () async {
            await updateData(context, currentData);
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await updateData(context, currentData);
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget buildDataTabllesWidget(BuildContext context, Cubacel currentData,
      Cubacel delta, DateTime prevDate) {
    return ListView(
      shrinkWrap: true,
      children: <Widget>[
        SizedBox(height: 10),
        Flex(
          direction: Axis.horizontal,
          children: [
            Expanded(
                child: Center(
              child: Text('Última Actualización: ', style: headTextStyle),
            ))
          ],
        ),
        Flex(
          direction: Axis.horizontal,
          children: [
            Expanded(
                child: Center(
              child: Text('${dateToString(currentData.date)}',
                  style: headTextStyle.copyWith(fontWeight: FontWeight.w600)),
            ))
          ],
        ),
        Flex(
          direction: Axis.horizontal,
          children: [
            Expanded(
                child: Center(
              child: Text('Penúltima Actualización: ', style: headTextStyle),
            ))
          ],
        ),
        Flex(
          direction: Axis.horizontal,
          children: [
            Expanded(
                child: Center(
              child: Text('${dateToString(prevDate)}',
                  style: headTextStyle.copyWith(fontWeight: FontWeight.w600)),
            ))
          ],
        ),
        SizedBox(height: 20),
        Flex(
          direction: Axis.horizontal,
          children: [
            Expanded(
                child:
                    Center(child: Text('Internet (MB)', style: headTextStyle)))
          ],
        ),
        Flex(
          direction: Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DataTable(
                headingRowColor:
                    MaterialStateProperty.all(Color.fromRGBO(92, 92, 92, 1)),
                headingTextStyle: TextStyle(
                    color: Color.fromRGBO(255, 255, 255, 1),
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
                columns: [
                  DataColumn(label: Text('Servicio')),
                  DataColumn(label: Text('Valor')),
                  DataColumn(label: Text('Delta'))
                ],
                rows: [
                  DataRow(cells: [
                    DataCell(Text(
                      'Datos',
                      style: textTableStyle,
                    )),
                    DataCell(Text(
                        internetToString(currentData.internet.all_networks!),
                        style: textTableStyle)),
                    DataCell(Text(
                        internetToString(delta.internet.all_networks!),
                        style: textTableStyle)),
                  ]),
                  DataRow(cells: [
                    DataCell(Text('LTE', style: textTableStyle)),
                    DataCell(Text(
                        internetToString(currentData.internet.only_lte!),
                        style: textTableStyle)),
                    DataCell(Text(internetToString(delta.internet.only_lte!),
                        style: textTableStyle)),
                  ]),
                  DataRow(cells: [
                    DataCell(Text('Bono Datos', style: textTableStyle)),
                    DataCell(Text(
                        internetToString(
                            currentData.internet.promotional_data!),
                        style: textTableStyle)),
                    DataCell(Text(
                        internetToString(delta.internet.promotional_data!),
                        style: textTableStyle)),
                  ]),
                  DataRow(cells: [
                    DataCell(Text('Datos.cu', style: textTableStyle)),
                    DataCell(Text(
                        internetToString(currentData.internet.national_data!),
                        style: textTableStyle)),
                    DataCell(Text(
                        internetToString(delta.internet.national_data!),
                        style: textTableStyle)),
                  ])
                ]),
          ],
        ),
        SizedBox(height: 20),
        Flex(
          direction: Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
                child: Center(
                    child: Text('Saldo, Voz y Minutos', style: headTextStyle)))
          ],
        ),
        Flex(
            direction: Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DataTable(
                  headingRowColor:
                      MaterialStateProperty.all(Color.fromRGBO(92, 92, 92, 1)),
                  headingTextStyle: TextStyle(
                      color: Color.fromRGBO(255, 255, 255, 1),
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                  columns: [
                    DataColumn(label: Text('Servicio')),
                    DataColumn(label: Text('Valor')),
                    DataColumn(label: Text('Delta'))
                  ],
                  rows: [
                    DataRow(cells: [
                      DataCell(Text(
                        'Saldo',
                        style: textTableStyle,
                      )),
                      DataCell(Text(
                          currentData.credit.credit_normal!.toStringAsFixed(2),
                          style: textTableStyle)),
                      DataCell(Text(
                          delta.credit.credit_normal!.toStringAsFixed(2),
                          style: textTableStyle)),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Saldo Bono', style: textTableStyle)),
                      DataCell(Text(
                          currentData.credit.credit_bonus!.toStringAsFixed(2),
                          style: textTableStyle)),
                      DataCell(Text(
                          delta.credit.credit_bonus!.toStringAsFixed(2),
                          style: textTableStyle)),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('SMS', style: textTableStyle)),
                      DataCell(Text(currentData.others.sms.toString(),
                          style: textTableStyle)),
                      DataCell(Text(delta.others.sms.toString(),
                          style: textTableStyle)),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Minutos', style: textTableStyle)),
                      DataCell(Text(
                          minutesToString(currentData.others.minutes!),
                          style: textTableStyle)),
                      DataCell(Text(minutesToString(delta.others.minutes!),
                          style: textTableStyle)),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Bono Minutos', style: textTableStyle)),
                      DataCell(Text(
                          minutesToString(currentData.others.minutes_bonus!),
                          style: textTableStyle)),
                      DataCell(Text(
                          minutesToString(delta.others.minutes_bonus!),
                          style: textTableStyle)),
                    ])
                  ])
            ]),
        SizedBox(height: 60),
      ],
    );
  }

  Future<void> updateData(BuildContext context, Cubacel currentData) async {
    context.read(loadingProvider).state = true;
    //await Future.delayed(Duration(seconds: 4));
    Cubacel cData = await getCubacelData();
    await store.add(cubacelDb!, cData.toJson());

    cacheCubacelDb!.transaction((txn) async {
      await store.record(dataKey).put(txn, cData.toJson());
      await store.record(prevDataKey).put(txn, currentData.toJson());
    });

    context.read(dataProvider).state = cData;
    context.read(prevDataProvider).state = currentData;
    context.read(loadingProvider).state = false;
  }
}
