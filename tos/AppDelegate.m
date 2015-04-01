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
@property (strong) IBOutlet NSTextView *tv;

@property (strong, nonatomic) NSStatusItem *statusItem;

///@property (nonatomic) NSTimeInterval intervalTOS;

@property(readonly, strong) NSNotificationCenter *notificationCenter;

@property NSUserNotification * lastSent;

@property NSString * reasonOfNot;

@property NSDate * lastTimeInFront;
@property NSInteger score;

@property TOSAlgorithm *tosAlgorithm;
@property TOSMenu *tosMenu;

@property NSTimer * trueCardTimer;
@property NSTimer * updateMenus;
@property NSTimer * responseTimerNotification;

@end

@implementation AppDelegate

@synthesize score;




-(void)updateMenuBarTitle {
    [_statusItem setTitle:[Utils statusIdToString:_tosAlgorithm.statusNow]];
}

-(void)appendInMenuBarTitle:(NSString *) a{
    [self updateMenuBarTitle];
    NSString * s = _statusItem.title;
    [_statusItem setTitle:[NSString stringWithFormat:@"%@%@",s,a]];
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
    /*
    NSRunningApplication *_frontApp = [[NSWorkspace sharedWorkspace] frontmostApplication];
    if ([_frontApp.bundleIdentifier isEqualToString:@"com.mindnode.MindNodePro"]) {
        _lastTimeInFront = [NSDate date];
    } else {
        NSTimeInterval since = [_lastTimeInFront timeIntervalSinceNow];
        since *= -1;
        if (since > 1000) {
            [NotificationCard newNotificationCardWithText:@"MindMone Pro" subtitle:@"Está aberto" text:@"Está Estudando!?"];
            _lastTimeInFront = [NSDate date];
        }
    }
     */
}

// work flow when status is TOS
-(void)tosStatusWF {
    [self checkMindMap];
    [_tosMenu getFrontApp];
}

// work flow when status is NOT
-(void)notStatusWF {
    [_tosMenu getFrontApp];    
}

// work flow when status is IDLE
-(void)idleStatusWF {
    //     [self getFrontApp];
}

