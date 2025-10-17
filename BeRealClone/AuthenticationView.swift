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
    @State private var isLoading = false
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Spacer()
                
                // Logo/Title
                VStack(spacing: 8) {
                    Text("📸")
                        .font(.system(size: 80))
                    Text("BeReal Clone")
                        .font(.largeTitle)
                        .bold()
                    Text(isRegistering ? "Create your account" : "Welcome back!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 40)
                
                // Input fields
                VStack(spacing: 16) {
                    TextField("Username", text: $username)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                        .padding(.horizontal)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                }
                
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // Action button
                Button(action: {
                    if isRegistering {
                        register()
                    } else {
                        login()
                    }
                }) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        }
                        Text(isRegistering ? "Sign Up" : "Login")
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(username.isEmpty || password.isEmpty || isLoading)
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Toggle button
                Button(action: {
                    isRegistering.toggle()
                    errorMessage = nil
                }) {
                    Text(isRegistering ? "Already have an account? Login" : "Don't have an account? Sign Up")
                        .foregroundColor(.blue)
                        .font(.subheadline)
                }
                .padding(.top, 8)
                
                Spacer()
            }
            .padding()
        }
    }
    
    private func login() {
        isLoading = true
        errorMessage = nil
        
        AppUser.login(username: username, password: password) { result in
            DispatchQueue.main.async {
                isLoading = false
                
                switch result {
                case .success(let user):
                    print("✅ Logged in as \(user.username ?? "Unknown")")
                    isLoggedIn = true
                case .failure(let error):
                    errorMessage = "Login failed: \(error.localizedDescription)"
                    print("❌ Login error: \(error)")
                }
            }
        }
    }
    
    private func register() {
        isLoading = true
        errorMessage = nil
        
        var newUser = AppUser()
        newUser.username = username
        newUser.password = password
        
        newUser.signup { result in
            DispatchQueue.main.async {
                isLoading = false
                
                switch result {
                case .success(let user):
                    print("✅ Registered new user \(user.username ?? "Unknown")")
                    isLoggedIn = true
                case .failure(let error):
                    errorMessage = "Registration failed: \(error.localizedDescription)"
                    print("❌ Registration error: \(error)")
                }
            }
        }
    }
}
