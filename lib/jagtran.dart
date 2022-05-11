import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'main.dart';

class BusPage extends StatefulWidget {
  const BusPage({Key? key}) : super(key: key);

  @override
  _BusPageState createState() => _BusPageState();

}

class _BusPageState extends State<BusPage> {
  Map<int, bool> switchToggled = {};
  get _routes => JagTran().getRoutes();
  List<Bus> _activeBuses = List.empty(growable: true);
  get _map => JagTran().getMap(_activeBuses);


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
          return Container(
            child: Image.asset("assets/placeholder-map.png"),
          );
        }
        if (snapshot.hasData) {
            return (snapshot.data as Widget);
        } else {
          return Center(
                child: Image.asset("assets/placeholder-map.png"),
              );
        }
      }
    );
  }
  FutureBuilder<List<Map<Bus, Route>>> routeListBuilder() {
    return FutureBuilder<List<Map<Bus, Route>>>(
        future: _routes,
        builder: (BuildContext context, AsyncSnapshot<List<Map<Bus, Route>>> snapshot) {
          if (snapshot.hasData) {
            return RefreshIndicator(
                child: ListView.builder(
                    itemCount: (snapshot.data?.length)! + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        index++;
                        return Container(
                          height: 400,
                            child: Stack(
                              children: <Widget>[
                                Image.asset("assets/placeholder-map.png"),
                                mapBuilder(),
                              ]
                            )
                        );
                      }

                      Map<Bus, Route> currentEntry = snapshot.data![index-1];
                      return ListTile(
                        title: Text(currentEntry.values.toList()[0].name),
                        trailing: Switch(
                          value: switchToggled[index] ?? false,
                          onChanged: (value) {
                            setState(() {
                              switchToggled[index] = value;
                              if (value) {
                                _activeBuses.add(currentEntry.keys.toList()[0]);
                              }
                              else {
                                for (Bus bus in _activeBuses) {
                                  if (bus.id == currentEntry.keys.toList()[0].id) {
                                    _activeBuses.remove(bus);
                                    break;
                                  }
                                }
                              }
                            });
                          },
                        ),
                      );
                    }
                ),
                onRefresh: () {
                  return Future.delayed(
                    // there is DEFINITELY a better way to do this what the FUCK am I even doing here
                      Duration(microseconds: 1),
                      () {
                        setState(() {});
                      }
                  );
                },
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
  Future<List<Map<Bus, Route>>> getRoutes() async {
    List<Route> routes;
    var routesJson = await rootBundle.loadString("assets/routesOriginal.json");
    var busesJson = await rootBundle.loadString("assets/buses.json");
    routes = (json.decode(routesJson) as List).map((i) =>
        Route.fromJson(i)).toList();
    List<Bus> buses = (json.decode(busesJson) as List).map((i) =>
        Bus.fromJson(i)).toList();
    Map<int, Route> routeNums = {};
    List<Map<Bus, Route>> list = List.empty(growable: true);
    for (var route in routes) {
      routeNums[route.id] = route;
    }
    for (var bus in buses) {
      bus.routeName = routeNums[bus.routeId]?.name ?? "";
      list.add({bus:(routeNums[bus.routeId] ?? Route(id: 0, name: ""))});
    }
    return list;
  }
  Future<Map<int, int>> getBusRoutes() async {
    // load placeholder json since no buses run in May semester
    String busesJson = await rootBundle.loadString("assets/buses.json");
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
  Future<Image> getMap(List<Bus> buses) async {
    String apikey = await rootBundle.loadString("assets/api.key");
    if (buses.isEmpty) {
      return Image.network("https://open.mapquestapi.com/staticmap/v5/map?key=$apikey&boundingBox=30.70309,-88.19106000000001,30.690920000000002,-88.18334999999999&margin=75");
    }
    double n = -1000;
    double e = -1000;
    double s = 1000;
    double w = 1000;
    //List<Map<double, double>> busLatLong = List.empty(growable: true);
    StringBuffer latLongPairs = StringBuffer();
    for (var bus in buses) {
      n = (bus.lat > n) ? bus.lat : n;
      s = (bus.lat < s) ? bus.lat : s;
      e = (bus.long > e) ? bus.long : e;
      w = (bus.long < w) ? bus.long : w;
      String color;
      switch (bus.routeName) {

        case "Blue Route":
          color = "0000ff";
          break;
        case "Green Route":
          color = "008080";
          break;
        case "Red Route":
          color = "ff0000";
          break;
        case "Yellow Route ":
          color = "ffff00";
          break;
        case "Orange Route":
          color = "ffa500";
          break;
        default:
          color = "000000";
          break;
      }
      latLongPairs.write("${bus.lat},${bus.long}|marker-$color||");
    }
    String locations = latLongPairs.toString().substring(0,latLongPairs.length-2);
    n += 0.005;
    s -= 0.005;
    e -= 0.005;
    w += 0.005;

    return Image.network("https://open.mapquestapi.com/staticmap/v5/map?key=$apikey&boundingBox=$n,$w,$s,$e&locations=$locations&margin=50");
  }
}

class Bus {
  final int id, routeId;
  final double lat, long;
  late String routeName;
  Bus({
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

