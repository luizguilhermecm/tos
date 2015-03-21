//
//  NotificationCard.h
//  tos
//
//  Created by snk on 3/1/15.
//  Copyright (c) 2015 snk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>


@interface NotificationCard : NSObject
+(NSUserNotification *) newNotificationCard;
+(void) readFile;
+(NSInteger)nb;
+(NSDate *)lastTcDeliveredDate;
+(NSString *)lastTcIdentifier;
+(void)lastTcDeliveredDateWith:(NSDate *)adate;
+(void)newNotificationCardWithText:(NSString *)title
                          subtitle:(NSString *)sub
                              text:(NSString*)atext;

+(void)removeAllNotifications;


@end
