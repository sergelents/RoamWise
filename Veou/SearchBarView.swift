import SwiftUI

struct SearchBarView: View {
    @Binding var searchText: String
    @Binding var isSearching: Bool
    var onSearch: () -> Void
    
    @FocusState private var isFocused: Bool
    @State private var isEditing = false
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(isFocused || !searchText.isEmpty ? .blue : .gray)
                    .padding(.leading, 10)
                
                TextField("Where do you want to stream?", text: $searchText)
                    .padding(.vertical, 12)
                    .focused($isFocused)
                    .onChange(of: isFocused) { _, newValue in
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isEditing = newValue
                            if newValue {
                                isSearching = true
                            }
                        }
                    }
                    .onSubmit {
                        onSearch()
                    }
                
                if isEditing || !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                        onSearch()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                            .padding(.trailing, 8)
                    }
                    .transition(.opacity)
                }
            }
            .padding(.horizontal, 4)
            .background(Color(.systemBackground))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isFocused ? Color.blue.opacity(0.5) : Color.gray.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 5)
            
            if isEditing {
                Button("Cancel") {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    withAnimation {
                        searchText = ""
                        isEditing = false
                        isSearching = false
                    }
                }
                .foregroundColor(.blue)
                .padding(.trailing, 8)
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .padding(.vertical, 8)
        .animation(.easeInOut(duration: 0.2), value: isEditing)
        .animation(.easeInOut(duration: 0.2), value: searchText)
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.2).ignoresSafeArea()
        
        SearchBarView(
            searchText: .constant(""),
            isSearching: .constant(false),
            onSearch: {}
        )
        .padding(.horizontal)
    }
} 