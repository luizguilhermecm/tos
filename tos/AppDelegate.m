//
//  AppDelegate.m
//  tos
//
//  Created by snk on 2/23/15.
//  Copyright (c) 2015 snk. All rights reserved.
//



#import "AppDelegate.h"
#import "TOSLog.h"
#import "defines.h"
#import "TrueCard.h"
#import "CDManager.h"
#import "NotificationCard.h"
#import "Utils.h"


@interface AppDelegate ()

@property (strong) IBOutlet NSWindow *window;
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
@property (strong) IBOutlet NSMenu * toolSubmenu;
@property (strong) IBOutlet NSMenuItem * quitMI;
@property (strong) IBOutlet NSMenuItem * resetMI;
@property (strong) IBOutlet NSMenuItem * notificationStartMI;
@property (strong) IBOutlet NSMenuItem * notificationStopMI;


@property (strong) IBOutlet NSMenuItem * idleMI;
@property (strong) IBOutlet NSMenu * idleSubmenu;

@property (strong) IBOutlet NSMenuItem * tosMI;
@property (strong) IBOutlet NSMenu * tosSubmenu;

@property (strong) IBOutlet NSMenuItem * notMI;
@property (strong) IBOutlet NSMenu * notSubmenu;

@property(readonly, strong) NSNotificationCenter *notificationCenter;
@property (strong) NSTimer * notificationTimer;

@property NSInteger statusNow;

@property TOSLog * log;

@property BOOL isIdle;
@property BOOL isTOS;
@property NSInteger score;

//@property TrueCard * tc;

@end

@implementation AppDelegate

@synthesize isIdle;
@synthesize isTOS;
@synthesize tos;
@synthesize idleT;
@synthesize notT;
@synthesize score;

@synthesize statusNow;

-(void)updateSubMenuTimer {
        [_idleMI setTitle:[Utils formatTos:idleT status:@"IDLE"]];
        [_tosMI setTitle:[Utils formatTos:tos status:@"TOS"]];
        [_notMI setTitle:[Utils formatTos:notT status:@"NOT"]];
}


// atualiza o tempo dos aplicativos no submenu NOT
-(void)updateSubMenuItemTimer {
    
    [_tosActualMI setTitle:[self getNewIntervalFromDateFormated]];
    
    NSArray *items = [_notSubmenu itemArray];
    for (NSMenuItem *item in items) {
        NSTimeInterval t = [_notApp[[item toolTip]] integerValue];
        NSString * newTitle = [Utils formatTos:t status:[item toolTip]];
        [item setTitle:newTitle];
    }
}

-(void)updateMenuTitle {
    if (statusNow == IDLE_STATUS) {
        [_statusItem setTitle:@"IDLE"];
    } else if (statusNow == TOS_STATUS) {
        [_statusItem setTitle:@"TOS"];
    } else if (statusNow == NOT_STATUS) {
        [_statusItem setTitle:@"NOT"];
    }
}


-(void)idleTimer:(NSTimeInterval)interval {
    idleT += interval;
}

-(void)tosTimer :(NSTimeInterval)interval{
    tos += interval;
}

-(void)notTimer :(NSTimeInterval)interval{
    notT += interval;
}

-(NSString *)getNewIntervalFromDateFormated {
    NSTimeInterval interval = [self getNewIntervalFromDate];
    return [Utils formatTos:interval status:@"Now"];
}

-(NSTimeInterval)getNewIntervalFromDate {
    return [_startInterval timeIntervalSinceNow] * -1;
}

-(void)setNewIntervalToStatus {
    NSTimeInterval interval = [self getNewIntervalFromDate];
    
    if (statusNow == TOS_STATUS) {
        [self tosTimer:interval];
        
    } else if (statusNow == IDLE_STATUS) {
        [self idleTimer:interval];
        
    } else if (statusNow == NOT_STATUS) {
        [self notTimer:interval];
        
    }
    _startInterval = [NSDate date];
}

