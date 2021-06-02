import 'dart:typed_data';

import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage() : super(key: GlobalKey());

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double _selectedIndex = 0;
  static const platform =
      const MethodChannel('dev.arslee.the_worst_launcher_i_made/wallpaper');
  Future wallpaper = platform.invokeMethod('getWallpaper');
  Future<List<Application>> apps = DeviceApps.getInstalledApplications(
      includeAppIcons: false,
      onlyAppsWithLaunchIntent: true,
      includeSystemApps: true);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Future.wait([wallpaper, apps]),
        builder: (BuildContext context, AsyncSnapshot<List<dynamic>> data) {
          if (data.data?[0] == null ||
              data.data?[0] is Future ||
              data.data?[1] == null ||
              data.data?[1] is Future) {
            return Scaffold(
                body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Loading...'),
                  )
                ],
              ),
            ));
          } else {
            Uint8List _wallpaper = data.data![0];
            List<Application> _apps = data.data![1];
            _apps.sort((a, b) => a.appName.compareTo(b.appName));
            Application _app = _apps[_selectedIndex.toInt()];

            return Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: MemoryImage(_wallpaper),
                    fit: BoxFit.fill,
                    colorFilter: ColorFilter.mode(
                        Color.fromARGB(128, 0, 0, 0), BlendMode.darken)),
              ),
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: SafeArea(
                  minimum: EdgeInsets.all(16.0),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Slider(
                            value: _selectedIndex,
                            min: 0,
                            max: _apps.length.toDouble() - 1,
                            label: _app.appName[0],
                            divisions: _apps.length - 1,
                            onChanged: (val) {
                              setState(() {
                                _selectedIndex = val;
                              });
                            }),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                              onPressed: () {
                                DeviceApps.openApp(_app.packageName);
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 18.0),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.play_arrow,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4),
                                        child: Text(
                                          _app.appName,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        });
  }
}
