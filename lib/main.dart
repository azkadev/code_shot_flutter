// ignore_for_file: unused_local_variable, duplicate_ignore

import 'dart:io';
import 'dart:math';
import 'package:alfred/alfred.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'dart:async';
import 'dart:isolate';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;

import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:highlight/languages/java.dart';
import 'package:highlight/languages/dart.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Azka Dev",
      home: App(),
    ),
  );
}

class App extends StatefulWidget {
  const App({super.key});
  @override
  MyApp createState() => MyApp();
}

class ClientData {
  final String title;
  final String code;
  late bool isFinished = false;
  final int timeStamp;
  late bool isSend = false;
  late Uint8List data;
  ClientData({
    required this.title,
    required this.code,
    required this.timeStamp,
  });
}

class MyApp extends State<App> {
  late List<ClientData> items = [];
  Alfred app = Alfred(
    onNotFound: (req, res) {
      return res.json({"@type": "error"});
    },
  );
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    task();
  }

  task() async {
    // Timer.periodic(const Duration(seconds: 1), (timer) async {
    //   setState(() {
    //     items.add(ClientData(title: "Data ${DateTime.now().toString()}", timeStamp: DateTime.now().millisecondsSinceEpoch));
    //   });
    // });
    Timer.periodic(const Duration(seconds: 2), (timer) async {
      setState(() {
        items = items.where((element) => !element.isSend).toList();
      });
    });
    app.all("/", (req, res) async {
      try {
        if (req.method.toLowerCase() == "get") {
          Map<String, String> data = req.uri.queryParameters;
          ClientData clientDataNew = ClientData(
            title: data["title"] ?? "-",
            code: data["code"] ?? defaultCode,
            timeStamp: DateTime.now().millisecondsSinceEpoch,
          );
          items.add(clientDataNew);
          DateTime dateTimeExpire = DateTime.now().add(const Duration(seconds: 10));
          while (true) {
            await Future.delayed(const Duration(milliseconds: 10));
            if (DateTime.now().isAfter(dateTimeExpire)) {
              return res.json({"@type": "error", "message": "time out"});
            }
            for (var i = 0; i < items.length; i++) {
              // ignore: non_constant_identifier_names
              ClientData clientData = items[i];
              if (clientData.timeStamp == clientDataNew.timeStamp && clientData.isFinished) {
                setState(() {
                  clientData.isSend = true;
                });

                res.headers.add("content-type", "image/png");
                res.add(clientData.data);
                await res.close();
                return;
              }
            }
          }
        } else if (req.method.toLowerCase() == "post") {
          Map data = await req.bodyAsJsonMap;
          ClientData clientDataNew = ClientData(
            title: data["title"] ?? "-",
            code: data["code"] ?? defaultCode,
            timeStamp: DateTime.now().millisecondsSinceEpoch,
          );
          items.add(clientDataNew);
          DateTime dateTimeExpire = DateTime.now().add(const Duration(seconds: 10));
          while (true) {
            await Future.delayed(const Duration(milliseconds: 10));
            if (DateTime.now().isAfter(dateTimeExpire)) {
              return res.json({"@type": "error", "message": "time out"});
            }
            for (var i = 0; i < items.length; i++) {
              // ignore: non_constant_identifier_names
              ClientData clientData = items[i];
              if (clientData.timeStamp == clientDataNew.timeStamp && clientData.isFinished) {
                setState(() {
                  clientData.isSend = true;
                });

                res.headers.add("content-type", "image/png");
                res.add(clientData.data);
                await res.close();
                return;
              }
            }
          }
        }
      } catch (e) {}
      return res.json({"@type": "error"});
    });
    await app.listen(int.parse(Platform.environment["PORT"] ?? "8080"), Platform.environment["HOST"] ?? "0.0.0.0");
  }

  final controller = CodeController(
    text: "javaFactorialSnippet",
    language: dart,
  );

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final getHeight = mediaQuery.size.height;
    final getWidth = mediaQuery.size.width;
    return Scaffold(
      extendBody: true,
      body: Visibility(
        visible: true,
        replacement: CodeWidget(
          title: "azkaoksoas",
          code: defaultCode,
          onInit: (BuildContext context, CodeWidget page, CodeWidgetState pageState) async {},
        ),
        child: ListView.builder(
          primary: true,
          shrinkWrap: true,
          itemCount: items.length,
          itemBuilder: (context, index) {
            ClientData clientData = items[index];
            if (clientData.isFinished) {
              return const SizedBox.shrink();
            }
            return CodeWidget(
              title: clientData.title,
              code: clientData.code,
              onInit: (BuildContext context, CodeWidget page, CodeWidgetState pageState) async {
                try {
                  RenderRepaintBoundary boundary = context.findRenderObject() as RenderRepaintBoundary;
                  ui.Image image = await boundary.toImage(pixelRatio: 3.0);
                  ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
                  Uint8List pngBytes = byteData!.buffer.asUint8List();

                  setState(() {
                    items[index].data = pngBytes;
                    items[index].isFinished = true;
                  });
                } catch (e) {
                  print(e);
                }
              },
            );
          },
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () async {
      //     print(items);
      //     return;
      //     // try {
      //     //   setState(() {
      //     //     items = items.where((element) => !element.isFinished).toList();
      //     //   });
      //     //   await Future.delayed(const Duration(milliseconds: 500));
      //     //   setState(() {
      //     //     items.addAll(List.generate(10, (index) => ClientData(title: "haha ${index}")));
      //     //   });
      //     // } catch (e) {
      //     //   print(e);
      //     // }
      //   },
      //   child: const Icon(Icons.add),
      // ),
    );
  }
}

String defaultCode = """
void main(List<String> args) {
  print("Hello World Azkadev");
}
""";

class CodeWidget extends StatefulWidget {
  final void Function(BuildContext context, CodeWidget page, CodeWidgetState pageState) onInit;

  final String title;
  final String code;
  const CodeWidget({super.key, required this.onInit, required this.title, required this.code});

  @override
  State<CodeWidget> createState() => CodeWidgetState();
}

class CodeWidgetState extends State<CodeWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((Duration duration) async {
      widget.onInit.call(context, widget, this);
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    // ignore: unused_local_variable
    final getHeight = mediaQuery.size.height;
    final getWidth = mediaQuery.size.width;
    return RepaintBoundary(
      child: Container(
        constraints: const BoxConstraints(
          maxHeight: double.maxFinite,
          maxWidth: double.maxFinite,
        ),
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 15,
                      width: 15,
                      margin: const EdgeInsets.all(5),
                      decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(20)),
                    ),
                    Container(
                      height: 15,
                      width: 15,
                      margin: const EdgeInsets.all(5),
                      decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(20)),
                    ),
                    Container(
                      height: 15,
                      width: 15,
                      margin: const EdgeInsets.all(5),
                      decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(20)),
                    ),
                  ],
                ),
                Text(
                  widget.title,
                  style: TextStyle(color: Colors.white),
                  overflow: TextOverflow.clip,
                ),
                SizedBox.shrink(),
              ],
            ),
            Flexible(
              child: CodeField(
                background: Colors.transparent,
                controller: CodeController(
                  text: widget.code,
                  language: dart,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
