//
//  KnobRenderer.swift
//  KnobControl
//
//  Created by VINHLT6 on 10/24/20.
//  Copyright © 2020 VINHLT6. All rights reserved.
//

import Foundation
import UIKit

class KnobRenderer {
  var color: UIColor = .blue {
    didSet {
      trackLayer.strokeColor = color.cgColor
      pointerLayer.strokeColor = color.cgColor
    }
  }

  var lineWidth: CGFloat = 2 {
    didSet {
      trackLayer.lineWidth = lineWidth
      pointerLayer.lineWidth = lineWidth
      updateTrackLayerPath()
      updatePointerLayerPath()
    }
  }

  var startAngle: CGFloat = CGFloat(-Double.pi) * 11 / 8 {
    didSet {
      updateTrackLayerPath()
    }
  }

  var endAngle: CGFloat = CGFloat(Double.pi) * 3 / 8 {
    didSet {
      updateTrackLayerPath()
    }
  }

  var pointerLength: CGFloat = 6 {
    didSet {
      updateTrackLayerPath()
      updatePointerLayerPath()
    }
  }

  private (set) var pointerAngle: CGFloat = CGFloat(-Double.pi) * 11 / 8

  func setPointerAngle(_ newPointerAngle: CGFloat, animated: Bool = false) {
    CATransaction.begin()
    CATransaction.setDisableActions(true)

    pointerLayer.transform = CATransform3DMakeRotation(newPointerAngle, 0, 0, 1)

    if animated {
      let midAngleValue = (max(newPointerAngle, pointerAngle) - min(newPointerAngle, pointerAngle)) / 2 + min(newPointerAngle, pointerAngle)
      let animation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
      animation.values = [pointerAngle, midAngleValue, newPointerAngle]
      animation.keyTimes = [0.0, 0.5, 1.0]
      animation.timingFunctions = [CAMediaTimingFunction(name: .easeInEaseOut)]
      pointerLayer.add(animation, forKey: nil)
    }

    CATransaction.commit()

    pointerAngle = newPointerAngle
  }

  let trackLayer = CAShapeLayer()
  let pointerLayer = CAShapeLayer()

  init() {
    trackLayer.fillColor = UIColor.clear.cgColor
    pointerLayer.fillColor = UIColor.clear.cgColor
  }

  private func updateTrackLayerPath() {
    let bounds = trackLayer.bounds
    let center = CGPoint(x: bounds.midX, y: bounds.midY)
    let offset = max(pointerLength, lineWidth  / 2)
    let radius = min(bounds.width, bounds.height) / 2 - offset

    let ring = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
    trackLayer.path = ring.cgPath
  }

  private func updatePointerLayerPath() {
    let bounds = trackLayer.bounds

    let pointer = UIBezierPath()
    pointer.move(to: CGPoint(x: bounds.width - CGFloat(pointerLength) - CGFloat(lineWidth) / 2, y: bounds.midY))
    pointer.addLine(to: CGPoint(x: bounds.width, y: bounds.midY))
    pointerLayer.path = pointer.cgPath
  }

  func updateBounds(_ bounds: CGRect) {
    trackLayer.bounds = bounds
    trackLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
    updateTrackLayerPath()

    pointerLayer.bounds = trackLayer.bounds
    pointerLayer.position = trackLayer.position
    updatePointerLayerPath()
  }
}
