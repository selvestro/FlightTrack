//
//  Extensions.swift
//  FlightTrack
//
//  Created by Dmitry Seliverstov on 10.10.15.
//  Copyright © 2015 Dmitry Seliverstov. All rights reserved.
//

import Foundation
import MapKit

let SineArraySize = 100
let Amplitude = 0.005
let Frequency = 2.0
let Phase = 0.0

let TopLeft = CLLocationCoordinate2DMake(55.7522200, 37.6155600)
let BottomRight = CLLocationCoordinate2DMake(39.9075000, 116.3972300)
let TopRight = CLLocationCoordinate2DMake(60,110)
let BottomLeft = CLLocationCoordinate2DMake(30,30)

public enum PathElement {
  case MoveToPoint(CGPoint)
  case AddLineToPoint(CGPoint)
  case AddQuadCurveToPoint(CGPoint, CGPoint)
  case AddCurveToPoint(CGPoint, CGPoint, CGPoint)
  case CloseSubpath
  
  init(element: CGPathElement) {
    switch element.type {
    case .MoveToPoint:
      self = .MoveToPoint(element.points[0])
    case .AddLineToPoint:
      self = .AddLineToPoint(element.points[0])
    case .AddQuadCurveToPoint:
      self = .AddQuadCurveToPoint(element.points[0], element.points[1])
    case .AddCurveToPoint:
      self = .AddCurveToPoint(element.points[0], element.points[1], element.points[2])
    case .CloseSubpath:
      self = .CloseSubpath
    }
  }
}
extension PathElement : CustomDebugStringConvertible {
  public var debugDescription: String {
    switch self {
    case let .MoveToPoint(point):
      return "\(point.x) \(point.y) moveto"
    case let .AddLineToPoint(point):
      return "\(point.x) \(point.y) lineto"
    case let .AddQuadCurveToPoint(point1, point2):
      return "\(point1.x) \(point1.y) \(point2.x) \(point2.y) quadcurveto"
    case let .AddCurveToPoint(point1, point2, point3):
      return "\(point1.x) \(point1.y) \(point2.x) \(point2.y) \(point3.x) \(point3.y) curveto"
    case .CloseSubpath:
      return "closepath"
    }
  }
  public var output : CGPoint {
    switch self {
    case let .AddLineToPoint(point):
      return CGPoint(x: point.x, y: point.y)
    default:
      return CGPoint(x: 0, y: 0)
    }
  }
}

extension PathElement : Equatable { }

public func ==(lhs: PathElement, rhs: PathElement) -> Bool {
  switch(lhs, rhs) {
  case let (.MoveToPoint(l), .MoveToPoint(r)):
    return l == r
  case let (.AddLineToPoint(l), .AddLineToPoint(r)):
    return l == r
  case let (.AddQuadCurveToPoint(l1, l2), .AddQuadCurveToPoint(r1, r2)):
    return l1 == r1 && l2 == r2
  case let (.AddCurveToPoint(l1, l2, l3), .AddCurveToPoint(r1, r2, r3)):
    return l1 == r1 && l2 == r2 && l3 == r3
  case (.CloseSubpath, .CloseSubpath):
    return true
  case (_, _):
    return false
  }
}
extension UIBezierPath {
  var elements: [PathElement] {
    var pathElements = [PathElement]()
    withUnsafeMutablePointer(&pathElements) { elementsPointer in
      CGPathApply(CGPath, elementsPointer) { (userInfo, nextElementPointer) in
        let nextElement = PathElement(element: nextElementPointer.memory)
        let elementsPointer = UnsafeMutablePointer<[PathElement]>(userInfo)
        elementsPointer.memory.append(nextElement)
      }
    }
    return pathElements
  }
}
extension UIBezierPath : SequenceType {
  public func generate() -> AnyGenerator<PathElement> {
    return anyGenerator(elements.generate())
  }
}
extension UIBezierPath : CustomDebugStringConvertible {
  public override var debugDescription: String {
    let cgPath = self.CGPath;
    let bounds = CGPathGetPathBoundingBox(cgPath);
    let controlPointBounds = CGPathGetBoundingBox(cgPath);
    
    let description = "\(self.dynamicType)\n"
      + "    Bounds: \(bounds)\n"
      + "    Control Point Bounds: \(controlPointBounds)"
      + elements.reduce("", combine: { (acc, element) in
        acc + "\n    \(String(reflecting: element))"
      })
    return description
  }
}

func Sine(sineArraySize: Int,
  amplitude: Double,
  frequency: Double,
  phase: Double) -> [Double] {
    let sineWave = (0..<sineArraySize).map {
      amplitude * sin(1 * M_PI / Double(sineArraySize) * Double($0) * frequency + phase)
    }
    return sineWave
}

func RadiansToDegrees(radians: Double) -> Double {
  return radians * 180.0 / M_PI
}
func DegreesToRadians(degrees: Double) -> CGFloat {
  return CGFloat(degrees * M_PI / 180.0)
}
func DirectionBetweenPoints(previousMapPoint: MKMapPoint, nextMapPoint: MKMapPoint) -> CLLocationDirection {
  let x: Double = nextMapPoint.x - previousMapPoint.x
  let y: Double = nextMapPoint.y - previousMapPoint.y
  
  return fmod(RadiansToDegrees(atan2(y, x)), 360.0) + 90.0
}