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
import 'package:sim_data_plus/sim_data.dart';
import 'package:ussd_advanced/ussd_advanced.dart';

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
    return simData.cards.first.subscriptionId!;
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
    String ussdResponseMessage = (await UssdAdvanced.sendAdvancedUssd(
        code: code, subscriptionId: subscriptionId))!;

    //print("succes! message: $ussdResponseMessage");
    return ussdResponseMessage;
  } catch (e) {
    print(e);
    return '';
  }
}

Future<Cubacel> getCubacelData() async {
  int subscription;
  if (!(await Permission.phone.status).isGranted) {
    if (!(await Permission.phone.request().isGranted)) {
      print('Permision denied');
      throw ("Permision denied");
    }
  }
// Either the permission was already granted before or the user just granted it.
  subscription = await getSimCardsData();
  //subscription = 0;
  String response = await makeUSSDRequest("*222#", subscription);
  String response2 = await makeUSSDRequest("*222*266#", subscription);
  String response3 = await makeUSSDRequest("*222*328#", subscription);
  /*String response =
      "Saldo: 435.54 CUP. Datos: 1.3 GB + 404.32 MB LTE. Voz: 00:08:44. SMS: 150. Linea activa hasta 06-09-22 vence 06-10-22.";
  String response2 =
      "Bono->vence: Datos 453.75 MB->10-11-21. MIN 00:27:11->10-11-21. Datos.cu 100.00 MB->10-11-21.";
  String response3 =
  Tarifa: No activa. Paquetes: 2.74 GB + 1.67 GB LTE validos 27 dias. */

  Cubacel cubacel = fromUssd(response, response2, response3);

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
      dataProvider.overrideWith((ref) => r),
      //dataProvider.overrideWithProvider(StateProvider<Cubacel>((_) => r)),
      prevDataProvider.overrideWith((_) => r2)
      //prevDataProvider.overrideWithProvider(StateProvider<Cubacel>((_) => r2))
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
  Widget build(BuildContext context, WidgetRef ref) {
    final bool loading = ref.watch(loadingProvider);
    final Cubacel currentData = ref.watch(dataProvider);
    final Cubacel prevData = ref.watch(prevDataProvider);
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
            await updateData(ref, currentData);
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await updateData(ref, currentData);
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
                child: Center(child: Text('Internet', style: headTextStyle)))
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
                    DataCell(Text('Bono LTE', style: textTableStyle)),
                    DataCell(Text(
                        internetToString(
                            currentData.internet.promotional_data_lte!),
                        style: textTableStyle)),
                    DataCell(Text(
                        internetToString(delta.internet.promotional_data_lte!),
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
                      DataCell(Text('Bono SMS', style: textTableStyle)),
                      DataCell(Text(currentData.others.sms_bonus.toString(),
                          style: textTableStyle)),
                      DataCell(Text(delta.others.sms_bonus.toString(),
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

  Future<void> updateData(WidgetRef ref, Cubacel currentData) async {
    ref.read(loadingProvider.notifier).state = true;
    Cubacel cData;
    try {
      cData = await getCubacelData();
    } catch (e) {
      print(e);
      return;
    }
    await store.add(cubacelDb!, cData.toJson());

    cacheCubacelDb!.transaction((txn) async {
      await store.record(dataKey).put(txn, cData.toJson());
      await store.record(prevDataKey).put(txn, currentData.toJson());
    });

    ref.read(dataProvider.notifier).state = cData;
    ref.read(prevDataProvider.notifier).state = currentData;
    ref.read(loadingProvider.notifier).state = false;
  }
}
