//
//  TDATasksSyncManager.m
//  ToDo
//
//  Created by Yuriy Berdnikov on 03.11.13.
//  Copyright (c) 2013 Yuriy Berdnikov. All rights reserved.
//

#import "TDATasksSyncManager.h"
#import "TDADataContextProxy.h"
#import "TDATaskEntity.h"
#import <CoreData/CoreData.h>

static NSString *kLastSyncDate = @"tda.last.sync.date";

@interface TDATasksSyncManager ()

@property (atomic, assign) BOOL syncInProgress;

@end

@implementation TDATasksSyncManager

+ (instancetype)sharedInstance
{
    static TDATasksSyncManager *_sharedSyncManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedSyncManager = [[TDATasksSyncManager alloc] init];
    });
    
    return _sharedSyncManager;
}

- (void)syncTasks
{
    if (self.syncInProgress)
        return;
    
    self.syncInProgress = YES;
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:kLastSyncDate])
        [self performFirstDataSync];
    else
        [self performDeltaDataSync];
}

- (void)performFirstDataSync
{
    //fetch data for first start
    
    //parse to some NSArray of NSDictionaries and create new managed object
    
    //store new objects in background context
    //NSManagedObjectContext *managedObjectContext = [[TDADataContextProxy sharedInstance] backgroundQueueManagedObjectContext];
    //TDATaskEntity *task = [NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:managedObjectContext];
    //after all - save contexts :
    //    [[TDADataContextProxy sharedInstance] saveBackgroundQueueContext];
    //    [[TDADataContextProxy sharedInstance] saveMainContext];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kLastSyncDate];
    self.syncInProgress = NO;
}

- (void)performDeltaDataSync
{
    //fetch data from server using kLastSyncDate
    
    //after completion -
    /*
     if (receive some data)
     {
         for each task - try to fetch object for received ID - if exists - update old task, else - create new one
          NSManagedObjectContext *managedObjectContext = [[TDADataContextProxy sharedInstance] backgroundQueueManagedObjectContext];
     
          create or update existing object
     
         [[TDADataContextProxy sharedInstance] saveBackgroundQueueContext];
     }
     */
    
    // post local objects to server
    [self postLocalTasksToServer];
}

- (void)postLocalTasksToServer
{
    NSManagedObjectContext *managedObjectContext = [[TDADataContextProxy sharedInstance] backgroundQueueManagedObjectContext];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Task"];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"syncState != %d AND modifiedDate > %@", TDATaskDeleted, [[NSUserDefaults standardUserDefaults] objectForKey:kLastSyncDate]];
    [fetchRequest setPredicate:predicate];
    
    __block NSArray *tasksToPost = nil;
    [managedObjectContext performBlockAndWait:^{
        NSError *error = nil;
        tasksToPost = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    }];
    
    //Serialize data to JSON format
    
    //Post data to server
    
    //update objects syncState to TDATaskSynced and modifiedDate
    
    //after completion
    [self deleteTasksOnServer];
}

- (void)deleteTasksOnServer
{
    NSManagedObjectContext *managedObjectContext = [[TDADataContextProxy sharedInstance] backgroundQueueManagedObjectContext];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Task"];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"syncState == %d", TDATaskDeleted];
    [fetchRequest setPredicate:predicate];
    
    __block NSArray *tasksToPost = nil;
    [managedObjectContext performBlockAndWait:^{
        NSError *error = nil;
        tasksToPost = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    }];
    
    //Serialize data to JSON format
    
    //Post data to server - can be done as batch request or separate operation for each object
    //if success - remove objects from background context

    //save contexts
    [[TDADataContextProxy sharedInstance] saveBackgroundQueueContext];
    [[TDADataContextProxy sharedInstance] saveMainContext];
}

@end
