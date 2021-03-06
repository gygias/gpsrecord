//
//  State.h
//  GPSRecord
//
//  Created by david on 8/5/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface State : NSObject

+ (State *)state;

@property NSArray *startLocations;
@property NSArray *movingLocations;
@property NSArray *endLocations;
@property NSArray *images;
@property UIImage *mapImage;

@end
