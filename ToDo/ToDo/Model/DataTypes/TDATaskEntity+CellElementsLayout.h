//
//  TDATaskEntity+CellElementsLayout.h
//  ToDo
//
//  Created by Yuriy Berdnikov on 11/1/13.
//  Copyright (c) 2013 Yuriy Berdnikov. All rights reserved.
//

#import "TDATaskEntity.h"

#define TASK_CELL_TITLE_PADDING 10.0f
#define TASK_CELL_TITLE_FONT [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0f]

@interface TDATaskEntity (CellElementsLayout)

- (CGFloat)titleLabelOptimalHeightWithWidth:(CGFloat)maxWidth;
- (CGFloat)cellOptimalHeightWithWidth:(CGFloat)maxWidth;

@end
