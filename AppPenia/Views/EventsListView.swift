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

    var body: some View {
        NavigationStack {
            List {
                ForEach(events) { event in
                    NavigationLink(destination: EventDetailView(event: event)) {
                        EventRow(event: event)
                    }
                }
                .onDelete(perform: deleteEvents)
            }
            .navigationTitle("Eventos")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddEvent = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddEvent) {
                AddEventView(isPresented: $showingAddEvent)
            }
            .overlay {
                if events.isEmpty {
                    ContentUnavailableView(
                        "No hay eventos",
                        systemImage: "calendar.badge.plus",
                        description: Text("Toca + para crear el primer evento")
                    )
                }
            }
        }
    }

    private func deleteEvents(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(events[index])
        }
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
    @Binding var isPresented: Bool
    @State private var selectedDate = Date()
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Fecha del Evento") {
                    DatePicker("Fecha", selection: $selectedDate, displayedComponents: .date)
                }

                Section("Notas (Opcional)") {
                    TextField("Notas", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Nuevo Evento")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        saveEvent()
                    }
                }
            }
        }
    }

    private func saveEvent() {
        let newEvent = Event(date: selectedDate, notes: notes)
        modelContext.insert(newEvent)
        isPresented = false
    }
}

#Preview {
    EventsListView()
        .modelContainer(for: [Event.self, User.self, Attendance.self])
}
