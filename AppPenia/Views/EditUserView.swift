//
//  EditUserView.swift
//  AppPenia
//
//  Created by Pablo Segovia on 13/11/2025.
//

import SwiftUI
import SwiftData

struct EditUserView: View {
    @Environment(\.modelContext) private var modelContext
    let user: User
    @Binding var isPresented: Bool

    @State private var name: String
    @State private var hasBirthday: Bool
    @State private var selectedBirthday: Date
    @State private var hasSede: Bool
    @State private var address: String
    @FocusState private var isNameFocused: Bool

    init(user: User, isPresented: Binding<Bool>) {
        self.user = user
        self._isPresented = isPresented

        // Initialize state from user
        _name = State(initialValue: user.name)
        _hasBirthday = State(initialValue: user.birthday != nil)
        _selectedBirthday = State(initialValue: user.birthday ?? Date())
        _hasSede = State(initialValue: user.hasSede)
        _address = State(initialValue: user.address)
    }

    var body: some View {
        ZStack {
            GlassBackground()

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

                            if !address.isEmpty {
                                SedeMapView(address: address, height: 180)
                                    .padding(.top, 8)
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .navigationTitle("Editar Miembro")
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
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                        .buttonStyle(.glass)
                    }
                }
            }
        }
    }

    private func saveChanges() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }

        user.name = trimmedName
        user.birthday = hasBirthday ? selectedBirthday : nil
        user.hasSede = hasSede
        user.address = hasSede ? address : ""

        isPresented = false
    }
}

#Preview {
    EditUserView(user: User(name: "Juan Pérez", birthday: Date(), hasSede: true, address: "Calle Principal 123"), isPresented: .constant(true))
        .modelContainer(for: [Event.self, User.self, Attendance.self])
}
