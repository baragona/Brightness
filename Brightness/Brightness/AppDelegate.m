//
//  AppDelegate.m
//  Brightness
//
//  Created by Kevin on 3/1/15.
//  Copyright (c) 2015 Kevin. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate



- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    self.brightCtrl = [[BrightnessController alloc] init];
    
    [self.brightCtrl start];
    NSTimer * timer = [NSTimer timerWithTimeInterval:1.0 target:self.brightCtrl selector:@selector(refresh) userInfo:nil repeats:YES];
    NSRunLoop * mainLoop = [NSRunLoop mainRunLoop];
    [mainLoop addTimer:timer forMode:NSRunLoopCommonModes];
    
    //These notifications are filed on NSWorkspace's notification center, not the default
    // notification center. You will not receive sleep/wake notifications if you file
    //with the default notification center.
    
    for (NSString * notification in @[
                                      NSWorkspaceSessionDidBecomeActiveNotification,
                                      NSWorkspaceScreensDidWakeNotification,
                                      NSWorkspaceDidWakeNotification
                                      ]){
        [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self.brightCtrl
                                                               selector: @selector(receiveWakeNote:)
                                                                   name: notification object: NULL];
    }
    
    self.appNapPreventionActivity = [[NSProcessInfo processInfo] beginActivityWithOptions:NSActivityUserInitiated reason:@"Prevent app nap from pausing brightness sync."];
    
    /*
     
     //Status Bar
     
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [self.statusItem setMenu:self.statusMenu];
    [self.statusItem setTitle:@"My App"];
    [self.statusItem setHighlightMode:YES];
    */
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

-(void) applicationDidChangeScreenParameters:(NSNotification *)notification{
    [self.brightCtrl applicationDidChangeScreenParameters: notification];
}


@end
