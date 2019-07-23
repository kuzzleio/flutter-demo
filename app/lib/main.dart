import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers.dart';
import 'kuzzle.dart';
import 'widgets/go_map.dart';
import 'widgets/caught_list.dart';


void main() {
  kuzzle.on('error', (e) {
    debugPrint(e);
  });

  kuzzle.connect();
  return runApp(App());
}

class App extends StatefulWidget {
  App({Key key}) : super(key: key);

  @override
  _AppState createState() => _AppState();  
}

class _AppState extends State<App> {
  _AppState();

  Map<String, dynamic> _entities;
  SharedPreferences _prefs;
  bool _isLoading = true;

  loadData() async {
    final Map<String, dynamic> entities = Map();

    final results = await kuzzle.document.search(
      'world',
      'entities',
      size: 100,
    );

    for (var entity in results.hits) {
      entities[entity['_id']] = entity['_source'];
      entities[entity['_id']]['asset'] = await loadNetworkImage(entity['_source']['image'], width: 100);
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      _prefs = prefs;
      _entities = entities;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                child: CircularProgressIndicator(),
                height: 200.0,
                width: 200.0,
              ),
            ],
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'Kuzzle GO',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(text: 'Map', icon: Icon(Icons.map)),
                Tab(text: 'Stock', icon: Icon(Icons.library_books)),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              GoMap(entities: _entities, prefs: _prefs),
              CaughtList(entities: _entities, prefs: _prefs),
            ],
          ),
        ),
      ),
    );
  }
}





