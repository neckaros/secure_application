# secure_window

This plugin allow you to protect your application content from view on demand


## Example

Look at example app to see a use case

## Authentication

This tool does not impose a way to authenticate the user to give them back access to their content

You are free to use your own Widget/Workflow to allow user to see their content once locked (cf **SecureWindow** widget argument **onNeedUnlock**)

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
