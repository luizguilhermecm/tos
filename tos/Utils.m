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

+(NSString *)statusIdToString:(NSInteger)astatus {
    if (astatus == IDLE_STATUS) {
        return @"IDLE";
    } else if (astatus == TOS_STATUS) {
        return @"TOS";
    } else if (astatus == NOT_STATUS) {
        return @"NOT";
    } else if (astatus == FORCED_NOT) {
        return @"!NOT!";
    } else if (astatus == SLEEP_STATUS) {
        return @"SLEEP";
    } else if (astatus == WAKE_STATUS) {
        return @"WAKE";
    } else if (astatus == QUIT_TOS) {
        return @"QUIT";
    } else {
        return @"ERROR";
    }
}

+(NSString *) formartTime:(NSTimeInterval)interval {
    NSInteger ti = (NSInteger)interval;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);
    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld",
            (long)hours, (long)minutes, (long)seconds];
}

+(NSString *)formatTos:(NSTimeInterval)interval status:(NSInteger)astatus{
    NSInteger ti = (NSInteger)interval;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);
    return [NSString stringWithFormat:@"%@: %02ld:%02ld:%02ld",
            [Utils statusIdToString:astatus], (long)hours, (long)minutes, (long)seconds];
}

+(void) runningApps {
    NSArray * running = [[NSWorkspace sharedWorkspace] runningApplications];

    for (NSRunningApplication * app in running) {
//        [array addObject:app.bundleIdentifier];
        NSLog(app.bundleIdentifier);
    }
}

+(NSInteger) isAppOpen:(NSString *)thisApp {
    NSArray * running = [NSRunningApplication runningApplicationsWithBundleIdentifier:thisApp];
//    [self runningApps];
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

+(void)showAlert:(NSString *)title  text:(NSString *) atext {
    NSAlert *alert = [[NSAlert alloc] init];
    NSWindow *window;
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:title];
    [alert setInformativeText:atext];
    [alert setAlertStyle:NSCriticalAlertStyle];
    [alert beginSheetModalForWindow:window modalDelegate:self didEndSelector:nil contextInfo:nil];
}

+(NSString *)getNewIntervalFromDateFormated:(NSDate *)adate status:(NSInteger)astatus{
    NSTimeInterval interval = [Utils getNewIntervalFromDate:adate];
    return [Utils formatTos:interval status:astatus];
}

+(NSTimeInterval)getNewIntervalFromDate:(NSDate *)adate {
    return [adate timeIntervalSinceNow] * -1;
}




@end
