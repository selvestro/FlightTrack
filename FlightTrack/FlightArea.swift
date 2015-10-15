//
//  FlightArea.swift
//  FlightTrack
//
//  Created by Dmitry Seliverstov on 10.10.15.
//  Copyright © 2015 Dmitry Seliverstov. All rights reserved.
//

import Foundation
import MapKit

class FlightArea {
  
  var source: CLLocationCoordinate2D
  var destination: CLLocationCoordinate2D
  
  init(source: CLLocationCoordinate2D, destination: CLLocationCoordinate2D) {
    self.source = source
    self.destination = destination
  }
  
  var mapRect: MKMapRect {
    var mr = MKMapRectNull
    let sourcePoint = MKMapPointForCoordinate(source)
    mr = MKMapRectUnion(mr, MKMapRectMake(sourcePoint.x, sourcePoint.y, 0, 0))
    
    let destinationPoint = MKMapPointForCoordinate(destination)
    mr = MKMapRectUnion(mr, MKMapRectMake(destinationPoint.x, destinationPoint.y, 0, 0))
    
    return mr
  }
  
  func createArea() -> MKCoordinateRegion {
    
    let region = MKCoordinateRegionForMapRect(mapRect)
    
    var latitudeDelta = fabs(topLeftCoordinate.latitude - bottomRightCoordinate.latitude) * 1.1;
    var longitudeDelta = fabs(bottomRightCoordinate.longitude - topLeftCoordinate.longitude) * 1.1;
    
    if latitudeDelta < 100 || latitudeDelta > 200{
      latitudeDelta = 100
    }
    if longitudeDelta < 100 || longitudeDelta > 200 {
      longitudeDelta = 100
    }
    let span = MKCoordinateSpanMake(latitudeDelta, longitudeDelta)
    
    return MKCoordinateRegionMake(region.center, span)
  }
  
  var flightDirection: Direction.FlightDirection {
    return Direction.directionFromCoordinates(source, destination: destination)
  }
  
  var topLeftCoordinate: CLLocationCoordinate2D {
    switch flightDirection {
    case .Nord:
      return CLLocationCoordinate2DMake(destination.latitude, destination.longitude)
    case .NordEast:
      return CLLocationCoordinate2DMake(destination.latitude, source.longitude)
    case .East:
      return CLLocationCoordinate2DMake(source.latitude, source.longitude)
    case .SouthEast:
      return CLLocationCoordinate2DMake(source.latitude, source.longitude)
    case .South:
      return CLLocationCoordinate2DMake(source.latitude, source.longitude)
    case .SouthWest:
      return CLLocationCoordinate2DMake(destination.latitude, source.longitude)
    case .West:
      return CLLocationCoordinate2DMake(destination.latitude, destination.longitude)
    case .NordWest:
      return CLLocationCoordinate2DMake(destination.latitude, destination.longitude)
    default:
      return CLLocationCoordinate2DMake(source.latitude, source.longitude)
    }
  }
  
  var topRightCoordinate: CLLocationCoordinate2D {
    return CLLocationCoordinate2DMake(topLeftCoordinate.latitude, bottomRightCoordinate.longitude)
  }
  
  var bottomRightCoordinate: CLLocationCoordinate2D {
    switch flightDirection {
    case .Nord:
      return CLLocationCoordinate2DMake(source.latitude, source.longitude)
    case .NordEast:
      return CLLocationCoordinate2DMake(source.latitude, destination.longitude)
    case .East:
      return CLLocationCoordinate2DMake(destination.latitude, destination.longitude)
    case .SouthEast:
      return CLLocationCoordinate2DMake(destination.latitude, destination.longitude)
    case .South:
      return CLLocationCoordinate2DMake(destination.latitude, destination.longitude)
    case .SouthWest:
      return CLLocationCoordinate2DMake(source.latitude, destination.longitude)
    case .West:
      return CLLocationCoordinate2DMake(source.latitude, source.longitude)
    case .NordWest:
      return CLLocationCoordinate2DMake(source.latitude, source.longitude)
    default:
      return CLLocationCoordinate2DMake(destination.latitude, destination.longitude)
    }
  }
  
  var bottomLeftCoordinate: CLLocationCoordinate2D {
    return CLLocationCoordinate2DMake(bottomRightCoordinate.latitude, topLeftCoordinate.longitude)
  }
  
  var boundaryCoordinates: [CLLocationCoordinate2D] {
    return [
      topLeftCoordinate, topRightCoordinate, bottomRightCoordinate, bottomLeftCoordinate
    ]
  }
}