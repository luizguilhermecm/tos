//
//  Utils.m
//  tos
//
//  Created by snk on 3/2/15.
//  Copyright (c) 2015 snk. All rights reserved.
//

#import "Utils.h"
#import <Cocoa/Cocoa.h>
#import "defines.h"


@implementation Utils
+(NSString *)formatTos:(NSTimeInterval)interval status:(NSString*)astatus{
    NSInteger ti = (NSInteger)interval;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);
    return [NSString stringWithFormat:@"%@: %02ld:%02ld:%02ld", astatus, (long)hours, (long)minutes, (long)seconds];
}

+(NSInteger) isAppOpen:(NSString *)thisApp {
    NSArray * running = [NSRunningApplication runningApplicationsWithBundleIdentifier:thisApp];
    if([running count] > 0){
        return 1;
    } else {
        return 0;
    }
}

+(BOOL)isSystemIdle
{
    CFTimeInterval timeSinceLastEvent = CGEventSourceSecondsSinceLastEventType(kCGEventSourceStateHIDSystemState, kCGAnyInputEventType);
    
    if (timeSinceLastEvent > IDLE_MAX) {
        return YES;
    } else {
        return NO;
    }
}

+ (NSString*) safariURL
{
    NSDictionary *dict;
    NSAppleEventDescriptor *result;
    
    NSAppleScript *script = [[NSAppleScript alloc] initWithSource:
                             @"\ntell application \"Safari\"\n\tget URL of document 1\nend tell\n"];
    
    result = [script executeAndReturnError:&dict];
    
    if ((result != nil) && ([result descriptorType] != kAENullEvent)) {
        NSLog([result stringValue]);
        return [result stringValue];
    }
    return nil;
}


@end
