//
//  TOSMenu.m
//  tos
//
//  Created by snk on 3/1/15.
//  Copyright (c) 2015 snk. All rights reserved.
//

#import "TOSMenu.h"
#import "NotificationCard.h"
#import "Utils.h"
#import "defines.h"
#import "TOSAlgorithm.h"
#import "AppDelegate.h"

@interface TOSMenu()


@property (strong) IBOutlet NSMenuItem * tosUpdateMI;
@property (strong) IBOutlet NSMenuItem * tosActualMI;
@property (strong) IBOutlet NSMenuItem * idleMI;
@property (strong) IBOutlet NSMenuItem * notMI;
@property (strong) IBOutlet NSMenuItem * tosMI;

@property (strong) IBOutlet NSMenu * toolSubmenu;
@property (strong) IBOutlet NSMenuItem * quitMI;
@property (strong) IBOutlet NSMenuItem * resetMI;
@property (strong) IBOutlet NSMenuItem * windowMI;

@property (strong) IBOutlet NSMenu * idleSubmenu;

@property (strong) IBOutlet NSMenu * tosSubmenu;

@property (strong) IBOutlet NSMenu * notSubmenu;

@property NSTimer *notificationTimer;

@property NSMutableDictionary * notAppDictonary;
@property NSMutableDictionary * tosAppDictonary;
@property NSMutableDictionary * idleAppDictonary;

@property TOSAlgorithm *tosAlgorithm;

@property NSMutableArray * list;

@end

@implementation TOSMenu

-(NSMenu *)getNotSubmenu {
    return _notSubmenu;
}

+ (id)sharedMenu {
    static TOSMenu *sharedMenu = nil;
    @synchronized(self) {
        if (sharedMenu == nil)
            sharedMenu = [[self alloc] init];
    }
    return sharedMenu;
}

-(instancetype)init {

    _mainMenu = [[NSMenu alloc] initWithTitle:@"TOS" ];
    
    _tosUpdateMI = [[NSMenuItem alloc] initWithTitle:@"update"
                                              action:@selector(updateMenu:)
                                       keyEquivalent:@"r"];
    
    _tosActualMI = [[NSMenuItem alloc] initWithTitle:@"timer: "
                                              action:nil
                                       keyEquivalent:@""];
    
    _quitMI = [[NSMenuItem alloc] initWithTitle:@"Quit"
                                         action:@selector(quitTOS:)
                                  keyEquivalent:@"q"];
    
    _resetMI = [[NSMenuItem alloc] initWithTitle:@"Reset"
                                          action:@selector(resetTOS:)
                                   keyEquivalent:@""];
    
    
    _notificationStartMI = [[NSMenuItem alloc] initWithTitle:@"Start TrueCard"
                                                      action:@selector(notificationStart:)
                                               keyEquivalent:@""];
    
    _notificationStopMI = [[NSMenuItem alloc] initWithTitle:@"Stop TrueCard"
                                                     action:@selector(notificationStop:)
                                              keyEquivalent:@""];
    
    _windowMI = [[NSMenuItem alloc] initWithTitle:@"Text"
                                                     action:@selector(textEditorMI:)
                                              keyEquivalent:@"t"];
    _tosMI =  [[NSMenuItem alloc] initWithTitle:@"TOS" action:nil keyEquivalent:@""];
    _notMI =  [[NSMenuItem alloc] initWithTitle:@"NOT" action:nil keyEquivalent:@""];
    _idleMI = [[NSMenuItem alloc] initWithTitle:@"IDLE" action:nil keyEquivalent:@""];
    
    _tosSubmenu  = [[NSMenu alloc] initWithTitle:@"subTOS"];
    _idleSubmenu = [[NSMenu alloc] initWithTitle:@"idleNOT"];
    _notSubmenu  = [[NSMenu alloc] initWithTitle:@"subNOT"];
    _toolSubmenu = [[NSMenu alloc] initWithTitle:@"tools"];
    
    [_mainMenu insertItem:_tosUpdateMI atIndex:0];
    [_mainMenu insertItem:_tosMI atIndex:1];
    [_mainMenu insertItem:_idleMI atIndex:2];
    [_mainMenu insertItem:_notMI atIndex:3];
    [_mainMenu insertItem:_tosActualMI atIndex:4];
    
    
    [_tosMI setSubmenu:_tosSubmenu];
    [_notMI setSubmenu:_notSubmenu];
    [_idleMI setSubmenu:_idleSubmenu];
    [_tosActualMI setSubmenu:_toolSubmenu];
    
    [_toolSubmenu insertItem:_notificationStartMI atIndex:0];
    [_toolSubmenu insertItem:_notificationStopMI atIndex:1];
    [_toolSubmenu insertItem:_resetMI atIndex:2];
    [_toolSubmenu insertItem:_quitMI atIndex:3];
    [_toolSubmenu insertItem:_windowMI atIndex:4];
    
    _notAppDictonary =  [[NSMutableDictionary alloc] init];
    _tosAppDictonary =  [[NSMutableDictionary alloc] init];
    _idleAppDictonary =  [[NSMutableDictionary alloc] init];
    
    _tosAlgorithm = [TOSAlgorithm sharedAlgorithm];
    return self;
}

