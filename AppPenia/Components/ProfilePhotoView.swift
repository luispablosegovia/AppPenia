//
//  ProfilePhotoView.swift
//  AppPenia
//
//  Created by Pablo Segovia on 13/11/2025.
//

import SwiftUI

enum PhotoSize {
    case small, medium, large

    var dimension: CGFloat {
        switch self {
        case .small: return 40
        case .medium: return 80
        case .large: return 150
        }
    }
}

struct ProfilePhotoView: View {
    let photoData: Data?
    let size: PhotoSize

    var body: some View {
        Group {
            if let photoData = photoData,
               let uiImage = UIImage(data: photoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size.dimension, height: size.dimension)
                    .clipShape(Circle())
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: size.dimension, height: size.dimension)
                    .foregroundStyle(.secondary)
            }
        }
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
                    lineWidth: 2
                )
        )
        .shadow(color: .black.opacity(0.15), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    VStack(spacing: 20) {
        ProfilePhotoView(photoData: nil, size: .small)
        ProfilePhotoView(photoData: nil, size: .medium)
        ProfilePhotoView(photoData: nil, size: .large)
    }
    .padding()
}
