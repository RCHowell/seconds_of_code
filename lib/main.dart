import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:seconds_of_code/snippet_page.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: '30 Seconds of Code',
      theme: new ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: new MyHomePage(title: '30 Seconds of Code'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  List<Map> _snippets;

  @override
  initState() {
    print('Initializing state');
    print('Getting snippets');
    _getSnippets();
  }

  _getSnippets() async {
    String url = 'https://api.github.com/repos/Chalarangelo/30-seconds-of-code/contents/snippets';
    HttpClient client = new HttpClient();
    var data;

    try {
      HttpClientRequest req = await client.getUrl(Uri.parse(url));
      HttpClientResponse res = await req.close();
      if (res.statusCode == HttpStatus.OK) {
        String jsonString = await res.transform(UTF8.decoder).join();
        data = JSON.decode(jsonString);
      }
    } catch (exception) {
      print(exception.toString());
    }

    if (!mounted) return;

    setState(() {
//      print(data);
      _snippets = data;
    });
  }

  String _nameTransform(String name) {
    String noExt = name.substring(0, name.length - 3);
    return noExt;
  }

//  _onFail(HttpException exception) {
//    print(exception.toString());
//  }

  @override
  Widget build(BuildContext context) {
    Widget loading = new Center(child: new CircularProgressIndicator());

    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: (_snippets != null) ? new ListView(
        children: _snippets.map((Map snippet) =>
        new Card(
          child: new ListTile(
            leading: const Icon(Icons.code),
            title: new Text(_nameTransform(snippet['name'])),
            trailing: new FlatButton(
              onPressed: () {
                Navigator.of(context).push(new MaterialPageRoute(
                    builder: (BuildContext context) {
                      return new SnippetPage(snippet);
                    }
                ));
              },
              child: new Icon(
                Icons.chevron_right,
                color: Theme
                    .of(context)
                    .primaryColor,),
            ),
          ),
        )).toList(),
      ) : loading,
    );
  }
}
