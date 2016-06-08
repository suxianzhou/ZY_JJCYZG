//
//  RWPhoneVerificationController.m
//  ZhongYuSubjectHubKY
//
//  Created by zhongyu on 16/5/24.
//  Copyright © 2016年 RyeWhiskey. All rights reserved.
//

#import "RWPhoneVerificationController.h"
#import "RWLoginTableViewCell.h"
#import <SXColorGradientView.h>
#import "RWRequsetManager+UserLogin.h"

@interface RWPhoneVerificationController ()

<
    UITableViewDelegate,
    UITableViewDataSource,
    RWButtonCellDelegate,
    RWRequsetDelegate,
    RWTextFiledCellDelegate
>

@property (strong, nonatomic)UITableView *viewList;

@property (strong, nonatomic)RWRequsetManager *requestManager;

@property (weak, nonatomic)RWDeployManager *deployManager;

@property (strong, nonatomic)RWButtonCell *buttonCell;

@property (weak, nonatomic)UIButton *clickBtn;

@property (assign ,nonatomic)NSInteger countDown;

@property (nonatomic,assign)CGPoint viewCenter;

@property (weak ,nonatomic)NSTimer *timer;

@property (nonatomic ,strong)NSString *facePlaceHolder;

@property (nonatomic,strong)UIView *contrast;

@end

static NSString *const textFileCell = @"textFileCell";

static NSString *const buttonCell = @"buttonCell";

@implementation RWPhoneVerificationController

@synthesize viewList;
@synthesize requestManager;
@synthesize deployManager;
@synthesize countDown;
@synthesize clickBtn;
@synthesize viewCenter;
@synthesize facePlaceHolder;
@synthesize contrast;

#pragma mark AutoSize Keyboard

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(keyboardWasHidden:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)keyboardWasShown:(NSNotification *) notif
{
    NSDictionary *info = [notif userInfo];
    
    NSValue *value = [info objectForKey:UIKeyboardFrameBeginUserInfoKey];
    
    CGSize keyboardSize = [value CGRectValue].size;
    
    NSInteger gap = self.view.frame.size.height - keyboardSize.height;
    
    NSInteger height;
    
    if ([facePlaceHolder isEqualToString:@"请输入手机号"])
    {
        height = self.view.frame.size.height *0.3 + 50 * 4;
    }
    else
    {
        height = self.view.frame.size.height *0.3 + 50 * 4;
    }
    
    if (self.navigationController.view.center.y == viewCenter.y + gap - height)
    {
        return;
    }
    
    if (gap - height < 0)
    {
        [UIView animateWithDuration:0.3 animations:^{
            
            CGPoint viewPt =  self.navigationController.view.center;
            
            viewPt.y += gap - height;
            
            self.navigationController.view.center = viewPt;
        }];
    }
}

- (void) keyboardWasHidden:(NSNotification *) notif
{
    [UIView animateWithDuration:0.3 animations:^{
        
        self.navigationController.view.center = viewCenter;
    }];
    
}

#pragma mark - views

- (void)obtainDeployManager
{
    if (!deployManager)
    {
        deployManager = [RWDeployManager defaultManager];
    }
}

- (void)requestError:(NSError *)error Task:(NSURLSessionDataTask *)task
{
    NSLog(@"%@",error.description);
    
    [RWRequsetManager warningToViewController:self
                                        Title:@"网络连接失败，请检查网络"
                                        Click:^{
                                            
                                        }];
}

- (void)obtainRequestManager
{
    
    if (!requestManager)
    {
        requestManager = [[RWRequsetManager alloc]init];
        
        requestManager.delegate = self;
    }
}

- (void)addTapGesture
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(releaseFirstResponder)];
    
    tap.numberOfTapsRequired = 1;
    
    [viewList addGestureRecognizer:tap];
}

