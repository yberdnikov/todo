//
//  TDATaskEntity.h
//  ToDo
//
//  Created by Yuriy Berdnikov on 11/4/13.
//  Copyright (c) 2013 Yuriy Berdnikov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TDATaskEntity : NSManagedObject

@property (nonatomic, retain) NSDate * createdDate;
@property (nonatomic, retain) NSDate * modifiedDate;
@property (nonatomic, retain) NSNumber * ordering;
@property (nonatomic, retain) NSNumber * resolved;
@property (nonatomic, retain) NSString * taskID;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * syncState;

@end
