**previously nammed secure_window**

# secure_application

This plugin allow you to protect your application content from view on demand

<img src="https://raw.githubusercontent.com/neckaros/secure_application/master/example/screenshot/gate_off.jpg" height="400" /> <img src="https://raw.githubusercontent.com/neckaros/secure_application/master/example/screenshot/gate_on.jpg" height="400" /> <img src="https://raw.githubusercontent.com/neckaros/secure_application/master/android_appswitcher.JPG" height="400" /> <img src="https://raw.githubusercontent.com/neckaros/secure_application/master/Gate_ios.jpg" height="400" />

Pluggin in iOS is in swift

Pluggin in Android is in Kotlin / AndroidX libraries

## Usage

### Installation

Add `secure_application` as a dependency in your pubspec.yaml file ([what?](https://flutter.io/using-packages/)).

### Import

Import secure_application:
```dart
import 'package:secure_application/secure_application.dart';
```

Add a top level SecureApplication
```dart
SecureApplication(
        onNeedUnlock: (secure) => print(
            'need unlock maybe use biometric to confirm and then use sercure.unlock()'),
        child: MyAppContent(),
)
```

Put the content you want to protect in a SecureGate (could be the whole app)
```dart
SecureGate(
          blurr: 5,
          lockedBuilder: (context, secureNotifier) => Center(
              child: RaisedButton(
            child: Text('test'),
            onPressed: () => secureNotifier.unlock(),
          )),
          child: YouProtectedWidget(),
)
```

## API Docs
[API Reference](https://pub.dev/documentation/secure_application/latest/)

## Basic understanding

The library is mainly controller via the [SecureApplicationController](https://pub.dev/documentation/secure_application/latest/secure_application_controller/SecureApplicationController-class.html) which can be

### secured
if the user switch app or leave app the content will not be visible in the app switcher
and when it goes back to the app it will **lock** it

### locked
the child of the **SecureGate**s will be hidden bellow the blurry barrier

### paused
even if secured **SecureGate**s will not activate when user comes back to the app

### authenticated
last authentication status. To help you manage visibility of some elements of your UI
depending on auth status

* **secureApplicationController.authFailed()** will set it to **false**
* **secureApplicationController.authLogout()** will set it to **false**
* **secureApplicationController.authSuccess()** will set it to **true**


## Example

Look at example app to see a use case

## Authentication

This tool does not impose a way to authenticate the user to give them back access to their content

You are free to use your own Widget/Workflow to allow user to see their content once locked (cf **SecureApplication** widget argument [onNeedUnlock](https://pub.dev/documentation/secure_application/latest/secure_application/SecureApplication/onNeedUnlock.html))

Therefore you can use any method you like:
* Your own Widget for code Authentication
* biometrics with the [local_auth](https://pub.dev/packages/local_auth) package
* ...

## Android
On Android as soon as you **secure** the application the user will not be able to capture the screen in the app (even if unlocked)
We might give an option to allow screenshot as an option if need arise

## iOS
Contrary to Android we create a native frosted view over your app content so that content is not visible in the app switcher.
When the user gets back to the app we wait for ~500ms to remove this view to allow time for the app to woke and flutter gate to draw

# Widgets

## SecureApplication
[Api Doc](https://pub.dev/documentation/secure_application/latest/secure_application/SecureApplication-class.html)
this widget is **required** and need to be a parent of any Gate
it provides to its descendant a SecureApplicationProvider that allow you to secure or open the application

You can pass you own initialized SecureApplicationController if you want to set default values

## SecureGate
[Api Doc](https://pub.dev/documentation/secure_application/latest/secure_gate/SecureGate-class.html)
The **child** of this widget will be below a blurry barrier (control the amount of **blurr** and **opacity** with its arguments)
if the provided SecureApplicationController is **locked**

# Native workings

## Android
When **locked** we set the secure flag to true
```kotlin
activity?.window?.addFlags(LayoutParams.FLAG_SECURE)
```
When **opened** we remove the secure flag
```kotlin
activity?.window?.clearFlags(LayoutParams.FLAG_SECURE)
```

## iOS
When app will become inactive we add a top view with a blurr filter
We remove this app 500ms after the app become active to avoid your content form being breifly visible

# Because we all want to see code in a Readme
```dart
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
          //  return SecureApplicationAuthenticationStatus.SUCCESS;
          //}
          // else {
          //  return SecureApplicationAuthenticationStatus.FAILED;
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
                var valueNotifier = SecureApplicationProvider.of(context);
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
```