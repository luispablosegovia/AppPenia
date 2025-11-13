//
//  EventsListView.swift
//  AppPenia
//
//  Created by Pablo Segovia on 13/11/2025.
//

import SwiftUI
import SwiftData

struct EventsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Event.date, order: .reverse) private var events: [Event]
    @State private var showingAddEvent = false
    @State private var newEventDate = Date()
    @State private var newEventNotes = ""
    @State private var showingDeleteAlert = false
    @State private var eventToDelete: Event?

    var body: some View {
        NavigationStack {
            List {
                ForEach(events) { event in
                    NavigationLink(destination: EventDetailView(event: event)) {
                        EventRow(event: event)
                    }
                    .buttonStyle(.plain)
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            eventToDelete = event
                            showingDeleteAlert = true
                        } label: {
                            Label("Eliminar", systemImage: "trash")
                        }
                    }
                }
            }
            .glassListBackground()
            .navigationTitle("Peña de los Miércoles")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddEvent = true }) {
                        Image(systemName: "plus")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                    .buttonStyle(GlassButtonStyle())
                }
            }
            .alert("Eliminar Juntada", isPresented: $showingDeleteAlert, presenting: eventToDelete) { event in
                Button("Cancelar", role: .cancel) {
                    eventToDelete = nil
                }
                Button("Eliminar", role: .destructive) {
                    deleteEvent(event)
                }
            } message: { event in
                Text("¿Estás seguro de que quieres eliminar la juntada del \(event.formattedDate)? Esta acción no se puede deshacer.")
            }
            .sheet(isPresented: $showingAddEvent) {
                AddEventView(isPresented: $showingAddEvent)
            }
            .overlay {
                if events.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "calendar.badge.plus")
                            .font(.system(size: 60))
                            .foregroundStyle(.secondary)
                        Text("No hay juntadas")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text("Toca + para crear la primera juntada")
                            .foregroundStyle(.secondary)
                    }
                    .padding(40)
                    .glassCard()
                }
            }
        }
    }

    private func deleteEvent(_ event: Event) {
        modelContext.delete(event)
        eventToDelete = nil
    }
}

struct EventRow: View {
    let event: Event

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(event.formattedDate)
                .font(.headline)
            Text("\(event.attendeeCount) asistentes")
                .font(.subheadline)
                .foregroundColor(.secondary)
            if let host = event.host {
                Text("🏠 Sede: \(host.name)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            if !event.notes.isEmpty {
                Text(event.notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 4)
    }
}

struct AddEventView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \User.name) private var allUsers: [User]
    @Binding var isPresented: Bool
    @State private var selectedDate = Date()
    @State private var notes = ""
    @State private var selectedHostId: UUID?
    @State private var selectedCookId: UUID?
    @State private var selectedDishwasherId: UUID?

    private var usersWithSede: [User] {
        allUsers.filter { $0.hasSede }
    }

    private var canSave: Bool {
        selectedHostId != nil && selectedCookId != nil && selectedDishwasherId != nil
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
                .navigationTitle("Nueva Juntada")
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
                            saveEvent()
                        }
                        .disabled(!canSave)
                        .buttonStyle(GlassButtonStyle())
                    }
                }
            }
        }
    }

    private func saveEvent() {
        guard let hostId = selectedHostId,
              let cookId = selectedCookId,
              let dishwasherId = selectedDishwasherId else { return }

        guard let host = allUsers.first(where: { $0.id == hostId }),
              let cook = allUsers.first(where: { $0.id == cookId }),
              let dishwasher = allUsers.first(where: { $0.id == dishwasherId }) else { return }

        let newEvent = Event(date: selectedDate, notes: notes, host: host, cook: cook, dishwasher: dishwasher)
        modelContext.insert(newEvent)
        isPresented = false
    }
}

#Preview {
    EventsListView()
        .modelContainer(for: [Event.self, User.self, Attendance.self])
}
