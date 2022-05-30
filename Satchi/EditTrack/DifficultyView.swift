//
//  DifficultyView.swift
//  Satchi
//
//  Created by Carl-Johan Svedin on 2022-05-29.
//

import SwiftUI

struct DifficultyView: View {
    @Binding var difficulty: Int16

    var body: some View {
        difficultyView
            .overlay(overlayView.mask(difficultyView))
    }

    private var difficultyView: some View {
        HStack(spacing: 5) {
            ForEach(1..<6) { index in
                Image(systemName: "pawprint.fill")
                    .foregroundColor(difficulty >= index ? .red : .gray)
                    .onTapGesture {
                        withAnimation {
                            difficulty = Int16(index)
                        }
                    }
            }

        }
    }

    private var overlayView: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(
                        LinearGradient(colors: [.yellow, .orange, .red],
                                       startPoint: .leading,
                                       endPoint: .trailing))
                    .frame(width: CGFloat(difficulty) / 5 * proxy.size.width)
            }
        }
        .allowsHitTesting(false)
    }
}

struct DifficultyView_Previews: PreviewProvider {

    static var previews: some View {
        DifficultyView(difficulty: .constant(2))
    }
}
