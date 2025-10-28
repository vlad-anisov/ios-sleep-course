import SwiftUI
import SwiftData

struct ArticlesView: View {
    @Query(filter: #Predicate<Article> { $0.isAvailable }, sort: \Article.id) private var articles: [Article]

//    var body: some View {
//        NavigationStack {
//            List(articles) { article in
//                NavigationLink(destination: ArticleView(article: article)) {
//                    HStack(spacing: 0) {
//                        VStack(alignment: .leading, spacing: 4) {
//                            Text(article.shortName ?? "").font(.title3).bold()
//                            Text(article.articleDescription ?? "").font(.callout)
//                        }
//                        Spacer()
//                        Text(article.emoji ?? "").font(.system(size: 70))
//                    }
//                    .padding()
//                }
//                .background(RadialGradient(colors: article.gradientColors, center: .bottom, startRadius: 0, endRadius: 200))
//                .clipShape(.rect(cornerRadius: 35))
//                .glassEffect(.clear.interactive(), in: .rect(cornerRadius: 35))
//                .listRowBackground(Color.clear)
//                .listRowSeparator(.hidden)
//            }
//            .listStyle(.plain)
//            .scrollIndicators(.hidden)
//            .navigationLinkIndicatorVisibility(.hidden)
//            .background(Color("BackgroundColor"))
//            .navigationTitle("Статьи")
//        }
//    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                ForEach(articles) { article in
                    NavigationLink(destination: ArticleView(article: article)) {
                        HStack(spacing: 0) {
                            VStack(alignment: .leading) {
                                Text(article.shortName ?? "").font(.title3).bold()
                                Text(article.articleDescription ?? "")
                                    .font(.callout)
                                    .multilineTextAlignment(.leading)
                            }
                            Spacer()
                            Text(article.emoji ?? "").font(.system(size: 70))
                        }
                        .padding()
                        .foregroundStyle(.white)
                    }
                    .background(RadialGradient(colors: article.gradientColors, center: .bottom, startRadius: 0, endRadius: 200))
                    .clipShape(.rect(cornerRadius: 35))
                    .glassEffect(.clear.interactive(), in: .rect(cornerRadius: 35))
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                }
            }
            .background(Color("BackgroundColor"))
            .navigationTitle("Статьи")
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Article.self, configurations: config)
    
    // Добавляем моковые статьи в контейнер
    for article in Article.mockArticles {
        container.mainContext.insert(article)
    }
    
    return ArticlesView()
        .modelContainer(container)
}
