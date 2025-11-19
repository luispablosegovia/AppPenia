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

    // Financial balance calculations
    private var eventsWithExpenses: [Event] {
        allEvents.filter { event in
            guard let _ = event.expense,
                  let attendances = event.attendances else { return false }
            return attendances.contains(where: { $0.user?.id == user.id })
        }
    }

    private var totalPaid: Decimal {
        eventsWithExpenses.compactMap { event in
            event.expense?.amountPaidBy(user: user)
        }.reduce(Decimal(0), +)
    }

    private var totalOwed: Decimal {
        eventsWithExpenses.compactMap { event in
            guard let expense = event.expense else { return nil }
            let balance = expense.balanceFor(user: user)
            return balance < 0 ? -balance : 0
        }.reduce(Decimal(0), +)
    }

    private var totalOwedToUser: Decimal {
        eventsWithExpenses.compactMap { event in
            guard let expense = event.expense else { return nil }
            let balance = expense.balanceFor(user: user)
            return balance > 0 ? balance : 0
        }.reduce(Decimal(0), +)
    }

    private var netBalance: Decimal {
        totalOwedToUser - totalOwed
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
                    .buttonStyle(.glass)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
            }
            .listRowBackground(Color(.secondarySystemBackground).opacity(0.3))
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
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Dirección")
                            .font(.subheadline)
                        Text(user.address)
                            .foregroundColor(.secondary)
                            .font(.callout)
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
            .listRowBackground(Color(.secondarySystemBackground).opacity(0.3))
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))

            // Map Section for sede
            if user.hasSede && !user.address.isEmpty {
                Section {
                    SedeMapView(address: user.address)
                        .padding(.vertical, 8)
                } header: {
                    Text("Ubicación de la Sede")
                }
                    .listRowBackground(Color(.secondarySystemBackground).opacity(0.3))
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }

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
            .listRowBackground(Color(.secondarySystemBackground).opacity(0.3))
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))

            // Financial Balance Section
            if !eventsWithExpenses.isEmpty {
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        // Total paid
                        HStack {
                            Text("Total Aportado")
                                .font(.subheadline)
                            Spacer()
                            Text(formatCurrency(totalPaid))
                                .font(.title3)
                                .bold()
                                .foregroundColor(.green)
                        }

                        Divider()

                        // What they owe
                        HStack {
                            Text("Debe")
                                .font(.subheadline)
                            Spacer()
                            Text(formatCurrency(totalOwed))
                                .font(.callout)
                                .foregroundColor(.red)
                        }

                        // What is owed to them
                        HStack {
                            Text("Le deben")
                                .font(.subheadline)
                            Spacer()
                            Text(formatCurrency(totalOwedToUser))
                                .font(.callout)
                                .foregroundColor(.green)
                        }

                        Divider()

                        // Net balance
                        HStack {
                            Text("Balance Neto")
                                .font(.headline)
                            Spacer()
                            Text(formatCurrency(netBalance))
                                .font(.title2)
                                .bold()
                                .foregroundColor(netBalance >= 0 ? .green : .red)
                        }

                        if netBalance < 0 {
                            Text("Debe pagar \(formatCurrency(-netBalance))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .italic()
                        } else if netBalance > 0 {
                            Text("Le deben \(formatCurrency(netBalance))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .italic()
                        } else {
                            Text("Está al día")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .italic()
                        }
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("Balance Financiero")
                } footer: {
                    Text("Basado en \(eventsWithExpenses.count) juntadas con gastos registrados")
                }
                    .listRowBackground(Color(.secondarySystemBackground).opacity(0.3))
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }

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
            .listRowBackground(Color(.secondarySystemBackground).opacity(0.3))
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
                .buttonStyle(.glass)
            }
        }
        .sheet(isPresented: $showingEditPhoto) {
            EditPhotoView(user: user, isPresented: $showingEditPhoto)
        }
        .sheet(isPresented: $showingEditUser) {
            EditUserView(user: user, isPresented: $showingEditUser)
        }
    }

    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "es_AR")
        return formatter.string(from: amount as NSDecimalNumber) ?? "$0"
    }
}

#Preview {
    NavigationStack {
        UserProfileView(user: User(name: "Juan Pérez"))
    }
    .modelContainer(for: [Event.self, User.self, Attendance.self])
}
