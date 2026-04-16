//
//  ConnectionStatusBadge.swift
//  BuzzPlay
//

import SwiftUI

struct ConnectionStatusBadge: View {
    let connected: Int
    let total: Int

    private var dotColor: Color {
        if total == 0 { return .gray }
        if connected == 0 { return .red }
        if connected < total { return .orange }
        return .green
    }

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(dotColor)
                .frame(width: 10, height: 10)
                .shadow(color: dotColor.opacity(0.6), radius: 4)

            Text("\(connected)/\(total)")
                .font(.poppins(.subheadline, weight: .semibold))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(.ultraThinMaterial, in: Capsule())
    }
}

#Preview {
    VStack(spacing: 16) {
        ConnectionStatusBadge(connected: 2, total: 2)
        ConnectionStatusBadge(connected: 1, total: 2)
        ConnectionStatusBadge(connected: 0, total: 2)
        ConnectionStatusBadge(connected: 0, total: 0)
    }
    .padding()
    .background(Color.black)
}
