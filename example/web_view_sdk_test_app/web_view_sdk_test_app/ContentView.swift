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
        print(url)
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
                apiKey: "Rv7MCdaiaLc5plgOOvmunOfsqNyiHzSTvrYVJ45G7P7XH2Y"
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
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            } else if let error = vm.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            } else if let url = vm.flowURL {
                SecureWebView(
                    whitelistedURL: url,
                    customCSP: csp,
                    testMode: true,
                    onSuccess: { didSucceed in
                        if didSucceed {
                            withAnimation {
                                showToast = true
                            }
                            // Auto-hide after 5 seconds
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                withAnimation {
                                    showToast = false
                                }
                            }
                        }
                    }
                )
                .ignoresSafeArea(edges: .all)
            } else {
                // First load state before API call
                Text("Preparing session…")
                    .foregroundColor(.gray)
            }
        }
        .task {
            await vm.startFlow()
        }
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

// MARK: - Preview
#Preview {
    ContentView()
}
