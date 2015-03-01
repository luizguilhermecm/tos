//
//  TOSLog.m
//  tos
//
//  Created by snk on 2/26/15.
//  Copyright (c) 2015 snk. All rights reserved.
//

#import "TOSLog.h"
#import "defines.h"

@implementation TOSLog

-(NSString *) getStatusName:(NSInteger)status {
    if (status == TOS_STATUS){
            return @"TOS :";
    } else if (status == NOT_STATUS) {
            return @"NOT :";
    } else if (status == IDLE_STATUS) {
            return @"IDLE:";
    } else if (status == SLEEP_STATUS) {
        return @"SLEEP:";
    } else if (status == WAKE_STATUS) {
        return @"WAKE:";
    }

    return @"ERROR:";
}

-(void)LogInterval:(NSTimeInterval)interval status:(NSInteger)astatus {
    [self writeToLogFile:[self formatLogTime:interval status:[self getStatusName:astatus]]];
}

-(NSString *)formatLogTime:(NSTimeInterval)interval status:(NSString*)astatus{
    NSInteger ti = (NSInteger)interval;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);
    return [NSString stringWithFormat:@"%@ %02ld:%02ld:%02ld", astatus, (long)hours, (long)minutes, (long)seconds];
}

-(void) writeToLogFile:(NSString*)content{
    
    content = [NSString stringWithFormat:@"%@ : %@\n",[NSDate date], content];
    
    //get the documents directory:
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *fileName = [documentsDirectory stringByAppendingPathComponent:@"_log-tos.txt"];
    
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:fileName];
    if (fileHandle){
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:[content dataUsingEncoding:NSUTF8StringEncoding]];
        [fileHandle closeFile];
    }
    else{
        [content writeToFile:fileName
                  atomically:NO
                    encoding:NSStringEncodingConversionAllowLossy
                       error:nil];
    }
}

@end