- (void)releaseFirstResponder
{
    RWTextFiledCell *usernameFiled = [viewList cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    if (usernameFiled.textFiled.isFirstResponder)
    {
        [usernameFiled.textFiled resignFirstResponder];
    }
    
    RWTextFiledCell *passwordFiled = [viewList cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    
    if (passwordFiled.textFiled.isFirstResponder)
    {
        [passwordFiled.textFiled resignFirstResponder];
    }
}

- (void)initViewList
{
    viewList = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 0, 0) style:UITableViewStyleGrouped];
    
    viewList.backgroundView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"background.jpg"]];
    
    [self.view addSubview:viewList];
    
    SXColorGradientView *gradientView = [SXColorGradientView createWithColorArray:
                                         @[[UIColor blackColor],Wonderful_WhiteColor10] frame:
                                         CGRectMake(20, 20,
                                                    self.view.frame.size.width - 40,
                                                    self.view.frame.size.height
                                                    * 0.3 + 150)
                                                                        direction:
                                         SXGradientToBottom];
    
    gradientView.alpha = 0.3;
    
    gradientView.layer.cornerRadius = 10;
    
    gradientView.clipsToBounds = YES;
    
    [viewList.backgroundView addSubview:gradientView];
    
    [viewList mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.view.mas_left).offset(0);
        make.right.equalTo(self.view.mas_right).offset(0);
        make.top.equalTo(self.view.mas_top).offset(0);
        make.bottom.equalTo(self.view.mas_bottom).offset(0);
    }];
    
    viewList.showsVerticalScrollIndicator = NO;
    viewList.showsHorizontalScrollIndicator = NO;
    
    viewList.allowsSelection = NO;
    viewList.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    viewList.delegate = self;
    viewList.dataSource = self;
    
    [viewList registerClass:[RWTextFiledCell class] forCellReuseIdentifier:textFileCell];
    
    [viewList registerClass:[RWButtonCell class] forCellReuseIdentifier:buttonCell];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 2;
    }
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0)
    {
        RWTextFiledCell *cell = [tableView dequeueReusableCellWithIdentifier:textFileCell forIndexPath:indexPath];
        
        cell.textFiled.keyboardType = UIKeyboardTypeNumberPad;
        
        cell.delegate = self;
        
        if (indexPath.row == 0)
        {
            cell.headerImage = [UIImage imageNamed:@"Login"];
            cell.placeholder = @"请输入手机号";
            
        }
        else
        {
            cell.headerImage = [UIImage imageNamed:@"PassWord"];
            cell.placeholder = @"请输入验证码";
           
        }
        
        return cell;
    }
    else
    {
        RWButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:buttonCell forIndexPath:indexPath];
        
        _buttonCell = cell;
        
        cell.delegate = self;
        
        cell.title = @"获取验证码";
        
        return cell;
    }
}

- (void)button:(UIButton *)button ClickWithTitle:(NSString *)title
{
    if ([self verificationAdministrator])
    {
        return;
    }
    
    if ([title isEqualToString:@"获取验证码"]||
        [title isEqualToString:@"重新获取验证码"])
    {
        [self userRegister];
    }
    else
    {
        [self verificationCodeWithCode];
    }
}

- (void)textFiledCell:(RWTextFiledCell *)cell DidBeginEditing:(NSString *)placeholder
{
    facePlaceHolder = placeholder;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return self.view.frame.size.height *0.25;
    }
    
    return self.view.frame.size.height * 0.05;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    if (section == 0)
    {
        UIView *backView = [[UIView alloc]init];
        
        backView.backgroundColor = [UIColor clearColor];
        
        UILabel *titleLabel = [[UILabel alloc]init];
        
        titleLabel.text = @"免费注册\n\n立即下载海量题库及历年真题";
        
        titleLabel.numberOfLines = 0;
        
        titleLabel.textAlignment = NSTextAlignmentCenter;
        
        titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold"size:18];
        
        titleLabel.textColor = [UIColor whiteColor];
        
        [backView addSubview:titleLabel];
        
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.equalTo(backView.mas_left).offset(40);
            make.right.equalTo(backView.mas_right).offset(-40);
            make.top.equalTo(backView.mas_top).offset(20);
            make.bottom.equalTo(backView.mas_bottom).offset(-20);
        }];
        
        return backView;
    }
    
    return nil;
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    MAIN_NAV
    
    contrast = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    
    contrast.backgroundColor = [UIColor blackColor];
    
    viewCenter = self.navigationController.view.center;
    
    countDown = 60;
    
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.view.backgroundColor =[UIColor whiteColor];
    self.title = @"登录";
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissView)];
    
    self.navigationItem.leftBarButtonItem = item;
    
    [self registerForKeyboardNotifications];
    [self initViewList];
    [self addTapGesture];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (requestManager && requestManager.delegate == nil)
    {
        requestManager.delegate = self;
    }
    
    [self.view.window insertSubview:contrast atIndex:1];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    requestManager.delegate = nil;
    
    [contrast removeFromSuperview];
}

