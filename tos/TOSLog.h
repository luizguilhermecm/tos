//
//  TOSLog.h
//  tos
//
//  Created by snk on 2/26/15.
//  Copyright (c) 2015 snk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TOSLog : NSObject
+(void)LogInterval:(NSTimeInterval)interval status:(NSInteger)astatus;
@end
