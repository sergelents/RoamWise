//
//  CustomTextField.swift
//  Veou
//
//  Created on 4/10/25.
//

import SwiftUI

struct CustomTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var showPassword: Bool = false
    var onTogglePassword: (() -> Void)? = nil
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
                .frame(width: 20)
            
            if isSecure && !showPassword {
                SecureField(placeholder, text: $text)
                    .font(.system(size: 16))
                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                    .textContentType(isSecure ? .password : .none)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            } else {
                TextField(placeholder, text: $text)
                    .font(.system(size: 16))
                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                    .textContentType(isSecure ? .password : .emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            
            if isSecure && onTogglePassword != nil {
                Button(action: {
                    onTogglePassword?()
                }) {
                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(red: 0.9, green: 0.9, blue: 0.9), lineWidth: 1)
        )
    }
}

#Preview {
    VStack(spacing: 16) {
        CustomTextField(
            icon: "envelope",
            placeholder: "Enter your email",
            text: .constant("")
        )
        
        CustomTextField(
            icon: "lock",
            placeholder: "Enter your password",
            text: .constant(""),
            isSecure: true,
            showPassword: false,
            onTogglePassword: {}
        )
    }
    .padding()
    .background(Color(red: 0.95, green: 0.95, blue: 0.95))
}

