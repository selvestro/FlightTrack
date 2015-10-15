//
//  ViewController.swift
//  FlightTrack
//
//  Created by Dmitry Seliverstov on 10.10.15.
//  Copyright © 2015 Dmitry Seliverstov. All rights reserved.
//

import UIKit
import MapKit

class FlightTrackViewController: UIViewController {

  var source: CLLocationCoordinate2D = TopLeft
  var destination: CLLocationCoordinate2D = BottomRight
  var sourceAnnotation: (key: String, coordinates: String) = ("MOW", "")
  var destinationAnnotation: (key: String, coordinates: String) = ("PEK", "")

  var flightArea: FlightArea = FlightArea(source: TopLeft, destination: BottomRight)
  
  var mapRegion : MKCoordinateRegion = MKCoordinateRegion()

  var mainRect: CGRect = CGRectMake(0, 0, 0, 0)

  var trackPathPoints: [CGPoint] = []
  var trackPathMapPoints: [MKMapPoint] = []
  var trackPathCoordinates: [CLLocationCoordinate2D] = []
  var trackPathVisiblePoints: [CLLocationCoordinate2D] = []

  var flightPathPolyline: MKGeodesicPolyline = MKGeodesicPolyline()
  var pathRendered = false
  
  var trackPathPolyline: MKGeodesicPolyline = MKGeodesicPolyline()
  
  var planeAnnotation: MKPointAnnotation = MKPointAnnotation()
  var planeAnnotationPosition: NSInteger = 0
  var planeAnnotationView: MKAnnotationView!
  var readyToFlight: Bool {
    if planeAnnotation.coordinate.latitude == source.latitude &&
      planeAnnotation.coordinate.longitude == source.longitude {
        return true
    } else {
      return false
    }
  }
  var isFlying = false

  override func viewDidLoad() {
    super.viewDidLoad()
    self.sourceButton.setTitle("MOW", forState: UIControlState.Normal)
    self.destinationButton.setTitle("PEK", forState: UIControlState.Normal)

    updateData()
  }
  
//  MARK: - Map Objects
  func clearMap() {
    trackPathPoints = []
    trackPathMapPoints = []
    trackPathCoordinates = []
    trackPathVisiblePoints = []
    mapView.removeAnnotations(mapView.annotations)
    mapView.removeOverlays(mapView.overlays)
  }
  
  func updateData() {
    
    createMap()
//    addBoundary()
    createCGRect()
    addFlightTrack()
    addFlightPath()
    addSourceAndDestination()
  }
  
  func createMap() {
    flightArea = FlightArea(source: source, destination: destination)
    mapRegion = flightArea.createArea()
    mapView.setRegion(mapRegion, animated: true)
  }
  
  func addBoundary() {
    var coordinates = flightArea.boundaryCoordinates
    let polygon = MKPolygon(coordinates: &coordinates, count: coordinates.count)
    mapView.addOverlay(polygon)
  }
  
  func createCGRect() {
    
    let sourcePoint = mapView.convertCoordinate(source, toPointToView: self.view)
    
    let destinationPoint = mapView.convertCoordinate(destination, toPointToView: self.view)
    
    mainRect = CGRectMake(min(sourcePoint.x, destinationPoint.x), min(sourcePoint.y, destinationPoint.y), fabs(sourcePoint.x - destinationPoint.x), fabs(sourcePoint.y - destinationPoint.y));
  }

  func addFlightTrack() {
    trackPathPoints = []
    let sourcePoint: CGPoint = mapView.convertCoordinate(source, toPointToView: self.view)
    let destinationPoint: CGPoint = mapView.convertCoordinate(destination, toPointToView: self.view)
    
    let flightTrack: FlightTrack = FlightTrack(source: sourcePoint, destination: destinationPoint)
    flightTrack.drawWave()
    trackPathPoints = flightTrack.outputPoints
    
    for point in trackPathPoints {
      let coordinate = mapView.convertPoint(point, toCoordinateFromView: self.view)
      trackPathCoordinates.append(coordinate)
    }
    if !trackPathCoordinates.isEmpty {
      trackPathCoordinates.removeFirst()
    }
    trackPathCoordinates.append(destination)

    for index in 0..<trackPathCoordinates.count {
      if index % 5 == 0 {
        trackPathVisiblePoints.append(trackPathCoordinates[index])
      }
    }
    
    for coordinate in trackPathVisiblePoints {
      let pointRadius = CLLocationDistance(max(100000, Int(rand()%10)))
      let trackPoint: TrackPoint = TrackPoint(centerCoordinate: coordinate, radius: pointRadius)
      trackPoint.color = UIColor.grayColor()
      mapView.addOverlay(trackPoint)
    }
  }
  
  func addSourceAndDestination() {
    let pointRadius = CLLocationDistance(max(30000, Int(rand()%10)))
    let sourcePoint: TrackPoint = TrackPoint(centerCoordinate: source, radius: pointRadius)
    sourcePoint.color = UIColor.greenColor()
    mapView.addOverlay(sourcePoint)
    
    let sAnnotation = TrackPointAnnotation(coordinate: source, title: sourceAnnotation.key, subtitle: sourceAnnotation.coordinates, type: TrackPointType.Source)
    mapView.addAnnotation(sAnnotation)
    
    let destinationPoint: TrackPoint = TrackPoint(centerCoordinate: destination, radius: pointRadius)
    destinationPoint.color = UIColor.redColor()
    mapView.addOverlay(destinationPoint)
    
    let dAnnotation = TrackPointAnnotation(coordinate: destination, title: destinationAnnotation.key, subtitle: destinationAnnotation.coordinates, type: TrackPointType.Destination)
    mapView.addAnnotation(dAnnotation)
  }
  
