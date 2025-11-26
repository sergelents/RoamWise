import SwiftUI

struct TabBarView: View {
    @Binding var selectedTab: Int
    
    // Tab items data
    private let tabs = [
        TabItem(icon: "map.fill", title: "Explore"),
        TabItem(icon: "plus", title: "Add"),
        TabItem(icon: "person.fill", title: "Profile")
    ]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { index in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = index
                    }
                } label: {
                    VStack(spacing: 4) {
                        if selectedTab == index {
                            // Active state: icon with light blue circular background
                            ZStack {
                                Circle()
                                    .fill(Color.blue.opacity(0.15))
                                    .frame(width: 40, height: 40)
                                
                                Image(systemName: tabs[index].icon)
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.blue)
                            }
                        } else {
                            // Inactive state: simple icon
                            Image(systemName: tabs[index].icon)
                                .font(.system(size: 22, weight: .regular))
                                .foregroundColor(.gray)
                        }
                        
                        Text(tabs[index].title)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(selectedTab == index ? .blue : .gray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: -2)
        )
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }
}

struct TabItem {
    let icon: String
    let title: String
}

#Preview {
    ZStack {
        Color.gray.opacity(0.2).ignoresSafeArea()
        
        VStack {
            Spacer()
            TabBarView(selectedTab: .constant(0))
        }
    }
}
