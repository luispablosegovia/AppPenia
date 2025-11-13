//
//  EditPhotoView.swift
//  AppPenia
//
//  Created by Pablo Segovia on 13/11/2025.
//

import SwiftUI
import SwiftData

struct EditPhotoView: View {
    @Environment(\.modelContext) private var modelContext
    let user: User
    @Binding var isPresented: Bool
    @State private var capturedImage: UIImage?
    @State private var showingCamera = false
    @State private var hasChanges = false

    var body: some View {
        ZStack {
            GlassBackground()

            NavigationStack {
                VStack(spacing: 30) {
                    Spacer()

                    // Photo preview
                    VStack(spacing: 16) {
                        if let image = capturedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 200, height: 200)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .strokeBorder(
                                            LinearGradient(
                                                colors: [
                                                    Color.white.opacity(0.6),
                                                    Color.white.opacity(0.2)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 3
                                        )
                                )
                                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                        } else if let photoData = user.photoData,
                                  let uiImage = UIImage(data: photoData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 200, height: 200)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .strokeBorder(
                                            LinearGradient(
                                                colors: [
                                                    Color.white.opacity(0.6),
                                                    Color.white.opacity(0.2)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 3
                                        )
                                )
                                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                        } else {
                            Circle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 200, height: 200)
                                .overlay(
                                    Image(systemName: "person.circle.fill")
                                        .font(.system(size: 100))
                                        .foregroundStyle(.secondary)
                                )
                                .overlay(
                                    Circle()
                                        .strokeBorder(
                                            LinearGradient(
                                                colors: [
                                                    Color.white.opacity(0.6),
                                                    Color.white.opacity(0.2)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 3
                                        )
                                )
                        }

                        Text(user.name)
                            .font(.title2)
                            .fontWeight(.bold)
                    }

                    Spacer()

                    // Action buttons
                    VStack(spacing: 16) {
                        Button(action: { showingCamera = true }) {
                            Label("Tomar Nueva Foto", systemImage: "camera.fill")
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                        .buttonStyle(GlassButtonStyle())

                        if user.photoData != nil || capturedImage != nil {
                            Button(action: deletePhoto) {
                                Label("Eliminar Foto", systemImage: "trash")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            }
                            .buttonStyle(GlassButtonStyle())
                        }

                        Button(action: { isPresented = false }) {
                            Text("Cancelar")
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                        .buttonStyle(GlassButtonStyle())
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
                .navigationTitle("Editar Foto")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Guardar") {
                            savePhoto()
                        }
                        .disabled(!hasChanges)
                        .buttonStyle(GlassButtonStyle())
                    }
                }
                .sheet(isPresented: $showingCamera) {
                    CameraView(image: $capturedImage)
                        .onDisappear {
                            if capturedImage != nil {
                                hasChanges = true
                            }
                        }
                }
            }
        }
    }

    private func deletePhoto() {
        capturedImage = nil
        user.photoData = nil
        hasChanges = true
    }

    private func savePhoto() {
        if let image = capturedImage {
            user.photoData = image.jpegData(compressionQuality: 0.8)
        }
        isPresented = false
    }
}

#Preview {
    EditPhotoView(user: User(name: "Juan Pérez"), isPresented: .constant(true))
        .modelContainer(for: [Event.self, User.self, Attendance.self])
}
