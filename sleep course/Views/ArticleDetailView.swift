import SwiftUI

struct ArticleDetailView: View {
    let article: Article
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header with gradient
                ZStack(alignment: .bottomLeading) {
                    RadialGradient(
                        gradient: Gradient(colors: article.gradientColors),
                        center: .bottom,
                        startRadius: 0,
                        endRadius: 300
                    )
                    .frame(height: 200)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            if let emoji = article.emoji {
                                Text(emoji)
                                    .font(.system(size: 60))
                            }
                            
                            Text(article.name)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding()
                        
                        Spacer()
                    }
                }
                
                // HTML Content
                HTMLContentView(htmlContent: article.text)
                    .padding(.horizontal)
            }
        }
        .background(Color(red: 20/255, green: 30/255, blue: 54/255))
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(article.name)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(Color(red: 0/255, green: 120/255, blue: 255/255))
                }
            }
        }
        .onAppear {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
            
            let navigationBar = UINavigationBar.appearance()
            navigationBar.standardAppearance = appearance
            navigationBar.scrollEdgeAppearance = appearance
            navigationBar.compactAppearance = appearance
        }
    }
}

struct HTMLContentView: View {
    let htmlContent: String
    @State private var attributedString: AttributedString = AttributedString()
    
    var body: some View {
        Text(attributedString)
            .font(.system(size: 17))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .onAppear {
                Task {
                    if let data = htmlContent.data(using: .utf8) {
                        do {
                            let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
                                .documentType: NSAttributedString.DocumentType.html,
                                .characterEncoding: String.Encoding.utf8.rawValue
                            ]
                            let nsAttributedString = try NSAttributedString(data: data, options: options, documentAttributes: nil)
                            
                            // Convert to SwiftUI AttributedString
                            var swiftAttributedString = AttributedString(nsAttributedString)
                            
                            // Apply white color to all text
                            swiftAttributedString.foregroundColor = .white
                            
                            attributedString = swiftAttributedString
                        } catch {
                            // Fallback to plain text if HTML parsing fails
                            attributedString = AttributedString(htmlContent.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression))
                        }
                    }
                }
            }
    }
}

#Preview {
    ArticleDetailView(article: Article.mockArticles[0])
}

