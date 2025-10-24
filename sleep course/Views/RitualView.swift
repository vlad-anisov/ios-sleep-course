import SwiftUI
import SwiftData

struct RitualView: View {
    @Bindable var ritual: Ritual
    @Query private var allLines: [RitualLine]
    @Environment(\.modelContext) private var modelContext
    @State private var isEditing = false
    @State private var showingAddSheet = false
    @State private var newTask = ""
    
    private var lines: [RitualLine] {
        ritual.lines.sorted { $0.sequence < $1.sequence }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(lines) { line in
                    HStack(spacing: 10) {
                        if !isEditing {
                            Button(action: {
                                line.isCheck.toggle()
                                try? modelContext.save()
                            }) {
                                Circle()
                                                        .glassEffect(.clear.tint(Color(red: 0/255, green: 30/255, blue: 75/255)).interactive())
                                                    .frame(width: 40, height: 40)
//                                Image(systemName: line.isCheck ? "checkmark.circle.fill" : "circle")
//                                    .foregroundColor(line.isCheck ? .green : .gray)
//                                    .font(.system(size: 24))
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        Text(line.name)
                            .strikethrough(line.isCheck && !isEditing, color: .gray)
                            .foregroundColor(line.isCheck && !isEditing ? .gray : .primary)
                        Spacer()
                    }
                    .padding()
                }
                .onMove { from, to in
                    var ordered = lines
                    ordered.move(fromOffsets: from, toOffset: to)
                    ordered.enumerated().forEach { $1.sequence = $0 }
                }
                .onDelete {
                    lines[$0.first!].ritual = nil
                }
//                .clipShape(.rect(cornerRadius: 35))
                .glassEffect(.clear.interactive())
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                
                if isEditing {
                    Button("Добавить задачу") {
                        showingAddSheet = true
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
//            .background(Color.appBackground)
            .navigationTitle("Ритуал")
            .scrollIndicators(.hidden)
            .toolbar {
                Button(isEditing ? "Готово" : "Править") {
                    isEditing.toggle()
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
