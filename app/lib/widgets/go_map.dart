import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kuzzle/kuzzle.dart';

import '../kuzzle.dart';
import './caught_alert.dart';

class GoMap extends StatefulWidget {
  GoMap({Key key, @required this.entities, @required this.prefs }) : super(key: key);
  final dynamic entities;
  final dynamic prefs;

  @override
  _GoMapState createState() => _GoMapState(entities: entities, prefs: prefs);
}

class _GoMapState extends State<GoMap> with AutomaticKeepAliveClientMixin {
  _GoMapState({ @required this.entities, @required this.prefs });
  final dynamic entities;
  final dynamic prefs;

  // tells flutter to not destroy
  // this widget on tabs change
  bool wantKeepAlive = true;

  CameraPosition _initialPosition = CameraPosition(target: LatLng(0, 0), zoom: 18.8);
  Set<Marker> _markers = {};
  GoogleMapController _controller;

  _registerPositionToServer(Position position) async {
    await kuzzle.query(KuzzleRequest(
      controller: 'kuzzle-plugin-advanced-boilerplate/location', 
      action: 'register',
      body: {
        'latitude': position.latitude,
        'longitude': position.longitude
      }
    ));
  }
  
  _searchEntities(Position position) async {
    return await kuzzle.document.search(
      'world',
      'collectable',
      size: 100,
      query: {
        'query': {
          'bool': {
            'must': { 'match_all' : {} },
            'filter': {
              'geo_distance': {
                'distance': '50m',
                'location': {
                  'lat': position.latitude,
                  'lon': position.longitude
                }
              }
            }
          }
        }
      }
    );
  }

  _updateMarkers(results) {
    setState(() {
      _markers.clear();

      for (var collectable in results.hits) {
        final markerId = MarkerId('${collectable['_source']['location']['lat']}#${collectable['_source']['location']['lon']}');

        _markers.add(Marker(
          markerId: markerId,
          position: LatLng(collectable['_source']['location']['lat'], collectable['_source']['location']['lon']),
          icon: entities[collectable['_source']['entity']]['asset'],
          consumeTapEvents: true,
          onTap: _catchEntity(markerId, collectable)
        ));
      }
    });
  }

  _synchronize() async {
    Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    this._registerPositionToServer(position);

    _controller.animateCamera(
      CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)),
    );

    final results = await this._searchEntities(position);
    this._updateMarkers(results);

    sleep(new Duration(seconds: 1));
    this._synchronize();
  }

  _catchEntity(markerId, collectable) {
    return () async {
      final entity = entities[collectable['_source']['entity']];

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CaughtAlert(entity: entity, count: prefs.getInt(entity['name']) ?? 0);
        },
      );

      setState(() => _markers.removeWhere((marker) => marker.markerId == markerId));
      kuzzle.document.delete('world', 'collectable', collectable['_id']);

      int counter = (prefs.getInt(entity['name']) ?? 0) + 1;
      await prefs.setInt(entity['name'], counter);
    };
  }

  _onMapCreated(GoogleMapController controller) async {
    _controller = controller;

    this._synchronize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          GoogleMap(    
            onMapCreated: _onMapCreated,
            initialCameraPosition: _initialPosition,
            markers: _markers,
            myLocationEnabled: true,
            mapType: MapType.terrain,
            rotateGesturesEnabled: false,
            scrollGesturesEnabled: false,
            tiltGesturesEnabled: false,
            zoomGesturesEnabled: false
          ),
        ],
      )
    );
  }
}