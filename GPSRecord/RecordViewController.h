//
//  RecordViewController.h
//  GPSRecord
//
//  Created by david on 8/5/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MapViewController.h"

#import <CoreLocation/CoreLocation.h>
#import <MessageUI/MessageUI.h>
#import <MobileCoreServices/MobileCoreServices.h> // kUTType*

typedef NS_ENUM(NSInteger,RecordState)
{
    StartPointState = 0,
    MovingState,
    EndPointState,
    NeverRecorded,
    NotRecording,
};

@interface RecordViewController : UIViewController <CLLocationManagerDelegate,MFMailComposeViewControllerDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
    BOOL _recording;
    RecordState _state;
    NSMutableArray *_currentRecordingLocations;
    UIImagePickerController *_imagePickerController;
    NSMutableArray *_currentImages;
    dispatch_source_t _recordingTimer;
    CLLocationManager *_locationManager;
}

//@property IBOutlet UILabel *lastGPSLabel1;
//@property IBOutlet UILabel *lastGPSLabel2;
//@property IBOutlet UILabel *lastGPSLabel3;

@property IBOutlet MapViewController *mapViewController;

@property IBOutlet UITableView *tableView;

@property IBOutlet UIView *recordingView;
@property IBOutlet UILabel *recordingLabel;

@property IBOutlet UIButton *mapButton;
@property IBOutlet UIButton *recordButton;
@property IBOutlet UIButton *nextButton;
@property IBOutlet UIButton *cancelButton;
@property IBOutlet UIButton *pictureButton;
@property IBOutlet UIButton *emailButton;

@end

