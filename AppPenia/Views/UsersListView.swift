//
//  UsersListView.swift
//  AppPenia
//
//  Created by Pablo Segovia on 13/11/2025.
//

import SwiftUI
import SwiftData

struct UsersListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \User.name) private var users: [User]
    @State private var showingAddUser = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(users) { user in
                    NavigationLink(destination: UserProfileView(user: user)) {
                        UserRow(user: user)
                    }
                }
                .onDelete(perform: deleteUsers)
            }
            .navigationTitle("Miembros")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddUser = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddUser) {
                AddUserView(isPresented: $showingAddUser)
            }
            .overlay {
                if users.isEmpty {
                    ContentUnavailableView(
                        "No hay miembros",
                        systemImage: "person.2.fill",
                        description: Text("Toca + para crear el primer miembro")
                    )
                }
            }
        }
    }

    private func deleteUsers(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(users[index])
        }
    }
}

struct UserRow: View {
    let user: User

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(user.name)
                .font(.headline)
            Text("\(user.attendanceCount) asistencias")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct AddUserView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var isPresented: Bool
    @State private var name = ""
    @State private var birthday: Date?
    @State private var hasBirthday = false
    @State private var selectedBirthday = Date()
    @State private var hasSede = false
    @State private var address = ""
    @FocusState private var isNameFocused: Bool

    var body: some View {
        NavigationStack {
            Form {
                Section("Nombre del Miembro") {
                    TextField("Nombre", text: $name)
                        .focused($isNameFocused)
                }

                Section("Fecha de Cumpleaños (Opcional)") {
                    Toggle("Agregar cumpleaños", isOn: $hasBirthday)

                    if hasBirthday {
                        DatePicker("Fecha", selection: $selectedBirthday, displayedComponents: .date)
                    }
                }

                Section("Sede") {
                    Toggle("¿Tiene sede?", isOn: $hasSede)

                    if hasSede {
                        TextField("Dirección", text: $address, axis: .vertical)
                            .lineLimit(2...4)
                    }
                }
            }
            .navigationTitle("Nuevo Miembro")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        saveUser()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                isNameFocused = true
            }
        }
    }

    private func saveUser() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }

        let finalBirthday = hasBirthday ? selectedBirthday : nil
        let finalAddress = hasSede ? address : ""

        let newUser = User(name: trimmedName, birthday: finalBirthday, hasSede: hasSede, address: finalAddress)
        modelContext.insert(newUser)
        isPresented = false
    }
}

#Preview {
    UsersListView()
        .modelContainer(for: [Event.self, User.self, Attendance.self])
}
