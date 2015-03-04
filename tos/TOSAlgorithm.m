//
//  TOSAlgorithm.m
//  tos
//
//  Created by snk on 3/3/15.
//  Copyright (c) 2015 snk. All rights reserved.
//

#define ZERO 0

#import "TOSAlgorithm.h"
#import "Utils.h"
#import "defines.h"

@interface TOSAlgorithm()



@end


@implementation TOSAlgorithm

@synthesize tosTime;
@synthesize idleTime;
@synthesize notTime;
@synthesize statusNow;

-(void)idleTimer:(NSTimeInterval)interval {
    idleTime += interval;
}


-(void)tosTimer :(NSTimeInterval)interval{
    tosTime += interval;
}


-(void)notTimer :(NSTimeInterval)interval{
    notTime += interval;
}


-(void)setNewIntervalToStatus {
    NSTimeInterval interval = [Utils getNewIntervalFromDate:_startInterval];
    
    if (statusNow == TOS_STATUS) {
        [self tosTimer:interval];
        
    } else if (statusNow == IDLE_STATUS) {
        [self idleTimer:interval];
        
    } else if (statusNow == NOT_STATUS || statusNow == FORCED_NOT) {
        [self notTimer:interval];
        
    }
    _startInterval = [NSDate date];
}


+ (id)sharedAlgorithm {
    static TOSAlgorithm *sharedAlgorithm = nil;
    @synchronized(self) {
        if (sharedAlgorithm == nil)
            sharedAlgorithm = [[self alloc] init];
    }
    return sharedAlgorithm;
}


-(instancetype)init {
    tosTime = ZERO;
    idleTime = ZERO;
    notTime = ZERO;
    
    return self;
}

@end
