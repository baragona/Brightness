//
//  AppDelegate.h
//  Brightness
//
//  Created by Kevin on 3/1/15.
//  Copyright (c) 2015 Kevin. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GammaTable.h"
#import "BrightnessController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property BrightnessController * brightCtrl;

@property (strong, nonatomic) IBOutlet NSMenu *statusMenu;
@property (strong, nonatomic) NSStatusItem *statusItem;
@property (strong, nonatomic) NSSlider *statusSlider;

- (void) handleTargetBrightnessChanged: (float)newTarget ;
@property NSObject * appNapPreventionActivity;

@end

