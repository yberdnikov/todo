//
//  TDATasksSyncManager.h
//  ToDo
//
//  Created by Yuriy Berdnikov on 03.11.13.
//  Copyright (c) 2013 Yuriy Berdnikov. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, TDATaskSyncState) {
    TDATaskSynced,
    TDATaskNew,
    TDATaskDeleted,
};

@interface TDATasksSyncManager : NSObject

+ (instancetype)sharedInstance;

- (void)syncTasks;

@end
