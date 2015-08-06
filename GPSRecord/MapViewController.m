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

//+ (UIImage *)mapImage
//{
//    MapViewController *vc = [MapViewController new];
//    CGRect frame = CGRectMake(0,0,400,400);
//    vc.mapView = [[MKMapView alloc] initWithFrame:frame];
//    vc.mapView.bounds = frame;
//    [vc _centerView];
//    [vc _drawPath];
//    [vc.mapView drawRect:frame];
//    //[vc.mapView drawLayer: inContext:]
//    return [vc getImage];
//}

- (void)viewWillAppear:(BOOL)animated
{
//    if ( ! [State state].startLocations )
//    {
//        [self _initStateFromTestData];
//    }
    
    [self update];
}

- (void)update
{
    //NSLog(@"updating...");
    [self _arrangeView];
    [self.view setNeedsDisplay];
}

- (IBAction)backPressed:(id)sender
{
    [State state].mapImage = [self getImage];
}

- (UIImage *)getImage
{
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, self.view.opaque, 0.0);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)_arrangeView
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ((MKMapView *)self.view).delegate = (id<MKMapViewDelegate>)self;
    });
    
    BOOL hasStart = [State state].startLocations.count > 0;
    
    if ( ! hasStart )
        return;
    
    BOOL hasEnd = [State state].endLocations.count > 0;
    BOOL hasMiddle = [State state].movingLocations.count > 0;
    
    float spanX;// = 0.00725;
    float spanY;// = 0.00725;
    CLLocationCoordinate2D center;
    //[self _center:&center spanX:&spanX spanY:&spanY];
    
    CLLocationCoordinate2D start = ((CLLocation *)[State state].startLocations.lastObject).coordinate;
    CLLocationCoordinate2D end = hasEnd ? ((CLLocation *)[State state].endLocations.lastObject).coordinate : start;
    center.latitude = ( start.latitude + end.latitude ) / 2;
    center.longitude = ( start.longitude + end.longitude ) / 2;
    
    if ( hasMiddle )
    {
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
        
        spanX = maxLat - minLat;
        spanY = maxLon - minLon;
    }
    else
    {
        spanX = 0.005;
        spanY = 0.005;
    }
    
    MKCoordinateRegion region;
    region.center.latitude = center.latitude;//self.mapView.userLocation.coordinate.latitude;
    region.center.longitude = center.longitude;//self.mapView.userLocation.coordinate.longitude;
    region.span.latitudeDelta = spanX;
    region.span.longitudeDelta = spanY;
    
    [(MKMapView *)self.view setRegion:region animated:NO];
    
    // remove polyline if one exists
    [(MKMapView *)self.view removeOverlay:self.polyline];
    
    // create an array of coordinates from allPins
    unsigned long size = [State state].movingLocations.count +
                                    ( hasStart ? 1 : 0 ) +
                                    ( hasEnd ? 1 : 0 );
    CLLocationCoordinate2D coordinates[size];

    coordinates[0] = ((CLLocation *)[State state].startLocations.lastObject).coordinate;
    if ( hasMiddle )
    {
        int i = 0;
        for ( ; i + 1 < [State state].movingLocations.count + 1; i++ ) {
            coordinates[i + 1] = ((CLLocation *)[State state].movingLocations[i]).coordinate;
        }
    }
    if ( hasEnd )
        coordinates[size - 1] = ((CLLocation *)[State state].endLocations.lastObject).coordinate;
    
    // create a polyline with all cooridnates
    MKPolyline *polyline = [MKPolyline polylineWithCoordinates:coordinates count:size];
    [(MKMapView *)self.view addOverlay:polyline];
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
