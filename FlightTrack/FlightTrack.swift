//
//  FlightTrack.swift
//  FlightTrack
//
//  Created by Dmitry Seliverstov on 10.10.15.
//  Copyright © 2015 Dmitry Seliverstov. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class FlightTrack  {
  
  var source: CGPoint
  var destination: CGPoint
  
  init(source: CGPoint, destination: CGPoint) {
    self.source = source
    self.destination = destination
  }
  
  var mainRect : CGRect = CGRectMake(0, 0, 0, 0)
  
  var direction : Direction.FlightDirection {
    return Direction.directionFromPoints(source, destination: destination)
  }
  
  var topLeftPoint: CGPoint {
    switch direction {
    case .Nord:
      return CGPoint(x: destination.x, y: destination.y)
    case .NordEast:
      return CGPoint(x: source.x, y: destination.y)
    case .East:
      return CGPoint(x: source.x, y: source.y)
    case .SouthEast:
      return CGPoint(x: source.x, y: source.y)
    case .South:
      return CGPoint(x: source.x, y: source.y)
    case .SouthWest:
      return CGPoint(x: destination.x, y: source.y)
    case .West:
      return CGPoint(x: destination.x, y: destination.y)
    case .NordWest:
      return CGPoint(x: destination.x, y: destination.y)
    default:
      return CGPoint(x: source.x, y: destination.y)
    }
  }
  
  var bottomRightPoint: CGPoint {
    switch direction {
    case .Nord:
      return CGPoint(x: source.x, y: source.y)
    case .NordEast:
      return CGPoint(x: destination.x, y: source.y)
    case .East:
      return CGPoint(x: destination.x, y: destination.y)
    case .SouthEast:
      return CGPoint(x: destination.x, y: destination.y)
    case .South:
      return CGPoint(x: destination.x, y: destination.y)
    case .SouthWest:
      return CGPoint(x: source.x, y: destination.y)
    case .West:
      return CGPoint(x: source.x, y: source.y)
    case .NordWest:
      return CGPoint(x: source.x, y: source.y)
    default:
      return CGPoint(x: source.x, y: destination.y)
    }
  }
  var topRightPoint: CGPoint {
    return CGPoint(x: bottomRightPoint.x, y: topLeftPoint.y)
  }
  var bottomLeftPoint: CGPoint {
    return CGPoint(x: topLeftPoint.x, y: bottomRightPoint.y)
  }
  
  var theRect : CGRect {
    return CGRectMake(topLeftPoint.x, topLeftPoint.y, topRightPoint.x - topLeftPoint.x, bottomLeftPoint.y - topLeftPoint.y)
  }
  
  var size: CGSize {
    return CGSizeMake(mainRect.width, mainRect.height)
  }
  
  var waveLength : CGFloat {
    return CGFloat(hypot(Double(theRect.size.width), Double(theRect.size.height)))
  }
  
  let rotate = true
  
  let sineArray = Sine(SineArraySize, amplitude: Amplitude, frequency: Frequency, phase: Phase)
  
  var sineArraySize : Int {
    return SineArraySize
  }
  
  var yArray: [CGFloat] {
    var array : [CGFloat] = []
    for value in sineArray {
      array.append(CGFloat(value * 10000))
    }
    return array
  }

  func points() -> [CGPoint] {
    let stepX = waveLength / CGFloat(sineArraySize)
    var startX : CGFloat = 0
    
    var array : [CGPoint] = []
    
    for value in yArray {
      let p = CGPoint(x: startX, y: value)
      array.append(p)
      startX = startX + stepX
    }
    return array
  }
  
  func drawRect(rect: CGRect) -> UIImage {
    UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
    
    let drawing = UIBezierPath()
    drawing.moveToPoint(topLeftPoint)
    
    drawing.addLineToPoint(topRightPoint)
    drawing.addLineToPoint(bottomRightPoint)
    drawing.addLineToPoint(bottomLeftPoint)
    drawing.closePath()
    
    drawing.lineWidth = 5
    UIColor.redColor().setStroke()
    drawing.stroke()
    
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image
  }

  var rectAngleForWave : Double {
    var angle : Double = 0.0
    angle = atan(Double(theRect.size.width) / Double(theRect.size.height))
    return angle
  }
  
  var rectHeightForWave : CGFloat {
    return waveLength * CGFloat(sin(rectAngleForWave))
  }
  var angle : Double {
      
    switch direction {
    case .Nord: return -M_PI_2
    case .NordEast: return rectAngleForWave - M_PI_2
    case .East: return 0
    case .SouthEast: return M_PI_2 - rectAngleForWave
    case .South: return M_PI_2
    case .SouthWest: return M_PI_2 + rectAngleForWave
    case .West: return -M_PI
    case .NordWest: return -M_PI_2 - rectAngleForWave
    default: return rectAngleForWave
    }
  }
  var degreesAngle : Double {
    return RadiansToDegrees(angle)
  }
  
  var wavePath : UIBezierPath = UIBezierPath()
  
  func drawWave() {
    
    UIColor.clearColor().setStroke()
    
    wavePath.moveToPoint(source)
    
    var rotation : CGAffineTransform = CGAffineTransform()
    let move : CGAffineTransform = CGAffineTransformMakeTranslation(source.x, source.y)
    if rotate {
      rotation = CGAffineTransformMakeRotation(CGFloat(angle))
    }
    
    for point in points() {
      wavePath.addLineToPoint(point)
    }
    
    wavePath.applyTransform(rotation)
    wavePath.applyTransform(move)
    wavePath.lineWidth = 5
  }

  var outputPoints : [CGPoint] {
    var array : [CGPoint] = []
    for element in wavePath {
      array.append(element.output)
    }
    return array
  }
}