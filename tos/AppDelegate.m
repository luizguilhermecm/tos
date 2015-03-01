//
//  AppDelegate.m
//  tos
//
//  Created by snk on 2/23/15.
//  Copyright (c) 2015 snk. All rights reserved.
//

#define UPDATE 5
#define IDLE_MAX 60

#import "AppDelegate.h"
#import "TOSLog.h"
#import "defines.h"
#import "TrueCard.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (strong, nonatomic) NSStatusItem *statusItem;

@property NSTimeInterval newInterval;
@property NSDate * startInterval;

@property NSMutableDictionary * notApp;

@property NSTimeInterval tos;
@property NSTimeInterval idleT;
@property NSTimeInterval notT;

@property (strong, nonatomic) NSDate *startTime;
@property (nonatomic) NSTimeInterval intervalTOS;

@property (strong) IBOutlet NSMenu * tosMenu;
@property (strong) IBOutlet NSMenuItem * tosUpdateMI;
@property (strong) IBOutlet NSMenuItem * tosActualMI;


@property (strong) IBOutlet NSMenuItem * idleMI;
@property (strong) IBOutlet NSMenu * idleSubmenu;

@property (strong) IBOutlet NSMenuItem * tosMI;
@property (strong) IBOutlet NSMenu * tosSubmenu;

@property (strong) IBOutlet NSMenuItem * notMI;
@property (strong) IBOutlet NSMenu * notSubmenu;

@property(readonly, strong) NSRunningApplication *frontApp;


@property(readonly, strong) NSNotificationCenter *notificationCenter;

@property NSInteger statusNow;

@property TOSLog * log;

@property BOOL isIdle;
@property BOOL isTOS;

@property TrueCard * tc;

@end

@implementation AppDelegate


-(NSString *)formatTos:(NSTimeInterval)interval status:(NSString*)astatus{
    NSInteger ti = (NSInteger)interval;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);
    return [NSString stringWithFormat:@"%@: %02ld:%02ld:%02ld", astatus, (long)hours, (long)minutes, (long)seconds];
}


-(NSInteger) getStatus {
    return _statusNow;
}

-(void)updateSubMenuTimer {
        
        [_idleMI setTitle:[self formatTos:_idleT status:@"IDLE"]];
        [_tosMI setTitle:[self formatTos:_tos status:@"TOS"]];
        [_notMI setTitle:[self formatTos:_notT status:@"NOT"]];
}

-(void)updateSubMenuItemTimer {
    
    [_tosActualMI setTitle:[self getNewIntervalFromDateFormated]];
    
    NSArray *items = [_notSubmenu itemArray];
    for (NSMenuItem *item in items) {
        
        NSTimeInterval t = [_notApp[[item toolTip]] integerValue];

        NSString * newTitle = [self formatTos:t status:[item toolTip]];
        [item setTitle:newTitle];
    }
}

-(void)updateMenuTitle {
    if (self.getStatus == IDLE_STATUS) {
        [_statusItem setTitle:@"IDLE"];
    } else if (self.getStatus == TOS_STATUS) {
        [_statusItem setTitle:@"TOS"];
    } else if (self.getStatus == NOT_STATUS) {
        [_statusItem setTitle:@"NOT"];
    }
}


-(void)idleTimer:(NSTimeInterval)interval {
    _idleT += interval;
}

-(void)tosTimer :(NSTimeInterval)interval{
    _tos += interval;
}

-(void)notTimer :(NSTimeInterval)interval{
    _notT += interval;
}

-(NSString *)getNewIntervalFromDateFormated {
    NSTimeInterval interval = [self getNewIntervalFromDate];
    return [self formatTos:interval status:@"Update"];
}

-(NSTimeInterval)getNewIntervalFromDate {
    return [_startInterval timeIntervalSinceNow] * -1;
}

-(void)setNewIntervalToStatus {
    NSTimeInterval interval = [self getNewIntervalFromDate];
    [_log LogInterval:interval status:_statusNow];

    
    if ([self getStatus] == TOS_STATUS) {
        [self tosTimer:interval];
    } else if ([self getStatus] == IDLE_STATUS) {
        [self idleTimer:interval];
    } else if ([self getStatus] == NOT_STATUS) {
        [self notTimer:interval];
    }
    _startInterval = [NSDate date];
    
    [self updateSubMenuTimer];
}

-(void)updateStatus:(NSInteger)status {
    
    if (_statusNow == NOT_STATUS) {
        if (status != NOT_STATUS) {
            [_tc invalidateTrueCardTimer];
        }
    } else {
        if (status == NOT_STATUS) {
            _tc = [[TrueCard alloc] init];
            [_tc setTrueCardTimer];
        }
    }
    
    
    if (_statusNow == status) {
        
        // do nothingj=
    } else {
        
        [self setNewIntervalToStatus];

        _statusNow = status;
        [self updateMenuTitle];
        
    }
}

- (BOOL)isSystemIdle
{
    CFTimeInterval timeSinceLastEvent = CGEventSourceSecondsSinceLastEventType(kCGEventSourceStateHIDSystemState, kCGAnyInputEventType);
    
    if (timeSinceLastEvent > IDLE_MAX) {
        [self updateStatus:IDLE_STATUS];
        return YES;
    } else {
        return NO;
    }
}

-(void)tosStatusWF {
    
}

-(void)notStatusWF {
    [self getFrontApp];
    
}

-(void)idleStatusWF {
     [self getFrontApp];
}

-(void)tosLoop {
    if ([self isSystemIdle]) {
        
        [self idleStatusWF];
        
    } else {
        [self lookApplicationsScore];
    }
}

