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
static NSInteger indexNot = 0;
static NSMutableArray *notifications;

@implementation NotificationCard

+(NSInteger)nb{return nb;}

+(NSInteger)getIndex {
    indexNot += 1;
    return indexNot;
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

+(void) newNotificationCard {
    
    [[NSUserNotificationCenter defaultUserNotificationCenter]
        deliverNotification:[notifications objectAtIndex:[self randomNumber:nb]]];
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
            
            [notifications addObject:notification];
        }
    }
    nb = [notifications count];
}

@end