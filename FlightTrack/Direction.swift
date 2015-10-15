//
//  Direction.swift
//  FlightTrack
//
//  Created by Dmitry Seliverstov on 10.10.15.
//  Copyright © 2015 Dmitry Seliverstov. All rights reserved.
//

import Foundation
import MapKit

struct Direction {
  
  enum FlightDirection {
    case Nord
    case NordEast
    case East
    case SouthEast
    case South
    case SouthWest
    case West
    case NordWest
    case Undefined
  }
  
  static func directionFromCoordinates(source : CLLocationCoordinate2D,
    destination : CLLocationCoordinate2D) -> FlightDirection {
      
      if source.latitude < destination.latitude &&
        source.longitude == destination.longitude {
          return .Nord
      } else if source.latitude < destination.latitude &&
        source.longitude < destination.longitude {
          return .NordEast
      } else if source.latitude == destination.latitude &&
        source.longitude < destination.longitude {
          return .East
      } else if source.latitude > destination.latitude &&
        source.longitude < destination.longitude {
          return .SouthEast
      } else if source.latitude > destination.latitude &&
        source.longitude == destination.longitude {
          return .South
      } else if source.latitude > destination.latitude &&
        source.longitude > destination.longitude {
          return .SouthWest
      } else if source.latitude == destination.latitude &&
        source.longitude > destination.longitude {
          return .West
      } else if source.latitude < destination.latitude &&
        source.longitude > destination.longitude {
          return .NordWest
      } else {
        return .Undefined
      }
  }
  
  static func directionFromPoints(source : CGPoint,
    destination : CGPoint) -> FlightDirection {
      
      if source.x == destination.x &&
        source.y > destination.y {
          return .Nord
      } else if source.x < destination.x &&
        source.y > destination.y {
          return .NordEast
      } else if source.x < destination.x &&
        source.y == destination.y {
          return .East
      } else if source.x < destination.x &&
        source.y < destination.y {
          return .SouthEast
      } else if source.x == destination.x &&
        source.y < destination.y {
          return .South
      } else if source.x > destination.x &&
        source.y < destination.y {
          return .SouthWest
      } else if source.x > destination.x &&
        source.y == destination.y {
          return .West
      } else if source.x > destination.x &&
        source.y > destination.y {
          return .NordWest
      } else {
        return .Undefined
      }
  }
}