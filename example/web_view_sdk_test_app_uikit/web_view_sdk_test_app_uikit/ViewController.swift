//
//  ViewController.swift
//  web_view_sdk_test_app_uikit
//
//  Created by Agoo Clinton on 9/22/25.
//

import UIKit
import SwiftUI
import web_view_sdk

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let csp = "default-src * 'unsafe-inline' 'unsafe-eval';"
        
        // Create SwiftUI SecureWebView
        let secureWebView = SecureWebView(
            whitelistedURL: URL(string: "https://biometric.vision")!,
            customCSP: csp,
            testMode: true
            
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
