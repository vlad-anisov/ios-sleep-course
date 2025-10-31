import SwiftUI

extension View {
    func appScreenStyle(title: String) -> some View {
        scrollContentBackground(.hidden)
            .scrollIndicators(.hidden)
            .background(Color("BackgroundColor"))
            .navigationTitle(title)
    }
}

