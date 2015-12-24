//
//  GammaTable.h
//  Brightness
//
//  Created by Kevin on 3/2/15.
//  Copyright (c) 2015 Kevin. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface GammaTable : NSObject
@property int length;
@property NSMutableArray * redTable;
@property NSMutableArray * greenTable;
@property NSMutableArray * blueTable;

- (GammaTable*)clone;
+ (GammaTable*) tableForDisplay:(CGDirectDisplayID) display;
- (GammaTable*)copyWithBrightness:(float) brightness;
- (CGError) applyToDisplay:(CGDirectDisplayID) display;
@end
