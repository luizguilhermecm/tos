//
//  TOSMenu.h
//  tos
//
//  Created by snk on 3/1/15.
//  Copyright (c) 2015 snk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>


@interface TOSMenu : NSObject

@property (strong) IBOutlet NSMenu * mainMenu;

+(id)sharedMenu;
-(void)updateSubMenuItemTimer;
-(void)getFrontAppWithNot;




@property (strong) IBOutlet NSMenuItem * notificationStartMI;
@property (strong) IBOutlet NSMenuItem * notificationStopMI;

@end
