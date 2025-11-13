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
                            } else {
                                EmptyChartPlaceholder(message: "No hay datos de asistencias")
                                    .padding(.horizontal)
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
                            } else {
                                EmptyChartPlaceholder(message: "No hay datos de sedes")
                                    .padding(.horizontal)
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
                            } else {
                                EmptyChartPlaceholder(message: "No hay datos de cocina")
                                    .padding(.horizontal)
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
                            } else {
                                EmptyChartPlaceholder(message: "No hay datos de lavado")
                                    .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.vertical, 20)
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

// MARK: - Empty Chart Placeholder

struct EmptyChartPlaceholder: View {
    let message: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 50))
                .foregroundStyle(.secondary)
            Text(message)
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
        .glassCard()
    }
}

#Preview {
    StatisticsView()
        .modelContainer(for: [Event.self, User.self, Attendance.self])
}
