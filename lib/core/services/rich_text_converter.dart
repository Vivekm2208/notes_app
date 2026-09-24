import 'dart:convert';

import 'package:flutter_quill/flutter_quill.dart';

class RichTextConverter {
  static Document plainTextToDocument(String text) {
    final normaalizedText = text.endsWith('\n') ? text : '$text\n';
    return Document.fromJson([
      {'insert': normaalizedText},
    ]);
  }

  static Document jsonToDocument(String content) {
    if (content.trim().isEmpty) {
      return Document();
    }
    final json = jsonDecode(content);

    return Document.fromJson(json);
  }

  static String documentToJsonString(Document document) {
    final json = document.toDelta().toJson();

    return jsonEncode(json);
  }

  static String jsonToPlainText(String plainText) {
    final document = jsonToDocument(plainText);

    return document.toPlainText().trim();
  }

  static String documentToPlainText(Document document) {
    return document.toPlainText().trim();
  }
}
