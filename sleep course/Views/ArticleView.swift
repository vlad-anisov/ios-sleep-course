import SwiftUI

struct ArticleView: View {
    let article: Article
    
    var body: some View {
        Form {
            Text(article.text).listRowBackground(Color.clear)
        }
        .scrollContentBackground(.hidden)
        .background(Color(red: 20/255, green: 30/255, blue: 54/255))
        .navigationTitle(article.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
