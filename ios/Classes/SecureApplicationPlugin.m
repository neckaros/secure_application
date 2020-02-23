#import "SecureApplicationPlugin.h"
#if __has_include(<secure_application/secure_application-Swift.h>)
#import <secure_application/secure_application-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "secure_application-Swift.h"
#endif

@implementation SecureApplicationPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftSecureApplicationPlugin registerWithRegistrar:registrar];
}
@end
