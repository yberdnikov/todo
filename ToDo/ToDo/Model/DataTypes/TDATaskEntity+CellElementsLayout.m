//
//  TDATaskEntity+CellElementsLayout.m
//  ToDo
//
//  Created by Yuriy Berdnikov on 11/1/13.
//  Copyright (c) 2013 Yuriy Berdnikov. All rights reserved.
//

#import "TDATaskEntity+CellElementsLayout.h"

@implementation TDATaskEntity (CellElementsLayout)

- (CGFloat)titleLabelOptimalHeightWithWidth:(CGFloat)maxWidth
{
    CGSize titleSize = [self.title sizeWithFont:TASK_CELL_TITLE_FONT constrainedToSize:CGSizeMake(maxWidth, 2009) lineBreakMode:NSLineBreakByWordWrapping];
    
    return ceilf(titleSize.height);
}

- (CGFloat)cellOptimalHeightWithWidth:(CGFloat)maxWidth
{
    CGFloat cellHeight = TASK_CELL_TITLE_PADDING; //top padding
    
    cellHeight += [self titleLabelOptimalHeightWithWidth:maxWidth];
    
    cellHeight += TASK_CELL_TITLE_PADDING; //bottom padding
    
    return cellHeight;
}

@end
