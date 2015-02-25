//
//  AppDelegate.m
//  tos
//
//  Created by snk on 2/23/15.
//  Copyright (c) 2015 snk. All rights reserved.
//

#define UPDATE 2
#define IDLE_MAX 15
#define REFRESH_MENU 5
#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (strong, nonatomic) NSStatusItem *statusItem;
@property NSInteger tos;
@property NSInteger idleT;
@property NSInteger notT;
@property (strong, nonatomic) NSDate *startTime;
@property (nonatomic) NSTimeInterval intervalTOS;

@property (strong) IBOutlet NSMenu * tosMenu;
@property (strong) IBOutlet NSMenuItem * idleMI;
@property (strong) IBOutlet NSMenuItem * tosMI;
@property (strong) IBOutlet NSMenuItem * notMI;

@property(readonly, strong) NSRunningApplication *frontmostApplication;


@property(readonly, strong) NSNotificationCenter *notificationCenter;


@property BOOL isIdle;
@property BOOL isTOS;

@end

@implementation AppDelegate

-(NSString *)formatTos:(NSInteger)interval status:(NSString*)astatus{
    NSInteger ti = (NSInteger)interval;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);
    return [NSString stringWithFormat:@"%@ %02ld:%02ld:%02ld", astatus, (long)hours, (long)minutes, (long)seconds];
}

-(void)updateTimer {
    //NSTimeInterval timeInterval = [_start timeIntervalSinceNow];
    if (_isIdle) {
        [_idleMI setTitle:[self formatTos:_idleT status:@"IDLE:"]];
        [_statusItem setTitle:@"IDLE"];
    } else if (_isTOS) {
        [_tosMI setTitle:[self formatTos:_tos status:@"TOS:"]];
        [_statusItem setTitle:@"TOS"];
    } else {
        [_notMI setTitle:[self formatTos:_notT status:@"NOT:"]];
        [_statusItem setTitle:@"NOT"];
    }
}


-(void)idleTimer {
    _idleT += UPDATE;
    //    [self updateTimer];
}


-(void)tosTimer {
    _tos += UPDATE;
    //    [self updateTimer];
}

-(void)notTimer {
    _notT += UPDATE;
    //    [self updateTimer];
}

- (BOOL)isSystemIdle
{
    CFTimeInterval timeSinceLastEvent = CGEventSourceSecondsSinceLastEventType(kCGEventSourceStateHIDSystemState, kCGAnyInputEventType);
    
    if (timeSinceLastEvent > IDLE_MAX) {
        _isIdle = YES;
        return YES;
    } else {
        _isIdle = NO;
        return NO;
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

    if (score > 3 && [self isSystemIdle] == NO){
        _isTOS = YES;
        [self tosTimer];
        
    } else {
        _isTOS = NO;
        if([self isSystemIdle]) {
            [self idleTimer];
        } else {
            [self notTimer];
        }
    }
    
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.statusItem=[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    _tosMenu = [[NSMenu alloc] initWithTitle:@"TOS"];
    
    [_tosMenu setTitle:@"TOS"];
    
    _tosMI = [[NSMenuItem alloc] init];
    _idleMI = [[NSMenuItem alloc] init];
    _notMI = [[NSMenuItem alloc] init];
    [_tosMI setTitle:@"TOS"];
    [_notMI setTitle:@"NOT"];
    [_idleMI setTitle:@"IDLE"];
    [_tosMenu insertItem:_tosMI atIndex:0];
    [_tosMenu insertItem:_idleMI atIndex:1];
    [_tosMenu insertItem:_notMI atIndex:2];
    
    
    
    
    [_statusItem setTitle:@"tos"];
    [_statusItem setEnabled:YES];
    [_statusItem setHighlightMode:YES];
    [_statusItem setMenu:_tosMenu];
    
    _tos = 0;
    _idleT = 0;
    _notT = 0;
    
    
    _startTime = [NSDate date];
    _intervalTOS = 0;
    _isIdle = NO;
    _isTOS = NO;
    
    // do stuff...
    
    [self lookApplicationsScore];
    [self startTOS];
    [self updateTimerTimer];
    [self setNotifications];
    
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


-(void)updateTimerTimer {
    [NSTimer
     scheduledTimerWithTimeInterval:(REFRESH_MENU)
     target:self
     selector:@selector(updateTimer)
     userInfo:nil
     repeats:YES];
}

- (void) receiveNote: (NSNotification*) note
{
    NSLog(@"receiveNote: %@", [note name]);
}

-(void)startTOS {
    [NSTimer
     scheduledTimerWithTimeInterval:(UPDATE)
     target:self
     selector:@selector(lookApplicationsScore)
     userInfo:nil
     repeats:YES];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
