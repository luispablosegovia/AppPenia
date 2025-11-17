//
//  UsersListView.swift
//  AppPenia
//
//  Created by Pablo Segovia on 13/11/2025.
//

import SwiftUI
import SwiftData
import PhotosUI

struct UsersListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \User.name) private var users: [User]
    @State private var showingAddUser = false
    @State private var showingDeleteAlert = false
    @State private var userToDelete: User?

    var body: some View {
        NavigationStack {
            List {
                ForEach(users) { user in
                    NavigationLink(destination: UserProfileView(user: user)) {
                        UserRow(user: user)
                    }
                    .buttonStyle(.plain)
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            userToDelete = user
                            showingDeleteAlert = true
                        } label: {
                            Label("Eliminar", systemImage: "trash")
                        }
                    }
                }
            }
            .glassListBackground()
            .navigationTitle("Miembros")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddUser = true }) {
                        Image(systemName: "plus")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                    .buttonStyle(GlassButtonStyle())
                }
            }
            .alert("Eliminar Miembro", isPresented: $showingDeleteAlert, presenting: userToDelete) { user in
                Button("Cancelar", role: .cancel) {
                    userToDelete = nil
                }
                Button("Eliminar", role: .destructive) {
                    deleteUser(user)
                }
            } message: { user in
                Text("¿Estás seguro de que quieres eliminar a \(user.name)? Esta acción eliminará también su historial de asistencias y no se puede deshacer.")
            }
            .sheet(isPresented: $showingAddUser) {
                AddUserView(isPresented: $showingAddUser)
            }
            .overlay {
                if users.isEmpty {
                    ContentUnavailableView(
                        "Sin Miembros",
                        systemImage: "person.2",
                        description: Text("Los miembros aparecerán aquí")
                    )
                }
            }
        }
    }

    private func deleteUser(_ user: User) {
        modelContext.delete(user)
        userToDelete = nil
    }
}

struct UserRow: View {
    let user: User

    var body: some View {
        HStack(spacing: 12) {
            ProfilePhotoView(photoData: user.photoData, size: .small)

            VStack(alignment: .leading, spacing: 4) {
                Text(user.name)
                    .font(.headline)
                Text("\(user.attendanceCount) asistencias")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
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
    @State private var capturedImage: UIImage?
    @State private var showingCamera = false
    @FocusState private var isNameFocused: Bool

    var body: some View {
        ZStack {
            GlassBackground()

            NavigationStack {
                Form {
                    Section("Foto (Opcional)") {
                        VStack(spacing: 12) {
                            if let image = capturedImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.white.opacity(0.3), lineWidth: 2))
                            } else {
                                Circle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: 120, height: 120)
                                    .overlay(
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 40))
                                            .foregroundColor(.secondary)
                                    )
                            }

                            Button(action: { showingCamera = true }) {
                                Label(capturedImage == nil ? "Tomar Foto" : "Cambiar Foto", systemImage: "camera")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                    }

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
                .glassForm()
                .scrollContentBackground(.hidden)
                .navigationTitle("Nuevo Miembro")
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
                            saveUser()
                        }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                        .buttonStyle(GlassButtonStyle())
                    }
                }
                .onAppear {
                    isNameFocused = true
                }
                .sheet(isPresented: $showingCamera) {
                    CameraView(image: $capturedImage)
                }
            }
        }
    }

    private func saveUser() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }

        let finalBirthday = hasBirthday ? selectedBirthday : nil
        let finalAddress = hasSede ? address : ""
        let photoData = capturedImage?.jpegData(compressionQuality: 0.8)

        let newUser = User(name: trimmedName, birthday: finalBirthday, hasSede: hasSede, address: finalAddress, photoData: photoData)
        modelContext.insert(newUser)
        isPresented = false
    }
}

#Preview {
    UsersListView()
        .modelContainer(for: [Event.self, User.self, Attendance.self])
}