// atualiza o tempo dos aplicativos no submenu NOT
-(void)updateSubMenuItemTimer {
    
    [_tosActualMI setTitle:[Utils getNewIntervalFromDateFormated:_tosAlgorithm.startInterval
                                                          status: _tosAlgorithm.statusNow]];
 /*
    NSArray *items = [_notSubmenu itemArray];
    for (NSMenuItem *item in items) {
        NSTimeInterval t = [_notAppDictonary[[item toolTip]] integerValue];
        NSString * newTitle = [NSString stringWithFormat:@"%@ %@",
                               [Utils formartTime:t], [item toolTip]];
        [item setTitle:newTitle];
    }
*/
    
    [self updateStatusSubMenu:_tosSubmenu dictionary:_tosAppDictonary];
    [self updateStatusSubMenu:_notSubmenu dictionary:_notAppDictonary];
    [self updateStatusSubMenu:_idleSubmenu dictionary:_idleAppDictonary];
    

}


-(void)updateStatusSubMenu:(NSMenu *)submenu dictionary:(NSMutableDictionary *)dic {
    NSArray * items = [submenu itemArray];
    for (NSMenuItem *item in items) {
        NSTimeInterval t = [dic [[item toolTip]] integerValue];
        NSString * newTitle = [NSString stringWithFormat:@"%@ %@",
                              [item toolTip], [Utils formartTime:t]];
        [item setTitle:newTitle];
    }
}

-(void)updateSubMenuTimer {
    [_idleMI setTitle:[Utils formatTos:_tosAlgorithm.idleTime status:IDLE_STATUS]];
    [_tosMI setTitle:[Utils formatTos:_tosAlgorithm.tosTime status:TOS_STATUS]];
    [_notMI setTitle:[Utils formatTos:_tosAlgorithm.notTime status:NOT_STATUS]];
}

-(void)getFrontAppWithNot {
    
    NSRunningApplication *_frontApp = [[NSWorkspace sharedWorkspace] frontmostApplication];
    NSString *fapp = _frontApp.localizedName;
    NSInteger tag = [_notSubmenu numberOfItems];
    
    NSNumber *index = [_notAppDictonary objectForKey:fapp];
    
    // index == nil means it isn't in the NOT list in Menu.
    if (index == nil) {
        NSMenuItem * novo = [_notSubmenu insertItemWithTitle:fapp action:nil keyEquivalent:@"" atIndex:0];
        [novo setToolTip:fapp];
        [novo setTag:tag];
        [_notAppDictonary setObject:[NSNumber numberWithInt:0] forKey:fapp];
    } else {
        // if the app is in the list, then increase the count (timer)
        NSInteger count = [_notAppDictonary[fapp] integerValue];
        count += UPDATE;
        _notAppDictonary[fapp] = [NSNumber numberWithInteger:count];
    }
}

-(NSInteger)getTagOfStatusSubmenu {
    if (_tosAlgorithm.statusNow == TOS_STATUS) {
        return [_tosSubmenu numberOfItems];
    } else if (_tosAlgorithm.statusNow == IDLE_STATUS) {
        return [_idleSubmenu numberOfItems];
    } else if (_tosAlgorithm.statusNow == NOT_STATUS) {
        return [_notSubmenu numberOfItems];
    } else {
        return -1;
    }
}
-(NSMutableDictionary *)getDictionaryOfStatus {
    if (_tosAlgorithm.statusNow == TOS_STATUS) {
        return _tosAppDictonary;
    } else if (_tosAlgorithm.statusNow == IDLE_STATUS) {
        return _idleAppDictonary;
    } else if (_tosAlgorithm.statusNow == NOT_STATUS) {
        return _notAppDictonary;
    } else {
        return [[NSMutableDictionary alloc] init];;
    }
}

-(NSMenu *)getMenuOfStatus {
    if (_tosAlgorithm.statusNow == TOS_STATUS) {
        return _tosSubmenu;
    } else if (_tosAlgorithm.statusNow == IDLE_STATUS) {
        return _idleSubmenu;
    } else if (_tosAlgorithm.statusNow == NOT_STATUS) {
        return _notSubmenu;
    } else {
        return nil;
    }
}



-(void)getFrontApp {
    
    NSRunningApplication *_frontApp = [[NSWorkspace sharedWorkspace] frontmostApplication];
    NSString *fapp = _frontApp.localizedName;
    NSInteger tag = [self getTagOfStatusSubmenu];
    NSMutableDictionary * ad = [self getDictionaryOfStatus];
    NSNumber *index = [ad objectForKey:fapp];
    NSMenu * menu = self.getMenuOfStatus;
    
    // index == nil means it isn't in the NOT list in Menu.
    if (index == nil) {
        NSMenuItem * novo = [menu insertItemWithTitle:fapp action:nil keyEquivalent:@"" atIndex:0];
        [novo setToolTip:fapp];
        [novo setTag:tag];
        [ad setObject:[NSNumber numberWithInt:0] forKey:fapp];
    } else {
        // if the app is in the list, then increase the count (timer)
        NSInteger count = [ad[fapp] integerValue];
        count += UPDATE;
        ad[fapp] = [NSNumber numberWithInteger:count];
    }
}

@end
