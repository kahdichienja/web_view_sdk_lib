//
//  ContentView.swift
//  web_view_sdk_test_app
//
//  Created by Agoo Clinton on 9/22/25.
//

import SwiftUI
import web_view_sdk
import Foundation
import Combine
 

// MARK: - View
struct ContentView: View {
    let csp = "default-src * 'unsafe-inline' 'unsafe-eval';"
    
    //Rv7MCdaiaLc5plgOOvmunOfsqNyiHzSTvrYVJ45G7P7XH2Y
    

    var body: some View {
        VStack {
            SecureWebView(
                appTeamId: "",
                appBundleIds: "com.example.web_view_sdk_test_app",
                isProd: false,
                apiKey: "Rv7MCdaiaLc5plgOOvmunOfsqNyiHzSTvrYVJ45G7P7XH2Y",
                onSuccess: { didSucceed in
                    if didSucceed {
                        print("Success")
                    }
                }
            )
            .ignoresSafeArea(edges: .all)
        }
        
    }
}

// MARK: - Preview
#Preview {
    ContentView()
}
