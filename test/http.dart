import 'dart:convert';
import 'dart:io';

import "package:http/http.dart" as http;

void main() async {
  var res = await http.post(
    Uri.parse("https://code-shot-azkadev.up.railway.app"),
    headers: {"Content-Type": "application/json"},
    body: json.encode(
      {
        "title": "asoka",
        "code": """
void main() {
  String code_shot_about = \"\"\"
Azkadev Creator Code Shot Flutter

Github: github.com/azkadev
Youtube: youtube.com/@azkadev
Telegram: t.me/azkadev

\"\"\";
  print(code_shot_about);
}
"""
      },
    ),
  );
  File("./data.png").writeAsBytes(res.bodyBytes);
  print(res.bodyBytes);
  print(res.headers);
}
