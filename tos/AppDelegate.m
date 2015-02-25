//
//  AppDelegate.m
//  tos
//
//  Created by snk on 2/23/15.
//  Copyright (c) 2015 snk. All rights reserved.
//

#define UPDATE 1
#define IDLE_MAX 10
#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (strong, nonatomic) NSStatusItem *statusItem;
@property NSInteger tos;
@property NSInteger idleTimes;
@property (strong, nonatomic) NSDate *startTime;
@property (nonatomic) NSTimeInterval intervalTOS;

@property BOOL isIdle;
@property BOOL isTOS;

@end

@implementation AppDelegate

-(NSString *)formatTos:(NSInteger)interval {
    NSInteger ti = (NSInteger)interval;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);
    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
}

-(void)updateTimer {
    //NSTimeInterval timeInterval = [_start timeIntervalSinceNow];
    if (_isIdle) {
        [_statusItem setTitle:@"IDLE"];
    } else {
        NSString * formated;
        NSInteger seconds = _tos % 60;
        NSInteger minutes = (_tos / 60) % 60;
        NSInteger hours = (_tos / 3600);
        formated =  [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
        [_statusItem setTitle:[NSString stringWithFormat:@"tos: %@", formated]];
    }
}


-(void)minusTimer {
    
}


- (void)systemIdleTimeVoid
{
    CFTimeInterval timeSinceLastEvent = CGEventSourceSecondsSinceLastEventType(kCGEventSourceStateHIDSystemState, kCGAnyInputEventType);
    NSLog(@"\ntempo= %f", timeSinceLastEvent);
    if (timeSinceLastEvent > IDLE_MAX) {
        if (_isIdle == YES) {
            //do nothing;
        } else {
            _tos -= UPDATE;
            _isIdle = YES;
        }
    } else {
        _tos += UPDATE;
        _isIdle = NO;
    }
    [self updateTimer];
}

-(void)lookApplicationsScore{
    // lista os applicativos de "usuários"
    NSWorkspace * ws = [NSWorkspace sharedWorkspace];
    NSArray * apps = [ws runningApplications];
    NSUInteger count = [apps count];
    
    
    int score = 0;
    for (NSUInteger i = 0; i < count; i++) {
        NSRunningApplication *app = [apps objectAtIndex: i];
        
        if(app.activationPolicy == NSApplicationActivationPolicyRegular) {
            
            if([app.localizedName isEqualToString:@"MindNode Pro"]){
                score+=2;
            } else if ([app.localizedName isEqualToString:@"MacVim"]){
                score++;
            }
            else if ([app.localizedName isEqualToString:@"TextEdit"]){
                score++;
            }
            else if ([app.localizedName isEqualToString:@"Preview"]){
                score++;
            }
            if(app.active) {
                NSLog(@"app ativo: %@",app.localizedName);
            }
            if (app.hidden){
                 NSLog(@"app hidden: %@",app.localizedName);
                NSLog(@"app PID: %d",app.processIdentifier);

            }
        }
        
    }
    
    if (score > 3){
        
        [self systemIdleTimeVoid];
        /*
        NSTimeInterval timeInterval = [_startTime timeIntervalSinceNow];
        NSLog(@"interval: %f", timeInterval);
        */
        
    } else {
         [_statusItem setTitle:@"NOT"];
    }

}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.statusItem=[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [_statusItem setTitle:[NSString stringWithFormat:@"tos"]];

    
    _tos = 0;
    _idleTimes = 0;
    
    
    _startTime = [NSDate date];
    _intervalTOS = 0;
    _isIdle = NO;
    _isTOS = NO;
    
    // do stuff...

    [self lookApplicationsScore];
    [self startTOS];

}

-(void)startTOS {
    NSTimeInterval update;
    update = UPDATE;
    [NSTimer
     scheduledTimerWithTimeInterval:(update)
     target:self
     selector:@selector(lookApplicationsScore)
     userInfo:nil
     repeats:YES];
    
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
