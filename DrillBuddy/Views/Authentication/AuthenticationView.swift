//
//  AuthenticationView.swift
//  DrillBuddy
//
//  Created by Roman on 2023-11-01.
//

import SwiftUI

// MARK: - AuthenticationView

struct AuthenticationView: View {
    
    // MARK: - AuthenticationType
    
    enum AuthenticationType: Int, Identifiable {
        var id: Int {
            rawValue
        }
        
        case signIn
        case signUp
    }
    
    // MARK: - Propeties
    
    @State var authenticationType: AuthenticationType {
        didSet {
            username = ""
            password = ""
        }
    }
    
    var authenticationService: AuthenticationService = AuthenticationService()
    
    @State private var error: Error?
    
    @State private var isAuthenticating: Bool = false
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var username: String = ""
    
    private let maxUsernameLength = 15
    
    // MARK: View
    
    var body: some View {
        Group {
            switch authenticationType {
            case .signIn:
                signInView
            case .signUp:
                signUpView
            }
        }
        .loadingOverlay(isLoading: isAuthenticating)
        .errorAlert(error: $error)
    }
    
    // MARK: - Private Views
    
    private var signInView: some View {
        VStack {
            Spacer()
            TextField("Enter your email", text: $email)
                .keyboardType(.emailAddress)
                .padding()
                .textInputAutocapitalization(.never)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .autocorrectionDisabled(true)
            
            SecureField("Enter your password", text: $password)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .autocorrectionDisabled(true)
            
            Spacer()
                .frame(height: 16)
            
            Button(action: {
                Task {
                    isAuthenticating = true
                    do {
                        try await authenticationService.signIn(with: email, password: password)
                    } catch let authError {
                        error = authError
                    }
                    
                    isAuthenticating = false
                }
            }, label: {
                Text("Sign In")
                    .padding()
                    .frame(maxWidth: .infinity)
            })
            .buttonStyle(.borderedProminent)
            .disabled(email.isEmpty || password.isEmpty)
            
            Spacer()
                .frame(height: 24)
            
            HStack {
                Text("Don't have an account?")
                Button(action: {
                    authenticationType = .signUp
                }, label: {
                    Text("Sign Up")
                })
            }
        }
        .padding()
    }
    
    private var signUpView: some View {
        VStack {
            Spacer()
            
            TextField("Choose your username", text: $username)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.never)
                .onChange(of: username) {
                    username = String(username.replacingOccurrences(of: " ", with: "").prefix(maxUsernameLength))
//                    isInputValid = usernamePredicate.evaluate(with: username)
                }
            
            TextField("Enter your email", text: $email)
                .keyboardType(.emailAddress)
                .padding()
                .textInputAutocapitalization(.never)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .autocorrectionDisabled(true)
            
            SecureField("Create new password", text: $password)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .autocorrectionDisabled(true)
            
            Spacer()
                .frame(height: 16)
            
            Button(action: {
                Task {
                    isAuthenticating = true
                    
                    do {
                        try await authenticationService.createUser(username: username, email: email, password: password)
                    } catch let authError {
                        error = authError
                    }
                    
                    isAuthenticating = false
                }
            }, label: {
                Text("Sign Up")
                    .padding()
                    .frame(maxWidth: .infinity)
            })
            .buttonStyle(.borderedProminent)
            .disabled(username.isEmpty || email.isEmpty || password.isEmpty)
            
            Spacer()
                .frame(height: 24)
            
            HStack {
                Text("Already have an account?")
                Button(action: {
                    authenticationType = .signIn
                }, label: {
                    Text("Sign In")
                })
            }
        }
        .padding()
    }
}

// MARK: - Previews

#Preview("Sign Up") {
    AuthenticationView(authenticationType: .signUp)
}

#Preview("Sign In") {
    AuthenticationView(authenticationType: .signIn)
}
