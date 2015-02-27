//
//  CardManager.m
//  tos
//
//  Created by snk on 2/27/15.
//  Copyright (c) 2015 snk. All rights reserved.
//

#import "CardManager.h"

@interface CardManager ()
//@property NSManagedObjectContext *context;
@property (nonatomic)  NSManagedObjectModel * managedObjectModel;
@end


@implementation CardManager
/*
 NSManagedObjectContext *context = [self managedObjectContext];
 NSManagedObject *failedBankInfo = [NSEntityDescription
 insertNewObjectForEntityForName:@"FailedBankInfo"
 inManagedObjectContext:context];
 [failedBankInfo setValue:@"Test Bank" forKey:@"name"];
 [failedBankInfo setValue:@"Testville" forKey:@"city"];
 [failedBankInfo setValue:@"Testland" forKey:@"state"];
 NSManagedObject *failedBankDetails = [NSEntityDescription
 insertNewObjectForEntityForName:@"FailedBankDetails"
 inManagedObjectContext:context];
 [failedBankDetails setValue:[NSDate date] forKey:@"closeDate"];
 [failedBankDetails setValue:[NSDate date] forKey:@"updateDate"];
 [failedBankDetails setValue:[NSNumber numberWithInt:12345] forKey:@"zip"];
 [failedBankDetails setValue:failedBankInfo forKey:@"info"];
 [failedBankInfo setValue:failedBankDetails forKey:@"details"];
 NSError *error;
 if (![context save:&error]) {
 NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
 }

 */

-(NSManagedObjectModel *)managedObjectModel {
    
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSString *modelPath = [[NSBundle mainBundle] pathForResource:@"flash_true" ofType:@"mom"];
    NSURL *modelURL = [NSURL fileURLWithPath:modelPath];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];

    return _managedObjectModel;
}

-(void) teste {
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    //    [context ins]
//    NSManagedObjectModel * asd
    context.persistentStoreCoordinator =
    [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    NSError* error;
    
    NSManagedObject *trueCards = [NSEntityDescription
                                  insertNewObjectForEntityForName:@"TrueCards"
                                  inManagedObjectContext:context];
    [trueCards setValue:@"rede" forKey:@"disciplina"];
    [trueCards setValue:@"IPv6 não tem broadcast." forKey:@"text"];
    

    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    
}
@end
