//
//  ConfettiView.swift
//  ACSP Exam Prep
//
//  Created by Craig Opie on 7/2/24.
//

import Foundation
import SwiftUI
import UIKit

struct ConfettiView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()

        let emitterLayer = CAEmitterLayer()
        emitterLayer.emitterShape = .line
        emitterLayer.emitterPosition = CGPoint(x: UIScreen.main.bounds.width / 2, y: -10)
        emitterLayer.emitterSize = CGSize(width: UIScreen.main.bounds.width, height: 1)

        let colors: [UIColor] = [
            .red, .green, .blue, .yellow, .orange, .purple, .cyan, .magenta
        ]

        let cells: [CAEmitterCell] = colors.map { color in
            let cell = CAEmitterCell()
            cell.birthRate = 4
            cell.lifetime = 10.0
            cell.color = color.cgColor
            cell.velocity = 200
            cell.velocityRange = 50
            cell.emissionLongitude = .pi
            cell.emissionRange = .pi / 4
            cell.spin = 3.5
            cell.spinRange = 1.0
            cell.scaleRange = 0.25
            cell.scaleSpeed = -0.05
            cell.contents = UIImage(named: "confetti")?.cgImage
            return cell
        }

        emitterLayer.emitterCells = cells
        view.layer.addSublayer(emitterLayer)

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            emitterLayer.birthRate = 0
        }

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
