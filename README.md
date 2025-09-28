 

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
    let csp = "default-src * 'unsafe-inline' 'unsafe-eval';"

    var body: some View {
        SecureWebView(
            whitelistedURL: URL(string: "https://biometric.vision")!,
            customCSP: csp,
            testMode: true  // ⚠️ Display warnings instead of terminating
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
| `testMode = true`  | Shows warnings for network, environment, or URL issues without crashing |
| `testMode = false` | Critical anomalies terminate the web view load                          |

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

        let csp = "default-src * 'unsafe-inline' 'unsafe-eval';"

        let secureWebView = SecureWebView(
            whitelistedURL: URL(string: "https://biometric.vision")!,
            customCSP: csp,
            testMode: true
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

        WebViewSDK.logString(for: "UIKit WebView loaded")
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

These demonstrate CSP setup, `testMode`, and logging.

---

## 🧑‍💻 7. Best Practices

* Only whitelist URLs that your app should load.
* Use **testMode** in development to show warnings instead of crashing.
* Always log anomalies for audit and diagnostics.
* Keep CSP updated to block untrusted sources.
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
import Foundation
import Combine

// MARK: - Model
struct SessionResponse: Codable {
    let session_id: String
    let technologies: [String]
}

// MARK: - Service
class KYCService {
    private let endpoint = URL(string: "https://kyc.biometric.kz/api/v1/flows/session/create/")!

    func createSession(apiKey: String) async throws -> URL {
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["api_key": apiKey]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(SessionResponse.self, from: data)

        let urlString = "https://remote.biometric.kz/flow/\(response.session_id)?web_view=true"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        return url
    }
}

// MARK: - ViewModel
@MainActor
class KYCViewModel: ObservableObject {
    @Published var flowURL: URL?
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false

    private let service = KYCService()

    func startFlow() async {
        isLoading = true
        defer { isLoading = false }

        do {
            flowURL = try await service.createSession(
                apiKey: "YOUR_API_KEY"
            )
        } catch {
            errorMessage = "❌ \(error.localizedDescription)"
        }
    }
}

// MARK: - View
struct ContentView: View {
    let csp = "default-src * 'unsafe-inline' 'unsafe-eval';"
    @StateObject private var vm = KYCViewModel()
    @State private var showToast = false

    var body: some View {
        VStack {
            if vm.isLoading {
                ProgressView("Creating session…")
            } else if let error = vm.errorMessage {
                Text(error)
                    .foregroundColor(.red)
            } else if let url = vm.flowURL {
                SecureWebView(
                    whitelistedURL: url,
                    customCSP: csp,
                    testMode: true,
                    onSuccess: { didSucceed in
                        if didSucceed {
                            withAnimation { showToast = true }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                withAnimation { showToast = false }
                            }
                        }
                    }
                )
                .ignoresSafeArea(edges: .all)
            } else {
                Text("Preparing session…")
                    .foregroundColor(.gray)
            }
        }
        .task { await vm.startFlow() }

        if showToast {
            VStack {
                Spacer()
                HStack {
                    Text("✅ Success!")
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.green.opacity(0.9))
                        .cornerRadius(10)
                }
                .padding(.bottom, 40)
            }
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
}
```

---

## 📞 Support

For questions or support, visit: [https://webviewsdk.dev/](https://guide.biometric.kz/en/integrations/flow_webview/)

---

