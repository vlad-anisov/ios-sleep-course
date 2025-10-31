import SwiftUI
import SwiftData

struct RitualView: View {
    @Bindable var ritual: Ritual
    @Query private var allLines: [RitualLine]
    @Environment(\.modelContext) private var modelContext
    @State private var mode: EditMode = .inactive
    private var isEditing: Bool { mode.isEditing }
    @State private var showingAddSheet = false
    @State private var isPresentingCreateTask = false
    @State private var createTaskName = ""
    @FocusState private var isCreateTaskFieldFocused: Bool
    private var lines: [RitualLine] {
        ritual.activeLines
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(lines) { line in
                    HStack(spacing: 15) {
                        Button {
                            withAnimation {
                                ritual.toggleCheck(for: line)
                            }
                        } label: {
                            Image(systemName: line.isCheck ? "checkmark" : "circle")
                            .font(line.isCheck ? .system(size: 20, weight: .regular) : .system(size: 30, weight: .ultraLight))
                            .foregroundStyle(line.isCheck ? .white : .blue)
                        }
                        .frame(width: isEditing ? 0 : 30, height: 30)
                        .glassEffect(.identity.interactive())
                        .padding(.horizontal, isEditing ? 11 : 16)
                        .padding(.vertical, 16)
                        .opacity(isEditing ? 0 : 1)
                        Text(line.name)
                        Spacer()
                    }
                    .clearListRow()
                    .background(line.isCheck && !isEditing ? .blue : .clear)
                    .clipShape(.rect(cornerRadius: 31))
                    .glassEffect(line.isCheck && !isEditing ? .clear.interactive() : .identity.interactive(), in: .rect(cornerRadius: 31))
                    .shadow(color: line.isCheck && !isEditing ? .blue : .clear, radius: 40)
                }
                .onMove { from, to in
                    ritual.moveLines(fromOffsets: from, toOffset: to)
                }
                .onDelete {
                    ritual.removeLines(at: $0, in: modelContext)
                }
                if isEditing {
                    Button("Добавить задачу") { showingAddSheet = true }
                        .clearListRow()
                        .blueGlassButton()
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .toolbar {
                EditButton()
            }
            .sheet(isPresented: $showingAddSheet) {
                List(ritual.availableLines(from: allLines)) { line in
                    Button(line.name) {
                        ritual.attachExistingLine(line, in: modelContext)
                        showingAddSheet = false
                    }
                    .listRowBackground(Color("MessageColor"))
                    .foregroundStyle(.white)
                }
                .scrollContentBackground(.hidden)
                .scrollIndicators(.hidden)
                .presentationDetents([.medium])
                Button("Создать свою задачу") {
                    createTaskName = ""
                    isPresentingCreateTask = true
                }
                .blueGlassButton()
                .alert("Новая задача", isPresented: $isPresentingCreateTask) {
                    TextField("Название", text: $createTaskName)
                        .focused($isCreateTaskFieldFocused)
                        .onAppear {
                            isCreateTaskFieldFocused = true
                        }
                    Button(role: .confirm) {
                        _ = ritual.addCustomLine(named: createTaskName, in: modelContext)
                        showingAddSheet = false
                    }
                    Button(role: .close) {}
                }
            }
            .environment(\.editMode, $mode)
            .appScreenStyle("Ритуал")
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
