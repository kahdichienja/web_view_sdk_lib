//
//  ContentView.swift
//  web_view_sdk_test_app
//
//  Created by Agoo Clinton on 9/22/25.
//

import SwiftUI
import web_view_sdk


struct ContentView: View {
    
    let csp = "default-src * 'unsafe-inline' 'unsafe-eval';"

    
    var body: some View {
        SecureWebView(
            whitelistedURL: URL(string: "https://www.pexels.com")!,
            customCSP: csp,
            testMode: true,
            
        )
        .ignoresSafeArea(edges:.all)
        .onAppear() {
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
