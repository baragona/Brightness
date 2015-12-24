//
//  DisplayCollection.h
//  Brightness
//
//  Created by Kevin on 3/5/15.
//  Copyright (c) 2015 Kevin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DisplayInfo.h"

@interface DisplayCollection : NSObject
@property NSArray * displays; // Of DisplayInfo


+ (DisplayCollection *) makeFromCurrentlyActiveDisplays;

- (BOOL) collectionContainsDisplay: (CGDirectDisplayID) display;

- (DisplayInfo*) getInfoForDisplay: (CGDirectDisplayID) display;

@end
