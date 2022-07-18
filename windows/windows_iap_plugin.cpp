#include "windows_iap_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

// For getPlatformVersion; remove unless needed for your plugin implementation.
#include <VersionHelpers.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <memory>
#include <sstream>

#pragma once
#include <winrt/Windows.Services.Store.h>
#include <winrt/Windows.Foundation.Collections.h>
#include <shobjidl.h>

using namespace winrt;
using namespace Windows::Services::Store;
namespace foundation = Windows::Foundation;

namespace windows_iap {

    flutter::PluginRegistrarWindows* _registrar;

    HWND GetRootWindow(flutter::FlutterView* view) {
        return ::GetAncestor(view->GetNativeWindow(), GA_ROOT);
    }

    StoreContext getStore() {
        StoreContext store = StoreContext::GetDefault();
        auto initWindow = store.try_as<IInitializeWithWindow>();
        if (initWindow != nullptr) {
            initWindow->Initialize(GetRootWindow(_registrar->GetView()));
        }
        return store;
    }

    std::wstring s2ws(const std::string& s)
    {
        int len;
        int slength = (int)s.length() + 1;
        len = MultiByteToWideChar(CP_ACP, 0, s.c_str(), slength, 0, 0);
        wchar_t* buf = new wchar_t[len];
        MultiByteToWideChar(CP_ACP, 0, s.c_str(), slength, buf, len);
        std::wstring r(buf);
        delete[] buf;
        return r;
    }

    std::string debugString(std::vector<std::string> vt) {

        std::stringstream ss;
        ss << "( ";
        for (auto t : vt) {
            ss << t << ", ";
        }
        ss << " )\n";
        return ss.str();
    }


    std::string debugString2(StorePurchaseResult result) {

        std::stringstream ss;
        ss << "( ";
        ss << result.ExtendedError().value << ", ";
        auto status = reinterpret_cast<int32_t*>(result.Status());
        ss << status << ", ";
        ss << " )\n";
        return ss.str();
    }

    foundation::IAsyncAction makePurchase(hstring storeId)
    {
        StorePurchaseResult result = co_await getStore().RequestPurchaseAsync(storeId);
        OutputDebugString(s2ws(debugString2(result)).c_str());
    }

// static
void WindowsIapPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
    _registrar = registrar;
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "windows_iap",
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<WindowsIapPlugin>();

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto &call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

WindowsIapPlugin::WindowsIapPlugin() {}

WindowsIapPlugin::~WindowsIapPlugin() {}

void WindowsIapPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  if (method_call.method_name().compare("getPlatformVersion") == 0) {
    std::ostringstream version_stream;
    version_stream << "Windows ";
    if (IsWindows10OrGreater()) {
      version_stream << "10+";
    } else if (IsWindows8OrGreater()) {
      version_stream << "8";
    } else if (IsWindows7OrGreater()) {
      version_stream << "7";
    }
    result->Success(flutter::EncodableValue(version_stream.str()));
  }
  else if (method_call.method_name().compare("makePurchase") == 0) {
      auto args = std::get<flutter::EncodableMap>(*method_call.arguments());
      auto storeId = std::get<std::string>(args[flutter::EncodableValue("storeId")]);
      makePurchase(to_hstring(storeId));
  }else {
    result->NotImplemented();
  }
}

}  // namespace windows_iap
