//
//  DisplayInfo.m
//  Brightness
//
//  Created by Kevin on 3/4/15.
//  Copyright (c) 2015 Kevin. All rights reserved.
//

#import "DisplayInfo.h"

@implementation DisplayInfo

//https://github.com/glfw/glfw/commit/8101d7a7b67fc3414769b25944dc7c02b58d53d0
+ (io_service_t) IOServicePortFromCGDisplayID: (CGDirectDisplayID) displayID
{
    io_iterator_t iter;
    io_service_t serv, servicePort = 0;
    
    CFMutableDictionaryRef matching = IOServiceMatching("IODisplayConnect");
    
    // releases matching for us
    kern_return_t err = IOServiceGetMatchingServices(kIOMasterPortDefault,
                                                     matching,
                                                     &iter);
    if (err)
    {
        return 0;
    }
    
    while ((serv = IOIteratorNext(iter)) != 0)
    {
        CFDictionaryRef info;
        CFIndex vendorID, productID;
        CFNumberRef vendorIDRef, productIDRef;
        Boolean success;
        
        info = IODisplayCreateInfoDictionary(serv,
                                             kIODisplayOnlyPreferredName);
        
        vendorIDRef = CFDictionaryGetValue(info,
                                           CFSTR(kDisplayVendorID));
        productIDRef = CFDictionaryGetValue(info,
                                            CFSTR(kDisplayProductID));
        
        if(vendorIDRef == NULL || productIDRef == NULL){
            success = false;
            CFRelease(info);
            continue;
        }
        
        success = CFNumberGetValue(vendorIDRef, kCFNumberCFIndexType,
                                   &vendorID);
        success &= CFNumberGetValue(productIDRef, kCFNumberCFIndexType,
                                    &productID);
        
        if (!success)
        {
            CFRelease(info);
            continue;
        }
        
        if (CGDisplayVendorNumber(displayID) != vendorID ||
            CGDisplayModelNumber(displayID) != productID)
        {
            CFRelease(info);
            continue;
        }
        
        // we're a match
        servicePort = serv;
        CFRelease(info);
        break;
    }
    
    IOObjectRelease(iter);
    return servicePort;
}

static void KeyArrayCallback(const void* key, const void* value, void* context) {
    CFArrayAppendValue(context, key);
}

+ (NSString*)localizedDisplayNameForDisplayServicePort: (io_service_t) displayPort
{
    CFStringRef localName;
    CFDictionaryRef dict = (CFDictionaryRef)IODisplayCreateInfoDictionary(displayPort, 0);
    CFDictionaryRef names = CFDictionaryGetValue(dict, CFSTR(kDisplayProductName));
    if(names)
    {
        CFArrayRef langKeys = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks );
        CFDictionaryApplyFunction(names, KeyArrayCallback, (void*)langKeys);
        CFArrayRef orderLangKeys = CFBundleCopyPreferredLocalizationsFromArray(langKeys);
        CFRelease(langKeys);
        if(orderLangKeys && CFArrayGetCount(orderLangKeys))
        {
            CFStringRef langKey = CFArrayGetValueAtIndex(orderLangKeys, 0);
            localName = CFDictionaryGetValue(names, langKey);
            CFRetain(localName);
        }
        CFRelease(orderLangKeys);
    }
    CFRelease(dict);
    return (NSString*)CFBridgingRelease(localName);
}

+(NSDictionary*) infoDictionaryForDisplayServicePort: (io_service_t) displayPort{
    CFDictionaryRef ref = IODisplayCreateInfoDictionary(displayPort, kNilOptions);
    NSDictionary *dict = CFBridgingRelease(ref);
    
    return dict;
}

+(NSString*)stringFromError:(unsigned int)errorVal
{
    NSDictionary *ioReturnMap =
    @{@kIOReturnSuccess:          @"success",
       @kIOReturnError:            @"general error",
       @kIOReturnNoMemory:         @"memory allocation error",
       @kIOReturnNoResources:      @"resource shortage",
       @kIOReturnIPCError:         @"Mach IPC failure",
       @kIOReturnNoDevice:         @"no such device",
       @kIOReturnNotPrivileged:    @"privilege violation",
       @kIOReturnBadArgument:      @"invalid argument",
       @kIOReturnLockedRead:       @"device is read locked",
       @kIOReturnLockedWrite:      @"device is write locked",
       @kIOReturnExclusiveAccess:  @"device is exclusive access",
       @kIOReturnBadMessageID:     @"bad IPC message ID",
       @kIOReturnUnsupported:      @"unsupported function",
       @kIOReturnVMError:          @"virtual memory error",
       @kIOReturnInternalError:    @"internal driver error",
       @kIOReturnIOError:          @"I/O error",
       @kIOReturnCannotLock:       @"cannot acquire lock",
       @kIOReturnNotOpen:          @"device is not open",
       @kIOReturnNotReadable:      @"device is not readable",
       @kIOReturnNotWritable:      @"device is not writeable",
       @kIOReturnNotAligned:       @"alignment error",
       @kIOReturnBadMedia:         @"media error",
       @kIOReturnStillOpen:        @"device is still open",
       @kIOReturnRLDError:         @"rld failure",
       @kIOReturnDMAError:         @"DMA failure",
       @kIOReturnBusy:             @"device is busy",
       @kIOReturnTimeout:          @"I/O timeout",
       @kIOReturnOffline:          @"device is offline",
       @kIOReturnNotReady:         @"device is not ready",
       @kIOReturnNotAttached:      @"device/channel is not attached",
       @kIOReturnNoChannels:       @"no DMA channels available",
       @kIOReturnNoSpace:          @"no space for data",
       @kIOReturnPortExists:       @"device port already exists",
       @kIOReturnCannotWire:       @"cannot wire physical memory",
       @kIOReturnNoInterrupt:      @"no interrupt attached",
       @kIOReturnNoFrames:         @"no DMA frames enqueued",
       @kIOReturnMessageTooLarge:  @"message is too large",
       @kIOReturnNotPermitted:     @"operation is not permitted",
       @kIOReturnNoPower:          @"device is without power",
       @kIOReturnNoMedia:          @"media is not present",
       @kIOReturnUnformattedMedia: @"media is not formatted",
       @kIOReturnUnsupportedMode:  @"unsupported mode",
       @kIOReturnUnderrun:         @"data underrun",
       @kIOReturnOverrun:          @"data overrun",
       @kIOReturnDeviceError:      @"device error",
       @kIOReturnNoCompletion:     @"no completion routine",
       @kIOReturnAborted:          @"operation was aborted",
       @kIOReturnNoBandwidth:      @"bus bandwidth would be exceeded",
       @kIOReturnNotResponding:    @"device is not responding",
       @kIOReturnInvalid:          @"unanticipated driver error",
       @0:                         @"0"};
    return [ioReturnMap objectForKey:[NSNumber numberWithInt:err_get_code(errorVal)]];
}


