//
//  TDATasksSyncManager.m
//  ToDo
//
//  Created by Yuriy Berdnikov on 03.11.13.
//  Copyright (c) 2013 Yuriy Berdnikov. All rights reserved.
//

#import "TDATasksSyncManager.h"

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
    
}

@end
