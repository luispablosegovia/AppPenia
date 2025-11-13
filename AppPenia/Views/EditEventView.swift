//
//  EditEventView.swift
//  AppPenia
//
//  Created by Pablo Segovia on 13/11/2025.
//

import SwiftUI
import SwiftData

struct EditEventView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \User.name) private var allUsers: [User]
    let event: Event
    @Binding var isPresented: Bool

    @State private var selectedDate: Date
    @State private var notes: String
    @State private var selectedHostId: UUID?
    @State private var selectedCookId: UUID?
    @State private var selectedDishwasherId: UUID?

    private var usersWithSede: [User] {
        allUsers.filter { $0.hasSede }
    }

    private var canSave: Bool {
        selectedHostId != nil && selectedCookId != nil && selectedDishwasherId != nil
    }

    init(event: Event, isPresented: Binding<Bool>) {
        self.event = event
        self._isPresented = isPresented

        // Initialize state from event
        _selectedDate = State(initialValue: event.date)
        _notes = State(initialValue: event.notes)
        _selectedHostId = State(initialValue: event.host?.id)
        _selectedCookId = State(initialValue: event.cook?.id)
        _selectedDishwasherId = State(initialValue: event.dishwasher?.id)
    }

    var body: some View {
        ZStack {
            GlassBackground()

            NavigationStack {
                Form {
                    Section("Fecha de la Juntada") {
                        DatePicker("Fecha", selection: $selectedDate, displayedComponents: .date)
                    }

                    Section("Sede") {
                        if usersWithSede.isEmpty {
                            Text("No hay miembros con sede registrada")
                                .foregroundColor(.secondary)
                                .italic()
                        } else {
                            Picker("Seleccionar sede", selection: $selectedHostId) {
                                Text("Seleccionar...").tag(nil as UUID?)
                                ForEach(usersWithSede) { user in
                                    Text(user.name).tag(user.id as UUID?)
                                }
                            }
                        }
                    }

                    Section("Quién cocina") {
                        if allUsers.isEmpty {
                            Text("No hay miembros registrados")
                                .foregroundColor(.secondary)
                                .italic()
                        } else {
                            Picker("Seleccionar cocinero", selection: $selectedCookId) {
                                Text("Seleccionar...").tag(nil as UUID?)
                                ForEach(allUsers) { user in
                                    Text(user.name).tag(user.id as UUID?)
                                }
                            }
                        }
                    }

                    Section("Quién lava") {
                        if allUsers.isEmpty {
                            Text("No hay miembros registrados")
                                .foregroundColor(.secondary)
                                .italic()
                        } else {
                            Picker("Seleccionar lavador", selection: $selectedDishwasherId) {
                                Text("Seleccionar...").tag(nil as UUID?)
                                ForEach(allUsers) { user in
                                    Text(user.name).tag(user.id as UUID?)
                                }
                            }
                        }
                    }

                    Section("Notas (Opcional)") {
                        TextField("Notas", text: $notes, axis: .vertical)
                            .lineLimit(3...6)
                    }
                }
                .glassForm()
                .scrollContentBackground(.hidden)
                .navigationTitle("Editar Juntada")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: { isPresented = false }) {
                            Image(systemName: "chevron.left")
                                .font(.body)
                                .fontWeight(.semibold)
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Guardar") {
                            saveChanges()
                        }
                        .disabled(!canSave)
                        .buttonStyle(GlassButtonStyle())
                    }
                }
            }
        }
    }

    private func saveChanges() {
        guard let hostId = selectedHostId,
              let cookId = selectedCookId,
              let dishwasherId = selectedDishwasherId else { return }

        guard let host = allUsers.first(where: { $0.id == hostId }),
              let cook = allUsers.first(where: { $0.id == cookId }),
              let dishwasher = allUsers.first(where: { $0.id == dishwasherId }) else { return }

        event.date = selectedDate
        event.notes = notes
        event.host = host
        event.cook = cook
        event.dishwasher = dishwasher

        isPresented = false
    }
}

#Preview {
    EditEventView(event: Event(date: Date(), notes: "Juntada de prueba"), isPresented: .constant(true))
        .modelContainer(for: [Event.self, User.self, Attendance.self])
}
