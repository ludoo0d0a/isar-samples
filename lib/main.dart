import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:isar_connect/isar_connect.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quotes/load_quotes.dart';
import 'package:quotes/quote.dart';
import 'package:quotes/quotes_list.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeIsarConnect();
  final isar = await Isar.open(
    schemas: [QuoteSchema],
    directory: (await getApplicationDocumentsDirectory()).path,
  );
  runApp(QuotesApp(
    isar: isar,
  ));
}

class QuotesApp extends StatelessWidget {
  final Isar isar;

  QuotesApp({required this.isar});

  Stream<List<Quote>> execQuery() {
    return isar.quotes.where().limit(1).build().watch(initialReturn: true);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: StreamBuilder(
            stream: execQuery(),
            builder: (context, AsyncSnapshot<List<Quote>?> data) {
              if (data.hasData) {
                if (data.data!.isEmpty) {
                  return LoadQuotes(isar: isar);
                } else {
                  return QuotesList(
                    isar: isar,
                  );
                }
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
