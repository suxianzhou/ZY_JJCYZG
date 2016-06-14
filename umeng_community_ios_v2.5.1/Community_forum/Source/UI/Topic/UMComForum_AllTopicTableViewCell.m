//
//  UMComForumAllTopicTableViewCell.m
//  UMCommunity
//
//  Created by 张军华 on 15/12/7.
//  Copyright © 2015年 Umeng. All rights reserved.
//

#import "UMComForum_AllTopicTableViewCell.h"
#import "UMComImageView.h"
#import "UMComTools.h"

static const int g_UMComForum_AllTopicTableViewCell_imgoffset = 30;//偏移的距离

@implementation UMComForum_AllTopicTableViewCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellSize:(CGSize)size
{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier cellSize:size]) {
        
        self.iconBgImageView = [[UIImageView alloc]initWithFrame:self.topicIcon.frame];
        self.iconBgImageView.image = UMComImageWithImageName(@"um_topic_list_forum");
        [self.iconBgImageView addSubview:self.topicIcon];
        
        [self.contentView addSubview:self.iconBgImageView];
        CGFloat topicIconEdge = 5;
        self.topicIcon.frame = CGRectMake(topicIconEdge, topicIconEdge, self.topicIcon.frame.size.width - topicIconEdge*2, self.topicIcon.frame.size.height - topicIconEdge*2);
        
        //设置头像的为圆角
        if (self.topicIcon) {
            self.topicIcon.layer.cornerRadius = 6;
        }
        
        //设置关注按钮
        if (self.button) {
            CGFloat iconWidth = 11;
            CGFloat iconHeight = 20;
            CGFloat tailMargin = 13;
            [self.button setImage:UMComImageWithImageName(@"um_arrow_forum") forState:UIControlStateNormal];
            self.button.contentMode = UIViewContentModeScaleAspectFit;
            CGRect orgFrame = self.button.frame;
            orgFrame.origin.y = size.height/2 - iconHeight/2;
            orgFrame.origin.x = size.width - tailMargin - iconWidth;
            orgFrame.size.width = iconWidth;
            orgFrame.size.height = iconHeight;
            self.button.frame = orgFrame;
        }
        
        //设置主题
        if (self.topicNameLabel) {
            self.topicNameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
            self.topicNameLabel.numberOfLines = 1;
            self.topicNameLabel.textAlignment = NSTextAlignmentLeft;
            CGRect orgFrame = self.topicNameLabel.frame;
            orgFrame.size.width  = self.button.frame.origin.x - orgFrame.origin.x;
            self.topicNameLabel.frame = orgFrame;
        }
        
        //设置主题详细
        if (self.topicDetailLabel) {
            self.topicDetailLabel.numberOfLines = 1;
            self.topicDetailLabel.textAlignment = NSTextAlignmentLeft;
            CGRect orgFrame = self.topicDetailLabel.frame;
            orgFrame.size.width = self.topicNameLabel.frame.size.width;
            self.topicDetailLabel.frame = orgFrame;
        }
        

    }
    
    return self;
}

@end