static CGError getBrightnessForDisplayServicePort(io_service_t displayPort, float * storeResultIn){
    kern_return_t result = IODisplayGetFloatParameter(displayPort, kNilOptions, CFSTR(kIODisplayBrightnessKey), storeResultIn);
    if (result == kIOReturnSuccess){
        return 0;
    }else{
        NSLog(@"get brightness error: %@", [DisplayInfo stringFromError: result]);
        return 1;
    }
}

static CGError setBrightnessForDisplayServicePort(io_service_t displayPort, float brightness){
    kern_return_t result = IODisplaySetFloatParameter(displayPort, kNilOptions, CFSTR(kIODisplayBrightnessKey), brightness);
    if (result == kIOReturnSuccess){
        return 0;
    }else{
        return 1;
    }
}

- (float) getRealBrightness{
    if(self.IOServicePort){
        float b;
        CGError err = getBrightnessForDisplayServicePort(self.IOServicePort, &b);
        if(err){
            @throw [NSException
                    exceptionWithName:@"UnknownBrightnessGettingError"
                    reason:@"UnknownBrightnessGettingError"
                    userInfo:nil];
        }
        return b;
    }else{
        @throw [NSException
                exceptionWithName:@"NoIOServicePortException"
                reason:@"Does not have an IO service Port"
                userInfo:nil];
    }
}

- (void) setRealBrightness: (float) brightness{
    if(self.IOServicePort){
        CGError err = setBrightnessForDisplayServicePort(self.IOServicePort, brightness);
        if(err){
            @throw [NSException
                    exceptionWithName:@"UnknownBrightnessSettingError"
                    reason:@"UnknownBrightnessSettingError"
                    userInfo:nil];
        }
    }else{
        @throw [NSException
                exceptionWithName:@"NoIOServicePortException"
                reason:@"Does not have an IO service Port"
                userInfo:nil];
    }
}

- (float) getFakeBrightness{
    return self.lastSetFakeBrightness;
}

- (void) setFakeBrightness: (float) brightness{
    GammaTable * origTable = self.origGammaTable;
    GammaTable * darker = [origTable copyWithBrightness:brightness];
    [self applyGammaTable:darker];
    self.lastSetFakeBrightness = brightness;
}

- (void) applyGammaTable: (GammaTable *) gammaTable{
    [gammaTable applyToDisplay:self.displayID];
}

+ (DisplayInfo *) makeForDisplay: (CGDirectDisplayID) display{
    DisplayInfo * new = [[super alloc] init];
    
    new.displayID = display;
    new.IOServicePort = [self IOServicePortFromCGDisplayID:display];
    new.canReadRealBrightness = NO;//Init to no
    new.canSetRealBrightness  = NO;
    if(new.IOServicePort){
        new.displayName = [self localizedDisplayNameForDisplayServicePort: new.IOServicePort];
        
        //NSDictionary* infoDict = [self infoDictionaryForDisplayServicePort: new.IOServicePort];
        //NSLog(@"%@", infoDict);
        new.isBuiltIn = CGDisplayIsBuiltin(display);
        
        //test getting brightness TODO USE OBJC METHODS HERE
        float b;
        CGError err = getBrightnessForDisplayServicePort(new.IOServicePort, &b);
        if(!err){
            new.canReadRealBrightness = YES;
            //test setting
            err = setBrightnessForDisplayServicePort(new.IOServicePort, b);
            if(!err){
                new.canSetRealBrightness = YES;
            }
        }
    }
    new.origGammaTable = [GammaTable tableForDisplay:display];
    new.lastSetFakeBrightness = 1.0;
    
    return new;
}

- (void) dealloc
{
    if(self.IOServicePort){
        IOObjectRelease(self.IOServicePort);
    }
    // [super dealloc]; //(provided by the compiler)
}

@end
