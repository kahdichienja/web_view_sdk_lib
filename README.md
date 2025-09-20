
---

# Web View SDK

The **Web View SDK** provides a secure, customizable web view for iOS apps, supporting CSP (Content Security Policy) enforcement and restricted URL loading.

This SDK abstracts away the implementation details — you just import and use it.

---

## 📦 Installation

### Swift Package Manager (Recommended)

1. In Xcode, go to **File > Add Packages…**

2. Enter the package repository URL for the SDK (replace with your actual URL):

   ```
   https://github.com/kahdichienja/web_view_sdk_lib.git
   ```

3. Choose the **latest version**.

4. Add the dependency to your app target.

---

## 🚀 Usage

### SwiftUI

```swift
import SwiftUI
import web_view_sdk

struct ContentView: View {
    
    // Define your Content Security Policy (CSP)
    let csp = "default-src * 'unsafe-inline' 'unsafe-eval';"
    
    var body: some View {
        SecureWebView(
            whitelistedURL: URL(string: "https://www.pexels.com")!,
            customCSP: csp
        )
        .ignoresSafeArea(edges: .all)
        .onAppear {
            log("WebView appeared")
        }
    }
    
    private func log(_ message: String) {
        print("[ContentView] \(message)")
        
        // Send logs through the SDK if needed
        WebViewSDK.logString(for: message)
    }
}
```

---

### UIKit

If you’re not using SwiftUI, the SDK also works in UIKit.

```swift
import UIKit
import SwiftUI
import web_view_sdk

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Define your Content Security Policy (CSP)
        let csp = "default-src * 'unsafe-inline' 'unsafe-eval';"
        
        // Create SwiftUI SecureWebView
        let secureWebView = SecureWebView(
            whitelistedURL: URL(string: "https://www.pexels.com")!,
            customCSP: csp
        )
        
        // Wrap it in a UIHostingController
        let hostingController = UIHostingController(rootView: secureWebView)
        
        // Add as a child VC
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

## 🔧 Parameters

* **`whitelistedURL: URL`**
  The starting URL allowed to load inside the web view. Only HTTP/HTTPS schemes are supported.

* **`customCSP: String`** *(Optional)*
  A CSP string to restrict what resources can load. Example:

  ```swift
  "default-src * 'unsafe-inline' 'unsafe-eval';"
  ```

---

## 📋 Logging

You can send custom log messages to the SDK for debugging or monitoring:

```swift
WebViewSDK.logString(for: "Custom log message")
```

---

## ⚠️ Notes

* The SDK only supports **HTTP** and **HTTPS** schemes. Any other schemes will be blocked with an error.
* CSP should be carefully configured to match your app’s security requirements.

---

## 📖 Example Project

Check the **ExampleApp** folder in this repo for a working Xcode project that demonstrates SDK integration with both **SwiftUI** and **UIKit**.

---

## 🛠 Support

For questions, issues, or feature requests, please open an issue on [GitHub](https://github.com/kahdichienja/web_view_sdk_lib/issues).

---


