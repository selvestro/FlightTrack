//
//  FlightTrackOverlay.swift
//  FlightTrack
//
//  Created by Dmitry Seliverstov on 10.10.15.
//  Copyright © 2015 Dmitry Seliverstov. All rights reserved.
//

import Foundation
import MapKit

class FlightTrackOverlay : NSObject, MKOverlay {
  
  var area : FlightArea
  
  init(area: FlightArea) {
    self.area = area
  }
  var coordinate : CLLocationCoordinate2D {
    let region = MKCoordinateRegionForMapRect(area.mapRect)
    return region.center
  }

  var boundingMapRect : MKMapRect {
    return self.area.mapRect
  }
}