//
//  RWTabBarViewController.m
//  ZhongYuSubjectHubKY
//
//  Created by zhongyu on 16/5/5.
//  Copyright © 2016年 RyeWhiskey. All rights reserved.
//

#import "RWTabBarViewController.h"
#import "RWMainViewController.h"
#import "RWInformationViewController.h"
#import "RWErrorSubjectsController.h"
#import "RWMoreViewController.h"

@interface RWTabBarViewController ()

@property (nonatomic,strong) UIImageView *backBoard;

@property (nonatomic,strong) UIButton *button1;

@property (nonatomic,strong) UIButton *button2;

@property (nonatomic,strong) UIButton *button3;

@property (nonatomic,strong) UIButton *button4;

@property (nonatomic,strong) UILabel *nameLabel1;

@property (nonatomic,strong) UILabel *nameLabel2;

@property (nonatomic,strong) UILabel *nameLabel3;

@property (nonatomic,strong) UILabel *nameLabel4;

@property (nonatomic,assign) CGFloat width;

@property (nonatomic,assign) CGFloat height;

@end

@implementation RWTabBarViewController

@synthesize backBoard;
@synthesize button1;
@synthesize button2;
@synthesize button3;
@synthesize button4;
@synthesize nameLabel1;
@synthesize nameLabel2;
@synthesize nameLabel3;
@synthesize nameLabel4;
@synthesize width;
@synthesize height;

- (void)addHiddenBarObserver
{
    [[NSNotificationCenter defaultCenter] addObserverForName:HIDDEN_NOTIFICATION
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification * _Nonnull note)
     {
         self.tabBar.translucent = YES;
         self.tabBar.hidden = YES;
     }];
}

- (void)addUnhiddenBarObserver
{
    [[NSNotificationCenter defaultCenter] addObserverForName:UNHIDDEN_NOTIFICATION
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification * _Nonnull note)
     {
         self.tabBar.translucent = NO;
         self.tabBar.hidden = NO;
     }];
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    width = self.tabBar.frame.size.width;
    height = self.tabBar.frame.size.height;
    
    [self compositonViewControllers];
    
    backBoard = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, width,height)];
    
    backBoard.backgroundColor = [UIColor whiteColor];
    
    backBoard.userInteractionEnabled = YES;
    
    [self.tabBar addSubview:backBoard];
    
    [self compositionButton];
    
    [self addHiddenBarObserver];
    [self addUnhiddenBarObserver];
}

- (void)compositonViewControllers{
    
    RWMainViewController *main = [[RWMainViewController alloc]init];
    
    UINavigationController *mainNav = [[UINavigationController alloc]initWithRootViewController:main];
    
    RWInformationViewController *information = [[RWInformationViewController alloc]init];
    
    UINavigationController *notiNav = [[UINavigationController alloc]initWithRootViewController:information];
    
    RWErrorSubjectsController *error = [[RWErrorSubjectsController alloc]init];
    
    UINavigationController *errorNav = [[UINavigationController alloc]initWithRootViewController:error];
    
    RWMoreViewController *more = [[RWMoreViewController alloc]init];
    
    UINavigationController *moreNav = [[UINavigationController alloc]initWithRootViewController:more];
    
    
    self.viewControllers = @[mainNav,notiNav,errorNav,moreNav];
    
}

- (void)compositionButton
{
    
    NSArray *nameArr = @[@"题目练习",@"直播课",@"错题复习",@"更多"];
    
    NSArray *images = @[[UIImage imageNamed:@"main"],
                        [UIImage imageNamed:@"noti"],
                        [UIImage imageNamed:@"error"],
                        [UIImage imageNamed:@"set"]];
    
    NSArray *selectImages = @[[UIImage imageNamed:@"mian_s"],
                              [UIImage imageNamed:@"noti_s"],
                              [UIImage imageNamed:@"error_s"],
                              [UIImage imageNamed:@"set_s"]];

    
    for (int i = 1; i <= 4; i++)
    {
        UIView *view = [[UIView alloc]initWithFrame:
                                    CGRectMake(self.view.frame.size.width/4*(i-1), 0,
                                               self.view.frame.size.width/4,
                                               backBoard.frame.size.height)];
        
        view.backgroundColor = [UIColor clearColor];
        view.tag = 1000 + i;
        
        [backBoard addSubview:view];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(attachClick:)];
        tap.numberOfTapsRequired = 1;
        [view addGestureRecognizer:tap];
        
        UIButton *btn = [self valueForKey:[NSString stringWithFormat:@"button%d",i]];
        
        btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 25, 24)];
        
        btn.center = CGPointMake(width/4/2+width/4*(i-1), 24/2+6);
        
        [backBoard addSubview:btn];
        
        [btn setBackgroundImage:images[i-1] forState:UIControlStateNormal];
        [btn setBackgroundImage:selectImages[i-1] forState:UIControlStateSelected];
        
        btn.tag = i+10;
        
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        
        btn.backgroundColor = [UIColor clearColor];
        
        UILabel *nameL = [self valueForKey:[NSString stringWithFormat:@"nameLabel%d",i]];
        
        nameL = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 40, height-30)];
        
        nameL.center = CGPointMake(width/4/2+width/4*(i-1), height-(height-30)/2);
        
        [backBoard addSubview:nameL];
        
        nameL.text = nameArr[i-1];
        
        nameL.textColor = [UIColor grayColor];
        
        nameL.font = [UIFont systemFontOfSize:10];
        
        nameL.textAlignment = NSTextAlignmentCenter;
        
        nameL.tag = 100+i;
        
        nameL.backgroundColor = [UIColor clearColor];
        
        if (i == 1)
        {
            btn.selected = YES;
            
            nameL.textColor = MAIN_COLOR;
        }
        
    }
}

- (void)btnClick:(UIButton *)btn
{
    
    for (int i = 1; i <= 4; i++)
    {
        UIButton *btnX = (UIButton *)[self.view viewWithTag:i+10];
        
        btnX.selected = NO;
        
        UILabel *nameX = (UILabel *)[self.view viewWithTag:i+100];
        
        nameX.textColor = [UIColor grayColor];
    }
    
    btn.selected = YES;
    
    UILabel *name = [self.view viewWithTag:100+btn.tag-10];
    
    name.textColor = MAIN_COLOR;
    
    self.selectedIndex = btn.tag - 1-10;
}

- (void)attachClick:(UITapGestureRecognizer *)tap
{
    
    for (int i = 1; i <= 4; i++)
    {
        UIButton *btnX = (UIButton *)[self.view viewWithTag:i+10];
        
        btnX.selected = NO;
        
        UILabel *nameX = (UILabel *)[self.view viewWithTag:i+100];
        
        nameX.textColor = [UIColor grayColor];
    }
    
    UIButton *selectBtn = [self.view viewWithTag:tap.view.tag-1000+10];
    
    selectBtn.selected = YES;
    
    UILabel *nameLabel = [self.view viewWithTag:tap.view.tag-1000+100];
    
    nameLabel.textColor = MAIN_COLOR;
    
    self.selectedIndex = tap.view.tag-1000-1;
}

- (void)toRootViewController
{
    for (int i = 1; i <= 4; i++)
    {
        UIButton *btnX = (UIButton *)[self.view viewWithTag:i+10];
        
        btnX.selected = NO;
        
        UILabel *nameX = (UILabel *)[self.view viewWithTag:i+100];
        
        nameX.textColor = [UIColor grayColor];
    }
    
    button1.selected = YES;
    
    nameLabel1.textColor = MAIN_COLOR;
    
    self.selectedIndex = 0;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