-(void)updateStatus:(NSInteger)status {
    
    if (statusNow == NOT_STATUS) {
        if (status != NOT_STATUS) {
//            [_tc invalidateTrueCardTimer];
        }
    } else {
        if (status == NOT_STATUS) {
  //          _tc = [[TrueCard alloc] init];
 //           [_tc setTrueCardTimer];
        }
    }
    
    
    if (statusNow == status) {
        
        // do nothingj=
    } else {
        [_log LogInterval:[self getNewIntervalFromDate] status:statusNow];
        
        [self setNewIntervalToStatus];
        [self updateSubMenuTimer];
        statusNow = status;
        [self updateMenuTitle];
    }
}


// work flow when status is TOS
-(void)tosStatusWF {
    
}

// work flow when status is NOT
-(void)notStatusWF {
    [self getFrontAppWithNot];
    
}

// work flow when status is IDLE
-(void)idleStatusWF {
//     [self getFrontApp];
}

-(void)tosLoop {
    if ([Utils isSystemIdle]) {

        [self updateStatus:IDLE_STATUS];
        [self idleStatusWF];
        
    } else {
        [self getApplicationsScore];
        [self choiseMaker];
    }
}

-(void)getApplicationsScore{
    
    score = 0;
    score += [Utils isAppOpen:@"com.apple.TextEdit"];
    score += [Utils isAppOpen:@"com.apple.Preview"];
    score += [Utils isAppOpen:@"org.vim.MacVim"];
    score += [Utils isAppOpen:@"com.mindnode.MindNodePro"];
    
    if ([Utils isAppOpen:@"com.apple.Safari"] == 1) {
        // decidir o que fazer qndo o safari estiver aberto
        //[Utils safariURL];
    }
}



-(void) choiseMaker {

    if (score >= 3){
        
        [self updateStatus:TOS_STATUS];
        [self tosStatusWF];
        
    } else {
        
        [self updateStatus:NOT_STATUS];
        [self notStatusWF];
    }
}

-(void)getFrontAppWithNot {
    
    NSRunningApplication *_frontApp = [[NSWorkspace sharedWorkspace] frontmostApplication];
    NSString *fapp = _frontApp.localizedName;
    NSInteger tag = [_notSubmenu numberOfItems];
    
    NSNumber *index = [_notApp objectForKey:fapp];
    
    // index == nil means it isn't in the NOT list in Menu.
    if (index == nil) {
        NSMenuItem * novo = [_notSubmenu insertItemWithTitle:fapp action:nil keyEquivalent:@"" atIndex:0];
        [novo setToolTip:fapp];
        [novo setTag:tag];
        [_notApp setObject:[NSNumber numberWithInt:0] forKey:fapp];
    } else {
        // if the app is in the list, then increase the count (timer)
        NSInteger count = [_notApp[fapp] integerValue];
        count += UPDATE;
        _notApp[fapp] = [NSNumber numberWithInteger:count];
    }
}


