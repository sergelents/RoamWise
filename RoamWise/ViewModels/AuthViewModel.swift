//
//  AuthViewModel.swift
//  Veou
//
//  Created on 4/10/25.
//

import Foundation
import SwiftUI

enum AuthMode {
    case login
    case signUp
}

@MainActor
class AuthViewModel: ObservableObject {
    @Published var authMode: AuthMode = .login
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Login fields
    @Published var loginEmail = ""
    @Published var loginPassword = ""
    
    // Sign up fields
    @Published var signUpName = ""
    @Published var signUpEmail = ""
    @Published var signUpPassword = ""
    @Published var confirmPassword = ""
    @Published var agreedToTerms = false
    
    // Password visibility
    @Published var showLoginPassword = false
    @Published var showSignUpPassword = false
    @Published var showConfirmPassword = false
    
    // Validation
    var isLoginValid: Bool {
        !loginEmail.isEmpty && !loginPassword.isEmpty && isValidEmail(loginEmail)
    }
    
    var isSignUpValid: Bool {
        !signUpName.isEmpty &&
        !signUpEmail.isEmpty &&
        isValidEmail(signUpEmail) &&
        !signUpPassword.isEmpty &&
        signUpPassword.count >= 8 &&
        signUpPassword == confirmPassword &&
        agreedToTerms
    }
    
    @AppStorage("isAuthenticated") var isAuthenticated = false
    @AppStorage("userName") var userName = ""
    
    // MARK: - Email Validation
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    // MARK: - Login
    func login() async {
        guard isLoginValid else {
            errorMessage = "Please enter a valid email and password"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        // Simulate API call
        do {
            try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
            
            // Mock authentication - in production, replace with actual API call
            if loginPassword.count >= 8 {
                isAuthenticated = true
                userName = loginEmail.components(separatedBy: "@").first ?? "User"
                errorMessage = nil
            } else {
                errorMessage = "Invalid email or password"
            }
        } catch {
            errorMessage = "An error occurred. Please try again."
        }
        
        isLoading = false
    }
    
    // MARK: - Sign Up
    func signUp() async {
        guard isSignUpValid else {
            if signUpPassword != confirmPassword {
                errorMessage = "Passwords do not match"
            } else if signUpPassword.count < 8 {
                errorMessage = "Password must be at least 8 characters"
            } else if !agreedToTerms {
                errorMessage = "Please agree to the terms and conditions"
            } else {
                errorMessage = "Please fill in all fields correctly"
            }
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        // Simulate API call
        do {
            try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
            
            // Mock authentication - in production, replace with actual API call
            isAuthenticated = true
            userName = signUpName
            errorMessage = nil
        } catch {
            errorMessage = "An error occurred. Please try again."
        }
        
        isLoading = false
    }
    
    // MARK: - Social Login
    func loginWithApple() async {
        isLoading = true
        errorMessage = nil
        
        // Simulate Apple Sign In
        do {
            try await Task.sleep(nanoseconds: 1_500_000_000)
            isAuthenticated = true
            userName = "Apple User"
            errorMessage = nil
        } catch {
            errorMessage = "Apple Sign In failed. Please try again."
        }
        
        isLoading = false
    }
    
    func loginWithGoogle() async {
        isLoading = true
        errorMessage = nil
        
        // Simulate Google Sign In
        do {
            try await Task.sleep(nanoseconds: 1_500_000_000)
            isAuthenticated = true
            userName = "Google User"
            errorMessage = nil
        } catch {
            errorMessage = "Google Sign In failed. Please try again."
        }
        
        isLoading = false
    }
    
    // MARK: - Reset Password
    func resetPassword() async {
        guard isValidEmail(loginEmail) else {
            errorMessage = "Please enter a valid email address"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        // Simulate password reset
        do {
            try await Task.sleep(nanoseconds: 1_000_000_000)
            errorMessage = "Password reset link sent to your email"
        } catch {
            errorMessage = "Failed to send reset link. Please try again."
        }
        
        isLoading = false
    }
    
    // MARK: - Clear Error
    func clearError() {
        errorMessage = nil
    }
    
    // MARK: - Switch Mode
    func switchMode() {
        authMode = authMode == .login ? .signUp : .login
        clearError()
    }
}

