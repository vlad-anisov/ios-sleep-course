import SwiftUI
import SwiftData

struct RitualView: View {
    @Query private var rituals: [Ritual]
    @Environment(\.modelContext) private var modelContext
    
    @State private var isEditMode = false
    @State private var showAddTaskSheet = false
    
    var ritual: Ritual? {
        rituals.first
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if let ritual = ritual {
                    if ritual.isCheck && !isEditMode {
                        // Done state
                        VStack(spacing: 16) {
                            Spacer()
                            Text("✨ Ритуал завершен ✨")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                            
                            Button(action: {
                                resetRitual()
                            }) {
                                Text("Сбросить")
                                    .font(.body)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 30)
                                    .padding(.vertical, 12)
                                    .background(Color(red: 0/255, green: 120/255, blue: 255/255))
                                    .cornerRadius(20)
                                    .glassEffect(.clear.interactive())
                            }
                            .padding(.top, 20)
                            
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(red: 20/255, green: 30/255, blue: 54/255))
                    } else {
                        // Active ritual list
                        VStack(spacing: 0) {
                            if isEditMode {
                                List {
                                    ForEach(ritual.activeLines) { line in
                                        RitualLineEditRow(
                                            line: line,
                                            onDelete: { deleteLine(line) }
                                        )
                                        .listRowBackground(Color.clear)
                                        .listRowInsets(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                                    }
                                    .onMove(perform: moveLines)
                                    .onDelete(perform: { indexSet in
                                        indexSet.forEach { index in
                                            deleteLine(ritual.activeLines[index])
                                        }
                                    })
                                }
                                .listStyle(.plain)
                                .scrollContentBackground(.hidden)
                                .environment(\.editMode, .constant(.active))
                            } else {
                                ScrollView {
                                    VStack(spacing: 20) {
                                        ForEach(ritual.activeLines) { line in
                                            RitualLineRow(line: line, onToggle: {
                                                toggleLine(line)
                                            })
                                        }
                                    }
                                    .padding(20)
                                }
                            }
                            
                            // Кнопка добавить задачу (только в режиме редактирования)
                            if isEditMode {
                                Button(action: {
                                    showAddTaskSheet = true
                                }) {
                                    HStack {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.system(size: 20))
                                        Text("Добавить задачу")
                                            .font(.system(size: 17, weight: .medium))
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Color(red: 0/255, green: 120/255, blue: 255/255))
                                    .cornerRadius(12)
                                    .glassEffect(.regular.interactive())
                                }
                                .padding(.horizontal, 20)
                                .padding(.bottom, 20)
                            }
                        }
                    }
                } else {
                    VStack {
                        Text("Загрузка ритуала...")
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(red: 20/255, green: 30/255, blue: 54/255))
                }
            }
            .background(Color(red: 20/255, green: 30/255, blue: 54/255))
            .navigationTitle("Ритуал")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditMode ? "Готово" : "Редактировать") {
                        withAnimation {
                            isEditMode.toggle()
                        }
                    }
                    .foregroundColor(.white)
                }
            }
            .sheet(isPresented: $showAddTaskSheet) {
                if let ritual = ritual {
                    AddTaskSheet(ritual: ritual, modelContext: modelContext)
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
    
    private func toggleLine(_ line: RitualLine) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
            line.isCheck.toggle()
        }
        
        do {
            try modelContext.save()
        } catch {
            print("Failed to save ritual line: \(error)")
        }
    }
    
    private func resetRitual() {
        guard let ritual = ritual else { return }
        
        withAnimation {
            ritual.activeLines.forEach { line in
                line.isCheck = false
            }
        }
        
        do {
            try modelContext.save()
        } catch {
            print("Failed to reset ritual: \(error)")
        }
    }
    
    private func deleteLine(_ line: RitualLine) {
        guard ritual != nil else { return }
        
        withAnimation {
            if line.isBase {
                // Базовую задачу просто скрываем
                line.isActive = false
            } else {
                // Кастомную задачу удаляем навсегда
                modelContext.delete(line)
            }
        }
        
        do {
            try modelContext.save()
        } catch {
            print("Failed to delete line: \(error)")
        }
    }
    
    private func moveLines(from source: IndexSet, to destination: Int) {
        guard let ritual = ritual else { return }
        
        var activeLines = ritual.activeLines
        activeLines.move(fromOffsets: source, toOffset: destination)
        
        // Обновляем sequence для всех элементов
        for (index, line) in activeLines.enumerated() {
            line.sequence = index
        }
        
        do {
            try modelContext.save()
        } catch {
            print("Failed to move lines: \(error)")
        }
    }
}

struct AnimatedCheckmark: View {
    let isChecked: Bool
    @State private var trimEnd: CGFloat = 0
    
    var body: some View {
        CheckmarkShape()
            .trim(from: 0, to: trimEnd)
            .stroke(Color.white, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
            .onAppear {
                withAnimation(.easeInOut(duration: 0.4)) {
                    trimEnd = 1
                }
            }
            .onChange(of: isChecked) { oldValue, newValue in
                if newValue {
                    trimEnd = 0
                    withAnimation(.easeInOut(duration: 0.4)) {
                        trimEnd = 1
                    }
                }
            }
    }
}

struct CheckmarkShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Начало галочки (левая нижняя точка)
        let startPoint = CGPoint(x: rect.minX, y: rect.midY)
        
        // Средняя точка (угол галочки)
        let middlePoint = CGPoint(x: rect.width * 0.4, y: rect.maxY)
        
        // Конечная точка (правая верхняя)
        let endPoint = CGPoint(x: rect.maxX, y: rect.minY)
        
        path.move(to: startPoint)
        path.addLine(to: middlePoint)
        path.addLine(to: endPoint)
        
