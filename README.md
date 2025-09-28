 

---

# WebViewSDK Integration Guide (iOS)

This guide provides a step-by-step walkthrough for integrating the **WebViewSDK** into your iOS project. This SDK provides a secure `WKWebView` wrapper with built-in security checks, Content Security Policy enforcement, and optional dev/test modes.

---

## 📦 SDK Contents Overview

* **SecureWebView**: SwiftUI `View` wrapper around `WKWebView` with security checks.
* **SecureWebViewController**: Programmatic `UIViewController` for UIKit apps.
* **SecureWebViewContainer**: Storyboard-friendly `UIView` wrapper.
* **SecurityManager**: Checks for network anomalies (VPN/Proxy).
* **RuntimeEnvironmentProtection**: Detects suspicious environments (simulator, debugger, etc.).
* **WebViewSDK**: Static logging and warning utilities.

---

## 📱 Requirements & SDK Info

* **iOS Deployment Target**: 13.0+ (UIKit & SwiftUI)
* **Swift Version**: 5+
* **Dependencies**: None external (pure Swift + WebKit)
* **Required Features**: Internet access
* **Permissions Required**:

  * `NSCameraUsageDescription`
  * `NSMicrophoneUsageDescription`

👉 Add these two keys to your app’s **Info.plist**, otherwise iOS will block camera/microphone access during biometric flows.

---

## 🚀 1. Adding the SDK to Your Project

Add the SDK via **Swift Package Manager**:

1. In Xcode → **File → Add Packages**
2. Enter the repository URL:

```
https://github.com/pretty128guydev/ios-sdk.git
```

3. Choose the `main` branch.
4. Import it in your Swift files:

```swift
import web_view_sdk
```

---

## 🏗 2. SwiftUI Integration

`SecureWebView` is the recommended approach for SwiftUI apps.

```swift
import SwiftUI
import web_view_sdk

struct ContentView: View {

    var body: some View {
        SecureWebView(
            appTeamId: "",
            appBundleIds: "com.example.web_view_sdk_test_app",
            isProd: false,   // ⚠️ Use true in production
            apiKey: "<YOU_API_KEY>",
            onSuccess: { didSucceed in
                if didSucceed {
                    print("✅ SwiftUI flow succeeded")
                }
            }
        )
        .ignoresSafeArea(edges: .all)
        .onAppear {
            WebViewSDK.logString(for: "SecureWebView appeared")
        }
    }
}

#Preview {
    ContentView()
}
```

### 🔧 Test Mode vs Production

| Mode               | Behavior                                                                |
| ------------------ | ----------------------------------------------------------------------- |
| `isProd = true`  | Shows warnings for network, environment, or URL issues without crashing |
| `isProd = false` | Critical anomalies terminate the web view load                          |

---

## 🖥 3. UIKit Integration

You can use `SecureWebViewController` or embed `SecureWebView` via a `UIHostingController`.

```swift
 import UIKit
import SwiftUI
import web_view_sdk

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()


        let secureWebView = SecureWebView(
            appTeamId: "",
            appBundleIds: "com.example.web_view_sdk_test_app",
            isProd: false,   // ⚠️ Use true in production
            apiKey: "<YOU_API_KEY>",
            onSuccess: { didSucceed in
                if didSucceed {
                    print("✅ UIKit flow succeeded")
                }
            }
        )

        let hostingController = UIHostingController(rootView: secureWebView)
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)

        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

```

---

## 🔐 4. Security & Environment Checks

WebViewSDK automatically validates:

1. **Runtime environment**: Detects simulator, debugger, or jailbroken devices.
2. **Network anomalies**: VPN or proxy detection.
3. **URL validation**: Only HTTP/HTTPS schemes allowed.
4. **Host reachability**: Ensures the host is reachable.
5. **URL reachability**: Ensures the page can be loaded.

> In **dev/test mode**, warnings are shown using `WebViewSDK.showWarning()` instead of terminating the web view.
 

---

##  Security Warnings

The SDK performs multiple **runtime, network, and environment validations** and raises `SecurityRisk` alerts whenever a potential threat is detected.

* In **production mode** (`isProd = true`), detection of any **critical** vulnerability **terminates the web view load immediately** (failing fast).
* In **test mode** (`isProd = false`), issues are shown as **non-blocking warnings** using `WebViewSDK.showWarning()` and logged via `WebViewSDK.logString(for:)`.

