//
//  UMComPostHtmlContentBodyCell.h
//  UMCommunity
//
//  Created by 张军华 on 16/3/23.
//  Copyright © 2016年 Umeng. All rights reserved.
//

#import "UMComPostContentBodyCell.h"

@class UMComWebView,UMComPostHtmlContentBodyCell,UMComUser;

@protocol UMComHtmlBodyCellDelegate <NSObject>

@optional
//html加载完成回调
-(void)UMComHtmlBodyCellDidFinishLoad:(UMComPostHtmlContentBodyCell*)cell;

-(void)handleClickCell:(UMComPostHtmlContentBodyCell*)cell withDataObject:(id)object userInfo:(NSDictionary*)userInfo;
@end

@interface UMComPostHtmlContentBodyCell : UMComPostContentCell


@property(nonatomic,readwrite,strong)UMComWebView* webView;
//位置图片
@property(nonatomic,strong) UMComImageView* loacationIMG;
//位置的名称
@property(nonatomic,strong) UILabel* loacationName;
@property (nullable, nonatomic, weak) id <UMComHtmlBodyCellDelegate> UMComHtmlBodyCellDelegate;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;


@property(nonatomic,strong)NSIndexPath *indexPath;

@property(nonatomic,readonly,assign)CGFloat totalHeight;//body的总高度


@end
