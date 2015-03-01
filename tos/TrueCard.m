//
//  TrueCard.m
//  tos
//
//  Created by snk on 2/27/15.
//  Copyright (c) 2015 snk. All rights reserved.
//

#import "TrueCard.h"

@interface TrueCard()
//@property (weak) IBOutlet NSWindow *window;

@property NSTimer * trueCardTimer;
@end


@implementation TrueCard

-(void) setTrueCardTimer {
    _trueCardTimer = [NSTimer
                      scheduledTimerWithTimeInterval:(3)
                      target:self
                      selector:@selector(randonCard)
                      userInfo:nil
                      repeats:YES];
}

-(void) invalidateTrueCardTimer {
    [_trueCardTimer invalidate];
}

-(void) randonCard {
    [self showSimpleCriticalAlert];
}

-(void)showSimpleCriticalAlert
{
    NSAlert *alert = [[NSAlert alloc] init];
    NSWindow *window;
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:@"Alert"];
    [alert setIcon:[NSImage imageNamed:@"transparent.png"]];
    [alert setInformativeText:@"NSCriticalAlertStyle\rPlease enter a valid email iasdfas dfasdkfja ;sdjfl;ajsd fkljaskdfjakw fasdfja sdkfj askdfjaskdf asdjf asjdfk asdjf asdfjaksdfjkasd fasjdkf asjkdf ajksdf aksdfd."];
    //  [alert setAlertStyle:NSCriticalAlertStyle];
    [alert beginSheetModalForWindow:window modalDelegate:self didEndSelector:nil contextInfo:nil];
}

/*
-(void)showSimpleAlert
{
    NSWindow *window;

    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Continue"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert setMessageText:@"Alert"];
    [alert setInformativeText:@"alert zone"];
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert beginSheetModalForWindow:window modalDelegate:self didEndSelector:nil contextInfo:nil];
}
*/

- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    /*
     The following options are deprecated in 10.9. Use NSAlertFirstButtonReturn instead
     NSAlertDefaultReturn = 1,
     NSAlertAlternateReturn = 0,
     NSAlertOtherReturn = -1,
     NSAlertErrorReturn = -2
     NSOKButton = 1, // NSModalResponseOK should be used
     NSCancelButton = 0 // NSModalResponseCancel should be used
     */
    if (returnCode == NSOKButton)
    {
        NSLog(@"(returnCode == NSOKButton)");
    }
    else if (returnCode == NSCancelButton)
    {
        NSLog(@"(returnCode == NSCancelButton)");
    }
    else if(returnCode == NSAlertFirstButtonReturn)
    {
        NSLog(@"if (returnCode == NSAlertFirstButtonReturn)");
    }
    else if (returnCode == NSAlertSecondButtonReturn)
    {
        NSLog(@"else if (returnCode == NSAlertSecondButtonReturn)");
    }
    else if (returnCode == NSAlertThirdButtonReturn)
    {
        NSLog(@"else if (returnCode == NSAlertThirdButtonReturn)");
    }
    else
    {
        NSLog(@"All Other return code %d",returnCode);
    }
}
@end;
