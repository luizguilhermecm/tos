//
//  NotificationCard.m
//  tos
//
//  Created by snk on 3/1/15.
//  Copyright (c) 2015 snk. All rights reserved.
//

#import "NotificationCard.h"


@interface NotificationCard()

//@property NSArray * notis;


@end

static NSInteger nb;
static NSMutableArray *notifications;
static NSString *lastTcIdentifier;
static NSDate *lastTcDeliveredDate;

@implementation NotificationCard

+(NSDate *)lastTcDeliveredDate{return lastTcDeliveredDate;}
+(void)lastTcDeliveredDateWith:(NSDate *)adate{lastTcDeliveredDate = adate;}
+(NSString *)lastTcIdentifier{return lastTcIdentifier;}

+(NSInteger)nb{return nb;}

+(void)removeAllNotifications {
    [notifications removeAllObjects];
    nb = 0;
}

+(NSInteger) randomNumber:(NSInteger)max {
    if (max == 0)
        return 0;
    
    return arc4random() % max;

}

+(void)newNotificationCardWithText:(NSString *)title
                          subtitle:(NSString *)sub
                              text:(NSString*)atext {
    NSUserNotification *withText = [[NSUserNotification alloc] init];
    [withText setTitle:title];
    [withText setSubtitle:sub];
    [withText setInformativeText:atext];

    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:withText];
}

+(NSUserNotification *) newNotificationCard {
    NSUserNotification *n = [notifications objectAtIndex:[self randomNumber:nb]];
    lastTcIdentifier = n.identifier;
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:n];
    return n;
}

+(void) readFile {
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *fileName = [documentsDirectory stringByAppendingPathComponent:@"_true_cards.txt"];
    
    // read everything from text
    NSString* fileContents =
    [NSString stringWithContentsOfFile:fileName
                              encoding:NSUTF8StringEncoding error:nil];
    
    // first, separate by new line
    NSArray* allLinedStrings =
    [fileContents componentsSeparatedByCharactersInSet:
     [NSCharacterSet newlineCharacterSet]];
    
    notifications = [[NSMutableArray alloc]init];
    
    for (NSString * line in allLinedStrings) {
        NSArray *fields = [line componentsSeparatedByString:@";"];
        
        if ([fields count] == 3) {
            NSUserNotification *notification = [[NSUserNotification alloc] init];
            [notification setTitle:fields[0]];
            [notification setSubtitle:fields[1]];
            [notification setInformativeText:fields[2]];
             notification.identifier = [NSString stringWithFormat:@"tcID_%ld", nb ];
            
            [notifications addObject:notification];
        }
    }
    nb = [notifications count];
}

@end