//
//  TDADataContextProxy.h
//  ToDo
//
//  Created by Yuriy Berdnikov on 03.11.13.
//  Copyright (c) 2013 Yuriy Berdnikov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TDADataContextProxy : NSObject

@property (nonatomic, strong, readonly) NSManagedObjectContext *mainManagedObjectContext; // saving to store without bloking UI
@property (nonatomic, strong, readonly) NSManagedObjectContext *backgroundQueueManagedObjectContext; //uses for sync data with server

+ (instancetype)sharedInstance;

- (NSManagedObjectContext *)createManagedObjectContext; //create context for using on main queue

- (void)saveMainContext;
- (void)saveBackgroundQueueContext;

@end
