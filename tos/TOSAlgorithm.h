//
//  TOSAlgorithm.h
//  tos
//
//  Created by snk on 3/3/15.
//  Copyright (c) 2015 snk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface TOSAlgorithm : NSObject <NSApplicationDelegate>

-(void)setNewIntervalToStatus;


+(id)sharedAlgorithm;

@property NSTimeInterval tosTime;
@property NSTimeInterval idleTime;
@property NSTimeInterval notTime;

@property NSInteger statusNow;
@property (strong, nonatomic) NSDate *startInterval;

@end
