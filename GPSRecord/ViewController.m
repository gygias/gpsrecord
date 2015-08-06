//
//  ViewController.m
//  GPSRecord
//
//  Created by david on 8/5/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self _setButtonState:NO];
    _state = NeverRecorded;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)recordButtonTouched:(id)sender
{
    [self _setButtonState:YES];
    
    _recording = YES;
//    _recordingTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0,0));
//    dispatch_source_set_timer(_recordingTimer, DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC, 0.5 * NSEC_PER_SEC);
//    dispatch_source_set_event_handler(_recordingTimer, ^{
//        
//    });
//    dispatch_resume(_recordingTimer);
    
    _state = StartPointState;
    _currentRecordingLocations = [NSMutableArray new];
    [self.tableView reloadData];
    _currentImages = [NSMutableArray new];
    [self _startUpdatingLocation];
    
    self.recordingLabel.text = @"recording start point...";
}

- (IBAction)nextButtonTouched:(id)sender
{
    if ( _state == StartPointState )
    {
        self.recordingLabel.text = @"recording motion...";
        _state = MovingState;
    }
    else if ( _state == MovingState )
    {
        self.recordingLabel.text = @"recording end point...";
        _state = EndPointState;
    }
    else
    {
        _state = NotRecording;
        [self _setButtonState:NO];
        [_locationManager stopUpdatingLocation];
    }
    
    // process _currentRecordingLocations
}

- (IBAction)cancelButtonTouched:(id)sender
{
    _state = NotRecording;
    [self _setButtonState:NO];
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    if ( _state < StartPointState || _state > EndPointState )
        return;
    //NSLog(@"%s:[%d], %d locations total",__PRETTY_FUNCTION__,(int)locations.count,(int)_currentRecordingLocations.count);
    if ( _currentRecordingLocations.count < ( _state + 1 ) )
        _currentRecordingLocations[_state] = [NSMutableArray new];
    NSMutableArray *subArray = _currentRecordingLocations[_state];
    [subArray addObjectsFromArray:locations];
    [self.tableView reloadData];
    int currentSections = (int)_currentRecordingLocations.count;
    if ( currentSections > 0 )
    {
        NSIndexPath* ipath = [NSIndexPath indexPathForRow: [_currentRecordingLocations[currentSections - 1] count] - 1 inSection: currentSections - 1];
        [self.tableView scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionTop animated: YES];
    }
    //[_currentRecordingLocations addObjectsFromArray:locations];
    
//    int idx = 0;
//    for ( CLLocation *location in _currentRecordingLocations.reverseObjectEnumerator )
//    {
//        NSLog(@"idx:%d",idx);
//        NSString *coordString = [NSString stringWithFormat:@"%0.6f,%0.6f",location.coordinate.latitude,location.coordinate.longitude];
//        [self setValue:coordString forKeyPath:[NSString stringWithFormat:@"lastGPSLabel%d.text",idx + 1]];
//        if ( idx++ == 2 )
//            break;
//    }
}
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,error);
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    NSLog(@"%s: %d",__PRETTY_FUNCTION__,status);
}

- (void)_setButtonState:(BOOL)started
{
    self.recordButton.enabled = ! started;
    self.nextButton.enabled = started;
    self.cancelButton.enabled = started;
    
//    self.lastGPSLabel1.hidden = ! started;
//    self.lastGPSLabel2.hidden = ! started;
//    self.lastGPSLabel3.hidden = ! started;
    
    //self.tableView.hidden = ( _state == NeverRecorded );
    
    self.recordingView.hidden = ! started;
    
    self.emailButton.enabled = ( _state == NotRecording );
    self.pictureButton.enabled = ( _state == NotRecording || _state == NeverRecorded );
}

