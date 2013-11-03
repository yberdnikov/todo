//
//  TDAJSONDataParser.m
//  ToDo
//
//  Created by Yuriy Berdnikov on 03.11.13.
//  Copyright (c) 2013 Yuriy Berdnikov. All rights reserved.
//

#import "TDAJSONDataParser.h"

@implementation TDAJSONDataParser

+ (instancetype)sharedInstance
{
    static TDAJSONDataParser *_sharedJSONParser = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedJSONParser = [[TDAJSONDataParser alloc] init];
    });
    
    return _sharedJSONParser;
}

@end
