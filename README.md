 

---

# WebViewSDK Integration Guide

Repository: [https://github.com/pretty128guydev/ios-sdk.git](https://github.com/pretty128guydev/ios-sdk.git)

This guide covers how to integrate **WebViewSDK** into SwiftUI and UIKit apps, including dev/test modes, Content Security Policy (CSP), and environment/network anomaly checks.

---

## 1️⃣ Add SDK to Your Project

1. Open Xcode → **File → Add Packages**
2. Enter the repository URL:

```
https://github.com/pretty128guydev/ios-sdk.git
```

3. Choose the `main` branch.

---

## 2️⃣ Import the SDK

```swift
import SwiftUI
import web_view_sdk
```

---

## 3️⃣ SwiftUI Integration

`SecureWebView` is a **UIViewRepresentable** wrapper around `WKWebView` with built-in security checks:

* **Whitelist URL only**
* **Optional custom CSP**
* **Network & environment anomaly detection**
* **Dev/test mode** to display warnings without crashing

### Basic SwiftUI Setup

```swift
struct ContentView: View {

    let csp = "default-src * 'unsafe-inline' 'unsafe-eval';"

    var body: some View {
        SecureWebView(
            whitelistedURL: URL(string: "https://www.pexels.com")!,
            customCSP: csp,
            testMode: true      // ⚠️ Enable warnings in dev mode
        )
        .ignoresSafeArea(edges: .all)
        .onAppear {
            log("View did appear")
        }
    }

    func log(_ message: String) {
        print("[ContentView] \(message)")
        WebViewSDK.logString(for: message)
    }
}

#Preview {
    ContentView()
}
```

### Dev/Test Mode Behavior

* `testMode = true` → shows warnings for network, environment, or URL issues **without terminating**.
* `testMode = false` → critical anomalies terminate the web view load.

---

## 4️⃣ UIKit Integration

You can embed `SecureWebView` inside a `UIViewController` via `UIHostingController`:

```swift
import UIKit
import SwiftUI
import web_view_sdk

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let csp = "default-src * 'unsafe-inline' 'unsafe-eval';"

        // Create SwiftUI SecureWebView
        let secureWebView = SecureWebView(
            whitelistedURL: URL(string: "https://www.pexels.com")!,
            customCSP: csp,
            testMode: true
        )

        // Wrap it in UIHostingController
        let hostingController = UIHostingController(rootView: secureWebView)

        // Add as child VC
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)

        // Fill parent view
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        WebViewSDK.logString(for: "UIKit WebView loaded")
    }
}
```

---

## 5️⃣ Security & Environment Checks

`SecureWebView` automatically checks:

1. **Runtime environment** → blocks SDK if suspicious (e.g., simulator, debugger)
2. **Network anomalies** → VPN or proxy detection
3. **URL validation** → only allows HTTP/HTTPS schemes
4. **Host reachability** → ensures the host is reachable
5. **URL reachability** → ensures the page can be loaded

> In dev/test mode, warnings are displayed via `WebViewSDK.showWarning()` instead of terminating.

---

## 6️⃣ Quick Start

Check the `/example` folder in the repo for ready-to-run examples:

* **SwiftUI Example:** `/example/web_view_sdk_test_app`
* **UIKit Example:** `/example/web_view_sdk_test_app_uikit`

> Both demonstrate CSP setup, test mode, and logging.

---

## 7️⃣ Logging & Debugging

`WebViewSDK.logString(for:)` logs messages for diagnostics.

Example:

```swift
WebViewSDK.logString(for: "Custom debug message")
```

* Useful in test mode to monitor environment/network checks
* Automatically logs errors and warnings

---

This guide gives **full SwiftUI + UIKit integration**, dev/test modes, and all security checks enabled.

---

 
