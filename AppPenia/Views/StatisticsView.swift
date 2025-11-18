//
//  StatisticsView.swift
//  AppPenia
//
//  Created by Pablo Segovia on 13/11/2025.
//

import SwiftUI
import SwiftData
import Charts

struct StatisticsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \User.name) private var users: [User]
    @Query(sort: \Event.date, order: .reverse) private var events: [Event]

    var body: some View {
        NavigationStack {
            ZStack {
                GlassBackground()

                if users.isEmpty && events.isEmpty {
                    ContentUnavailableView(
                        "Sin Datos",
                        systemImage: "chart.bar",
                        description: Text("Las estadísticas aparecerán aquí cuando haya datos")
                    )
                } else {
                    ScrollView {
                        VStack(spacing: 40) {
                        // Attendance Statistics
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Asistencias por Miembro")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal)

                            if !users.isEmpty {
                                AttendanceBarChart(users: users)
                                    .frame(height: 200)
                                    .padding()
                                    .glassCard()
                                    .padding(.horizontal)
                                    .allowsHitTesting(false)
                            }
                        }

                        // Sede Statistics
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Estadísticas de Sedes")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal)

                            if !events.isEmpty {
                                SedeBarChart(events: events)
                                    .frame(height: 200)
                                    .padding()
                                    .glassCard()
                                    .padding(.horizontal)
                                    .allowsHitTesting(false)
                            }
                        }

                        // Cook Statistics
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Veces que Cocinaron")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal)

                            if !events.isEmpty {
                                CookBarChart(events: events)
                                    .frame(height: 200)
                                    .padding()
                                    .glassCard()
                                    .padding(.horizontal)
                                    .allowsHitTesting(false)
                            }
                        }

                        // Dishwasher Statistics
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Veces que Lavaron")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal)

                            if !events.isEmpty {
                                DishwasherBarChart(events: events)
                                    .frame(height: 200)
                                    .padding()
                                    .glassCard()
                                    .padding(.horizontal)
                                    .allowsHitTesting(false)
                            }
                        }

                        // Expenses Statistics
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Gastos Acumulados por Persona")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal)

                            if !events.isEmpty {
                                ExpensesBarChart(events: events)
                                    .frame(height: 200)
                                    .padding()
                                    .glassCard()
                                    .padding(.horizontal)
                                    .allowsHitTesting(false)
                            }
                        }
                        }
                        .padding(.vertical, 20)
                    }
                }
            }
            .navigationTitle("Estadísticas")
        }
    }
}

// MARK: - Attendance Bar Chart

struct AttendanceBarChart: View {
    let users: [User]

    private var sortedUsers: [(name: String, count: Int)] {
        users.map { (name: $0.name, count: $0.attendanceCount) }
            .sorted { $0.count > $1.count }
    }

