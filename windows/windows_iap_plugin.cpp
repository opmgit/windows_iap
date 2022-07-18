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

#include <flutter/event_sink.h>
#include <flutter/event_channel.h>
#include <flutter/event_stream_handler.h>
#include <flutter/event_stream_handler_functions.h>

using namespace winrt;
using namespace Windows::Services::Store;
using namespace Windows::Foundation::Collections;
namespace foundation = Windows::Foundation;

namespace windows_iap {

    flutter::PluginRegistrarWindows* _registrar;
    std::unique_ptr<flutter::EventSink<>> _event;

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

    std::string getExtendedErrorString(winrt::hresult error) {
        const HRESULT IAP_E_UNEXPECTED = 0x803f6107L;
        std::string message;
        if (error.value == IAP_E_UNEXPECTED) {
            message = "This Product has not been properly configured.";
        }
        else {
            message = "ExtendedError: " + std::to_string(error.value);
        }
        return message;
    }

    foundation::IAsyncAction makePurchase(hstring storeId, std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> resultCallback)
    {

        if (_event != nullptr) {
            _event->Success(flutter::EncodableValue("day la string 2"));
        }
        StorePurchaseResult result = co_await getStore().RequestPurchaseAsync(storeId);

        if (result.ExtendedError().value != S_OK) {
            resultCallback->Error(std::to_string(result.ExtendedError().value), getExtendedErrorString(result.ExtendedError().value));
            co_return;
        }
        int32_t returnCode;
        switch (result.Status()) {
            case StorePurchaseStatus::AlreadyPurchased:
                returnCode = 1; 
                break;

            case StorePurchaseStatus::Succeeded:
                returnCode = 0;
                break;

            case StorePurchaseStatus::NotPurchased:
                returnCode = 2;
                break;

            case StorePurchaseStatus::NetworkError:
                returnCode = 3;
                break;

            case StorePurchaseStatus::ServerError:
                returnCode = 4;
                break;

            default:
                auto status = reinterpret_cast<int32_t*>(result.Status());
                resultCallback->Error(std::to_string(*status), "Product was not purchased due to an unknown error.");
                co_return;
                break;
        }

        resultCallback->Success(flutter::EncodableValue(returnCode));
    }

    foundation::IAsyncAction getProducts() {
        auto result = co_await getStore().GetAssociatedStoreProductsAsync({ L"Consumable", L"Durable", L"UnmanagedConsumable" });
        if (result.ExtendedError().value != S_OK) {
            getExtendedErrorString(result.ExtendedError());
        }
        else if (result.Products().Size() == 0) {
            // send error: This Product has not been properly configured.
        }
        else {
            std::vector<StoreProduct> products;
            for (IKeyValuePair<hstring, StoreProduct> addOn : result.Products())
            {
                StoreProduct product = addOn.Value();
                products.push_back(product);
            }
        }
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

  auto event = std::make_unique<flutter::EventChannel<flutter::EncodableValue>>(
      registrar->messenger(),"windows_iap_event",
      &flutter::StandardMethodCodec::GetInstance());
  auto handler = std::make_unique<flutter::StreamHandlerFunctions<>>(
      [](const flutter::EncodableValue* arguments,
          std::unique_ptr<flutter::EventSink<>>&& events)
      -> std::unique_ptr<flutter::StreamHandlerError<>> {
          _event = std::move(events);
          return nullptr;
      },
      [](const flutter::EncodableValue* arguments)
          -> std::unique_ptr<flutter::StreamHandlerError<>> { _event.release(); return nullptr; });

  event->SetStreamHandler(std::move(handler));

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
      makePurchase(to_hstring(storeId), std::move(result));
  }else if(method_call.method_name().compare("getProducts") == 0){
      getProducts();
  }else {
    result->NotImplemented();
  }
}

}  // namespace windows_iap
