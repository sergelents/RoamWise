import SwiftUI

struct TabBarView: View {
    @Binding var selectedTab: Int
    
    // Tab items data
    private let tabs = [
        TabItem(icon: "house.fill", title: "Home"),
        TabItem(icon: "magnifyingglass", title: "Search"),
        TabItem(icon: "person.fill", title: "Profile"),
        TabItem(icon: "bell.fill", title: "Notifications"),
        TabItem(icon: "gear", title: "Settings")
    ]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { index in
                Button {
                    withAnimation(.easeInOut) {
                        selectedTab = index
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tabs[index].icon)
                            .font(.system(size: selectedTab == index ? 22 : 20))
                            .foregroundColor(selectedTab == index ? .blue : .gray)
                        
                        Text(tabs[index].title)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(selectedTab == index ? .blue : .gray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: -5)
        )
        .padding(.horizontal)
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
