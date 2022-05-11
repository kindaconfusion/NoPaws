import 'package:flutter/material.dart';
import 'jagtran.dart';

void main() => runApp(const NoPaws());

class NoPaws extends StatelessWidget {
  const NoPaws({Key? key}) : super(key: key);

  static const appTitle = 'NoPaws';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      theme: ThemeData.dark(),
      home: const HomePage(title: appTitle),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body:
      Column(
        children: [
          Image.asset("assets/nopaws.png", width: 300, height: 300),
          const Text("Welcome to NoPaws", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const Text("NoPaws is a replacement mobile app for USA students"),
          Padding(
            padding: const EdgeInsets.all(10),
            child:
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                  _buildButtonColumn(Colors.white, Icons.directions_bus, 'JagTran', context, MaterialPageRoute(builder: (context) => const BusPage())),
                  _buildButtonColumn(Colors.white, Icons.school, 'Canvas', context, null),
                ],
              )
          )

        ],
      ),
      drawer: MainDrawer()
    );
  }
}

class MainDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.black12,
            ),
            child: Text('NoPaws Menu'),
          ),
          ListTile(
            title: const Text('Home'),
            leading: const Icon(Icons.house),
            onTap: () {
              Navigator.popUntil(context, ModalRoute.withName('/'));
            },
          ),
          ListTile(
            title: const Text('JagTran'),
            leading: const Icon(Icons.directions_bus),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BusPage()),
              );

            },
          ),
          ListTile(
            title: const Text('Canvas'),
            leading: const Icon(Icons.school),
            onTap: () {
              // Close the drawer
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

ElevatedButton _buildButtonColumn(Color color, IconData icon, String label, BuildContext cxt, MaterialPageRoute? rte) {
  return ElevatedButton(
    onPressed: () {
      if (rte != null)
        Navigator.push(cxt, rte);
      else {
        final notImp = const SnackBar(
          content: const Text("Not implemented", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.black,
        );
        ScaffoldMessenger.of(cxt).showSnackBar(notImp);
      }
    },
    child: Container(
        margin: const EdgeInsets.all(5),
        child: Column(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(icon, color: color),
      Container(
        margin: const EdgeInsets.only(top: 8),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: color,
          ),
        ),
      ),
    ],
  )));
}

