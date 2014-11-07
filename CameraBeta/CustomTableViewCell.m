//
//  CustomCellTableViewCell.m
//  CameraBeta
//
//  Created by 康伟 on 14-9-2.
//  Copyright (c) 2014年 kangwei. All rights reserved.
//

#import "CustomTableViewCell.h"

@implementation CustomTableViewCell
@synthesize camera_icon_iv = _camera_icon_iv;
@synthesize camera_name_lable = _camera_name_lable;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