  func addFlightPath() {
    var coordinates : [CLLocationCoordinate2D] = trackPathCoordinates
    flightPathPolyline = MKGeodesicPolyline(coordinates:&coordinates, count:coordinates.count)
    
    mapView.addOverlay(flightPathPolyline)
    
    planeAnnotation = MKPointAnnotation()
    planeAnnotation.coordinate = source
    
    mapView.addAnnotation(planeAnnotation)
  }

  func updatePlanePosition() {
    
    let step:NSInteger = 50
    if (planeAnnotationPosition + step >= flightPathPolyline.pointCount) {
      isFlying = false
      planeAnnotationPosition = 0
      return;
    }
    
    let previousPolyLinePoints = flightPathPolyline.points()
    let previousMapPoint: MKMapPoint = previousPolyLinePoints[planeAnnotationPosition]
    
    planeAnnotationPosition += step
    
    let nextPolyLinePoints = flightPathPolyline.points()
    let nextMapPoint: MKMapPoint = nextPolyLinePoints[planeAnnotationPosition]
    let nextCoord: CLLocationCoordinate2D = MKCoordinateForMapPoint(nextMapPoint)
    let planeDirection = DirectionBetweenPoints(previousMapPoint, nextMapPoint: nextMapPoint)
    planeAnnotation.coordinate = nextCoord
    planeAnnotationView.transform = CGAffineTransformRotate(mapView.transform, DegreesToRadians(planeDirection));
    
    let delay = 0.05 * Double(NSEC_PER_SEC)
    let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
    
    dispatch_after(time, dispatch_get_main_queue(), {
      self.updatePlanePosition()
    })
  }
  
//  MARK: - MapView Delegates
  func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer! {
    
    if overlay is MKPolygon {
      let polygonView = MKPolygonRenderer(overlay: overlay)
      polygonView.strokeColor = UIColor.greenColor()
      return polygonView

    } else if overlay is MKGeodesicPolyline {

    } else if overlay is TrackPoint {
      let circleView = MKCircleRenderer(overlay: overlay)
      circleView.strokeColor = (overlay as! TrackPoint).color
      circleView.fillColor = (overlay as! TrackPoint).color
      return circleView
    }
    return nil
  }
  
  func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
  
    if annotation is TrackPointAnnotation {
      let identifier = "TrackPoint"
      var point = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
      if point == nil {
        point = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        let label: UILabel! = UILabel(frame: CGRectMake(-24, 40, 100, 30))
        label.textColor = UIColor.yellowColor()
        
        if annotation.title! == sourceAnnotation.key {
          label.font = UIFont(name: sourceAnnotation.key, size: 10)
        } else if annotation.title! == destinationAnnotation.key {
          label.font = UIFont(name: destinationAnnotation.key, size: 10)
        }
        label.textAlignment = NSTextAlignment.Center
        point!.addSubview(label)
      } else {
        point!.annotation = annotation
      }
      return point
      
    } else {
      let identifier = "Plane"
      if planeAnnotationView == nil {
        planeAnnotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
      }
      planeAnnotationView.image = UIImage(named: "plane")!
      planeAnnotationView.annotation = annotation
      return planeAnnotationView
    }
  }
  
  func mapViewWillStartRenderingMap(mapView: MKMapView) {
    createCGRect()
  }
  
  func mapViewDidFinishRenderingMap(mapView: MKMapView, fullyRendered: Bool) {
  }
  
//  MARK: - Segues
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    
    let vc: PointsViewController = segue.destinationViewController as! PointsViewController
    if segue.identifier == "Source" {
      vc.isSource = true
    } else if segue.identifier == "Destination" {
      vc.isSource = false
    }
  }
  
//  MARK: - Controls
  @IBOutlet weak var sourceButton: UIButton!
  @IBOutlet weak var destinationButton: UIButton!
  
  @IBOutlet weak var mapView: MKMapView!
  
  @IBOutlet weak var startButton: UIButton!
  

//  MARK: - Actions
  @IBAction func pointButtonPressed(sender: UIButton) {
  }
  @IBAction func pointDidPicked(segue: UIStoryboardSegue) {
    
    let vc: PointsViewController = segue.sourceViewController as! PointsViewController
    if let selected = vc.selected {
      for (key, value) in selected {
        if vc.isSource {
          self.sourceButton.setTitle(key, forState: UIControlState.Normal)
          source = value
          self.sourceAnnotation = (key, String(value))
        } else {
          self.destinationButton.setTitle(key, forState: UIControlState.Normal)
          destination = value
          self.destinationAnnotation = (key, String(value))
        }
      }
      if source.latitude == destination.latitude &&
        source.longitude == destination.longitude {
          clearMap()
      } else {
        clearMap()
        updateData()
      }
    }
  }
  
  @IBAction func startButtonPressed(sender: UIButton) {
        
    if readyToFlight {
      isFlying = true
      updatePlanePosition()
    } else {
      planeAnnotation.coordinate = source
    }
  }
}