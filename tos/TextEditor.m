//
//  TextEditor.m
//  tos
//
//  Created by snk on 3/12/15.
//  Copyright (c) 2015 snk. All rights reserved.
//

#import "TextEditor.h"

@interface TextEditor ()
@property (strong) IBOutlet NSWindow *window;

@end

@implementation TextEditor

-(void)openTextEditor:(id)sender {
    NSLog(@"openTextEditor");
    
//    _window = sender;
    
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Desktop"];
    NSString *fileName = [documentsDirectory stringByAppendingPathComponent:@"_test.txt"];
    if (_window == nil) {
        _window = [[NSWindow alloc] initWithContentRect:NSMakeRect(200.0, 200.0, 300, 200)
                                              styleMask:(NSTitledWindowMask | NSClosableWindowMask)
                                                backing:NSBackingStoreBuffered defer:NO];
        [_window setReleasedWhenClosed:FALSE];
        
        NSRect cFrame =[[_window contentView] frame];
        NSTextView *_tv = [[NSTextView alloc] initWithFrame:cFrame];
        
        [_window setContentView:_tv];
        [_window makeFirstResponder:_tv];
        [_window setRepresentedFilename:fileName];
        [_window setTitleWithRepresentedFilename:fileName];
        
    }
    
    
    [_window makeKeyAndOrderFront:nil];
     
}
@end
