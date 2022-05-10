import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'main.dart';

class BusPage extends StatefulWidget {
  const BusPage({Key? key}) : super(key: key);

  @override
  _BusPageState createState() => _BusPageState();
  /*@override
  Widget build(BuildContext context) {

    return Scaffold(
      drawer: MainDrawer(),
      appBar: AppBar(title: Text('JagTran')),
    );
  }*/
}

class _BusPageState extends State<BusPage> {

  get _routes => JagTran().getBuses();
  int id = 0;

  @override
  initState() {
    super.initState();
    //Future<List<Route>?> _routes = JagTran().getBuses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: MainDrawer(),
        appBar: AppBar(title: Text('JagTran')),
        body: ListView(
          children: [
            map(),
            routeListBuilder(),
          ]
        ),
    );
  }
  Image map() {
    if (id == 0) {
      late Image map;
      Uint8List blankBytes = Base64Codec().decode("R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7");
      map = Image.memory(blankBytes, height: 1);
      return map;
    }
    else {
      return Image.network("http://kindaconfused.com/assets/img/logo.jpg");
    }
  }
  FutureBuilder<List<Route>> routeListBuilder() {
    return FutureBuilder<List<Route>>(
        future: _routes,
        builder: (BuildContext context, AsyncSnapshot<List<Route>> snapshot) {
          if (snapshot.hasData) {
            return Container(
              child: ListView.builder(
                itemCount: snapshot.data?.length,
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                itemBuilder: (context, index) {
                  Route? currentEntry = snapshot.data?[index];
                  return ListTile(
                      title: Text('${currentEntry?.name}'),
                      onTap: (){
                        if (currentEntry != null) {
                          id = currentEntry.id;
                        }

                        //Navigator.push(
                          //context,
                          //MaterialPageRoute(builder: (context) => const MapView()),
                        //);
                      }
                  );
                },
              ),
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

/*class MapView extends StatelessWidget {

  const MapView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: (
        Center(child: Image.network("http://kindaconfused.com/assets/img/logo.jpg")
        )
      )
    );
  }
}*/

class JagTran {
  Future<List<Route>> getBuses() async {
    var response = await http.get(Uri.parse("http://jagtran.doublemap.com/map/v2/routes"));
    List<Route> routes;
    if (response.statusCode == 200) {
      Iterable l = json.decode(response.body);
      routes = (json.decode(response.body) as List).map((i) =>
        Route.fromJson(i)).toList();
    }
    else {
      return new List<Route>.empty();
    }
    return routes;
  }
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

