import 'package:flutter/material.dart';
import 'package:secure_window/secure_window.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SecureApplication(
        onNeedUnlock: (secure) => print(
            'need unlock maybe use biometric to confirm and then sercure.unlock()'),
        child: SecureGate(
          blurr: 5,
          lockedBuilder: (context, secureNotifier) => Center(
              child: RaisedButton(
            child: Text('test'),
            onPressed: () => secureNotifier.unlock(),
          )),
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Plugin example app'),
            ),
            body: Center(
              child: Builder(builder: (context) {
                var valueNotifier = SecureWindowProvider.of(context);
                return Column(
                  children: <Widget>[
                    Text('This is secure content'),
                    MaterialButton(
                      onPressed: () => valueNotifier.secure(),
                      child: Text('secure'),
                    ),
                    MaterialButton(
                      onPressed: () => valueNotifier.open(),
                      child: Text('open'),
                    )
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
