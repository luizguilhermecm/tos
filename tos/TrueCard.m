//
//  TrueCard.m
//  tos
//
//  Created by snk on 2/27/15.
//  Copyright (c) 2015 snk. All rights reserved.
//

#import "TrueCard.h"
#import "CDManager.h"
#include <stdlib.h>
@interface TrueCard()
@property (weak) IBOutlet NSWindow *window;

@property NSTimer * trueCardTimer;

@property (nonatomic) NSManagedObjectContext *managedObjectContext;

@property NSInteger last_id;

@end

@implementation TrueCard


-(void) insertCards {
    NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:@"TrueCards"
                                                            inManagedObjectContext:_managedObjectContext];
    NSLog(@"with id: %ld", (long)[self numberOfCards]);
    [object setValue:@"snk is dumb" forKey:@"text"];
//    [object setValue:[self numberOfCards] forKey:@"id"];
    
    NSError *error;
    if (![_managedObjectContext save:&error]) {
        NSLog(@"Failed to save - error: %@", [error localizedDescription]);
    }

}

-(NSInteger) numberOfCards {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TrueCards" inManagedObjectContext:_managedObjectContext];
    [request setEntity:entity];

    NSError *errorFetch = nil;
    NSInteger nbc = [_managedObjectContext countForFetchRequest:request error:&errorFetch];
    NSLog(@"nbc = %ld", nbc);
    return nbc;
    
}

-(void) randonCard {

    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TrueCards" inManagedObjectContext:_managedObjectContext];
    [request setEntity:entity];
    // Assumes that you know the number of objects per entity, and that your order starts at zero.
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id = %d", arc4random() % [self numberOfCards]];
  //  [request setPredicate:predicate];
    [request setFetchLimit:1];
    NSError *error = nil;
    NSArray *results = [_managedObjectContext executeFetchRequest:request error:&error];
    NSLog(@"if - %ld", results.count);
    if (results.count > 0) {
            NSLog(@"ok");
        NSManagedObject *object = [results objectAtIndex:0];
        [self showSimpleCriticalAlert:[NSString stringWithFormat: @"%@ = %@", [object valueForKey:@"id"], [object valueForKey:@"text"]]];
    }
    
    
    
//    [self showSimpleCriticalAlert:@"erro"];
    
}


-(void)showSimpleCriticalAlert:(NSString *)msg
{
    NSAlert *alert = [[NSAlert alloc] init];
    NSWindow *window;
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:@"Rede"];
    [alert setIcon:[NSImage imageNamed:@"transparent.png"]];
    [alert setInformativeText:msg];
    //  [alert setAlertStyle:NSCriticalAlertStyle];
    [alert beginSheetModalForWindow:window modalDelegate:self didEndSelector:nil contextInfo:nil];
}

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }

    CDManager * cdm = [[CDManager alloc] init];
    _managedObjectContext = [cdm managedObjectContext];
    
    [self emptyTable];
    [self readFile];

    
    return _managedObjectContext;
}


-(void) setTrueCardTimer {
    /*
    [self managedObjectContext];

    _trueCardTimer = [NSTimer
                      scheduledTimerWithTimeInterval:(5)
                      target:self
                      selector:@selector(randonCard)
                      userInfo:nil
                      repeats:YES];
     */
}

-(void) invalidateTrueCardTimer {
    [_trueCardTimer invalidate];
}

-(void) emptyTable {
    NSFetchRequest * all = [[NSFetchRequest alloc] init];
    [all setEntity:[NSEntityDescription entityForName:@"TrueCards" inManagedObjectContext:_managedObjectContext]];
    [all setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSError * error = nil;
    NSArray * cards = [_managedObjectContext executeFetchRequest:all error:&error];

    //error handling goes here
    for (NSManagedObject * card in cards) {
        [_managedObjectContext deleteObject:card];
    }
    NSError *saveError = nil;
    [_managedObjectContext save:&saveError];
}


-(void) readFile {
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *fileName = [documentsDirectory stringByAppendingPathComponent:@"_true_cards.txt"];
    
    // read everything from text
    NSString* fileContents =
    [NSString stringWithContentsOfFile:fileName
                              encoding:NSUTF8StringEncoding error:nil];
    
    // first, separate by new line
    NSArray* allLinedStrings =
    [fileContents componentsSeparatedByCharactersInSet:
     [NSCharacterSet newlineCharacterSet]];

    NSInteger i = 0;
    for (NSString * line in allLinedStrings) {
    
        
    }
}

@end;
