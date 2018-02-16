import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'dart:convert';
import 'dart:io';

class SnippetPage extends StatefulWidget {

  final Map snippet;

  SnippetPage(this.snippet);

  @override
  State<StatefulWidget> createState() => new _SnippetPageState();

}

class _SnippetPageState extends State<SnippetPage> {

  bool _done;
  StringBuffer _markdown;

  @override
  initState() {
    super.initState();
    _done = false;
    _markdown = new StringBuffer();
    _getSnippet();
  }

  _getSnippet() async {
    String url = 'https://api.github.com/repos/Chalarangelo/30-seconds-of-code/contents/' + widget.snippet['path'];
    HttpClient client = new HttpClient();
    var data;

    try {
      HttpClientRequest req = await client.getUrl(Uri.parse(url));
      HttpClientResponse res = await req.close();
      if (res.statusCode == HttpStatus.OK) {
        String jsonString = await res.transform(UTF8.decoder).join();
        data = JSON.decode(jsonString);
        if (data['content'] == null) throw new Exception('No Content');
      }
    } catch (exception) {
      print(exception.toString());
    }

    if (!mounted) return;

    // Dart's BASE64 does not support newlines
    // Convert each line by line
    data['content'].split('\n').forEach((String b64) {
      String text = UTF8.fuse(BASE64).decode(b64);
      _markdown.write(text);
    });

    setState(() {
      _done = true;
    });
  }

  String _nameTransform(String name) {
    String noExt = name.substring(0, name.length - 3);
    return noExt;
  }

  @override
  Widget build(BuildContext context) {

    Widget loading = new Center(child: new CircularProgressIndicator());

    return new Scaffold(
      appBar: new AppBar(
        title: new Text(_nameTransform(widget.snippet['name'])),
      ),
      body: (_done) ? new Markdown(
        data: _markdown.toString(),
      ) : loading,
    );
  }

}