-(void)tosLoop {
    
//    NSPoint location = [NSEvent mouseLocation];
//    NSLog(@"x: %f, y: %f", location.x, location.y);
    
    NSRunningApplication *_frontApp = [[NSWorkspace sharedWorkspace] frontmostApplication];
//    NSLog(@"%@",_frontApp.bundleIdentifier);
    if ([_frontApp.bundleIdentifier isEqualToString:@"cm.tos"]) {
        [self appendInMenuBarTitle:@"."];
    } else {
        [self updateMenuBarTitle];
    }

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

BOOL checkAccessibility()
{
    NSDictionary* opts = @{(__bridge id)kAXTrustedCheckOptionPrompt: @YES};
    return AXIsProcessTrustedWithOptions((__bridge CFDictionaryRef)opts);
}

-(void)applicationDidFinishLaunching:(NSNotification *)aNotification {

    NSUserNotificationCenter.defaultUserNotificationCenter.delegate = self;
    
    self.statusItem=[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    self.tosAlgorithm = [TOSAlgorithm sharedAlgorithm];
    
    self.tosMenu = [TOSMenu sharedMenu];
    
    [_statusItem setTitle:@"tos"];
    [_statusItem setEnabled:YES];
    [_statusItem setHighlightMode:YES];
    [_statusItem setMenu:[_tosMenu mainMenu]];

    
    /*     Text Editor Staff
     
     
    if (checkAccessibility()) {
        NSLog(@"Accessibility Enabled");
    }
    else {
        NSLog(@"Accessibility Disabled");
    }
    
    [NSEvent addGlobalMonitorForEventsMatchingMask:NSFlagsChangedMask
                                           handler:^(NSEvent *event){
                                               //NSLog(@"keydown: %ld", event.modifierFlags);
                                               if([event modifierFlags] == 1573160){
                                                   NSLog(@"asdf");
                                                   [self textEditorMI:event];
                                               }
                                           }];

     */
    
    [self startTOS];
//    [[NSWorkspace sharedWorkspace] showSearchResultsForQueryString:@"SMTP"];

}



-(IBAction) resetTOS :(id)sender {
    _tosAlgorithm = [[TOSAlgorithm alloc] init];
    _tosMenu = [[TOSMenu alloc] init];
}

-(IBAction) updateMenu :(id)sender {
    [_tosMenu updateSubMenuItemTimer];
    [_tosMenu updateSubMenuTimer];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
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

    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(windowWillClose:)
     name:NSWindowWillCloseNotification
     object:self.window];
}

- (void) notificationReceived: (NSNotification*) note
{
    NSLog(@"%@", [note name]);
}

- (void) sleepNote: (NSNotification*) note
{
    if (note.name == NSWorkspaceScreensDidSleepNotification) {
        [TOSLog LogEvent:SCREEN_DID_SLEEP_EVENT];
    } else if (note.name == NSWorkspaceWillSleepNotification) {
        [TOSLog LogEvent:WILL_SLEEP_EVENT];
    }
}

- (void) wakeNote: (NSNotification*) note
{
    if (note.name == NSWorkspaceScreensDidWakeNotification) {
        [TOSLog LogEvent:SCREEN_DID_WAKE_EVENT];
    } else if (note.name == NSWorkspaceDidWakeNotification) {
        [TOSLog LogEvent:DID_WAKE_EVENT];
    }
    
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
    [TOSLog LogEvent:QUIT_EVENT];
    
    
    [[NSApplication sharedApplication] terminate:nil];

}
/*
 NSBorderlessWindowMask
 NSClosableWindowMask
 NSTexturedBackgroundWindowMask
 NSTitledWindowMask
 
 NSRect frame = NSMakeRect(100, 100, 200, 200);
 NSInteger styleMask = NSClosableWindowMask;
 NSLog(@"mask; %d", styleMask);
 NSRect rect = [NSWindow contentRectForFrameRect:frame styleMask:styleMask];
 _window =  [[NSWindow alloc] initWithContentRect:rect styleMask:styleMask backing: NSBackingStoreBuffered    defer:false];
 
  (NSTitledWindowMask | NSClosableWindowMask) // works
 */

-(IBAction)textEditorMI:(id)sender {

    NSLog(@"textEditorMI");
 
        NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Desktop"];
        NSString *fileName = [documentsDirectory stringByAppendingPathComponent:@"_test.txt"];
        NSString *file = [NSString stringWithContentsOfFile:fileName
                                               encoding:NSUTF8StringEncoding
                                                  error:nil];

    if (_window == nil) {
        _window = [[NSWindow alloc] initWithContentRect:NSMakeRect(320.0, 550.0, 640, 250)
                                          styleMask:(NSTitledWindowMask | NSClosableWindowMask)
                                            backing:NSBackingStoreBuffered defer:NO];
        [_window setReleasedWhenClosed:FALSE];
        [_window setMovable:NO];
        NSLog(@"file_content: %@", file);
        NSRect cFrame =[[_window contentView] frame];
        _tv = [[NSTextView alloc] initWithFrame:cFrame];
        [_tv setString:file];
        [_window setContentView:_tv];
        [_window makeFirstResponder:_tv];
        [_window setRepresentedFilename:fileName];
        [_window setTitleWithRepresentedFilename:fileName];
        

    }
    

        [_window makeKeyAndOrderFront:self];

    [self.window setLevel:NSStatusWindowLevel];





}
- (void)windowWillClose:(NSNotification *)notification
{
    NSLog(@"windowWillClose");
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Desktop"];
    NSString *fileName = [documentsDirectory stringByAppendingPathComponent:@"_test.txt"];
    
    [[_tv string] writeToFile:fileName
                   atomically:YES
                     encoding:NSUTF8StringEncoding
                        error:nil];
    _window = nil;
}
/* NSWindow
 
 [_window setCollectionBehavior: NSWindowCollectionBehaviorCanJoinAllSpaces
 | NSWindowCollectionBehaviorStationary ];
        //        [[NSApplication sharedApplication] runModalForWindow:_window];
 //    [_window setRestorable:YES];
//        [_window makeKeyAndOrderFront:nil];
 
 */

/*
 ****************************************************************************************
 
 -------------------------____TRUE CARD NOTIFIFICATION____--------------------------------
 
 How it works:
 If user starts the True Card Notification, a notification will be sent.
 Once the notification is delivered, the timer "_responseTimerNotification" is set;
 If user do not activate the notification in MAX_TRUE_CARD_TIME, all delivered
 notifications will be removed.
 A notification will be sent to alert the user that True Cards was turned off.
 If user activate the alert notification True Cards will turn on again.
 If user do activate the notification, the _responseTimerNotification is invalidated
 and _trueCardTimer is turned on to send other one in TRUE_CARD_TIMER_DELAY
 
 The stop in menu will be used to clean the true cards array.
 
 
 notificao_enviada {
 usuario_clica_SHOW {
 interagiu
 da para veriricar o lastTcIdentifier
 }
 usuario_clica_CLOSE {
 
 
 }
 
 usuario_NAO_CLICA
 
 }
 
 
 
 
 ****************************************************************************************
 */

-(IBAction) notificationStart :(id)sender {
    [NotificationCard readFile];
    [self setTrueCardTimer];
    [_tosMenu.notificationStartMI
     setTitle:[NSString stringWithFormat:@"Started %ld cards", NotificationCard.nb]];
}

-(void) setTrueCardTimer {
    
    _trueCardTimer = [NSTimer
                      scheduledTimerWithTimeInterval:(TRUE_CARD_TIMER_DELAY)
                      target:self
                      selector:@selector(notificationBridge)
                      userInfo:nil
                      repeats:YES];
}

-(void) setTrueCardCleaner {
    _responseTimerNotification = [NSTimer
                                  scheduledTimerWithTimeInterval:(MAX_TRUE_CARD_TIME)
                                  target:self
                                  selector:@selector(removeNotificationNotActivated)
                                  userInfo:nil
                                  repeats:YES];
}


-(void) notificationBridge {
    [NotificationCard newNotificationCard];
}

-(IBAction) notificationStop :(id)sender {
    [NotificationCard removeAllNotifications];
    [_tosMenu.notificationStartMI setTitle:@"Start TrueCard"];
    [[NSUserNotificationCenter defaultUserNotificationCenter]removeAllDeliveredNotifications];
    [NotificationCard newNotificationCardWithText:@"True Cards"
                                         subtitle:@"Was turned off"
                                             text:@"Be Aware"];
    
}


- (void)userNotificationCenter:(NSUserNotificationCenter *)center
       didActivateNotification:(NSUserNotification *)notification{
    if ([[NotificationCard lastTcIdentifier] isEqualToString:notification.identifier]) {
//        [self setTrueCardTimer];
    }
    
}

- (void)userNotificationCenter:(NSUserNotificationCenter *)center
        didDeliverNotification:(NSUserNotification *)notification{
    
     // is this necessary?
    if ([[NotificationCard lastTcIdentifier] isEqualToString:notification.identifier]) {
        [NotificationCard lastTcDeliveredDateWith:[NSDate date]];
    }
    
}

-(void)removeNotificationNotActivated {
    [[NSUserNotificationCenter defaultUserNotificationCenter]removeAllDeliveredNotifications];
    [NotificationCard newNotificationCardWithText:@"True Cards" subtitle:@"Was turned off" text:@"Timeout"];
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center
     shouldPresentNotification:(NSUserNotification *)notification{
    return YES;
}

@end