This allows developers to validate integration safely during testing, while enforcing strict protection in production.

---

### SecurityRisk Enum and Severity

| Risk Type                   | Severity | Description                                                                 |
| --------------------------- | -------- | --------------------------------------------------------------------------- |
| `SimulatorDetected`         | CRITICAL | App is running in a simulator/emulator environment                          |
| `DebuggerAttached`          | CRITICAL | Debugger detected at runtime                                                |
| `JailbreakDetected`         | CRITICAL | Device is jailbroken / compromised                                          |
| `ProxyDetected`             | WARNING  | Active proxy detected in device network settings                            |
| `VPNDetected`               | WARNING  | Active VPN connection detected                                              |
| `UnreachableHost`           | CRITICAL | Host server not reachable                                                   |
| `UntrustedURL`              | CRITICAL | URL is not in the configured whitelist                                      |
| `InvalidScheme`             | CRITICAL | Non-HTTP/HTTPS scheme detected in request                                   |
| `TamperDetected`            | CRITICAL | SDK integrity check failed (tampering or re-signing suspected)              |
| `ScreenRecordingDetected`   | WARNING  | Active screen recording was detected during sensitive flow                  |
| `ScreenshotAttemptDetected` | WARNING  | Screenshot attempted during secure flow                                     |
| `DeveloperModeDetected`     | WARNING  | iOS developer mode enabled (device is in dev/testing configuration)         |
| `UnsupportedEnvironment`    | WARNING  | Running in unsupported environment (e.g., outdated iOS or missing features) |

---

### 🚦 Behavior by Mode

| Mode               | Behavior                                                                  |
| ------------------ | ------------------------------------------------------------------------- |
| `isProd = true`  | Critical threats terminate load; warnings may still be logged  |
| `isProd = false` | Non-blocking warnings are logged and shown to developer via `showWarning`            |

---

### Example: Handling Warnings in SwiftUI

```swift
SecureWebView(
    appTeamId: "",
    appBundleIds: "com.example.web_view_sdk_test_app",
    isProd: false,   // ⚠️ Use true in production
    apiKey: "<YOU_API_KEY>",
    onSuccess: { didSucceed in
        if didSucceed {
            print("✅ SwiftUI flow succeeded")
        }
    }
)
         
```

---

👉 **Note**: Always run in `isProd = false` during development to surface warnings.
Switch to `isProd = true` for production builds to enforce strict blocking on critical risks.

 


---

## ⚡ 5. Logging & Debugging

Use `WebViewSDK.logString(for:)` to log warnings or debug messages:

```swift
WebViewSDK.logString(for: "Debug: Page loaded successfully")
WebViewSDK.showWarning("⚠️ Warning: VPN detected in test mode")
```

---

## ✅ 6. Quick Start Examples

* **SwiftUI**: `/example/web_view_sdk_test_app`
* **UIKit**: `/example/web_view_sdk_test_app_uikit`


---

## 🧑‍💻 7. Best Practices

* Only whitelist URLs that your app should load.
* Use **isProd** in development to show warnings instead of crashing.
* Always log anomalies for audit and diagnostics.
* Do not disable security checks in production builds.

---

---

## 🎯 8. KYC Flow Example (SwiftUI)

The SDK can be integrated with external KYC/biometric APIs.
Below is a **complete SwiftUI example** that:

* Creates a KYC session via the `kyc.biometric.kz` API
* Loads the returned flow into a `SecureWebView`
* Shows a success **toast/snackbar** on completion

```swift
import SwiftUI
import web_view_sdk

struct ContentView: View {

    var body: some View {
        SecureWebView(
            appTeamId: "",
            appBundleIds: "com.example.web_view_sdk_test_app",
            isProd: false,   // ⚠️ Use true in production
            apiKey: "<YOU_API_KEY>",
            onSuccess: { didSucceed in
                if didSucceed {
                    print("✅ SwiftUI flow succeeded")
                }
            }
        )
        .ignoresSafeArea(edges: .all)
    }
}

#Preview {
    ContentView()
}

```

---

## 📞 Support

For questions or support, visit: [https://webviewsdk.dev/](https://guide.biometric.kz/en/integrations/flow_webview/)

---

