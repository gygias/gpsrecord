//
//  MapViewController.m
//  GPSRecord
//
//  Created by david on 8/5/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "MapViewController.h"

#import "State.h"

@interface MapViewController ()

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    if ( ! [State state].startLocations )
    {
        [self _initStateFromTestData];
    }
    
    float spanX;// = 0.00725;
    float spanY;// = 0.00725;
    CLLocationCoordinate2D center;
    [self _center:&center spanX:&spanX spanY:&spanY];
    MKCoordinateRegion region;
    region.center.latitude = center.latitude;//self.mapView.userLocation.coordinate.latitude;
    region.center.longitude = center.longitude;//self.mapView.userLocation.coordinate.longitude;
    region.span.latitudeDelta = spanX;
    region.span.longitudeDelta = spanY;
    [self.mapView setRegion:region animated:NO];
    
    [self _drawPath];
}

- (void)_drawPath {
    
    // remove polyline if one exists
    [self.mapView removeOverlay:self.polyline];
    
    // create an array of coordinates from allPins
    unsigned long size = [State state].movingLocations.count + 2;
    CLLocationCoordinate2D coordinates[size];
    coordinates[0] = ((CLLocation *)[State state].startLocations.lastObject).coordinate;
    coordinates[size - 1] = ((CLLocation *)[State state].endLocations.lastObject).coordinate;
    int i = 0;
    for ( ; i + 1 < [State state].movingLocations.count + 1; i++ ) {
        coordinates[i + 1] = ((CLLocation *)[State state].movingLocations[i]).coordinate;
    }
    
    // create a polyline with all cooridnates
    MKPolyline *polyline = [MKPolyline polylineWithCoordinates:coordinates count:size];
    [self.mapView addOverlay:polyline];
    self.polyline = polyline;
    
    // create an MKPolylineView and add it to the map view
    self.lineView = [[MKPolylineView alloc] initWithPolyline:self.polyline];
    self.lineView.strokeColor = [UIColor redColor];
    self.lineView.lineWidth = 5;
    
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay {
    
    return self.lineView;
}

- (void)_center:(CLLocationCoordinate2D *)outCenter spanX:(float *)outSpanX spanY:(float *)outSpanY
{
    CLLocationCoordinate2D start = ((CLLocation *)[State state].startLocations.lastObject).coordinate;
    CLLocationCoordinate2D end = ((CLLocation *)[State state].endLocations.lastObject).coordinate;
    (*outCenter).latitude = ( start.latitude + end.latitude ) / 2;
    (*outCenter).longitude = (start.longitude + end.longitude ) / 2;
    
    CLLocationDegrees minLat = NAN, maxLat = NAN;
    CLLocationDegrees minLon = NAN, maxLon = NAN;
    BOOL first = YES;
    for ( CLLocation *location in [State state].movingLocations ) {
        if ( location.coordinate.latitude < minLat || first )
            minLat = location.coordinate.latitude;
        if ( location.coordinate.latitude > maxLat || first )
            maxLat = location.coordinate.latitude;
        if ( location.coordinate.longitude < minLon || first )
            minLon = location.coordinate.longitude;
        if ( location.coordinate.longitude > maxLon || first )
            maxLon = location.coordinate.longitude;
        first = NO;
    }
    
    *outSpanX = maxLat - minLat;
    *outSpanY = maxLon - minLon;
}

- (void)_initStateFromTestData
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"coords" ofType:@"plist"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSArray *array = [NSPropertyListSerialization propertyListWithData:data options:0 format:NULL error:NULL];
    NSMutableArray *aComponentArray = [NSMutableArray new];
    for ( NSDictionary *dict in array[0] )
    {
        double lat = ((NSNumber *)dict[@"lat"]).doubleValue;
        double lon = ((NSNumber *)dict[@"lon"]).doubleValue;
        CLLocation *location = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
        [aComponentArray addObject:location];
    }
    [State state].startLocations = aComponentArray;
    aComponentArray = [NSMutableArray new];
    
    for ( NSDictionary *dict in array[1] )
    {
        double lat = ((NSNumber *)dict[@"lat"]).doubleValue;
        double lon = ((NSNumber *)dict[@"lon"]).doubleValue;
        CLLocation *location = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
        [aComponentArray addObject:location];
    }
    [State state].movingLocations = aComponentArray;
    aComponentArray = [NSMutableArray new];
    
    for ( NSDictionary *dict in array[2] )
    {
        double lat = ((NSNumber *)dict[@"lat"]).doubleValue;
        double lon = ((NSNumber *)dict[@"lon"]).doubleValue;
        CLLocation *location = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
        [aComponentArray addObject:location];
    }
    [State state].endLocations = aComponentArray;
    aComponentArray = [NSMutableArray new];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
