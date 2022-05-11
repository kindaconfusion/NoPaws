import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'main.dart';

class BusPage extends StatefulWidget {
  const BusPage({Key? key}) : super(key: key);

  @override
  _BusPageState createState() => _BusPageState();
}

class _BusPageState extends State<BusPage> {

  get _routes => JagTran().getRoutes();
  int _routeId = 0;
  int _busId = 0;
  get _map => JagTran().getMap(_busId);

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: MainDrawer(),
        appBar: AppBar(title: Text('JagTran')),
        body: routeListBuilder()
    );
  }
  FutureBuilder<Image> mapBuilder() {
    return FutureBuilder<Image>(
      future: _map,
      builder: (BuildContext context, AsyncSnapshot<Image> snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Text("Loading..");
        }
        if (snapshot.hasData) {
            return (snapshot.data as Widget);
        } else {
          return Container(
              child: const Center(
                child:
                CircularProgressIndicator(),
              )
          );
        }
      }
    );
  }
  FutureBuilder<List<Map<int, Route?>>> routeListBuilder() {
    return FutureBuilder<List<Map<int, Route?>>>(
        future: _routes,
        builder: (BuildContext context, AsyncSnapshot<List<Map<int, Route?>>> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
                itemCount: (snapshot.data?.length)! + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    index++;
                    return mapBuilder();
                  }
                  Map<int, Route?>? currentEntry = snapshot.data?[index-1];
                  return ListTile(
                      title: Text('${currentEntry?.values.toList()[0]?.name}'),
                      onTap: () {
                        if (currentEntry != null) {
                          setState(() {
                            _routeId = currentEntry?.values.toList()[0]?.id ??
                                0;
                            _busId = currentEntry?.keys.toList()[0] ?? 0;
                          });
                        }
                      }
                  );
                }
              );
          } else {
            return Container(
                child: const Center(
                  child:
                  CircularProgressIndicator(),
                )
            );

          }
        }
    );
  }
}

class JagTran {
  Future<List<Map<int, Route?>>> getRoutes() async {
    List<Route> routes;
    /*var response = await http.get(Uri.parse("http://jagtran.doublemap.com/map/v2/routes"));
    if (response.statusCode == 200) {
      routes = (json.decode(response.body) as List).map((i) =>
        Route.fromJson(i)).toList();
    }
    else {
      return new List<Route>.empty();
    }*/
    var routesJson = await rootBundle.loadString("assets/routesOriginal.json");
    var busesJson = await rootBundle.loadString("assets/buses.json");
    routes = (json.decode(routesJson) as List).map((i) =>
        Route.fromJson(i)).toList();
    List<Bus> buses = (json.decode(busesJson) as List).map((i) =>
        Bus.fromJson(i)).toList();
    Map<int, Route> routeNums = {};
    List<Map<int, Route?>> list = List.empty(growable: true);
    for (var route in routes) {
      routeNums[route.id] = route;
    }
    for (var bus in buses) {
      list.add({bus.id:routeNums[bus.routeId]});
    }
    return list;
  }
  Future<Map<int, int>> getBusRoutes() async {
    // load placeholder json since no buses run in May semester
    String busesJson = await rootBundle.loadString("assets/buses.json");
    //List<Route> routes = (json.decode(routesJson) as List).map((i) =>
    //    Route.fromJson(i)).toList();
    List<Bus> buses = (json.decode(busesJson) as List).map((i) =>
        Bus.fromJson(i)).toList();
    Map<int, int> routeMap = Map();
    for (Bus bus in buses) {
      routeMap.addAll({bus.routeId:bus.id});
    }
    return routeMap;
  }
  Future<Map<int, Bus>> getBuses() async {
    String busesJson = await rootBundle.loadString("assets/buses.json");
    List<Bus> buses = (json.decode(busesJson) as List).map((i) =>
        Bus.fromJson(i)).toList();
    Map<int, Bus> busMap = Map();
    for (Bus bus in buses) {
      busMap[bus.id] = bus;
    }
    return busMap;
  }
  Future<Image> getMap(int busId) async {
    Uint8List blankBytes = Base64Codec().decode("R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7");
    Image placeholderImage = Image.memory(blankBytes, height: 1);
    if (busId == 0) {
      return placeholderImage;
    }
    Map<int, Bus> buses = await getBuses();
    Bus? bus = buses[busId];
    if (bus != null) {
      String apikey = await rootBundle.loadString("assets/api.key");
      return Image.network(
          "http://open.mapquestapi.com/staticmap/v4/getmap?key=$apikey&size=500,400&zoom=16&center=${bus
              .lat},${bus.long}&pois=blue_1,${bus.lat},${bus.long},0,0");
    }
    else {
      return placeholderImage;
    }
  }
}

class Bus {
  final int id;
  final int routeId;
  final double lat;
  final double long;
  const Bus({
    required this.id,
    required this.routeId,
    required this.lat,
    required this.long,
  });
  Bus.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        routeId = json['route'],
        lat = json['lat'],
        long = json['lon'];
}

class Route {
  final int id;
  final String name;
  const Route({
    required this.id,
    required this.name,
  });
  Route.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'];
}

