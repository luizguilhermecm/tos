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
+(void) newNotificationCard;
+(void) readFile;
+(NSInteger)nb;


+(void)newNotificationCardWithText:(NSString *)title
                          subtitle:(NSString *)sub
                              text:(NSString*)atext;


@end