- (void)_startUpdatingLocation
{
    // Create the location manager if this object does not
    // already have one.
    if (nil == _locationManager)
    {
        _locationManager = [[CLLocationManager alloc] init];
    
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        
        // Set a movement threshold for new events.
        _locationManager.distanceFilter = kCLDistanceFilterNone; // meters
        
        // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
        if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [_locationManager requestWhenInUseAuthorization];
        }
    }
    
    [_locationManager startUpdatingLocation];
    
    NSLog(@"location services: %@ auth: %d",[CLLocationManager locationServicesEnabled]?@"OK":@"NOK",[CLLocationManager authorizationStatus]);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"%s: %d",__PRETTY_FUNCTION__,(int)section);
    if ( section < _currentRecordingLocations.count )
        return [_currentRecordingLocations[section] count];
    return 0;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,indexPath);
    NSUInteger section = [indexPath indexAtPosition:0];
    NSUInteger row = [indexPath indexAtPosition:1];
    CLLocation *location = [_currentRecordingLocations[section] objectAtIndex:row];
    NSString *label = [NSString stringWithFormat:@"%0.6f,%0.6f",location.coordinate.latitude,location.coordinate.longitude];
    UITableViewCell *tableViewCell = [tableView dequeueReusableCellWithIdentifier:label];
    if ( ! tableViewCell )
    {
        tableViewCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:label];
        tableViewCell.textLabel.text = label;
    }
    return tableViewCell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    return _currentRecordingLocations.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSLog(@"%s: %d",__PRETTY_FUNCTION__,(int)section);
    if ( section == 0 )
        return @"start point";
    else if ( section == 1 )
        return @"moving";
    else if ( section == 2 )
        return @"end point";
    return @"???";
}

- (IBAction)emailButtonPressed:(id)sender {
    // Email Subject
    
    CLPlacemark *placemark = [self getPlacemarkForCurrentData];
    NSString *subject = nil;
    NSString *body = nil;
    if ( ! placemark )
    {
        subject = @"failed to geodecode";
        body = subject;
        NSLog(@"%@",subject);
    }
    else
    {
        subject = [self locationStringWithPlacemark:placemark brief:YES];
        body = [self locationStringWithPlacemark:placemark brief:NO];
    }
    
    NSString *emailTitle = subject;
    // Email Content
    NSString *messageBody = body;
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:@"dave.desmond@me.com"];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    NSError *error = nil;
    NSArray *array = [self _plistizedLocations:_currentRecordingLocations];
    NSData *coordinateData = [NSPropertyListSerialization dataWithPropertyList:array format:NSPropertyListXMLFormat_v1_0 options:0 error:&error];
    NSLog(@"coord: %d bytes",(int)coordinateData.length);
    if ( ! coordinateData || error )
    {
        NSLog(@"error sending mail: %@",error);
        return;
    }
    
    [mc addAttachmentData:coordinateData mimeType:@"application/x-plist" fileName:@"coords"];
    
    NSUInteger idx = 0;
    for ( UIImage *image in _currentImages )
    {
        NSData *data = UIImageJPEGRepresentation(image,0.01);
        NSLog(@"image size: %d",(int)data.length);
        [mc addAttachmentData:data mimeType:@"image/jpeg" fileName:[NSString stringWithFormat:@"image-%lu",(unsigned long)idx++]];
    }
    
    [mc setToRecipients:toRecipents];
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];
    
}

- (IBAction)pictureButtonPressed:(id)sender
{
    _imagePickerController = [[UIImagePickerController alloc] init];
    _imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    // Displays a control that allows the user to choose picture or
    // movie capture, if both are available:
    _imagePickerController.mediaTypes =
        [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    _imagePickerController.allowsEditing = NO;
    
    _imagePickerController.delegate = self;
    _imagePickerController.mediaTypes = @[ (NSString *)kUTTypeImage ];
    
    [self presentViewController:_imagePickerController animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"%s: %@",__PRETTY_FUNCTION__, info);
    
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *imageToSave;
    
    // Handle a still image capture
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0)
        == kCFCompareEqualTo) {
        
        editedImage = (UIImage *) [info objectForKey:
                                   UIImagePickerControllerEditedImage];
        originalImage = (UIImage *) [info objectForKey:
                                     UIImagePickerControllerOriginalImage];
        
        if (editedImage) {
            imageToSave = editedImage;
        } else {
            imageToSave = originalImage;
        }
        
        if ( ! _currentImages )
            _currentImages = [NSMutableArray new];
        [_currentImages addObject:imageToSave];
    }
    
    // Handle a movie capture
