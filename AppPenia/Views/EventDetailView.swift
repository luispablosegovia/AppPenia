//
//  EventDetailView.swift
//  AppPenia
//
//  Created by Pablo Segovia on 13/11/2025.
//

import SwiftUI
import SwiftData

struct EventDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allUsers: [User]

    let event: Event

    @State private var showingAddAttendee = false
    @State private var showingEditEvent = false

    private var attendees: [User] {
        event.attendances?.compactMap { $0.user } ?? []
    }

    private var availableUsers: [User] {
        allUsers.filter { user in
            !attendees.contains(where: { $0.id == user.id })
        }
    }

    var body: some View {
        List {
            Section {
                HStack {
                    Text("Fecha")
                    Spacer()
                    Text(event.formattedDate)
                        .foregroundColor(.secondary)
                }

                if !event.notes.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Notas")
                            .font(.subheadline)
                        Text(event.notes)
                            .foregroundColor(.secondary)
                    }
                }

                if let host = event.host {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Sede")
                            .font(.subheadline)
                        HStack(spacing: 12) {
                            ProfilePhotoView(photoData: host.photoData, size: .small)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(host.name)
                                    .foregroundColor(.secondary)
                                if let address = event.hostAddress {
                                    Text(address)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }

                if let cook = event.cook {
                    HStack(spacing: 12) {
                        Text("Cocina")
                        Spacer()
                        ProfilePhotoView(photoData: cook.photoData, size: .small)
                        Text(cook.name)
                            .foregroundColor(.secondary)
                    }
                }

                if let dishwasher = event.dishwasher {
                    HStack(spacing: 12) {
                        Text("Lava")
                        Spacer()
                        ProfilePhotoView(photoData: dishwasher.photoData, size: .small)
                        Text(dishwasher.name)
                            .foregroundColor(.secondary)
                    }
                }

                HStack {
                    Text("Total Asistentes")
                    Spacer()
                    Text("\(event.attendeeCount)")
                        .foregroundColor(.secondary)
                        .bold()
                }
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))

            Section {
                if attendees.isEmpty {
                    Text("No hay asistentes registrados")
                        .foregroundColor(.secondary)
                        .italic()
                } else {
                    ForEach(attendees) { user in
                        NavigationLink(destination: UserProfileView(user: user)) {
                            HStack(spacing: 12) {
                                ProfilePhotoView(photoData: user.photoData, size: .small)
                                Text(user.name)
                            }
                        }
                    }
                    .onDelete(perform: deleteAttendance)
                }
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
        }
        .glassListBackground()
        .navigationTitle("Detalle de la Juntada")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { showingEditEvent = true }) {
                    Image(systemName: "pencil")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                .buttonStyle(GlassButtonStyle())
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddAttendee = true }) {
                    Image(systemName: "person.badge.plus")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                .disabled(availableUsers.isEmpty)
                .buttonStyle(GlassButtonStyle())
            }
        }
        .sheet(isPresented: $showingAddAttendee) {
            AddAttendeeView(
                event: event,
                availableUsers: availableUsers,
                isPresented: $showingAddAttendee
            )
        }
        .sheet(isPresented: $showingEditEvent) {
            EditEventView(event: event, isPresented: $showingEditEvent)
        }
    }

    private func deleteAttendance(offsets: IndexSet) {
        guard let attendances = event.attendances else { return }

        for index in offsets {
            let attendeeToRemove = attendees[index]
            if let attendanceToDelete = attendances.first(where: { $0.user?.id == attendeeToRemove.id }) {
                modelContext.delete(attendanceToDelete)
            }
        }
    }
}

struct AddAttendeeView: View {
    @Environment(\.modelContext) private var modelContext
    let event: Event
    let availableUsers: [User]
    @Binding var isPresented: Bool

    @State private var selectedUsers: Set<UUID> = []

    var body: some View {
        NavigationStack {
            List(availableUsers) { user in
                Button(action: {
                    if selectedUsers.contains(user.id) {
                        selectedUsers.remove(user.id)
                    } else {
                        selectedUsers.insert(user.id)
                    }
                }) {
                    HStack(spacing: 12) {
                        ProfilePhotoView(photoData: user.photoData, size: .small)
                        Text(user.name)
                            .foregroundColor(.primary)
                        Spacer()
                        if selectedUsers.contains(user.id) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                }
            }
            .navigationTitle("Agregar Asistentes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        saveAttendees()
                    }
                    .disabled(selectedUsers.isEmpty)
                }
            }
            .overlay {
                if availableUsers.isEmpty {
                    ContentUnavailableView(
                        "No hay miembros disponibles",
                        systemImage: "person.2.slash",
                        description: Text("Todos los miembros ya están registrados en esta juntada")
                    )
                }
            }
        }
    }

    private func saveAttendees() {
        for userId in selectedUsers {
            if let user = availableUsers.first(where: { $0.id == userId }) {
                let attendance = Attendance(user: user, event: event)
                modelContext.insert(attendance)
            }
        }
        isPresented = false
    }
}

#Preview {
    NavigationStack {
        EventDetailView(event: Event(date: Date(), notes: "Juntada de prueba"))
    }
    .modelContainer(for: [Event.self, User.self, Attendance.self])
}
