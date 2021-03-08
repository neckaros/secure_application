#include "include/secure_application/secure_application_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

// For getPlatformVersion; remove unless needed for your plugin implementation.
#include <VersionHelpers.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <map>
#include <memory>
#include <sstream>
#include <string>
#include <iostream>
using namespace std;

namespace
{
  HHOOK flutterWindowMonitor = nullptr;
  std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>, std::default_delete<flutter::MethodChannel<flutter::EncodableValue>>> channel = nullptr;

  class SecureApplicationPlugin : public flutter::Plugin
  {
  public:
    static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

    SecureApplicationPlugin();

    virtual ~SecureApplicationPlugin();

  private:
    static LRESULT CALLBACK monitorFlutterWindowsProc(int nCode, WPARAM wParam, LPARAM lParam);
    // Called when a method is called on this plugin's channel from Dart.
    void HandleMethodCall(
        const flutter::MethodCall<flutter::EncodableValue> &method_call,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
  };

  // static
  void SecureApplicationPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarWindows *registrar)
  {
    channel =
        std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
            registrar->messenger(), "secure_application",
            &flutter::StandardMethodCodec::GetInstance());

    auto plugin = std::make_unique<SecureApplicationPlugin>();

    channel->SetMethodCallHandler(
        [plugin_pointer = plugin.get()](const auto &call, auto result) {
          plugin_pointer->HandleMethodCall(call, std::move(result));
        });

    registrar->AddPlugin(std::move(plugin));
  }

  SecureApplicationPlugin::SecureApplicationPlugin()
  {
    DWORD threadID = GetCurrentThreadId();
    flutterWindowMonitor = SetWindowsHookEx(WH_CBT, &monitorFlutterWindowsProc, NULL, threadID);
  }

  SecureApplicationPlugin::~SecureApplicationPlugin()
  {
    UnhookWindowsHookEx(flutterWindowMonitor);
  }

  LRESULT CALLBACK SecureApplicationPlugin::monitorFlutterWindowsProc(
      _In_ int code,
      _In_ WPARAM wparam,
      _In_ LPARAM lparam)
  {
    //if ( WM_SYSCOMMAND
    if (code == HCBT_SYSCOMMAND)
    {
      if (SC_MINIMIZE == wparam)
      {
        channel->InvokeMethod("lock", nullptr);
      }
    }
    return 0;
  }

  void SecureApplicationPlugin::HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
  {
    if (method_call.method_name().compare("getPlatformVersion") == 0)
    {
      std::ostringstream version_stream;
      version_stream << "Windows ";
      if (IsWindows10OrGreater())
      {
        version_stream << "10+";
      }
      else if (IsWindows8OrGreater())
      {
        version_stream << "8";
      }
      else if (IsWindows7OrGreater())
      {
        version_stream << "7";
      }
      result->Success(flutter::EncodableValue(version_stream.str()));
    }
    else
    {
      result->Success();
    }
  }

} // namespace

void SecureApplicationPluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar)
{
  SecureApplicationPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