//    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeMovie, 0)
//        == kCFCompareEqualTo) {
//        
//        NSString *moviePath = [[info objectForKey:
//                                UIImagePickerControllerMediaURL] path];
//        
//        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum (moviePath)) {
//            UISaveVideoAtPathToSavedPhotosAlbum (
//                                                 moviePath, nil, nil, nil);
//        }
//    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (NSArray *)_plistizedLocations:(NSArray *)inArray
{
    NSMutableArray *outArray = [NSMutableArray new];
    for ( NSArray *subArray in inArray )
    {
        NSMutableArray *outSubArray = [NSMutableArray new];
        for ( CLLocation *location in subArray )
        {
            NSMutableDictionary *outLocation = [NSMutableDictionary new];
            outLocation[@"lat"] = @( location.coordinate.latitude );
            outLocation[@"lon"] = @( location.coordinate.longitude );
            [outSubArray addObject:outLocation];
        }
        [outArray addObject:outSubArray];
    }
    
    return outArray;
}

- (CLPlacemark *)getPlacemarkForCurrentData
{
    //CLLocation *location = [[CLLocation alloc] initWithLatitude:37.78583400 longitude:-122.40641700];
    CLGeocoder *geoCoder = [CLGeocoder new];
    __block CLPlacemark *placemark = nil;
    __block BOOL geolocated = NO;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [geoCoder reverseGeocodeLocation:_currentRecordingLocations[0][0] completionHandler:
         ^(NSArray *placemarks, NSError *error) {

             //Get nearby address
             placemark = [placemarks objectAtIndex:0];
             NSLog(@"got placemark...");
             geolocated = YES;
         }];
    });
    
    self.recordingLabel.text = @"geolocating...";
    self.recordingView.hidden = NO;
    
    // waiting will prevent completion handler from firing, evidently on main thread.
    NSPort *port = [NSPort port];
    [[NSRunLoop currentRunLoop] addPort:port forMode:NSRunLoopCommonModes];
    
    NSTimeInterval waitBy = 1, waitFor = 15, waited = 0;
    while ( ! geolocated )
    {
        // CFRunLoopRunInModes returns immediately (?)
        [[NSRunLoop currentRunLoop] runUntilDate:[[NSDate date] dateByAddingTimeInterval:waitBy]];
        waited += waitBy;
        if ( waited >= waitFor )
            break;
    }
    
    self.recordingView.hidden = YES;
    
    return placemark;
}

- (NSString *)locationStringWithPlacemark:(CLPlacemark *)placemark brief:(BOOL)brief
{
    NSMutableString *subjectString = [NSMutableString new];
    
    //String to hold address
    [subjectString appendString:placemark.thoroughfare];
    if ( ! brief )
    {
        if ( placemark.subLocality )
            [subjectString appendFormat:@", %@",placemark.subLocality];
    }
    if ( placemark.locality )
        [subjectString appendFormat:@", %@",placemark.locality];
    if ( ! brief )
    {
        if ( placemark.ISOcountryCode )
            [subjectString appendFormat:@", %@",placemark.ISOcountryCode];
    }
    
    if ( subjectString.length == 0 )
        subjectString = [@"unknown location" mutableCopy];
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [subjectString appendFormat:@" @ %@",[dateFormatter stringFromDate:[NSDate date]]];
    return subjectString;
}

@end
