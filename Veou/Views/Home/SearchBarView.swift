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
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(isFocused || !text.isEmpty ? .blue : .gray)
                    .padding(.leading, 10)
                
                TextField("Choose your location", text: $text)
                    .padding(.vertical, 12)
                    .focused($isFocused)
                    .onSubmit(onSubmit)
                    .onChange(of: text) { _, newValue in
                        onTextChange(newValue)
                    }
                    .onChange(of: isFocused) { _, focused in
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isActive = focused
                            if focused && text.isEmpty {
                                // Show popular places when search becomes active
                                onTextChange("")
                            }
                        }
                    }
                
                if isFocused || !text.isEmpty {
                    Button(action: clearSearch) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                            .padding(.trailing, 8)
                    }
                    .transition(.opacity)
                }
            }
            .background(.regularMaterial)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isFocused ? Color.blue.opacity(0.5) : Color.gray.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 5)
            
            if isFocused {
                Button("Cancel") {
                    dismissKeyboard()
                    withAnimation {
                        text = ""
                        isActive = false
                    }
                }
                .foregroundColor(.blue)
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isFocused)
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
