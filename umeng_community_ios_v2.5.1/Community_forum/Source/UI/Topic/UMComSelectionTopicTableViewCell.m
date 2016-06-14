//
//  UMComSelectionTopicTableViewCell.m
//  UMCommunity
//
//  Created by 张军华 on 16/3/29.
//  Copyright © 2016年 Umeng. All rights reserved.
//

#import "UMComSelectionTopicTableViewCell.h"
#import "UMComTools.h"

@implementation UMComSelectionTopicTableViewCell

#define UMComSelectionTopicTableViewCell_LabelTextColor @"178DE7"
#define UMComSelectionTopicTableViewCell_LabelTextFont 15

#pragma mark - override UITableViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.textLabel.textColor = UMComColorWithColorValueString(UMComSelectionTopicTableViewCell_LabelTextColor);
        self.textLabel.font = UMComFontNotoSansLightWithSafeSize(UMComSelectionTopicTableViewCell_LabelTextFont);
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - private method

@end