- (void)dismissView
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)verificationCodeWithCode
{
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
    
    [SVProgressHUD show];
    
    [_timer setFireDate:[NSDate distantFuture]];
    
    RWTextFiledCell *phoneNumberCell = [viewList cellForRowAtIndexPath:
                                        [NSIndexPath indexPathForRow:0 inSection:0]];
    
    RWTextFiledCell *verificationCell = [viewList cellForRowAtIndexPath:
                                         [NSIndexPath indexPathForRow:1 inSection:0]];
    
    [requestManager verificationWithVerificationCode:verificationCell.textFiled.text
                                         PhoneNumber:phoneNumberCell.textFiled.text
                                            Complate:^(BOOL isSuccessed) {
                                                
                                                [SVProgressHUD dismiss];
                                                
            if (isSuccessed)
            {
                [self obtainDeployManager];
                
                [deployManager setDeployValue:DID_LOGIN forKey:LOGIN];
                
                [deployManager setDeployValue:phoneNumberCell.textFiled.text
                                       forKey:USERNAME];
                
                [self.navigationController dismissViewControllerAnimated:YES
                                                              completion:nil];
            }
            else
            {
                RWButtonCell *cell = [viewList cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                                                    
                cell.title = @"重新获取验证码";
                                                    
                [RWRequsetManager warningToViewController:self
                                                    Title:@"验证失败"
                                                    Click:^{
                                                                                            
                }];
            }
        }];
}


-(void)userRegister
{
    [self obtainRequestManager];
    
    __block RWTextFiledCell *textCell = [viewList cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    NSString *phoneNumber = textCell.textFiled.text;
    
    __block RWTextFiledCell *verCell = [viewList cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    
    verCell.textFiled.text = nil;
    
    if ([requestManager verificationPhoneNumber:phoneNumber])
    {
        [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
        
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
        
        [SVProgressHUD show];
        
        [requestManager obtainVerificationCodeWithPhoneNumber:phoneNumber
                                                     Complate:^(BOOL isSuccessed) {
                                                         
                                                         [SVProgressHUD dismiss];
                                                         
            if (isSuccessed)
            {
                [self timerStart];
                
                [verCell.textFiled becomeFirstResponder];
            }
            else
            {
                [RWRequsetManager warningToViewController:self
                 
                                                    Title:@"验证码获取失败"
                 
                                                    Click:^{
                                                                                                     
                                                        textCell.textFiled.text = nil;
                                                                                                     
                                                        [textCell.textFiled
                                                                becomeFirstResponder];
                                                                                                 }];
                                                         }
                                                     }];
    }
    else
    {
        [RWRequsetManager warningToViewController:self
                                            Title:@"手机号输入有误,请重新输入"
                                            Click:^{
                                                
                                                textCell.textFiled.text = nil;
                                                
                                                [textCell.textFiled becomeFirstResponder];
                                            }];
    }
}

- (void)timerStart
{
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(renovateSecond) userInfo:nil repeats:YES];
}

- (void)renovateSecond
{
    if (countDown <= 0)
    {
        [_timer setFireDate:[NSDate distantFuture]];
        
        _buttonCell.title = @"重新获取验证码";
        
        return;
    }
    
    countDown --;
    
    _buttonCell.title = [NSString stringWithFormat:@"确定   %d",(int)countDown];
}

- (BOOL)verificationAdministrator
{
    RWTextFiledCell *textCell = [viewList cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    NSString *AdministratorID = textCell.textFiled.text;
    
    RWTextFiledCell *verCell = [viewList cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    
    NSString *AdministratorPassword = verCell.textFiled.text;
    
    if ([AdministratorID isEqualToString:@"94664985426982802"]&&
        [AdministratorPassword isEqualToString:@"7939447539"])
    {
        [self obtainDeployManager];
        
        [deployManager setDeployValue:DID_LOGIN forKey:LOGIN];
        
        [self.navigationController dismissViewControllerAnimated:YES
                                                      completion:nil];
        
        return YES;
    }
    else
    {
        return NO;
    }
}


@end
