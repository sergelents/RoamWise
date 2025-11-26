//
//  AuthView.swift
//  Veou
//
//  Created on 4/10/25.
//

import SwiftUI

struct AuthView: View {
    @StateObject private var viewModel = AuthViewModel()
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Tab Selector
                HStack(spacing: 0) {
                    // Login Tab
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.authMode = .login
                            viewModel.clearError()
                        }
                    }) {
                        Text("Login")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(viewModel.authMode == .login ? .white : Color(red: 0.2, green: 0.2, blue: 0.2))
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(viewModel.authMode == .login ? Color(red: 0.2, green: 0.2, blue: 0.2) : Color.white)
                            )
                    }
                    
                    // Sign Up Tab
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.authMode = .signUp
                            viewModel.clearError()
                        }
                    }) {
                        Text("Sign Up")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(viewModel.authMode == .signUp ? .white : Color(red: 0.2, green: 0.2, blue: 0.2))
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(viewModel.authMode == .signUp ? Color(red: 0.2, green: 0.2, blue: 0.2) : Color.white)
                            )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 8)
                
                // Content
                Group {
                    if viewModel.authMode == .login {
                        LoginView(viewModel: viewModel)
                            .transition(.opacity.combined(with: .move(edge: .leading)))
                    } else {
                        SignUpView(viewModel: viewModel)
                            .transition(.opacity.combined(with: .move(edge: .trailing)))
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: viewModel.authMode)
            }
        }
    }
}

#Preview {
    AuthView()
}