    var body: some View {
        Chart {
            ForEach(sortedUsers, id: \.name) { user in
                BarMark(
                    x: .value("Asistencias", user.count),
                    y: .value("Miembro", user.name)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.blue, Color.purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .annotation(position: .trailing) {
                    Text("\(user.count)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .chartXAxis {
            AxisMarks(position: .bottom)
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisValueLabel {
                    if let name = value.as(String.self) {
                        Text(name)
                            .font(.caption)
                    }
                }
            }
        }
    }
}

// MARK: - Sede Bar Chart

struct SedeBarChart: View {
    let events: [Event]

    private var sedeStats: [(name: String, count: Int)] {
        let hostCounts = Dictionary(grouping: events.compactMap { $0.host }, by: { $0.id })
            .mapValues { $0.count }

        return hostCounts.compactMap { id, count in
            guard let user = events.compactMap({ $0.host }).first(where: { $0.id == id }) else { return nil }
            return (name: user.name, count: count)
        }
        .sorted { $0.count > $1.count }
    }

    var body: some View {
        Chart {
            ForEach(sedeStats, id: \.name) { stat in
                BarMark(
                    x: .value("Veces", stat.count),
                    y: .value("Sede", stat.name)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.orange, Color.pink],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .annotation(position: .trailing) {
                    Text("\(stat.count)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .chartXAxis {
            AxisMarks(position: .bottom)
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisValueLabel {
                    if let name = value.as(String.self) {
                        Text(name)
                            .font(.caption)
                    }
                }
            }
        }
    }
}

// MARK: - Cook Bar Chart

struct CookBarChart: View {
    let events: [Event]

    private var cookStats: [(name: String, count: Int)] {
        let cookCounts = Dictionary(grouping: events.compactMap { $0.cook }, by: { $0.id })
            .mapValues { $0.count }

        return cookCounts.compactMap { id, count in
            guard let user = events.compactMap({ $0.cook }).first(where: { $0.id == id }) else { return nil }
            return (name: user.name, count: count)
        }
        .sorted { $0.count > $1.count }
    }

    var body: some View {
        Chart {
            ForEach(cookStats, id: \.name) { stat in
                BarMark(
                    x: .value("Veces", stat.count),
                    y: .value("Cocinero", stat.name)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.green, Color.mint],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .annotation(position: .trailing) {
                    Text("\(stat.count)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .chartXAxis {
            AxisMarks(position: .bottom)
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisValueLabel {
                    if let name = value.as(String.self) {
                        Text(name)
                            .font(.caption)
                    }
                }
            }
        }
    }
}

// MARK: - Dishwasher Bar Chart

struct DishwasherBarChart: View {
    let events: [Event]

    private var dishwasherStats: [(name: String, count: Int)] {
        let dishwasherCounts = Dictionary(grouping: events.compactMap { $0.dishwasher }, by: { $0.id })
            .mapValues { $0.count }

        return dishwasherCounts.compactMap { id, count in
            guard let user = events.compactMap({ $0.dishwasher }).first(where: { $0.id == id }) else { return nil }
            return (name: user.name, count: count)
        }
        .sorted { $0.count > $1.count }
    }

    var body: some View {
        Chart {
            ForEach(dishwasherStats, id: \.name) { stat in
                BarMark(
                    x: .value("Veces", stat.count),
                    y: .value("Lavador", stat.name)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.cyan, Color.blue],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .annotation(position: .trailing) {
                    Text("\(stat.count)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .chartXAxis {
            AxisMarks(position: .bottom)
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisValueLabel {
                    if let name = value.as(String.self) {
                        Text(name)
                            .font(.caption)
                    }
                }
            }
        }
    }
}

// MARK: - Expenses Bar Chart

struct ExpensesBarChart: View {
    let events: [Event]

    private var expensesStats: [(name: String, total: Decimal)] {
        // Get all events with expenses
        let eventsWithExpenses = events.filter { $0.expense != nil }

        // Create a dictionary to accumulate expenses per user
        var userExpenses: [UUID: (name: String, total: Decimal)] = [:]

        for event in eventsWithExpenses {
            guard let expense = event.expense,
                  let attendances = event.attendances else { continue }

            // Get all users who attended this event
            let attendees = attendances.compactMap { $0.user }

            for user in attendees {
                let amountPaid = expense.amountPaidBy(user: user)

                if amountPaid > 0 {
                    if let existing = userExpenses[user.id] {
                        userExpenses[user.id] = (name: user.name, total: existing.total + amountPaid)
                    } else {
                        userExpenses[user.id] = (name: user.name, total: amountPaid)
                    }
                }
            }
        }

        return userExpenses.values
            .map { (name: $0.name, total: $0.total) }
            .sorted { $0.total > $1.total }
    }

    var body: some View {
        if expensesStats.isEmpty {
            VStack {
                Text("No hay gastos registrados")
                    .foregroundStyle(.secondary)
                    .italic()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            Chart {
                ForEach(expensesStats, id: \.name) { stat in
                    BarMark(
                        x: .value("Monto", NSDecimalNumber(decimal: stat.total).doubleValue),
                        y: .value("Persona", stat.name)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.yellow, Color.orange],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .annotation(position: .trailing) {
                        Text(formatCurrency(stat.total))
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .chartXAxis {
                AxisMarks(position: .bottom)
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisValueLabel {
                        if let name = value.as(String.self) {
                            Text(name)
                                .font(.caption)
                        }
                    }
                }
            }
        }
    }

    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "es_AR")
        formatter.maximumFractionDigits = 0
        return formatter.string(from: amount as NSDecimalNumber) ?? "$0"
    }
}

#Preview {
    StatisticsView()
        .modelContainer(for: [Event.self, User.self, Attendance.self, Expense.self, Payment.self])
}
