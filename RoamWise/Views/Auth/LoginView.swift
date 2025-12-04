//
//  LoginView.swift
//  Veou
//
//  Created on 4/10/25.
//

import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: AuthViewModel
    @FocusState private var focusedField: LoginField?
    
    enum LoginField {
        case email
        case password
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("Welcome to RoamWise")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                    
                    Text("Sign in to explore safe travel destinations")
                        .font(.system(size: 15))
                        .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
                }
                .padding(.top, 20)
                .padding(.bottom, 8)
                
                // Social Login Buttons
                VStack(spacing: 12) {
                    SocialLoginButton(provider: .apple) {
                        Task {
                            await viewModel.loginWithApple()
                        }
                    }
                    
                    SocialLoginButton(provider: .google) {
                        Task {
                            await viewModel.loginWithGoogle()
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                // Separator
                HStack(spacing: 12) {
                    Rectangle()
                        .fill(Color(red: 0.9, green: 0.9, blue: 0.9))
                        .frame(height: 1)
                    
                    Text("or continue with email")
                        .font(.system(size: 13))
                        .foregroundColor(Color(red: 0.7, green: 0.7, blue: 0.7))
                    
                    Rectangle()
                        .fill(Color(red: 0.9, green: 0.9, blue: 0.9))
                        .frame(height: 1)
                }
                .padding(.horizontal, 20)
                
                // Email and Password Fields
                VStack(spacing: 16) {
                    CustomTextField(
                        icon: "envelope",
                        placeholder: "Enter your email",
                        text: $viewModel.loginEmail
                    )
                    .focused($focusedField, equals: .email)
                    
                    CustomTextField(
                        icon: "lock",
                        placeholder: "Enter your password",
                        text: $viewModel.loginPassword,
                        isSecure: true,
                        showPassword: viewModel.showLoginPassword,
                        onTogglePassword: {
                            viewModel.showLoginPassword.toggle()
                        }
                    )
                    .focused($focusedField, equals: .password)
                }
                .padding(.horizontal, 20)
                
                // Forgot Password
                HStack {
                    Spacer()
                    Button(action: {
                        Task {
                            await viewModel.resetPassword()
                        }
                    }) {
                        Text("Forgot Password?")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                    }
                }
                .padding(.horizontal, 20)
                
                // Error Message
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.system(size: 14))
                        .foregroundColor(.red)
                        .padding(.horizontal, 20)
                        .multilineTextAlignment(.center)
                }
                
                // Login Button
                Button(action: {
                    Task {
                        await viewModel.login()
                    }
                }) {
                    HStack {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Login")
                                .font(.system(size: 18, weight: .semibold))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .foregroundColor(.white)
                    .background(
                        LinearGradient(
                            colors: [
                                Color(red: 0.2, green: 0.4, blue: 0.9),
                                Color(red: 0.1, green: 0.3, blue: 0.8)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(14)
                    .shadow(
                        color: Color.blue.opacity(0.2),
                        radius: 8,
                        x: 0,
                        y: 4
                    )
                }
                .disabled(!viewModel.isLoginValid || viewModel.isLoading)
                .opacity((viewModel.isLoginValid && !viewModel.isLoading) ? 1.0 : 0.6)
                .padding(.horizontal, 20)
                .padding(.top, 8)
                
                // Terms and Privacy
                Text("By signing up, you agree to our Terms of service and Privacy_policy")
                    .font(.system(size: 12))
                    .foregroundColor(Color(red: 0.7, green: 0.7, blue: 0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.top, 8)
                    .padding(.bottom, 20)
                
                Spacer(minLength: 20)
            }
        }
        .onTapGesture {
            focusedField = nil
        }
    }
}

#Preview {
    LoginView(viewModel: AuthViewModel())
        .background(Color.white)
}

