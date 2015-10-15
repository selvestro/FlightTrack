//
//  TrackPoint.swift
//  FlightTrack
//
//  Created by Dmitry Seliverstov on 10.10.15.
//  Copyright © 2015 Dmitry Seliverstov. All rights reserved.
//

import Foundation
import UIKit
import MapKit

enum TrackPointType {
  case Source
  case Destination
  case RoutePoint
}

class TrackPoint: MKCircle {
  var name: String?
  var color: UIColor?
}

class TrackPointAnnotation: NSObject, MKAnnotation {
  var coordinate: CLLocationCoordinate2D
  var title: String?
  var subtitle: String?
  var type: TrackPointType
  
  init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String, type: TrackPointType) {
    self.coordinate = coordinate
    self.title = title
    self.subtitle = subtitle
    self.type = type
  }
}

class TrackPointAnnotationView: MKAnnotationView {
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
    super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    let trackPointAnnotation = self.annotation as! TrackPointAnnotation
    switch (trackPointAnnotation.type) {
    case .RoutePoint:
      image = UIImage(named: "routePoint")
    case .Source:
      image = UIImage(named: "source")
    case .Destination:
      image = UIImage(named: "destination")
    }
    
  }
  
  func drawCirclePoint(point: CGPoint, type: TrackPointType) -> UIImage {
    
    let drawing = UIBezierPath()
    drawing.addArcWithCenter(point, radius: 5, startAngle: 0, endAngle: CGFloat(2 * M_PI), clockwise: true)
    
    if type == .RoutePoint {
      UIColor.redColor().setStroke()
    } else if type == .Source {
      UIColor.greenColor().setStroke()
    } else if type == .Destination {
      UIColor.whiteColor().setStroke()
    } else {
      UIColor.redColor().setStroke()
    }
    
    drawing.lineWidth = 5
    drawing.stroke()
    
    let image = UIGraphicsGetImageFromCurrentImageContext()
    return image
  }
}