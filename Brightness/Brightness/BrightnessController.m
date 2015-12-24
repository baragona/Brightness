//
//  BrightnessController.m
//  Brightness
//
//  Created by Kevin on 3/3/15.
//  Copyright (c) 2015 Kevin. All rights reserved.
//

#import "BrightnessController.h"

const int maxDisplays=1000;


@implementation BrightnessController


- (CGError) getBrightness: (float*) storeResultIn
{
    
    io_iterator_t iterator;
    kern_return_t result = IOServiceGetMatchingServices(kIOMasterPortDefault,
                                                        IOServiceMatching("IODisplayConnect"),
                                                        &iterator);
    
    float sum=0;
    int count=0;
    // If we were successful
    if (result == kIOReturnSuccess)
    {
        io_object_t service;
        while ((service = IOIteratorNext(iterator))) {
            float brightness;
            CFDictionaryRef ref = IODisplayCreateInfoDictionary(service, kNilOptions);
            NSDictionary *andBack = (__bridge NSDictionary*)ref;
            NSLog(@"%@", andBack);
            result = IODisplayGetFloatParameter(service, kNilOptions, CFSTR(kIODisplayBrightnessKey), &brightness);
            if (result == kIOReturnSuccess)
            {
                count++;
                sum+=brightness;
                printf("%d: %f\n", count, brightness);
            }
            // Let the object go
            IOObjectRelease(service);
        }
    }
    printf("%d brightnesses\n", count);
    if(count>0){
        *storeResultIn = sum/count;
        return 0;
    }
    return 1;
}

- (NSString *) displayStr:(CGDirectDisplayID) display{
    return [NSString stringWithFormat:@"%d", (int)display];
}

- (NSMutableDictionary*) getDisplayGammaTableMapping{
    
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    const int maxDisplays=1000;
    
    CGDirectDisplayID activeDisplays[maxDisplays];
    uint32_t n_active_displays;
    CGError err = CGGetActiveDisplayList (maxDisplays, activeDisplays, &n_active_displays );
    if(!err){
        for(int i=0;i<n_active_displays;i++){
            CGDirectDisplayID display = activeDisplays[i];
            GammaTable * table = [GammaTable tableForDisplay:display];
            if(table){
                [dict setValue:table forKey:[self displayStr:display]];
                
            }
        }
    }
    return dict;
}

-(id) init{
    self = [super init];
    
    return self;
}

- (void) start{
    self.targetBrightness=1.0;
    self.lastReinitializedAt = 0.0;
    [self reinitialize: @"Just starting up"];
    
}



- (void) reinitialize: (NSString*) info{
    NSLog(@"Reinitializing: %@\n", info);
    
    
    CGDisplayRestoreColorSyncSettings();
    //self.dict = [self getDisplayGammaTableMapping]; //remove soon
    //self.lastCheckedActiveDisplays = [BrightnessController getActiveDisplays];
    self.displayCollection = [DisplayCollection makeFromCurrentlyActiveDisplays];
    self.drivingDisplay = [self searchForDrivingDisplay];
    

    
    [self updateAllDisplaysWithMeticulousness:YES];
    NSTimeInterval time_now = [[NSProcessInfo processInfo] systemUptime];
    self.lastReinitializedAt = time_now;
}

//A notification named NSApplicationDidChangeScreenParametersNotification. Calling the object method of this notification returns the NSApplication object itself.
-(void) applicationDidChangeScreenParameters:(NSNotification*) notification{
    [self reinitialize: notification.name];
}

- (void) receiveWakeNote: (NSNotification*) note{
    //NSLog(@"receiveWakeNote: %@", [note name]);
    [self reinitialize: note.name];
}

+ (NSArray*) getActiveDisplays{
    CGDirectDisplayID activeDisplays[maxDisplays];
    uint32_t n_active_displays;
    
    NSMutableArray * arr = [NSMutableArray array];
    
    CGError err = CGGetActiveDisplayList (maxDisplays, activeDisplays, &n_active_displays );
    if(!err){
        for(int i=0;i<n_active_displays;i++){
            arr[i] = @(activeDisplays[i]);
        }
    }
    return arr;
}

