//
//  State.m
//  GPSRecord
//
//  Created by david on 8/5/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "State.h"

@implementation State

static State *gGPSRecordState = nil;

+ (State *)state
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gGPSRecordState = [State new];
    });
    
    return gGPSRecordState;
}

@end
