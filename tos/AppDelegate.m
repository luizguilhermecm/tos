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
#import "TOSAlgorithm.h"
#import "TOSMenu.h"


@interface AppDelegate ()

@property (strong) IBOutlet NSWindow *window;
@property (strong, nonatomic) NSStatusItem *statusItem;

///@property (nonatomic) NSTimeInterval intervalTOS;

@property(readonly, strong) NSNotificationCenter *notificationCenter;
@property (strong) NSTimer * notificationTimer;

@property NSString * reasonOfNot;

@property NSDate * lastTimeInFront;
@property NSInteger score;

@property TOSAlgorithm *tosAlgorithm;
@property TOSMenu *tosMenu;

@end

@implementation AppDelegate

@synthesize score;




-(void)updateMenuBarTitle {
    [_statusItem setTitle:[Utils statusIdToString:_tosAlgorithm.statusNow]];
}

-(void)updateStatus:(NSInteger)status {

    if (_tosAlgorithm.statusNow == status) {
        
        // do nothingj=
    } else {
        [TOSLog LogInterval:[Utils getNewIntervalFromDate:[_tosAlgorithm startInterval]]
                     status:_tosAlgorithm.statusNow];
        
        [_tosAlgorithm setNewIntervalToStatus];
        [self.tosMenu updateSubMenuItemTimer];
        _tosAlgorithm.statusNow = status;
        [self updateMenuBarTitle];
    }
}



-(BOOL) checkSpecificApp :(NSString *) app{
    if ([Utils isAppOpen:app] == 1)
        return YES;
    else
        return NO;
}

-(void)checkMindMap {
    NSRunningApplication *_frontApp = [[NSWorkspace sharedWorkspace] frontmostApplication];
    if ([_frontApp.bundleIdentifier isEqualToString:@"com.mindnode.MindNodePro"]) {
        _lastTimeInFront = [NSDate date];
    } else {
        NSTimeInterval since = [_lastTimeInFront timeIntervalSinceNow];
        since *= -1;
        if (since > 300) {
            [NotificationCard newNotificationCardWithText:@"MindMone Pro" subtitle:@"Está aberto" text:@"Está Estudando!?"];
            _lastTimeInFront = [NSDate date];
        }
    }
}

// work flow when status is TOS
-(void)tosStatusWF {
    [self checkMindMap];
}

// work flow when status is NOT
-(void)notStatusWF {
    [_tosMenu getFrontAppWithNot];
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
    }
}

-(void)getApplicationsScore{
    
    score = 0;
    score += [Utils isAppOpen:@"com.apple.TextEdit"];
    score += [Utils isAppOpen:@"com.apple.Preview"];
    score += [Utils isAppOpen:@"org.vim.MacVim"];
    score += [Utils isAppOpen:@"com.mindnode.MindNodePro"];
    
    /*
    if ([Utils isAppOpen:@"com.apple.Safari"] == 1) {
        // decidir o que fazer qndo o safari estiver aberto
        //[Utils safariURL];
    }
    */
    
    [self choiseMaker];

}



-(void) choiseMaker {

    if (score >= 3){
        [self updateStatus:TOS_STATUS];
        [self tosStatusWF];
        
    } else if (score >=0) {
        
        [self updateStatus:NOT_STATUS];
        [self notStatusWF];
    }
}



-(void)applicationDidFinishLaunching:(NSNotification *)aNotification {

    self.statusItem=[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    self.tosAlgorithm = [TOSAlgorithm sharedAlgorithm];
    
    self.tosMenu = [TOSMenu sharedMenu];
    
    [_statusItem setTitle:@"tos"];
    [_statusItem setEnabled:YES];
    [_statusItem setHighlightMode:YES];
    [_statusItem setMenu:[_tosMenu mainMenu]];
    

    
    [self startTOS];
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
    _tosAlgorithm.statusNow = IDLE_STATUS;
    _tosAlgorithm.startInterval = [NSDate date];
    [self setNotifications];
    [self tosLoop];
    
    [NSTimer
     scheduledTimerWithTimeInterval:(UPDATE)
     target:self
     selector:@selector(tosLoop)
     userInfo:nil
     repeats:YES];
}

-(IBAction) quitTOS :(id)sender {
    
    [TOSLog LogInterval:[Utils
                         getNewIntervalFromDate:_tosAlgorithm.startInterval]
                 status:_tosAlgorithm.statusNow];
    [TOSLog LogInterval:0 status:QUIT_TOS];
    
    
    [[NSApplication sharedApplication] terminate:nil];
}

-(IBAction) notificationStart :(id)sender {
    [NotificationCard readFile];

    [_tosMenu.notificationStartMI setTitle:[NSString stringWithFormat:@"Started %ld cards", NotificationCard.nb]];
    
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
    [_tosMenu.notificationStartMI setTitle:@"Start TrueCard"];
}


-(IBAction) resetTOS :(id)sender {
     _tosAlgorithm = [[TOSAlgorithm alloc] init];
    _tosMenu = [[TOSMenu alloc] init];
}

-(IBAction) updateMenu :(id)sender {
    [_tosMenu updateSubMenuItemTimer];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
