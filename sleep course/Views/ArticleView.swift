import SwiftUI

struct ArticleView: View {
    let article: Article
    
    var body: some View {
        Form {
            Text(article.text).listRowBackground(Color.clear)
        }
        .appScreenStyle(title: article.name)
    }
}