        return path
    }
}

struct RitualLineRow: View {
    let line: RitualLine
    let onToggle: () -> Void
    
    private let customBlue = Color(red: 0/255, green: 120/255, blue: 255/255)
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                if line.isCheck {
                    Circle()
                        .fill(.clear)
                        .frame(width: 40, height: 40)
                    AnimatedCheckmark(isChecked: line.isCheck)
                        .frame(width: 20, height: 20)
                } else {
                    Circle()
                        .glassEffect(.clear.tint(Color(red: 0/255, green: 30/255, blue: 75/255)).interactive())
                    .frame(width: 40, height: 40)
                        
                }
            }
            
            Text(line.name)
                .font(.system(size: 17))
                .foregroundColor(.white)
            
            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 9)
        .background(
            Group {
                if line.isCheck {
                    Capsule().glassEffect(.regular.tint(customBlue).interactive())
                } else {
                    Color.clear
                }
            }
        )
        .shadow(
            color: line.isCheck ? customBlue.opacity(1.0) : Color.clear,
            radius: line.isCheck ? 40 : 0,
            x: 0,
            y: 0
        )
        .contentShape(Rectangle())
        .onTapGesture {
            onToggle()
        }
    }
}

// Строка ритуала в режиме редактирования
struct RitualLineEditRow: View {
    let line: RitualLine
    let onDelete: () -> Void
    
    private let customBlue = Color(red: 0/255, green: 120/255, blue: 255/255)
    
    var body: some View {
        HStack(spacing: 12) {
            // Название задачи
            HStack {
                if !line.isBase {
                    Image(systemName: "pencil")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.5))
                }
                
                Text(line.name)
                    .font(.system(size: 17))
                    .foregroundColor(.white)
                
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(Color.white.opacity(0.1))
            )
            
            // Кнопка удаления
            Button(action: onDelete) {
                Image(systemName: line.isBase ? "minus.circle.fill" : "trash.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.red)
                    .frame(width: 40, height: 40)
            }
        }
    }
}

// Sheet для добавления задач
struct AddTaskSheet: View {
    let ritual: Ritual
    let modelContext: ModelContext
    
    @Environment(\.dismiss) private var dismiss
    @State private var showCreateCustomTask = false
    @State private var customTaskName = ""
    
    private let customBlue = Color(red: 0/255, green: 120/255, blue: 255/255)
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if showCreateCustomTask {
                    // Форма создания кастомной задачи
                    VStack(spacing: 20) {
                        Text("Создать свою задачу")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.top, 30)
                        
                        TextField("Название задачи", text: $customTaskName)
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                        
                        HStack(spacing: 12) {
                            Button("Отмена") {
                                showCreateCustomTask = false
                                customTaskName = ""
                            }
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(12)
                            
                            Button("Создать") {
                                createCustomTask()
                            }
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(customBlue)
                            .cornerRadius(12)
                            .glassEffect(.regular.interactive())
                            .disabled(customTaskName.trimmingCharacters(in: .whitespaces).isEmpty)
                            .opacity(customTaskName.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1)
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(red: 20/255, green: 30/255, blue: 54/255))
                } else {
                    // Список удаленных задач и кнопка создания
                    VStack(spacing: 0) {
                        // Кнопка создать свою задачу
                        Button(action: {
                            showCreateCustomTask = true
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 20))
                                Text("Создать свою задачу")
                                    .font(.system(size: 17, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(customBlue)
                            .cornerRadius(12)
                            .glassEffect(.regular.interactive())
                        }
                        .padding(20)
                        
                        // Список удаленных базовых задач
                        if !ritual.inactiveBaseLines.isEmpty {
                            Text("Восстановить задачи")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white.opacity(0.7))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 20)
                                .padding(.bottom, 10)
                            
                            ScrollView {
                                VStack(spacing: 12) {
                                    ForEach(ritual.inactiveBaseLines) { line in
                                        Button(action: {
                                            restoreLine(line)
                                        }) {
                                            HStack {
                                                Text(line.name)
                                                    .font(.system(size: 17))
                                                    .foregroundColor(.white)
                                                
                                                Spacer()
                                                
                                                Image(systemName: "plus.circle")
                                                    .font(.system(size: 20))
                                                    .foregroundColor(customBlue)
                                            }
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 12)
                                            .background(
                                                Capsule()
                                                    .fill(Color.white.opacity(0.1))
                                            )
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        } else {
                            VStack(spacing: 12) {
                                Spacer()
                                Text("Все базовые задачи уже добавлены")
                                    .font(.system(size: 17))
                                    .foregroundColor(.white.opacity(0.5))
                                Spacer()
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(red: 20/255, green: 30/255, blue: 54/255))
                }
            }
            .navigationTitle("Добавить задачу")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрыть") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
    
    private func createCustomTask() {
        let trimmedName = customTaskName.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }
        
        // Находим максимальный sequence среди всех линий
        let maxSequence = ritual.lines.map { $0.sequence }.max() ?? 0
        
        // Создаем новую кастомную задачу с уникальным id
        let maxId = ritual.lines.map { $0.id }.max() ?? 0
        let newLine = RitualLine(
            id: maxId + 1,
            name: trimmedName,
            sequence: maxSequence + 1,
            isCheck: false,
            isBase: false,
            isActive: true,
            ritual: ritual
        )
        
        ritual.lines.append(newLine)
        modelContext.insert(newLine)
        
        do {
            try modelContext.save()
            customTaskName = ""
            showCreateCustomTask = false
            dismiss()
        } catch {
            print("Failed to create custom task: \(error)")
        }
    }
    
    private func restoreLine(_ line: RitualLine) {
        line.isActive = true
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Failed to restore line: \(error)")
        }
    }
}

#Preview {
    RitualView()
}

