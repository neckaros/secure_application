import 'package:flutter/material.dart';
import 'package:secure_window/secure_window.dart';

void main() => runApp(MaterialApp(home: MyApp()));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool failedAuth;
  double blurr = 20;
  double opacity = 0.6;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width * 0.8;
    return MaterialApp(
      home: SecureApplication(
        onNeedUnlock: (secure) async {
          print(
              'need unlock maybe use biometric to confirm and then sercure.unlock() or you can use the lockedBuilder');
          // var authResult = authMyUser();
          // if (authResul) {
          //  secure.unlock();
          //  return SecureWindowAuthenticationStatus.SUCCESS;
          //}
          // else {
          //  return SecureWindowAuthenticationStatus.FAILED;
          //}
          return null;
        },
        onAuthenticationFailed: () async {
          // clean you data
          setState(() {
            failedAuth = true;
          });
          print('auth failed');
        },
        onAuthenticationSucceed: () async {
          // clean you data

          setState(() {
            failedAuth = false;
          });
          print('auth success');
        },
        child: SecureGate(
          blurr: blurr,
          opacity: opacity,
          lockedBuilder: (context, secureNotifier) => Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                child: Text('UNLOCK'),
                onPressed: () => secureNotifier.authSuccess(unlock: true),
              ),
              RaisedButton(
                child: Text('FAIL AUTHENTICATION'),
                onPressed: () => secureNotifier.authFailed(unlock: true),
              ),
            ],
          )),
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Secure Window Example'),
            ),
            body: Center(
              child: Builder(builder: (context) {
                var valueNotifier = SecureWindowProvider.of(context);
                return ListView(
                  children: <Widget>[
                    Text('This is secure content'),
                    RaisedButton(
                      onPressed: () => valueNotifier.secure(),
                      child: Text('secure'),
                    ),
                    RaisedButton(
                      onPressed: () => valueNotifier.open(),
                      child: Text('open'),
                    ),
                    if (failedAuth == null)
                      Text(
                          'Lock the app then switch to another app and come back'),
                    if (failedAuth != null)
                      failedAuth
                          ? Text(
                              'Auth failed we cleaned sensitive data',
                              style: TextStyle(color: Colors.red),
                            )
                          : Text(
                              'Auth success',
                              style: TextStyle(color: Colors.green),
                            ),
                    FlutterLogo(
                      size: width,
                    ),
                    RaisedButton(
                      onPressed: () => valueNotifier.lock(),
                      child: Text('manually lock'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: <Widget>[
                          Text('Blurr:'),
                          Expanded(
                            child: Slider(
                                value: blurr,
                                min: 0,
                                max: 100,
                                onChanged: (v) => setState(() => blurr = v)),
                          ),
                          Text(blurr.floor().toString()),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: <Widget>[
                          Text('opacity:'),
                          Expanded(
                            child: Slider(
                                value: opacity,
                                min: 0,
                                max: 1,
                                onChanged: (v) => setState(() => opacity = v)),
                          ),
                          Text((opacity * 100).floor().toString() + "%"),
                        ],
                      ),
                    ),
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
