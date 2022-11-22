// ignore_for_file: unused_local_variable, duplicate_ignore, use_full_hex_values_for_flutter_colors, depend_on_referenced_packages

import 'dart:io';
import 'package:alfred/alfred.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'dart:async';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;

import 'package:flutter_code_editor/flutter_code_editor.dart';
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
    super.initState();
    task();
  }

  String defaultCode = """
void main(List<String> args) {
  print("Hello World Azkadev");
  if (true){

  } else {

  }
}
""";

  task() async { 
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

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final getHeight = mediaQuery.size.height;
    final getWidth = mediaQuery.size.width;
    return Scaffold(
      extendBody: true,
      body: Visibility(
        visible: false,
        replacement: SingleChildScrollView(
          child: CodeWidget(
            title: "azkaoksoas",
            code: defaultCode,
            onInit: (BuildContext context, CodeWidget page, CodeWidgetState pageState) async {
              List<String> codes = page.code.characters.toList();
              pageState.codeController.text = "";
              for (var i = 0; i < codes.length; i++) {
                String code = codes[i];
                await Future.delayed(const Duration(milliseconds: 1));
                pageState.codeController.text += code;
              }
            },
          ),
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
                  if (kDebugMode) {
                    print(e);
                  }
                }
              },
            );
          },
        ),
      ),
    );
  }
}

class CodeWidget extends StatefulWidget {
  final void Function(BuildContext context, CodeWidget page, CodeWidgetState pageState) onInit;

  final String title;
  final String code;
  const CodeWidget({super.key, required this.onInit, required this.title, required this.code});

  @override
  State<CodeWidget> createState() => CodeWidgetState();
}

class CodeWidgetState extends State<CodeWidget> {
  late CodeController codeController = CodeController(
    text: widget.code,
    language: dart,
  );
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
        decoration: BoxDecoration(color: const Color.fromARGB(255, 27, 25, 38), borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
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
                  style: const TextStyle(color: Colors.white),
                  overflow: TextOverflow.clip,
                ),
                const SizedBox.shrink(),
              ],
            ),
            Flexible(
              child: CodeTheme(
                data: CodeThemeData(
                  styles: const {
                    'root': TextStyle(
                      backgroundColor: Color(0xff011627),
                      color: Color.fromARGB(255, 186, 184, 221),
                    ),
                    'keyword': TextStyle(
                      color: Color(0xffc792ea),
                      fontStyle: FontStyle.normal,
                    ),
                    'built_in': TextStyle(
                      color: Color.fromARGB(255, 0, 185, 219),
                      fontStyle: FontStyle.normal,
                    ),
                    'type': TextStyle(color: Color(0xff82aaff)),
                    'literal': TextStyle(color: Color(0xffff5874)),
                    'number': TextStyle(color: Color(0xffF78C6C)),
                    'regexp': TextStyle(color: Color(0xff5ca7e4)),
                    'string': TextStyle(color: Color(0xffecc48d)),
                    'subst': TextStyle(color: Color(0xffd3423e)),
                    'symbol': TextStyle(color: Color(0xff82aaff)),
                    'class': TextStyle(color: Color(0xffffcb8b)),
                    'function': TextStyle(color: Color(0xff82AAFF)),
                    'title': TextStyle(
                      color: Color.fromARGB(255, 0, 185, 219),
                      fontStyle: FontStyle.normal,
                    ),
                    'params': TextStyle(color: Color(0xff7fdbca)),
                    'comment': TextStyle(
                      color: Color.fromARGB(143, 74, 88, 88),
                      fontStyle: FontStyle.normal,
                    ),
                    'doctag': TextStyle(color: Color(0xff7fdbca)),
                    'meta': TextStyle(color: Color(0xff82aaff)),
                    'meta-keyword': TextStyle(color: Color(0xff82aaff)),
                    'meta-string': TextStyle(color: Color(0xffecc48d)),
                    'section': TextStyle(color: Color(0xff82b1ff)),
                    'tag': TextStyle(color: Color(0xff7fdbca)),
                    'name': TextStyle(color: Color(0xff7fdbca)),
                    'builtin-name': TextStyle(color: Color(0xff7fdbca)),
                    'attr': TextStyle(color: Color(0xff7fdbca)),
                    'attribute': TextStyle(color: Color(0xff80cbc4)),
                    'variable': TextStyle(color: Color(0xffaddb67)),
                    'bullet': TextStyle(color: Color(0xffd9f5dd)),
                    'code': TextStyle(color: Color(0xff80CBC4)),
                    'emphasis': TextStyle(color: Color(0xffc792ea), fontStyle: FontStyle.normal),
                    'strong': TextStyle(color: Color(0xffaddb67), fontWeight: FontWeight.bold),
                    'formula': TextStyle(color: Color(0xffc792ea)),
                    'link': TextStyle(color: Color(0xffff869a)),
                    'quote': TextStyle(color: Color(0xff697098), fontStyle: FontStyle.normal),
                    'selector-tag': TextStyle(color: Color(0xffff6363)),
                    'selector-id': TextStyle(color: Color(0xfffad430)),
                    'selector-class': TextStyle(color: Color(0xffaddb67), fontStyle: FontStyle.normal),
                    'selector-attr': TextStyle(color: Color(0xffc792ea), fontStyle: FontStyle.normal),
                    'selector-pseudo': TextStyle(color: Color(0xffc792ea), fontStyle: FontStyle.normal),
                    'template-tag': TextStyle(color: Color(0xffc792ea)),
                    'template-variable': TextStyle(color: Color(0xffaddb67)),
                    'addition': TextStyle(color: Color(0xffaddb67ff), fontStyle: FontStyle.normal),
                    'deletion': TextStyle(color: Color(0xffef535090), fontStyle: FontStyle.normal),
                  },
                ),
                child: CodeField(
                  background: Colors.transparent,
                  controller: codeController,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
