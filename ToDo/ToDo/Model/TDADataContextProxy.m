//
//  TDADataContextProxy.m
//  ToDo
//
//  Created by Yuriy Berdnikov on 03.11.13.
//  Copyright (c) 2013 Yuriy Berdnikov. All rights reserved.
//

#import "TDADataContextProxy.h"
#import <CoreData/CoreData.h>

@interface TDADataContextProxy ()

@property (nonatomic, strong) NSManagedObjectContext *mainManagedObjectContext; // saving to store without bloking UI
@property (nonatomic, strong, readwrite) NSManagedObjectContext *backgroundQueueManagedObjectContext;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation TDADataContextProxy

+ (instancetype)sharedInstance
{
    static TDADataContextProxy *_sharedContextProxy = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedContextProxy = [[TDADataContextProxy alloc] init];
    });
    
    return _sharedContextProxy;
}

#pragma mark - Core data stack

- (NSString *)applicationDocumentsDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (!_managedObjectModel)
        _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator)
        return _persistentStoreCoordinator;
    
    NSURL *storeUrl = [NSURL fileURLWithPath:[[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"ToDo.sqlite"]];
    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption : @YES, NSInferMappingModelAutomaticallyOption : @YES};
    
    NSError *error = nil;
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error])
    {
        /*Error for store creation should be handled in here*/
        NSAssert(NO, error.localizedDescription);
    }
    
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)mainManagedObjectContext
{
    if (_mainManagedObjectContext)
        return _mainManagedObjectContext;
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator)
    {
        _mainManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_mainManagedObjectContext performBlockAndWait:^{
            [_mainManagedObjectContext setPersistentStoreCoordinator:coordinator];
        }];
    }
    
    return _mainManagedObjectContext;
}

- (NSManagedObjectContext *)backgroundQueueManagedObjectContext
{
    if (_backgroundQueueManagedObjectContext)
        return _backgroundQueueManagedObjectContext;
    
    if (self.mainManagedObjectContext)
    {
        _backgroundQueueManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_backgroundQueueManagedObjectContext performBlockAndWait:^{
            [_backgroundQueueManagedObjectContext setParentContext:self.mainManagedObjectContext];
        }];
    }
    
    return _backgroundQueueManagedObjectContext;
}

- (NSManagedObjectContext *)createManagedObjectContext
{
    NSManagedObjectContext *newContext = nil;
    if (self.mainManagedObjectContext)
    {
        newContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [newContext performBlockAndWait:^{
            [newContext setParentContext:self.mainManagedObjectContext];
        }];
    }
    
    return newContext;
}

#pragma mark - Saving context

- (void)saveMainContext
{
    [self.mainManagedObjectContext performBlockAndWait:^{
        NSError *error = nil;
        if (![self.mainManagedObjectContext save:&error])
            NSAssert(NO, error.localizedDescription);
    }];
}

- (void)saveBackgroundQueueContext
{
    [self.backgroundQueueManagedObjectContext performBlockAndWait:^{
        NSError *error = nil;
        if (![self.backgroundQueueManagedObjectContext save:&error])
            NSAssert(NO, error.localizedDescription);
    }];
}

@end
