## 3.5.2

* Small improvements to IOS Code

## 3.5.1

* Documentation tips
  
## 3.5.0

* Upgrade to RxDart 0.24.0
  
## 3.4.1

* Opacity is now propagated to IOS protection on task switcher
  
## 3.3.2

* Fix not implemented exception on Android when you exit the app

## 3.3.1

* Fix if you wanted to start the application locked. issue: https://github.com/neckaros/secure_application/issues/1

## 3.3.0

* New behavior stream for lock/unlock event so you can react to them in your application

## 3.2.0

* iOS works on iPad when you rotate after closing

## 3.1.2

* iOS fix

## 3.1.1

* require swift 4.2+

## 3.0.7

* allow to configure nativeRemoveDelay in secure_gate to let longer  app time to start especially on iOS

## 3.0.6

* iOS new bringSubview(toFront:) instead of deprecated metho
* pause during needunlock to prevent ios unlock loop when using faceid

## 3.0.3

* new authenticated information
* autenticationEvents is now a BehaviorSubject stream

## 3.0.0

* Rename package

## 1.0.0

* Working on iOS and Android

## 0.0.1

* Initial release
