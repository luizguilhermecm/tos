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
#import "CardManager.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (strong, nonatomic) NSStatusItem *statusItem;

@property NSTimeInterval newInterval;
@property NSDate * startInterval;

@property NSTimeInterval tos;
@property NSTimeInterval idleT;
@property NSTimeInterval notT;

@property (strong, nonatomic) NSDate *startTime;
@property (nonatomic) NSTimeInterval intervalTOS;

@property (strong) IBOutlet NSMenu * tosMenu;
@property (strong) IBOutlet NSMenuItem * tosUpdateMI;

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

@end

@implementation AppDelegate


-(NSString *)formatTos:(NSTimeInterval)interval status:(NSString*)astatus{
    NSInteger ti = (NSInteger)interval;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);
    return [NSString stringWithFormat:@"%@ %02ld:%02ld:%02ld", astatus, (long)hours, (long)minutes, (long)seconds];
}


-(NSInteger) getStatus {
    return _statusNow;
}

-(void)updateSubMenuTimer {
        
        [_idleMI setTitle:[self formatTos:_idleT status:@"IDLE:"]];
        [_tosMI setTitle:[self formatTos:_tos status:@"TOS:"]];
        [_notMI setTitle:[self formatTos:_notT status:@"NOT:"]];
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
        if ([_notSubmenu indexOfItemWithTitle:fapp] == -1) {
            [_notSubmenu insertItemWithTitle:fapp action:nil keyEquivalent:@"" atIndex:0];
        }
    } else if (self.getStatus == IDLE_STATUS) {
            if ([_idleSubmenu indexOfItemWithTitle:fapp] == -1) {
                [_idleSubmenu insertItemWithTitle:fapp action:nil keyEquivalent:@"" atIndex:0];
            }
    }
    
   
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    CardManager * tc = [[CardManager alloc] init];
    [tc teste];
    
    self.statusItem=[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    _log = [[TOSLog alloc] init];
    _tosMenu = [[NSMenu alloc] initWithTitle:@"TOS"];


    _tosUpdateMI = [[NSMenuItem alloc] initWithTitle:@"update" action:@selector(updateMenu:) keyEquivalent:@"r"];
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
    
    
    // do stuff...
    [self writeToLogFile:@"tos-started"];
    [self startTOS];



//    [[NSRunLoop currentRunLoop] performSelector:@selector(updateTheMenu:) target:self argument:_tosMenu order:0 modes:[NSArray arrayWithObject:NSRunLoopCommonModes]];



}
- (void)updateTheMenu:(NSMenu*)menu
{
 //   [menu addItemWithTitle:@"Foobar" action:NULL keyEquivalent:@""];
    [menu update];
    NSLog(@"teste");

}
-(IBAction) updateMenu :(id)sender {
    [self setNewIntervalToStatus];
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

-(void)setNotifications {
    [[[NSWorkspace sharedWorkspace] notificationCenter]
     addObserver: self
     selector: @selector(receiveNote:)
     name: NSWorkspaceWillSleepNotification object: NULL];
    
    [[[NSWorkspace sharedWorkspace] notificationCenter]
     addObserver: self
     selector: @selector(receiveNote:)
     name: NSWorkspaceScreensDidSleepNotification object: NULL];
    
    [[[NSWorkspace sharedWorkspace] notificationCenter]
     addObserver: self
     selector: @selector(receiveNote:)
     name: NSWorkspaceDidWakeNotification object: NULL];
    [[[NSWorkspace sharedWorkspace] notificationCenter]
     addObserver: self
     selector: @selector(receiveNote:)
     name: NSWorkspaceScreensDidWakeNotification object: NULL];
}

/*
-(void)updateTimerTimer {
    [NSTimer
     scheduledTimerWithTimeInterval:(REFRESH_MENU)
     target:self
     selector:@selector(updateTimer)
     userInfo:nil
     repeats:YES];
}
 */

- (void) receiveNote: (NSNotification*) note
{
    NSLog(@"receiveNote: %@", [note name]);
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
