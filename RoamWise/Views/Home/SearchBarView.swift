//
//  SearchBarView.swift
//  Veou
//
//  Created by Serg Tsogtbaatar on 4/10/25.
//

import SwiftUI

struct SearchBarView: View {
    @Binding var text: String
    @Binding var isActive: Bool
    let onTextChange: (String) -> Void
    let onSubmit: () -> Void
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Search bar
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color.black)
                    .font(.system(size: 16, weight: .medium))
                    .padding(.leading, 12)
                
                TextField("Discover...", text: $text)
                    .font(.system(size: 17))
                    .foregroundColor(Color.black)
                    .tint(Color.green) // Green cursor color
                    .padding(.vertical, 12)
                    .focused($isFocused)
                    .onSubmit(onSubmit)
                    .onChange(of: text) { _, newValue in
                        onTextChange(newValue)
                    }
                    .onChange(of: isFocused) { _, focused in
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isActive = focused
                            if focused {
                                // Trigger lazy loading of popular places when search is first focused
                                onTextChange(text.isEmpty ? "" : text)
                            }
                        }
                    }
                
                if !text.isEmpty {
                    Button(action: clearSearch) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
                            .font(.system(size: 16))
                    }
                    .padding(.trailing, 12)
                    .transition(.opacity)
                }
            }
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
            .frame(maxWidth: isFocused ? nil : .infinity)
            
            // Cancel button - plain text, appears when focused
            if isFocused {
                Button(action: {
                    dismissKeyboard()
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isFocused = false
                        text = ""
                        isActive = false
                    }
                }) {
                    Text("Cancel")
                        .font(.system(size: 17))
                        .foregroundColor(Color.black)
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isFocused)
        .contentShape(Rectangle())
        .onTapGesture {
            if !isFocused {
                isFocused = true
            }
        }
    }
    
    private func clearSearch() {
        text = ""
        onTextChange("")
    }
    
    private func dismissKeyboard() {
        #if os(iOS)
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        #endif
    }
}

#Preview {
    SearchBarView(
        text: .constant(""),
        isActive: .constant(false),
        onTextChange: { _ in },
        onSubmit: { }
    )
    .padding()
} 