-(void)lookApplicationsScore{
    int score = 0;

    NSArray * running;
    running = [NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.apple.TextEdit"];
    if([running count] > 0){
        score++;
    }
    
    running = [NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.apple.Preview"];
    if([running count] > 0){
        score++;
    }
    
    running = [NSRunningApplication runningApplicationsWithBundleIdentifier:@"org.vim.MacVim"];
    if([running count] > 0){
        score++;
    }
    running =
        [NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.mindnode.MindNodePro"];
    if([running count] > 0){
        score+=2;
    }
    
    [self choiseMaker:score];
}

-(void) choiseMaker:(NSInteger)score {

    if (score > 3){
        
        [self updateStatus:TOS_STATUS];
        [self tosStatusWF];
        
    } else {
        
        [self updateStatus:NOT_STATUS];
        [self notStatusWF];
    }
}

-(void)getFrontApp {
    
    _frontApp = [[NSWorkspace sharedWorkspace] frontmostApplication];
    NSString * fapp = _frontApp.localizedName;

    if (self.getStatus == NOT_STATUS) {
        
        NSInteger tag;
        tag = [_notSubmenu numberOfItems];
        NSNumber * index = [_notApp objectForKey:fapp];

        if (index == nil) {
            NSMenuItem * novo = [_notSubmenu insertItemWithTitle:fapp action:nil keyEquivalent:@"" atIndex:0];
            [novo setToolTip:fapp];
            [novo setTag:tag];
            [_notApp setObject:[NSNumber numberWithInt:0] forKey:fapp];
             
        } else {
            NSInteger count = [_notApp[fapp] integerValue];
            count += UPDATE;
            _notApp[fapp] = [NSNumber numberWithInteger:count];
        }
    } else if (self.getStatus == IDLE_STATUS) {
            if ([_idleSubmenu indexOfItemWithTitle:fapp] == -1) {
                [_idleSubmenu insertItemWithTitle:fapp action:nil keyEquivalent:@"" atIndex:0];
            }
    }
    
   
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

    self.statusItem=[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    _log = [[TOSLog alloc] init];
    _tosMenu = [[NSMenu alloc] initWithTitle:@"TOS"];


    _tosUpdateMI = [[NSMenuItem alloc] initWithTitle:@"update" action:@selector(updateMenu:) keyEquivalent:@"r"];
    _tosActualMI = [[NSMenuItem alloc] initWithTitle:@"timer: " action:nil keyEquivalent:@""];
    
    _tosMI = [[NSMenuItem alloc] initWithTitle:@"TOS" action:nil keyEquivalent:@""];
    _notMI = [[NSMenuItem alloc] initWithTitle:@"NOT" action:nil keyEquivalent:@""];
    _idleMI = [[NSMenuItem alloc] initWithTitle:@"IDLE" action:nil keyEquivalent:@""];

    _tosSubmenu = [[NSMenu alloc] initWithTitle:@"subTOS"];
    _idleSubmenu = [[NSMenu alloc] initWithTitle:@"idleNOT"];
    _notSubmenu = [[NSMenu alloc] initWithTitle:@"subNOT"];

    [_tosMenu insertItem:_tosUpdateMI atIndex:0];
    [_tosMenu insertItem:_tosMI atIndex:1];
    [_tosMenu insertItem:_idleMI atIndex:2];
    [_tosMenu insertItem:_notMI atIndex:3];
    [_tosMenu insertItem:_tosActualMI atIndex:4];
    
    [_tosMI setSubmenu:_tosSubmenu];
    [_notMI setSubmenu:_notSubmenu];
    [_idleMI setSubmenu:_idleSubmenu];
    
    [_statusItem setTitle:@"tos"];
    [_statusItem setEnabled:YES];
    [_statusItem setHighlightMode:YES];
    [_statusItem setMenu:_tosMenu];
    
    [_tosMenu performActionForItemAtIndex:0];
    
    _tos = 0;
    _idleT = 0;
    _notT = 0;
    
    _notApp =  [[NSMutableDictionary alloc] init];
    
    // do stuff...
    
    [self startTOS];
}

-(IBAction) updateMenu :(id)sender {
//    [self setNewIntervalToStatus];
    [self updateSubMenuItemTimer];
}

-(void)setNotifications {
    [[[NSWorkspace sharedWorkspace] notificationCenter]
     addObserver: self
     selector: @selector(sleepNote:)
     name: NSWorkspaceWillSleepNotification object: NULL];
    
    [[[NSWorkspace sharedWorkspace] notificationCenter]
     addObserver: self
     selector: @selector(sleepNote:)
     name: NSWorkspaceScreensDidSleepNotification object: NULL];
    
    [[[NSWorkspace sharedWorkspace] notificationCenter]
     addObserver: self
     selector: @selector(wakeNote:)
     name: NSWorkspaceDidWakeNotification object: NULL];
    
    [[[NSWorkspace sharedWorkspace] notificationCenter]
     addObserver: self
     selector: @selector(wakeNote:)
     name: NSWorkspaceScreensDidWakeNotification object: NULL];
}

- (void) sleepNote: (NSNotification*) note
{
    [_log LogInterval:0 status:SLEEP_STATUS];
}
- (void) wakeNote: (NSNotification*) note
{
    [_log LogInterval:0 status:WAKE_STATUS];
}


-(void)startTOS {
    
    _statusNow = IDLE_STATUS;
    _startInterval = [NSDate date];
    [self setNotifications];
    [self tosLoop];
    
    [NSTimer
     scheduledTimerWithTimeInterval:(UPDATE)
     target:self
     selector:@selector(tosLoop)
     userInfo:nil
     repeats:YES];
    

}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
