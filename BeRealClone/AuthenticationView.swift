//
//  AuthenticationView.swift
//  BeRealClone
//
//  Created by student on 9/23/25.
//

import SwiftUI

struct AuthenticationView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var isRegistering = false
    @State private var errorMessage: String?
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text(isRegistering ? "Register" : "Login")
                    .font(.largeTitle)
                    .bold()
                
                TextField("Username", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }
                
                Button(action: {
                    if isRegistering {
                        register()
                    } else {
                        login()
                    }
                }) {
                    Text(isRegistering ? "Sign Up" : "Login")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button(action: { isRegistering.toggle() }) {
                    Text(isRegistering ? "Already have an account? Login" :
                         "Don’t have an account? Sign Up")
                        .foregroundColor(.blue)
                }
                
                //NavigationLink(destination: MainFeedView(),
                               //isActive: $isLoggedIn) { EmptyView() }
            }
            .padding()
        }
    }
    
    // Functions
    private func login() {
        AppUser.login(username: username, password: password) { result in
            switch result {
            case .success(let user):
                print("✅ Logged in as \(user.username ?? "Unknown")")
                isLoggedIn = true
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }
    
    private func register() {
        var newUser = AppUser()
        newUser.username = username
        newUser.password = password
        
        newUser.signup { result in
            switch result {
            case .success(let user):
                print("✅ Registered new user \(user.username ?? "Unknown")")
                isLoggedIn = true
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }
}

