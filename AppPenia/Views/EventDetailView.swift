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
    @State private var showingAddExpense = false

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

            // Map Section for sede
            if let host = event.host, host.hasSede, !host.address.isEmpty {
                Section {
                    SedeMapView(address: host.address)
                        .padding(.vertical, 8)
                } header: {
                    Text("Ubicación de la Sede")
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }

            // Expense Section
            Section {
                if let expense = event.expense {
                    // Show expense summary
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Gasto Total")
                                .font(.subheadline)
                            Spacer()
                            Text(formatCurrency(expense.totalAmount))
                                .font(.title3)
                                .bold()
                        }

                        HStack {
                            Text("Por Persona")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(formatCurrency(expense.amountPerPerson))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        NavigationLink(destination: ExpenseDetailView(event: event)) {
                            HStack {
                                Image(systemName: "chart.bar.doc.horizontal")
                                    .foregroundColor(.accentColor)
                                Text("Ver Detalles del Gasto")
                                    .foregroundColor(.accentColor)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                        }
                    }
                } else {
                    // Show add expense button
                    Button(action: { showingAddExpense = true }) {
                        HStack {
                            Image(systemName: "dollarsign.circle")
                                .foregroundColor(.green)
                            Text("Agregar Gasto")
                                .foregroundColor(.green)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                    }
                    .disabled(attendees.isEmpty)
                    .opacity(attendees.isEmpty ? 0.5 : 1.0)

                    if attendees.isEmpty {
                        Text("Agrega asistentes primero para registrar gastos")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .italic()
                    }
                }
            } header: {
                Text("Gastos")
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
        .sheet(isPresented: $showingAddExpense) {
            AddExpenseView(event: event)
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

    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "es_CL")
        return formatter.string(from: amount as NSDecimalNumber) ?? "$0"
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
