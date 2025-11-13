//
//  UserProfileView.swift
//  AppPenia
//
//  Created by Pablo Segovia on 13/11/2025.
//

import SwiftUI
import SwiftData

struct UserProfileView: View {
    let user: User

    private var sortedAttendances: [Attendance] {
        (user.attendances ?? [])
            .sorted { ($0.event?.date ?? Date()) > ($1.event?.date ?? Date()) }
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

                HStack {
                    Text("Total Asistencias")
                    Spacer()
                    Text("\(user.attendanceCount)")
                        .foregroundColor(.secondary)
                        .bold()
                }

                HStack {
                    Text("Miembro desde")
                    Spacer()
                    Text(user.createdAt.formatted(date: .abbreviated, time: .omitted))
                        .foregroundColor(.secondary)
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
