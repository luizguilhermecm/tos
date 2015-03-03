//
//  CDManager.h
//  tos
//
//  Created by snk on 3/1/15.
//  Copyright (c) 2015 snk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>


@interface CDManager : NSObject
-(void) getTrueCard;
- (NSManagedObjectContext *)managedObjectContext;

@end
