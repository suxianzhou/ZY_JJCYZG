//
//  RWLoginTableViewCell.h
//  ZhongYuSubjectHubKY
//
//  Created by zhongyu on 16/5/6.
//  Copyright © 2016年 RyeWhiskey. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RWTextFiledCell;

@protocol RWTextFiledCellDelegate <NSObject>

- (void)textFiledCell:(RWTextFiledCell *)cell DidBeginEditing:(NSString *)placeholder;

@end

@interface RWTextFiledCell : UITableViewCell

@property (nonatomic,assign)id<RWTextFiledCellDelegate> delegate;

@property (nonatomic,strong,readonly)UITextField *textFiled;

@property (nonatomic,strong)UIImage *headerImage;

@property (nonatomic,strong)NSString *placeholder;

@end

@protocol RWButtonCellDelegate <NSObject>

- (void)button:(UIButton *)button ClickWithTitle:(NSString *)title;

@end


@interface RWButtonCell : UITableViewCell

@property (assign ,nonatomic)id<RWButtonCellDelegate> delegate;

@property (nonatomic ,strong)NSString *title;

@property (nonatomic,strong)UIButton *button;

@end

@interface RWTextViewCell :UITableViewCell

@property (nonatomic,strong)UITextView *inputTextView;

@property (nonatomic,strong)NSString *placeholderText;

@end

