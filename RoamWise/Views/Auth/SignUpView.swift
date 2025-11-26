//
//  SignUpView.swift
//  Veou
//
//  Created on 4/10/25.
//

import SwiftUI

struct SignUpView: View {
    @ObservedObject var viewModel: AuthViewModel
    @FocusState private var focusedField: SignUpField?
    
    enum SignUpField {
        case name
        case email
        case password
        case confirmPassword
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    // Logo
                    HStack(spacing: 8) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(red: 0.4, green: 0.7, blue: 0.9))
                                .frame(width: 32, height: 32)
                            
                            Text("R")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        Text("RoamWise")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                    }
                    .padding(.top, 20)
                    
                    Text("Welcome to RoamWise")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                    
                    Text("Create an account to start your journey")
                        .font(.system(size: 15))
                        .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
                }
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
                
                // Sign Up Fields
                VStack(spacing: 16) {
                    CustomTextField(
                        icon: "person",
                        placeholder: "Your name",
                        text: $viewModel.signUpName
                    )
                    .focused($focusedField, equals: .name)
                    
                    CustomTextField(
                        icon: "envelope",
                        placeholder: "Enter your email",
                        text: $viewModel.signUpEmail
                    )
                    .focused($focusedField, equals: .email)
                    
                    CustomTextField(
                        icon: "lock",
                        placeholder: "Enter your password",
                        text: $viewModel.signUpPassword,
                        isSecure: true,
                        showPassword: viewModel.showSignUpPassword,
                        onTogglePassword: {
                            viewModel.showSignUpPassword.toggle()
                        }
                    )
                    .focused($focusedField, equals: .password)
                    
                    CustomTextField(
                        icon: "lock",
                        placeholder: "Confirm your password",
                        text: $viewModel.confirmPassword,
                        isSecure: true,
                        showPassword: viewModel.showConfirmPassword,
                        onTogglePassword: {
                            viewModel.showConfirmPassword.toggle()
                        }
                    )
                    .focused($focusedField, equals: .confirmPassword)
                }
                .padding(.horizontal, 20)
                
                // Terms Checkbox
                HStack(alignment: .top, spacing: 12) {
                    Button(action: {
                        viewModel.agreedToTerms.toggle()
                    }) {
                        Image(systemName: viewModel.agreedToTerms ? "checkmark.square.fill" : "square")
                            .font(.system(size: 20))
                            .foregroundColor(viewModel.agreedToTerms ? Color(red: 0.2, green: 0.7, blue: 0.65) : Color(red: 0.7, green: 0.7, blue: 0.7))
                    }
                    
                    Text("By agreeing to the terms and conditions, you are entering into a legally binding contract with the service provider.")
                        .font(.system(size: 13))
                        .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
                        .fixedSize(horizontal: false, vertical: true)
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
                
                // Sign Up Button
                Button(action: {
                    Task {
                        await viewModel.signUp()
                    }
                }) {
                    HStack {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Sign Up")
                                .font(.system(size: 18, weight: .semibold))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .foregroundColor(.white)
                    .background(
                        viewModel.isSignUpValid && !viewModel.isLoading ?
                        LinearGradient(
                            colors: [
                                Color(red: 0.2, green: 0.4, blue: 0.9),
                                Color(red: 0.1, green: 0.3, blue: 0.8)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        ) :
                        LinearGradient(
                            colors: [
                                Color(red: 0.9, green: 0.9, blue: 0.9),
                                Color(red: 0.85, green: 0.85, blue: 0.85)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(14)
                    .shadow(
                        color: viewModel.isSignUpValid && !viewModel.isLoading ? Color.blue.opacity(0.2) : Color.clear,
                        radius: 8,
                        x: 0,
                        y: 4
                    )
                }
                .disabled(!viewModel.isSignUpValid || viewModel.isLoading)
                .padding(.horizontal, 20)
                .padding(.top, 8)
                
                // Terms and Privacy
                Text("By signing up, you agree to our Terms of service and Privacy policy")
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
    SignUpView(viewModel: AuthViewModel())
        .background(Color(red: 0.95, green: 0.95, blue: 0.95))
}

