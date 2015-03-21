//
//  Utils.h
//  tos
//
//  Created by snk on 3/2/15.
//  Copyright (c) 2015 snk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utils : NSObject

// get a NSTimeInterval (nb of seconds) and a string with the status
// returns a string like: @"IDLE: 02:32:31"
+(NSString *)formatTos:(NSTimeInterval)interval status:(NSInteger)astatus;

//get a NSString with the Application Bundle Identifier as "com.apple.Preview"
// return 1 if the application is open or 0 if it is not
+(NSInteger) isAppOpen:(NSString *)thisApp;

//return TRUE is system is idle more than IDLE_MAX in define.h
+(BOOL)isSystemIdle;

+(NSString*) safariURL;

//show an alert with specified title and text
+(void)showAlert:(NSString *)title  text:(NSString *) atext;

+(NSString *)statusIdToString:(NSInteger)astatus;
+(NSString *)eventIdToString:(NSInteger)aevent;

//return the number os secondes since date
+(NSTimeInterval)getNewIntervalFromDate:(NSDate *)adate;

//return the formated time with status since date as NOT: 00:34:00
+(NSString *)getNewIntervalFromDateFormated:(NSDate *)adate status:(NSInteger)astatus;

//format seconds in 00:00:00
+(NSString *) formartTime:(NSTimeInterval)interval;




@end