- (GammaTable *) origGammaTableForDisplay:(CGDirectDisplayID) display{
    if(self.dict){
        GammaTable * origTable = [self.dict objectForKey:[self displayStr:display]];
        if(origTable){
            return origTable;
        }
    }
    return nil;
}

- (DisplayInfo *) searchForDrivingDisplay{
    for (DisplayInfo * info in self.displayCollection.displays){
        if(info.canReadRealBrightness){
            return info;
        }
    }
    return nil;
}

- (void) updateAllDisplaysWithMeticulousness: (BOOL) meticulous{
    [self updateTargetBrightness];
    float target = self.targetBrightness;
    for (DisplayInfo * dispInfo in self.displayCollection.displays){
        @try{
            if(dispInfo.canSetRealBrightness){
                if(dispInfo == self.drivingDisplay){
                    //NSLog(@"Not setting real brightness of a driving display");
                }else{
                    float current = [dispInfo getRealBrightness]; // throws
                    if(meticulous || fabs(target - current) > .001){
                        NSLog(@"Setting Real brightness");
                        [dispInfo setRealBrightness:target]; // throws
                    }
                }
            }else{
                float current = [dispInfo getFakeBrightness]; // throws
                if(meticulous || fabs(target - current) > .001){
                    NSLog(@"Setting Fake brightness to %f", target);
                    [dispInfo setFakeBrightness:target]; // throws
                }
            }
        }
        @catch ( NSException *e ) {
            NSLog(@"Error updating brightness on display %d - %@", dispInfo.displayID, dispInfo.displayName);
        }
    }
}

- (void) updateTargetBrightness{
    if(self.drivingDisplay){
        if(CGDisplayIsActive(self.drivingDisplay.displayID)){
            float b=self.targetBrightness;
            int failed=0;
            @try{
                b = [self.drivingDisplay getRealBrightness]; // throws
            }
            @catch ( NSException *e ) {
                NSLog(@"Error getting brightness %@", e);
                failed=1;
            }
            if(!failed){
                self.targetBrightness = b;
            }
        }else{
            NSLog(@"Driving display is asleep -- it should be removed very soon -- keeping old brightness");
        }
    }else{
        NSLog(@"No driving display -- keeping old brightness");
    }
}

- (void) refresh{
    
    BOOL meticulous;
    NSTimeInterval time_now = [[NSProcessInfo processInfo] systemUptime];
    if(time_now - self.lastReinitializedAt < 6.0){
        meticulous = YES;
    }else{
        meticulous = NO;
    }
    [self updateAllDisplaysWithMeticulousness:meticulous];
    /*
    float builtInBrightness=1;
    CGError err = 0;
    //err = [self getBrightness: &builtInBrightness];
    NSArray * displays = [BrightnessController getActiveDisplays];
    for (id displayVal in displays){
        
        CGDirectDisplayID display = [displayVal intValue];
        [DisplayInfo makeForDisplay:display];
        float brightness;
        err = getBrightnessForDisplay(display, &brightness);
        if(!err){
            builtInBrightness = brightness;
            printf("Got brightness %f for display %d\n", brightness, (int)display);
        }else{
            puts("Error reading brightness");
        }
    }

    //CGDisplayRestoreColorSyncSettings();
    
    
    for (id displayVal in displays){
        //CGDirectDisplayID display = nil;
        CGDirectDisplayID display = [displayVal intValue];
        if(!CGDisplayIsBuiltin(display)){
            //setDisplayBrightness(display, builtInBrightness);
            GammaTable * origTable = [self origGammaTableForDisplay:display];
            GammaTable * darker = [origTable copyWithBrightness:builtInBrightness];
            [darker applyToDisplay:display];
        }
    }
    */
}

@end
