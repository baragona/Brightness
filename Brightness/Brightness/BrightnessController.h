//
//  BrightnessController.h
//  Brightness
//
//  Created by Kevin on 3/3/15.
//  Copyright (c) 2015 Kevin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GammaTable.h"
#import "DisplayInfo.h"
#import "DisplayCollection.h"

@interface BrightnessController : NSObject

@property NSMutableDictionary * dict;

@property NSTimeInterval lastReinitializedAt;
@property NSArray * lastCheckedActiveDisplays;
@property DisplayCollection * displayCollection;
@property DisplayInfo* drivingDisplay;

@property float targetBrightness;

@property bool reinitializeOnNextRefresh;

- (void) start;
-(void) applicationDidChangeScreenParameters:(NSNotification*) notification;
- (void) receiveWakeNote: (NSNotification*) note;
- (void) refresh;
@end
