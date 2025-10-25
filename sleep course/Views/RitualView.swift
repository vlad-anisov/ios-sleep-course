import SwiftUI
import SwiftData

struct RitualView: View {
    @Bindable var ritual: Ritual
    @Query private var allLines: [RitualLine]
    @Environment(\.modelContext) private var modelContext
    @State private var isEditing = false
    @State private var showingAddSheet = false
    @State private var newTask = ""
    private let customBlue = Color(red: 0/255, green: 120/255, blue: 255/255)
    
    private var lines: [RitualLine] {
        ritual.lines.sorted { $0.sequence < $1.sequence }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(lines) { line in
                    HStack(spacing: 15) {
                        if !isEditing {
                            Button {
                                withAnimation{
                                    line.isCheck.toggle()
                                }
                            } label: {
                                Image(systemName: line.isCheck ? "checkmark" : "circle")
                                    .font(.system(size: line.isCheck ? 25 : 40, weight: line.isCheck ? .regular : .ultraLight))
                                    .foregroundStyle(line.isCheck ? Color.primary : Color.blue)
                            }
                            .frame(width: 40, height: 40)
                            .glassEffect(.identity.interactive())
                            .transition(.opacity.combined(with: .scale))
                        }
                        
                        Text(line.name)
                        
                        Spacer()
                    }
                    .padding()
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .background(line.isCheck && !isEditing ? .blue: .clear)
                    .clipShape(.rect(cornerRadius: 35))
                    .shadow(color: line.isCheck && !isEditing ? .blue : .clear, radius: 40, x: 0, y: 0)
                    .glassEffect(line.isCheck && !isEditing ? .clear.interactive() : .identity.interactive())
                }
                .onMove { from, to in
                    var ordered = lines
                    ordered.move(fromOffsets: from, toOffset: to)
                    ordered.enumerated().forEach { $1.sequence = $0 }
                }
                .onDelete {
                    lines[$0.first!].ritual = nil
                }
                
                if isEditing {
                    Button("Добавить задачу") {
                        showingAddSheet = true
                    }
                }
            }
            .listStyle(.plain)
//            .scrollContentBackground(.hidden)
            .background(Color("BackgroundColor"))
            .navigationTitle("Ритуал")
            .scrollIndicators(.hidden)
            .toolbar {
                Button(isEditing ? "Готово" : "Править") {
                    withAnimation{
                        isEditing.toggle()
                    }
                }
            }
            .environment(\.editMode, .constant(isEditing ? .active : .inactive))
            .sheet(isPresented: $showingAddSheet) {
                List {
                    ForEach(allLines.filter{ $0.ritual?.id != ritual.id }){ line in
                        Button(line.name) {
                            line.ritual = ritual
                            showingAddSheet = false
                        }
                    }
                    
                    TextField("Новая задача", text: $newTask)
                        .onSubmit {
                            RitualLine(
                                name: newTask,
                                ritual: ritual,
                            )
                            newTask = ""
                            showingAddSheet = false
                        }
                }
                .presentationDetents([.medium, .large])
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Ritual.self, RitualLine.self, configurations: config)
    
    // Создаем тестовый ритуал
    let ritual = Ritual(id: 1, name: "Вечерний ритуал", userId: 1, sequence: 0)
    container.mainContext.insert(ritual)
    
    // Создаем линии для ритуала
    let line1 = RitualLine(id: 1, name: "Медитация 🧘", sequence: 0, isCheck: false, isBase: true, ritual: ritual)
    let line2 = RitualLine(id: 2, name: "Скушать киви 🥝", sequence: 1, isCheck: false, isBase: true, ritual: ritual)
    let line3 = RitualLine(id: 3, name: "Проветрить комнату 💨", sequence: 2, isCheck: false, isBase: true, ritual: ritual)
    
    container.mainContext.insert(line1)
    container.mainContext.insert(line2)
    container.mainContext.insert(line3)
    
    // Создаем доступные линии (не в ритуале)
    let availableLine1 = RitualLine(id: 4, name: "Тёплая ванна 🛁", sequence: 0, isCheck: false, isBase: true)
    let availableLine2 = RitualLine(id: 5, name: "Надеть носки 🧦", sequence: 1, isCheck: false, isBase: true)
    
    container.mainContext.insert(availableLine1)
    container.mainContext.insert(availableLine2)
    
    return RitualView(ritual: ritual)
        .modelContainer(container)
}
