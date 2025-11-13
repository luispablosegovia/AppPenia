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
            Section("Información") {
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

            Section("Estadísticas") {
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

            Section("Historial de Asistencias") {
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
        }
        .navigationTitle(user.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        UserProfileView(user: User(name: "Juan Pérez"))
    }
    .modelContainer(for: [Event.self, User.self, Attendance.self])
}
