import SwiftUI
import SwiftData

struct ArticlesView: View {
    @Query(sort: \Article.id) private var articles: [Article]
    
    let columns = [
        GridItem(.flexible(), spacing: 16)
    ]
    
    var availableArticles: [Article] {
        articles.filter { $0.isAvailable }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(availableArticles) { article in
                        NavigationLink(destination: ArticleDetailView(article: article)) {
                            ArticleCard(article: article)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }
            .background(Color(red: 20/255, green: 30/255, blue: 54/255))
            .navigationTitle("Статьи")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
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
}

struct ArticleCard: View {
    let article: Article
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Gradient background (matching Odoo radial gradient)
            RadialGradient(
                gradient: Gradient(colors: article.gradientColors),
                center: .bottom,
                startRadius: 0,
                endRadius: 200
            )
            .frame(height: 140)
            .cornerRadius(20)
            
            // Glass overlay
            RoundedRectangle(cornerRadius: 20)
                .fill(.clear)
                .frame(height: 140)
                .glassEffect(.regular.tint(.clear).interactive())
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(article.shortName ?? article.name)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                
                if let description = article.articleDescription {
                    Text(description)
                        .font(.system(size: 15))
                        .foregroundColor(.white.opacity(0.95))
                        .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            
            // Emoji icon
            if let emoji = article.emoji {
                Text(emoji)
                    .font(.system(size: 70))
                    .padding(.trailing, 8)
                    .padding(.bottom, 8)
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
            }
        }
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    ArticlesView()
}

