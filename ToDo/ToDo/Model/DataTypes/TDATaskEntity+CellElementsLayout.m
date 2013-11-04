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
    cellHeight += TASK_CELL_CHECKBOX_SIDE_SIZE; //checkbox
    cellHeight += TASK_CELL_TITLE_PADDING; //bottom padding
    
    CGFloat titleHeight = [self titleLabelOptimalHeightWithWidth:maxWidth - TASK_CELL_CHECKBOX_SIDE_SIZE - TASK_CELL_TITLE_PADDING * 2];
    
    // if title height is more then default cell height - increase cell height
    // title has top offset TASK_CELL_TITLE_PADDING * 2
    if (titleHeight > (TASK_CELL_CHECKBOX_SIDE_SIZE - TASK_CELL_TITLE_PADDING))
        cellHeight += (titleHeight - (TASK_CELL_CHECKBOX_SIDE_SIZE - TASK_CELL_TITLE_PADDING));
    
    return cellHeight;
}

@end
