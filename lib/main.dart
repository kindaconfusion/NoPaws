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
      home: HomePage(title: appTitle),
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
      body: const Center(
        child: Text('NoPaws'),
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
            leading: Icon(Icons.house),
            onTap: () {
              Navigator.popUntil(context, ModalRoute.withName('/'));
            },
          ),
          ListTile(
            title: const Text('JagTran'),
            leading: Icon(Icons.directions_bus),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BusPage()),
              );

            },
          ),
          ListTile(
            title: const Text('Canvas'),
            leading: Icon(Icons.school),
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

