//
//  PointsViewController.swift
//  FlightTrack
//
//  Created by Dmitry Seliverstov on 10.10.15.
//  Copyright © 2015 Dmitry Seliverstov. All rights reserved.
//

import UIKit
import MapKit

class PointsViewController: UITableViewController {
  
  var isSource = true
  var selected: [String: CLLocationCoordinate2D]?
  
  let points: [[String: CLLocationCoordinate2D]] = [
    ["DEL": CLLocationCoordinate2DMake(55.3047200, 77.2289700)],
    ["DUB": CLLocationCoordinate2DMake(25.2581700, 55.3047200)],
    ["PEK": CLLocationCoordinate2DMake(39.9075000, 116.3972300)],
    ["LAX": CLLocationCoordinate2DMake(34.0522300	, -118.2436800)],
    ["LED": CLLocationCoordinate2DMake(59.9386300, 30.3141300)],
    ["MOW": CLLocationCoordinate2DMake(55.7522200, 37.6155600)],
    ["NYC": CLLocationCoordinate2DMake(40.7142700, -74.0059700)],
    ["RIO": CLLocationCoordinate2DMake(-22.9027800, -43.2075000)],
    ["SIN": CLLocationCoordinate2DMake(1.2896700, 103.8500700)],
    ["TYO": CLLocationCoordinate2DMake(35.6895000, 139.6917100)],
    ["SYD": CLLocationCoordinate2DMake(-33.8678500, 151.2073200)],
    ["MEX": CLLocationCoordinate2DMake(19.4284700, -99.1276600)]
  ]
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return points.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
    let point = points[indexPath.row] as [String: CLLocationCoordinate2D]
    let key: String = point.keys.first!
    cell.textLabel?.text! = key
    let coord: CLLocationCoordinate2D = point[key]!
    cell.detailTextLabel?.text = String("LAT: \(coord.latitude), LONG:\(coord.longitude)")
    return cell
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let point = points[indexPath.row] as [String: CLLocationCoordinate2D]
    selected = point
    self.performSegueWithIdentifier("Exit", sender: nil)
  }
}
