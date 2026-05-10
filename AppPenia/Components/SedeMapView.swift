//
//  SedeMapView.swift
//  AppPenia
//
//  Created by Pablo Segovia on 17/11/2025.
//

import SwiftUI
import MapKit

struct SedeMapView: View {
    let address: String
    var height: CGFloat = 250
    @State private var position: MapCameraPosition = .automatic
    @State private var markerCoordinate: CLLocationCoordinate2D?
    @State private var isGeocoding = false
    @State private var geocodingError: String?

    var body: some View {
        VStack(spacing: 0) {
            if isGeocoding {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                        .frame(height: height)

                    VStack(spacing: 12) {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("Buscando ubicación...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.6), .white.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
            } else if let error = geocodingError {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                        .frame(height: height)

                    VStack(spacing: 12) {
                        Image(systemName: "map.fill")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                        Text(error)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.6), .white.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
            } else {
                Map(position: $position) {
                    if let coordinate = markerCoordinate {
                        Marker("Sede", systemImage: "house.fill", coordinate: coordinate)
                            .tint(.blue)
                    }
                }
                .mapStyle(.standard(elevation: .realistic))
                .frame(height: height)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.6), .white.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
            }
        }
        .task {
            await geocodeAddress()
        }
        .onChange(of: address) {
            Task {
                await geocodeAddress()
            }
        }
    }

    @MainActor
    private func geocodeAddress() async {
        guard !address.isEmpty else {
            geocodingError = "No hay dirección para mostrar"
            return
        }

        isGeocoding = true
        geocodingError = nil

        do {
            let searchRequest = MKLocalSearch.Request()
            searchRequest.naturalLanguageQuery = address

            let search = MKLocalSearch(request: searchRequest)
            let response = try await search.start()

            guard let firstItem = response.mapItems.first else {
                geocodingError = "No se pudo encontrar la ubicación"
                isGeocoding = false
                return
            }

            let coordinate = firstItem.location.coordinate
            markerCoordinate = coordinate
            position = .camera(
                MapCamera(
                    centerCoordinate: coordinate,
                    distance: 500,
                    heading: 0,
                    pitch: 0
                )
            )
            isGeocoding = false
        } catch {
            geocodingError = "No se pudo encontrar la dirección en el mapa"
            isGeocoding = false
        }
    }
}

#Preview {
    NavigationStack {
        VStack {
            SedeMapView(address: "Av. Providencia 1234, Santiago, Chile")
                .padding()

            Spacer()
        }
    }
}
