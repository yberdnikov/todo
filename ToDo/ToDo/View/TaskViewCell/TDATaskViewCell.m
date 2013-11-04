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

@property (nonatomic, strong) UIButton *checkboxButton;
@property (nonatomic, strong) UILabel *taskTitleLabel;

@end

@implementation TDATaskViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self.contentView addSubview:self.checkboxButton];
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
    self.checkboxButton.selected = NO;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.taskTitleLabel.width = CGRectGetWidth(self.contentView.bounds) - TASK_CELL_TITLE_PADDING * 2 - TASK_CELL_CHECKBOX_SIDE_SIZE;
    
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
    
    _taskTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(TASK_CELL_CHECKBOX_SIDE_SIZE + TASK_CELL_TITLE_PADDING, TASK_CELL_TITLE_PADDING * 2,
                                                                CGRectGetWidth(self.contentView.bounds) - TASK_CELL_TITLE_PADDING * 2 - TASK_CELL_CHECKBOX_SIDE_SIZE,
                                                                0)];
    _taskTitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _taskTitleLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    _taskTitleLabel.numberOfLines = 0;
    _taskTitleLabel.font = TASK_CELL_TITLE_FONT;
    _taskTitleLabel.backgroundColor = [UIColor clearColor];
    _taskTitleLabel.textColor = [UIColor darkGrayColor];
    _taskTitleLabel.highlightedTextColor = [UIColor whiteColor];
    
    return _taskTitleLabel;
}

- (UIButton *)checkboxButton
{
    if (_checkboxButton)
        return _checkboxButton;
    
    _checkboxButton = [[UIButton alloc] initWithFrame:CGRectMake(0, TASK_CELL_TITLE_PADDING, TASK_CELL_CHECKBOX_SIDE_SIZE, TASK_CELL_CHECKBOX_SIDE_SIZE)];
    [_checkboxButton setImage:[UIImage imageNamed:@"checkbox_off.png"] forState:UIControlStateNormal];
    [_checkboxButton setImage:[UIImage imageNamed:@"checkbox_on.png"] forState:UIControlStateSelected];
    [_checkboxButton addTarget:self action:@selector(checkboxButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    return _checkboxButton;
}

- (void)setTaskEntity:(TDATaskEntity *)taskEntity
{
    _taskEntity = taskEntity;
    if (!_taskEntity)
        return;
    
    self.checkboxButton.selected = taskEntity.resolved.boolValue;
    
    if (taskEntity.resolved.boolValue)
    {
        //cross text
        NSMutableAttributedString *attributeTitle = [[NSMutableAttributedString alloc] initWithString:taskEntity.title];
        [attributeTitle addAttribute:NSStrikethroughStyleAttributeName
                               value:@1
                               range:(NSRange){0, attributeTitle.length}];
        self.taskTitleLabel.attributedText = attributeTitle;
    }
    else
        self.taskTitleLabel.text = taskEntity.title;
    
    [self setNeedsLayout];
}

#pragma mark - Checkbox selector

- (void)checkboxButtonPressed:(UIButton *)sender
{
    self.checkboxButton.selected = !self.checkboxButton.selected;
    self.taskEntity.resolved = @(!self.taskEntity.resolved.boolValue);
    
    [self.taskEntity.managedObjectContext save:nil];
}

@end
