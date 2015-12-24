//
//  DisplayCollection.m
//  Brightness
//
//  Created by Kevin on 3/5/15.
//  Copyright (c) 2015 Kevin. All rights reserved.
//

#import "DisplayCollection.h"

@implementation DisplayCollection

+ (DisplayCollection *) makeFromCurrentlyActiveDisplays{
    NSMutableArray * arr = [NSMutableArray array];
    
    
    const int maxDisplays=1000;
    
    CGDirectDisplayID activeDisplays[maxDisplays];
    uint32_t n_active_displays;
    CGError err = CGGetActiveDisplayList (maxDisplays, activeDisplays, &n_active_displays );
    if(!err){
        for(int i=0;i<n_active_displays;i++){
            CGDirectDisplayID display = activeDisplays[i];
            DisplayInfo * info = [DisplayInfo makeForDisplay:display];
            arr[i] = info;
        }
    }
    
    DisplayCollection * new = [[self alloc] init];
    new.displays = arr;
    return new;
}

- (BOOL) collectionContainsDisplay: (CGDirectDisplayID) display{
    if([self getInfoForDisplay:display] != nil){
        return YES;
    }else{
        return NO;
    }
}

- (DisplayInfo*) getInfoForDisplay: (CGDirectDisplayID) display{
    for(DisplayInfo* info in self.displays){
        if(info.displayID == display){
            return info;
        }
    }
    return nil;
}

@end