-(void)applicationDidFinishLaunching:(NSNotification *)aNotification {

    self.statusItem=[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    _log = [[TOSLog alloc] init];
    _tosMenu = [[NSMenu alloc] initWithTitle:@"TOS"];


    _tosUpdateMI = [[NSMenuItem alloc] initWithTitle:@"update" action:@selector(updateMenu:) keyEquivalent:@"r"];
    _tosActualMI = [[NSMenuItem alloc] initWithTitle:@"timer: " action:nil keyEquivalent:@""];
    _quitMI = [[NSMenuItem alloc] initWithTitle:@"Quit" action:@selector(quitTOS:) keyEquivalent:@"q"];
    _resetMI = [[NSMenuItem alloc] initWithTitle:@"Reset" action:@selector(resetTOS:) keyEquivalent:@""];
    _notificationStartMI = [[NSMenuItem alloc] initWithTitle:@"Start TrueCard" action:@selector(notificationStart:) keyEquivalent:@""];
    _notificationStopMI = [[NSMenuItem alloc] initWithTitle:@"Stop TrueCard" action:@selector(notificationStop:) keyEquivalent:@""];
    
    _tosMI = [[NSMenuItem alloc] initWithTitle:@"TOS" action:nil keyEquivalent:@""];
    _notMI = [[NSMenuItem alloc] initWithTitle:@"NOT" action:nil keyEquivalent:@""];
    _idleMI = [[NSMenuItem alloc] initWithTitle:@"IDLE" action:nil keyEquivalent:@""];

    _tosSubmenu = [[NSMenu alloc] initWithTitle:@"subTOS"];
    _idleSubmenu = [[NSMenu alloc] initWithTitle:@"idleNOT"];
    _notSubmenu = [[NSMenu alloc] initWithTitle:@"subNOT"];
    _toolSubmenu = [[NSMenu alloc] initWithTitle:@"tools"];
    
    [_tosMenu insertItem:_tosUpdateMI atIndex:0];
    [_tosMenu insertItem:_tosMI atIndex:1];
    [_tosMenu insertItem:_idleMI atIndex:2];
    [_tosMenu insertItem:_notMI atIndex:3];
    [_tosMenu insertItem:_tosActualMI atIndex:4];

    
    [_tosMI setSubmenu:_tosSubmenu];
    [_notMI setSubmenu:_notSubmenu];
    [_idleMI setSubmenu:_idleSubmenu];
    [_tosActualMI setSubmenu:_toolSubmenu];
    
    [_toolSubmenu insertItem:_notificationStartMI atIndex:0];
    [_toolSubmenu insertItem:_notificationStopMI atIndex:1];
    [_toolSubmenu insertItem:_resetMI atIndex:2];
    [_toolSubmenu insertItem:_quitMI atIndex:3];
    
    
    [_statusItem setTitle:@"tos"];
    [_statusItem setEnabled:YES];
    [_statusItem setHighlightMode:YES];
    [_statusItem setMenu:_tosMenu];
    
    [_tosMenu performActionForItemAtIndex:0];
    
    tos = 0;
    idleT = 0;
    notT = 0;
    
    _notApp =  [[NSMutableDictionary alloc] init];
    
    // do stuff...
    
    
    
    [self startTOS];


}

-(IBAction) notificationStart :(id)sender {
    [NotificationCard readFile];
    
    [_notificationStartMI setTitle:[NSString stringWithFormat:@"Started %ld cards", NotificationCard.nb]];
    
    _notificationTimer = [NSTimer
     scheduledTimerWithTimeInterval:(60)
     target:self
     selector:@selector(callNotification)
     userInfo:nil
     repeats:YES];
}
-(void) callNotification {
    [NotificationCard newNotificationCard];

}

-(IBAction) notificationStop :(id)sender {
    [_notificationTimer invalidate];
    [_notificationStartMI setTitle:@"Start"];
}

-(IBAction) resetTOS :(id)sender {
    tos = 0;
    idleT = 0;
    notT = 0;
    [_notSubmenu removeAllItems];
    [_notApp removeAllObjects];
    _startInterval = [NSDate date];
    [_tosActualMI setTitle:[self getNewIntervalFromDateFormated]];
}

-(IBAction) quitTOS :(id)sender {
    [_log LogInterval:[self getNewIntervalFromDate] status:statusNow];
    [_log LogInterval:0 status:QUIT_TOS];
    
    [[NSApplication sharedApplication] terminate:nil];
}

-(IBAction) updateMenu :(id)sender {
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

- (void) notificationReceived: (NSNotification*) note
{
    NSLog(@"%@", [note name]);
}

- (void) sleepNote: (NSNotification*) note
{
    [self updateStatus:SLEEP_STATUS];
}
- (void) wakeNote: (NSNotification*) note
{
    [self updateStatus:WAKE_STATUS];
}


-(void)startTOS {
    statusNow = IDLE_STATUS;
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
