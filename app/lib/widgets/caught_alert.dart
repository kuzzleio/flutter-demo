import 'dart:ui';

import 'package:flutter/material.dart';

class CaughtAlert extends StatelessWidget {
  CaughtAlert({ @required this.entity, @required this.count });
  final dynamic entity;
  final int count;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('You caught ${entity['name']}!'),
      content: Column(
        children: <Widget>[
          Image.network(
            entity['image'],
            width: 100
          ),
          SizedBox(height: 20),
          Text(entity['description']),
        ],
        mainAxisSize: MainAxisSize.min
      ),
      actions: <Widget>[
        Text('Stock: $count'),
        FlatButton(
          child: Text("OK"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}