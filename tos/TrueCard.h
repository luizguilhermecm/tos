//
//  TrueCard.h
//  tos
//
//  Created by snk on 2/27/15.
//  Copyright (c) 2015 snk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface TrueCard :  NSObject <NSApplicationDelegate>


-(void) setTrueCardTimer;
-(void) invalidateTrueCardTimer;
-(NSInteger) numberOfCards;
-(void) emptyTable;



@end
