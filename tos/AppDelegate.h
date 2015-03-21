//
//  AppDelegate.h
//  tos
//
//  Created by snk on 2/23/15.
//  Copyright (c) 2015 snk. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, NSUserNotificationCenterDelegate>

-(IBAction) quitTOS :(id)sender;
-(IBAction) notificationStop :(id)sender;
-(IBAction) resetTOS :(id)sender;
-(IBAction) notificationStart :(id)sender;
-(IBAction) updateMenu :(id)sender;

@end

