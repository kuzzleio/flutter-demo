import 'dart:ui';

import 'package:flutter/material.dart';

class CaughtList extends StatelessWidget {
  CaughtList({Key key, @required this.entities, @required this.prefs });
  final dynamic entities;
  final dynamic prefs;

  @override
  Widget build(BuildContext context) {
    final keys = entities.keys.toList();

    return ListView.builder(
      itemCount: keys.length,
      itemBuilder: (BuildContext ctx, int index) {
        final entity = entities[keys[index]];
        return Opacity(
          opacity: (prefs.getInt(entity['name']) ?? 0) > 0 ? 1.0 : 0.2,
          child: Row(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Image.network(
                      entity['image'],
                      width: 50
                    )
                  ),
                  SizedBox(height: 20),
                  Text(entity['name'], style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  )),
                ]
              ),
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('${prefs.getInt(entity['name']) ?? 0}', style: TextStyle(
                  fontSize: 18.0,
                )),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceBetween
          )
        );
      }
    );
  }
}