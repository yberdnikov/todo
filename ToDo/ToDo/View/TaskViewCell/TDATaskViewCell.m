//
//  TDATaskViewCell.m
//  ToDo
//
//  Created by Yuriy Berdnikov on 11/1/13.
//  Copyright (c) 2013 Yuriy Berdnikov. All rights reserved.
//

#import "TDATaskViewCell.h"
#import "UIView+FrameAdditions.h"
#import "TDATaskEntity+CellElementsLayout.h"

@interface TDATaskViewCell ()

@property (nonatomic, strong) UILabel *taskTitleLabel;

@end

@implementation TDATaskViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self.contentView addSubview:self.taskTitleLabel];
    }
    return self;
}

- (void)dealloc
{
    self.taskEntity = nil;
    self.taskTitleLabel = nil;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.taskTitleLabel.text = nil;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.taskTitleLabel.width = CGRectGetWidth(self.contentView.bounds) - TASK_CELL_TITLE_PADDING * 2;
    
    if (!self.isEditing)
        self.taskTitleLabel.height = [self.taskEntity titleLabelOptimalHeightWithWidth:self.taskTitleLabel.width];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Properties

- (UILabel *)taskTitleLabel
{
    if (_taskTitleLabel)
        return _taskTitleLabel;
    
    _taskTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(TASK_CELL_TITLE_PADDING, TASK_CELL_TITLE_PADDING,
                                                                CGRectGetWidth(self.contentView.bounds) - TASK_CELL_TITLE_PADDING * 2,
                                                                0)];
    _taskTitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _taskTitleLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    _taskTitleLabel.numberOfLines = 0;
    _taskTitleLabel.font = TASK_CELL_TITLE_FONT;
    _taskTitleLabel.backgroundColor = [UIColor clearColor];
    _taskTitleLabel.textColor = [UIColor darkGrayColor];
    
    return _taskTitleLabel;
}

- (void)setTaskEntity:(TDATaskEntity *)taskEntity
{
    _taskEntity = taskEntity;
    if (!_taskEntity)
        return;
    
    self.taskTitleLabel.text = taskEntity.title;
    
    [self setNeedsLayout];
}

@end
