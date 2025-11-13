//
//  UserProfileView.swift
//  AppPenia
//
//  Created by Pablo Segovia on 13/11/2025.
//

import SwiftUI
import SwiftData

struct UserProfileView: View {
    @Query private var allEvents: [Event]
    let user: User
    @State private var showingEditPhoto = false
    @State private var showingEditUser = false

    private var sortedAttendances: [Attendance] {
        (user.attendances ?? [])
            .sorted { ($0.event?.date ?? Date()) > ($1.event?.date ?? Date()) }
    }

    private var timesHosted: Int {
        allEvents.filter { $0.host?.id == user.id }.count
    }

    private var timesCooked: Int {
        allEvents.filter { $0.cook?.id == user.id }.count
    }

    private var timesWashed: Int {
        allEvents.filter { $0.dishwasher?.id == user.id }.count
    }

    var body: some View {
        List {
            Section {
                VStack(spacing: 16) {
                    ProfilePhotoView(photoData: user.photoData, size: .large)

                    Button(action: { showingEditPhoto = true }) {
                        Label("Cambiar Foto", systemImage: "camera")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .buttonStyle(GlassButtonStyle())
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))

            Section {
                HStack {
                    Text("Nombre")
                    Spacer()
                    Text(user.name)
                        .foregroundColor(.secondary)
                }

                if let formattedBirthday = user.formattedBirthday {
                    HStack {
                        Text("Cumpleaños")
                        Spacer()
                        Text(formattedBirthday)
                            .foregroundColor(.secondary)
                    }
                }

                if let age = user.age {
                    HStack {
                        Text("Edad")
                        Spacer()
                        Text("\(age) años")
                            .foregroundColor(.secondary)
                    }
                }

                HStack {
                    Text("Miembro desde")
                    Spacer()
                    Text(user.createdAt.formatted(date: .abbreviated, time: .omitted))
                        .foregroundColor(.secondary)
                }

                HStack {
                    Text("Tiene sede")
                    Spacer()
                    Text(user.hasSede ? "Sí" : "No")
                        .foregroundColor(.secondary)
                }

                if user.hasSede && !user.address.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Dirección")
                            .font(.subheadline)
                        Text(user.address)
                            .foregroundColor(.secondary)
                    }
                }

                HStack {
                    Text("Total Asistencias")
                    Spacer()
                    Text("\(user.attendanceCount)")
                        .foregroundColor(.secondary)
                        .bold()
                }
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))

            Section {
                HStack {
                    Text("Veces que prestó sede")
                    Spacer()
                    Text("\(timesHosted)")
                        .foregroundColor(.secondary)
                        .bold()
                }

                HStack {
                    Text("Veces que cocinó")
                    Spacer()
                    Text("\(timesCooked)")
                        .foregroundColor(.secondary)
                        .bold()
                }

                HStack {
                    Text("Veces que lavó")
                    Spacer()
                    Text("\(timesWashed)")
                        .foregroundColor(.secondary)
                        .bold()
                }
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))

            Section {
                if sortedAttendances.isEmpty {
                    Text("No hay asistencias registradas")
                        .foregroundColor(.secondary)
                        .italic()
                } else {
                    ForEach(sortedAttendances, id: \.id) { attendance in
                        if let event = attendance.event {
                            NavigationLink(destination: EventDetailView(event: event)) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(event.formattedDate)
                                        .font(.headline)
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
                    }
                }
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
        }
        .glassListBackground()
        .navigationTitle(user.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingEditUser = true }) {
                    Image(systemName: "pencil")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                .buttonStyle(GlassButtonStyle())
            }
        }
        .sheet(isPresented: $showingEditPhoto) {
            EditPhotoView(user: user, isPresented: $showingEditPhoto)
        }
        .sheet(isPresented: $showingEditUser) {
            EditUserView(user: user, isPresented: $showingEditUser)
        }
    }
}

#Preview {
    NavigationStack {
        UserProfileView(user: User(name: "Juan Pérez"))
    }
    .modelContainer(for: [Event.self, User.self, Attendance.self])
}
