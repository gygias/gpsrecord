//
//  MapViewController.h
//  GPSRecord
//
//  Created by david on 8/5/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MapKit/MapKit.h>

@interface MapViewController : UIViewController

@property IBOutlet MKMapView *mapView;
@property MKPolyline *polyline;
@property MKPolylineView *lineView;

@end
