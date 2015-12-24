//
//  DisplayInfo.h
//  Brightness
//
//  Created by Kevin on 3/4/15.
//  Copyright (c) 2015 Kevin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GammaTable.h"

@interface DisplayInfo : NSObject

@property GammaTable * origGammaTable;
@property CGDirectDisplayID displayID;
@property io_service_t IOServicePort;
@property BOOL canReadRealBrightness;
@property BOOL canSetRealBrightness;
@property NSString * displayName;
@property BOOL isBuiltIn;
@property float lastSetFakeBrightness;

+ (DisplayInfo *) makeForDisplay: (CGDirectDisplayID) display;
- (float) getRealBrightness;
- (void) setRealBrightness: (float) brightness;

- (void) applyGammaTable: (GammaTable *) gammaTable;

- (float) getFakeBrightness;
- (void) setFakeBrightness: (float) brightness;


@end
