//
//  RWLoginTableViewCell.m
//  ZhongYuSubjectHubKY
//
//  Created by zhongyu on 16/5/6.
//  Copyright © 2016年 RyeWhiskey. All rights reserved.
//

#import "RWLoginTableViewCell.h"

@interface RWTextFiledCell ()

<
    UITextFieldDelegate
>

@property (nonatomic,strong)UIView *backView;

@property (nonatomic,strong)UIImageView *header;

@end

@implementation RWTextFiledCell

@synthesize textFiled;
@synthesize backView;
@synthesize header;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
       
        [self initViews];
        
    }
    
    return self;
}

- (void)initViews
{
    backView = [[UIView alloc]init];
    
    backView.backgroundColor = [UIColor whiteColor];
    
    backView.layer.cornerRadius = 10;
    
    [self addSubview:backView];
    
    header = [[UIImageView alloc]init];
    
    [backView addSubview:header];
    
    textFiled = [[UITextField alloc]init];
    
    textFiled.delegate = self;
    
    [backView addSubview:textFiled];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.delegate textFiledCell:self DidBeginEditing:_placeholder];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    [backView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.equalTo(self.mas_left).offset(40);
        make.right.equalTo(self.mas_right).offset(-40);
        make.top.equalTo(self.mas_top).offset(5);
        make.bottom.equalTo(self.mas_bottom).offset(-5);
    }];
    
    [header mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.equalTo(backView.mas_left).offset(5);
        make.top.equalTo(backView.mas_top).offset(5);
        make.width.equalTo([NSNumber numberWithFloat:frame.size.height - 20]);
        make.height.equalTo([NSNumber numberWithFloat:frame.size.height - 20]);
    }];
    
    [textFiled mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.equalTo(header.mas_right).offset(10);
        make.right.equalTo(backView.mas_right).offset(-10);
        make.top.equalTo(backView.mas_top).offset(10);
        make.bottom.equalTo(backView.mas_bottom).offset(-10);
    }];
}

- (void)setHeaderImage:(UIImage *)headerImage
{
    _headerImage = headerImage;
    
    header.image = _headerImage;
}

- (void)setPlaceholder:(NSString *)placeholder
{
    _placeholder = placeholder;
    
    textFiled.placeholder = _placeholder;
}

@end


@implementation RWButtonCell

@synthesize button;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        
        button = [[UIButton alloc]init];
        
        button.backgroundColor = MAIN_COLOR;
        
        button.layer.cornerRadius = 10;
        
        button.clipsToBounds = YES;
        
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        [self addSubview:button];
        
        [button addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return self;
}

- (void)btnClick
{
    [self.delegate button:button ClickWithTitle:_title];
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    
    [button setTitle:_title forState:UIControlStateNormal];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.equalTo(self.mas_left).offset(40);
        make.right.equalTo(self.mas_right).offset(-40);
        make.top.equalTo(self.mas_top).offset(7);
        make.bottom.equalTo(self.mas_bottom).offset(-7);
    }];
}

@end

@interface RWTextViewCell ()

<
    UITextViewDelegate
>

@property (nonatomic,strong)UILabel *placeholder;

@property (nonatomic,strong)UILabel *residueChar;

@property (nonatomic,strong)NSMutableString *input;

@end

@implementation RWTextViewCell

@synthesize placeholder;
@synthesize inputTextView;
@synthesize residueChar;
@synthesize input;

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (range.length == 0)
    {
        [input appendString:text];
    }
    else
    {
        [input deleteCharactersInRange:
                            NSMakeRange(input.length - range.length, range.length)];
    }
    
    residueChar.text = [NSString stringWithFormat:
                                            @"还可输入%d字",(int)(140 - input.length)];
    
    if (input.length == 0)
    {
        [self addSubview:placeholder];
        
        [placeholder mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.equalTo(self.mas_left).offset(22.5);
            make.top.equalTo(self.mas_top).offset(22);
            make.width.equalTo(@(placeholder.frame.size.width));
            make.height.equalTo(@(placeholder.frame.size.height));
        }];
    }
    else if (placeholder.superview)
    {
        [placeholder removeFromSuperview];
    }
    
    return YES;
}

- (void)setPlaceholderText:(NSString *)placeholderText
{
    _placeholderText = placeholderText;
    
    placeholder.text = _placeholderText;
    
    [placeholder sizeToFit];
    
    [placeholder mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.equalTo(self.mas_left).offset(22.5);
        make.top.equalTo(self.mas_top).offset(22);
        make.width.equalTo(@(placeholder.frame.size.width));
        make.height.equalTo(@(placeholder.frame.size.height));
    }];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        input = [[NSMutableString alloc]init];
        
        placeholder = [[UILabel alloc]init];
        placeholder.textColor = Wonderful_GrayColor5;
        placeholder.font = [UIFont systemFontOfSize:17];
        placeholder.numberOfLines = 0;
        
        [self addSubview:placeholder];
        
        residueChar = [[UILabel alloc]init];
        residueChar.text = @"还可输入140字";
        residueChar.textColor = Wonderful_GrayColor5;
        residueChar.font = [UIFont systemFontOfSize:12];
        
        [self addSubview:residueChar];
        
        inputTextView = [[UITextView alloc] init];
        inputTextView.backgroundColor = [UIColor clearColor];
        inputTextView.font = [UIFont systemFontOfSize:17];
        
        inputTextView.delegate = self;
        
        [self addSubview:inputTextView];
    }
    
    return self;
}


- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    [residueChar mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.width.equalTo(@(100));
        make.height.equalTo(@(30));
        make.bottom.equalTo(self.mas_bottom).offset(-15);
        make.right.equalTo(self.mas_right).offset(-15);
    }];
    
    [inputTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.mas_left).offset(15);
        make.right.equalTo(self.mas_right).offset(-15);
        make.top.equalTo(self.mas_top).offset(15);
        make.bottom.equalTo(residueChar.mas_top).offset(0);
    }];
}


@end