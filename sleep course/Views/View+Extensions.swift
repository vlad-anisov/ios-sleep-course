import SwiftUI

extension View {
    func appScreenStyle(_ title: String) -> some View {
        scrollContentBackground(.hidden)
            .scrollIndicators(.hidden)
            .listStyle(.plain)
            .navigationLinkIndicatorVisibility(.hidden)
            .padding(.horizontal, 5)
            .background(Color("BackgroundColor"))
            .navigationTitle(title)
    }
    
    func clearListRow() -> some View {
        listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
    }
    
    func blueGlassButton() -> some View {
        foregroundStyle(.white)
        .padding()
        .glassEffect(.clear.tint(.blue).interactive())
    }
}

