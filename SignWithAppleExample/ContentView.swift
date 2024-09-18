//
//  ContentView.swift
//  SignWithAppleExample
//
//  Created by Armando Cáceres on 18/9/24.
//

import SwiftUI
import AuthenticationServices

struct ContentView: View {
    @State private var userName: String = ""
    @State private var userEmail: String = ""
    @AppStorage("storedName") private var storedName : String = "" {
        didSet {
            userName = storedName
        }
    }
    
    @AppStorage("storedEmail") private var storedEmail : String = "" {
        didSet {
            userEmail = storedEmail
        }
    }
    @AppStorage("userID") private var userID : String = ""
    
    var body: some View {
        VStack {
            ZStack{
                Color.white
                if userName.isEmpty{
                    SignInWithAppleButton(.signIn,
                                          onRequest: onRequest,
                                          onCompletion: onCompletion)
                    .signInWithAppleButtonStyle(.black)
                    .frame(width: 200, height: 50)
                } else {
                    Text("Welcome\n\(userName), \(userEmail)")
                        .foregroundColor(.black)
                        .font(.headline)
                }
            }
            .task { await authorize() }
        }
    }
    
    private func authorize() async {
        guard !userID.isEmpty else {
            userName = ""
            userEmail = ""
            return
        }
        guard let credentialState = try? await
                ASAuthorizationAppleIDProvider()
            .credentialState(forUserID: userID) else {
            userName = ""
            userEmail = ""
            return
        }
        
        switch credentialState {
        case .authorized:
            userName = storedName
            userEmail = storedEmail
        default:
            userName = ""
            userEmail = ""
        }
    }
    
    private func onRequest(_ request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.fullName, .email]
    }
    
    private func onCompletion(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success (let authResults):
            guard let credential = authResults.credential as? ASAuthorizationAppleIDCredential
            else { return }
            storedName = credential.fullName?.givenName ?? ""
            storedEmail = credential.email ?? ""
            userID = credential.user
        case .failure (let error):
            print("Authorization failed: " + error.localizedDescription)
        }
    }
}

#Preview {
    ContentView()
}
