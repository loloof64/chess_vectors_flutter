import 'chess_vectors_flutter.dart';
import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const commonSize = 50.0;
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('Chess vectors experiment'),
          backgroundColor: Colors.blue,
        ),
        body: Container(
            decoration: BoxDecoration(
              color: Colors.red,
            ),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    WhitePawn(size: commonSize),
                    WhiteKnight(size: commonSize),
                    WhiteBishop(size: commonSize),
                    WhiteRook(size: commonSize),
                    WhiteQueen(size: commonSize),
                    WhiteKing(size: commonSize)
                  ],
                ),
                Row(
                  children: <Widget>[
                    BlackPawn(size: commonSize),
                    BlackKnight(size: commonSize),
                    BlackBishop(size: commonSize),
                    BlackRook(size: commonSize),
                    BlackQueen(size: commonSize),
                    BlackKing(size: commonSize)
                  ],
                ),
              ],
            )));
  }
}