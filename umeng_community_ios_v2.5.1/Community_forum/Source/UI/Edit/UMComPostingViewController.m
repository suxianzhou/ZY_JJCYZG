//
//  UMComPostEditViewController.m
//  UMCommunity
//
//  Created by umeng on 15/11/19.
//  Copyright © 2015年 Umeng. All rights reserved.
//

#import "UMComPostingViewController.h"
#import "UMComLocationListController.h"
#import "UMImagePickerController.h"
#import "UMComUser.h"
#import "UMComTopic.h"
#import "UMComShowToast.h"
#import "UMUtils.h"
#import "UMComSession.h"
#import "UIViewController+UMComAddition.h"
#import "UMComNavigationController.h"
#import "UMComImageView.h"
#import "UMComAddedImageView.h"
#import "UMComBarButtonItem.h"
#import "UMComFeedEntity.h"
#import <AVFoundation/AVFoundation.h>
#import "UMComHorizonMenuView.h"
#import "UMComEditTextView.h"
#import "UMComMutiStyleTextView.h"
#import "UMComLocationModel.h"
#import "UMComPushRequest.h"
#import "UMComUser+UMComManagedObject.h"
#import "UMComFeed.h"
#import "UMComLocationView.h"
#import "UMComSelectTopicView.h"
#import "UMComEditForwardView.h"
#import "UMComEmojiKeyboardView.h"
#include <objc/runtime.h>
#import "UMComSelectionTopicViewController.h"
#import "UMComProgressHUD.h"

//iphone6的模板宽度

const CGFloat g_template_NoticeViewLeftMargin = 30;//话题提示框左边距
const CGFloat g_template_NoticeViewRightMargin = 30;//话题提示框右边距
const CGFloat g_template_NoticeViewWidth = 316.f;//话题提示框的宽度
const CGFloat g_template_NoticeViewHeight = 96.f;//话题提示框的高度

const CGFloat g_template_NoticeImageViewTopMargin = 24.f;//提示图片上边距
const CGFloat g_template_NoticeImageViewWidth = 20.f;//提示图片的宽度
const CGFloat g_template_NoticeImageViewHeight = 20.f;//提示图片的高度

const CGFloat g_template_SpaceBetweenImageViewAndLabel = 14.f;//提示文字和图片的间距
const CGFloat g_template_NoticeLabelHeight = 15.f;//提示文字的高度


@interface UMComTopicNoticeView : UIView

@property(nonatomic,strong)UIImageView* noticeImageView;
@property(nonatomic,strong)UILabel* noticeLabel;

-(void) createNoticeImageView;
-(void) createNoticeLabel;

@end

@implementation UMComTopicNoticeView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        [self createNoticeImageView];
        [self createNoticeLabel];
        
        self.backgroundColor = [UIColor blackColor];
        
        self.layer.cornerRadius = 10;
        self.layer.opacity = 0.75;
    }
    return self;
}

-(void) createNoticeImageView
{
    CGFloat orgin_x = (self.bounds.size.width - g_template_NoticeImageViewWidth)/2;
    CGFloat orgin_y = g_template_NoticeImageViewTopMargin;
    self.noticeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(orgin_x, orgin_y, g_template_NoticeImageViewWidth, g_template_NoticeImageViewHeight)];
    
    self.noticeImageView.image = UMComImageWithImageName(@"um_edit_!_normal");
    [self addSubview:self.noticeImageView];
}

-(void) createNoticeLabel
{
    CGFloat orgin_x = 0;
    CGFloat orgin_y = g_template_NoticeImageViewTopMargin + g_template_NoticeImageViewHeight + g_template_SpaceBetweenImageViewAndLabel;
    self.noticeLabel = [[UILabel alloc] initWithFrame:CGRectMake(orgin_x, orgin_y, self.bounds.size.width, g_template_NoticeLabelHeight)];
    
    self.noticeLabel.backgroundColor = [UIColor clearColor];
    self.noticeLabel.text = UMComLocalizedString(@"um_com_selectionTopicPrompt",@"请选择所属话题");
    self.noticeLabel.textColor = UMComColorWithColorValueString(@"#FFFFFF");
    self.noticeLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.noticeLabel];
}


@end



#define ForwardViewHeight 101
#define EditToolViewHeight 43

#define textFont UMComFontNotoSansLightWithSafeSize(15)


#define MinTextLength 5

//定义新的话题逻辑宏
//#define NewEditTopic
//#ifdef NewEditTopic
//此模板参数为iphone6上得高度参数
const CGFloat g_template_visiableViewHeight = 378.f;//可视区域的高度
const CGFloat g_template_titleTextViewHeight = 47.f;//文本标题高度
const CGFloat g_template_contentTextViewHeight = 191.f;//内容高度
const CGFloat g_template_addImgViewHeight = 98.f;//添加图片高度
const CGFloat g_template_addImgViewSpaceHeight = 30.f;//添加图片上下间隔的总和，上面15下面15
const CGFloat g_template_locationViewHeight = 45.f;//位置高度

const CGFloat g_template_leftMargin = 15.f;//控件的左边距间距

//2.4版本编辑界面的宏
const CGFloat g_ForumTemplate_MainScreenWidth = 375.f;//论坛屏幕的宽度参考值
const CGFloat g_ForumTemplate_MainScreenHeight = 667.f;//论坛屏幕的高度参考值
const CGFloat g_ForumTemplate_leftMargin = 15.f;//控件的左边距间距
const CGFloat g_ForumTemplate_titleTextViewHeight = 47.f;//文本标题高度
const CGFloat g_ForumTemplate_contentTextViewHeight = 191.f;//内容高度
const CGFloat g_ForumTemplate_AddImageViewHeight = 90.f;//添加图片控件的高度
const CGFloat g_ForumTemplate_AddImageViewItemSize = 80.f;//添加图片控件的高度
const CGFloat g_ForumTemplate_LocationViewHeight = 45.f;//添加地图控件的高度
const CGFloat g_ForumTemplate_SelectTopicViewHeight = 45.f;//添加话题选择控件的高度
const CGFloat g_ForumTemplate_EditMenuViewViewHeight = 45.f;//UMComHorizonMenuView的高度


//关联一个有焦点的text控件的key
static void *g_ForumActionSheetWithFirstResponder = "g_ForumActionSheetWithFirstResponder";

@interface UIViewController (forwardDeclarationForUMComPostingViewController)
- (void)goBack;
@end

//#endif

typedef NS_ENUM(NSInteger,TopicState)
{
    TopicState_None,        //> 话题初始状态
    TopicState_Modifed,     //> 话题修改状态
    TopicState_UnModifed,   //> 话题不能修改状态
};
@interface UMComPostingViewController () <UMComEditTextViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,UMComEmojiKeyboardViewDelegate,UIAlertViewDelegate>


@property (nonatomic, strong) UMComTopic *topic;
@property (nonatomic, assign) TopicState  topicState;

@property (nonatomic, assign) CGFloat visibleViewHeight;

@property (nonatomic, strong) NSMutableArray *originImages;


@property (nonatomic, copy) void (^selectedFeedTypeBlock)(NSNumber *type);

@property (nonatomic,readwrite, strong)UIScrollView* backgroudScrollView;//2.5新增的可滑动的背景控件
@property (nonatomic,readwrite, strong)UIView* patentView;//2.5新增的父view（子控件都需要添加在此控件上,此变量是为了方便统一修改父窗口view）
//#ifdef NewEditTopic
@property(nonatomic,readwrite,strong)UMComEditTextView *titleTextView;//标题
@property(nonatomic,readwrite,strong)UMComEditTextView *contentTextView;//内容
@property(nonatomic,readwrite,strong)UMComAddedImageView* addImgView;//增加图片的控件
@property(nonatomic,readwrite,strong) UMComLocationView *locationView;
@property(nonatomic,readwrite,strong) UMComSelectTopicView *selectTopicView;

@property(nonatomic,readwrite,strong)UIView* menuViewForTitleView;//为标题控件对应menuview
@property(nonatomic,readwrite,strong)UIView* menuViewForContentView;//为内容控件对应的menuview
@property(nonatomic,readwrite,assign) CGRect viewFrameWithInit;//初始化的区域，在弹出相机时，坐标会变化影响addimage的布局

@property (nonatomic,assign) NSInteger addImgViewHeightWithkeyboard;//带键盘的高度
@property (nonatomic,assign) BOOL isClickEmoji;//是否点击切换键盘,防止键盘hide和show时间回调多次，出现布局抖动现象

@property (nonatomic,strong) UMComTopicNoticeView* topicNoticeView;
-(void) createTopicNoticeView;//创建话题提示框

-(void) createBackgroudScrollView;//设置背景控件(2.5新增为了控件增加超过一屏滚动查看与键盘事件脱离)
-(void) createTitleTextView;//设置标题控件
-(void) createContentTextView;//设置内容控件
-(void) createTopicNavigationItem;//设置导航栏
-(void) createSeparateLineBelowRect:(CGRect)frame;//设置分割线
-(void) createAddedImageView;//创建选择图片控件
-(void) popActionSheetForAddImageView; //用户点击+添加事件
-(void) createLocationView;
-(void) createSelectTopicView;
-(void) createMenuView;
-(void) createMenuViewForTitleView;
-(void) createMenuViewForContentView;
-(void) relayoutChildView;//重新布局子控件
-(void) relayoutChildViewForBelowAddIMG;//重新布局子控件定点位置(目前只有addIMG控件以下的位置会变化)
-(void) initPrePostingData;//初始化上次上传不成功的数据
@property(nonatomic,readwrite,assign) BOOL isFristHaveImgData;//此函数用来表明是第一次加载有图片的数据
//#endif

@property (nonatomic, strong) UMComEmojiKeyboardView *emojiKeyboardViewForTitleView;
@property (nonatomic, strong) UMComEmojiKeyboardView *emojiKeyboardViewForContentView;
@property(nonatomic,strong)UIButton* emojiBtnForTitleView;//点击表情的按钮
@property(nonatomic,strong)UIButton* emojiBtnForContentView;//点击表情的按钮
-(void) createEmojiKeyboardView;
-(void) createEmojiKeyboardViewForTitleView;
-(void) createEmojiKeyboardViewForContentView;
-(void) showEmojiKeyboardViewWithTextView:(UITextView*)textview;
-(void) changeEmojiBtnImg:(BOOL)isEmoji withTextView:(UITextView*)textview;
-(void) appendEmoji:(NSString*)emoji withUITextView:(UMComEditTextView*)textview;
-(void)handleCloseKeyboardBtn:(UIButton*)target;


//改变或者增加话题
-(void)changeOrAddTopic:(UMComTopic *)topic;

-(void)onClickClose:(id)sender;
//用户点击关闭按钮的提示回调
- (void)onClickCloseForprompting:(id)sender;

@end

@implementation UMComPostingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.editFeedEntity = [[UMComFeedEntity alloc]init];
    }
    return self;
}


- (id)initWithTopic:(UMComTopic *)topic
{
    self = [self init];
    if (self) {
        self.topic = topic;
    }
    return self;
}


-(void)viewWillAppear:(BOOL)animated
{

    [super viewWillAppear:animated];
    
    /*
     //2.4版本监控键盘事件调整控件高度
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
     */
}

- (void)viewDidAppear:(BOOL)animated;
{
    [super viewDidAppear:animated];
    self.viewFrameWithInit = self.view.frame;
    //此处重新调整scrollbar的位置
    self.backgroudScrollView.frame = CGRectMake(0, 0, self.viewFrameWithInit.size.width, self.viewFrameWithInit.size.height);
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    /*
     //2.4版本监控键盘事件调整控件高度
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:self];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:self];
    
    [self.titleTextView resignFirstResponder];
    [self.contentTextView resignFirstResponder];
     */
}


- (void)viewDidLoad
{
    self.doNotShowBackButton = YES;//不显示返回按钮
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }


    self.view.backgroundColor = [UIColor whiteColor];
    self.originImages = [NSMutableArray arrayWithCapacity:9];

    [self createBackgroudScrollView];
    self.patentView = self.backgroudScrollView;
    
    
    [self createTitleTextView];
    [self createContentTextView];
    [self createAddedImageView];
    [self createLocationView];
    [self createSelectTopicView];
    [self createMenuView];
    
    [self createTopicNavigationItem];
    
    [self createEmojiKeyboardView];
    
    [self initPrePostingData];
    
    //[self createTopicNoticeView];
}

-(void) initPrePostingData
{
    if ([UMComSession sharedInstance].draftFeed) {
        self.editFeedEntity = [UMComSession sharedInstance].draftFeed;
    }
    
    //简单判断当前用户的操作是否为空来判断当前用户是否已经提交过请求，并且提交请求失败
    if([self.editFeedEntity.uid isEqualToString:@""])
        return;
    
    if (self.editFeedEntity.title) {
        self.titleTextView.text = self.editFeedEntity.title;
        if (self.titleTextView.text.length > 0) {
            self.titleTextView.placeholderLabel.hidden = YES;
        }
    }
    
    if (self.editFeedEntity.text) {
        self.contentTextView.text = self.editFeedEntity.text;
        if (self.contentTextView.text.length > 0) {
            self.contentTextView.placeholderLabel.hidden = YES;
        }
    }
    
    if (self.editFeedEntity.images) {
        self.isFristHaveImgData = YES;
        [self.originImages addObjectsFromArray:self.editFeedEntity.images];
        [self.addImgView addImages:self.editFeedEntity.images];
    }
    
    if (self.editFeedEntity.locationDescription) {
        [self.locationView relayoutChildControlsWithLocation:self.editFeedEntity.locationDescription];
    }
    
    //先判断
    //1.草稿是否有话题
    //2.再判断self.topic是否有话题
    if (self.editFeedEntity.topics && self.editFeedEntity.topics.count > 0) {
        
        UMComTopic* topic = (UMComTopic*)self.editFeedEntity.topics.firstObject;
        [self.selectTopicView relayoutChildControlsWithTopicName:topic.name];
        self.topic = topic;
    }
    else if(self.topic)
    {
        self.topicState = TopicState_UnModifed;
        [self.selectTopicView relayoutChildControlsWithTopicName:self.topic.name];
        [self changeOrAddTopic:self.topic];
        
        __weak typeof(self) weakSelf = self;
        //设置用户不能修改的话题的提示
        self.selectTopicView.seletctedTopicBlock = ^{
            //如果从话题界面进入(会传入self.topic),提示用户不能换话题
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:UMComLocalizedString(@"um_com_sorry", @"抱歉")  message:UMComLocalizedString(@"um_com_noSelectionTopicPrompt",@"话题下发帖不能修改话题") delegate:nil cancelButtonTitle:UMComLocalizedString(@"um_com_ok",@"好") otherButtonTitles:nil];
            [alertView show];
        };
    }
    else{}
}



-(void)onClickClose:(id)sender
{
    //如果用户主动点击取消按钮，就直接清空draftFeed保存的内容，防止下次再进入是显示内容
    [self.titleTextView resignFirstResponder];
    [self.contentTextView resignFirstResponder];
    if([UMComSession sharedInstance].draftFeed)
    {
        [UMComSession sharedInstance].draftFeed = nil;
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    
    [self.navigationController popViewControllerAnimated:NO];
}


/**
 *  判断用户是否修改了编辑页面
 *
 *  @return YES 表示修改了,NO 表示没有修改
 */
-(BOOL) checkShowprompting
{
    if (self.titleTextView.text.length > 0 || self.contentTextView.text.length > 0 || self.originImages.count > 0 || self.editFeedEntity.location || self.topicState == TopicState_Modifed) {
        
        return YES;
    }
    
    return NO;
}

#define SYSTEM_VERSION [[UIDevice currentDevice].systemVersion floatValue]
- (void)onClickCloseForprompting:(id)sender
{
    if (![self checkShowprompting]) {
        [self onClickClose:nil];
        return;
    }
    
    if (SYSTEM_VERSION >= 8.0){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:UMComLocalizedString(@"um_com_prompting", @"提示")   message:UMComLocalizedString(@"um_com_emptyContentWhenGoBack",@"退出此次编辑,内容将丢失!") preferredStyle:UIAlertControllerStyleAlert];
        
        __weak typeof(self) weakself = self;
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:UMComLocalizedString(@"um_com_makesure", @"确定") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakself onClickClose:nil];
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:UMComLocalizedString(@"um_com_cancel", @"取消") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        
        [alertController addAction:cancelAction];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else{
        [self.titleTextView resignFirstResponder];
        [self.contentTextView resignFirstResponder];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:UMComLocalizedString(@"um_com_prompting", @"提示")  message:UMComLocalizedString(@"um_com_emptyContentWhenGoBack",@"退出此次编辑,内容将丢失!") delegate:self cancelButtonTitle:UMComLocalizedString(@"um_com_cancel", @"取消") otherButtonTitles:UMComLocalizedString(@"um_com_makesure", @"确定"),nil];
        alertView.tag = 11111;
        [alertView show];
    }
}


- (void)handleOriginImages:(NSArray *)images{
    
    //[self.originImages addObjectsFromArray:images];//zhangjunhua_删除，回调前，已经加入
    [self.addImgView addImages:images];
    [self viewsFrameChange];
//    CGSize itemSize = self.addImgView.itemSize;
//    CGSize contentSize = self.addImgView.contentSize;
//    CGPoint offset = self.addImgView.contentOffset;
    //NSLog(@"handleOriginImages:self.addImgView.contentSize=%f,self.addImgView.contentoffset = %f",self.addImgView.contentSize.height,self.addImgView.contentOffset.y);
//    if (self.originImages.count >= 4) {
//        self.addImgView.contentOffset = CGPointMake(0,self.addImgView.contentSize.height - self.addImgView.bounds.size.height - itemSize.height + itemSize.height /3);
//    }
}

- (void)updateImageAddedImageView
{
//    CGRect rect = self.addImgView.frame;
//    int i = 0;
//    i++;
}
- (void)viewsFrameChange
{
    //2.4版本的布局函数，随着键盘布局
    //[self relayoutChildView];
    
    //2.5版本的布局函数,不需要随着键盘高度布局
    [self relayoutChildViewForBelowAddIMG];
}


-(void)keyboardWillShow:(NSNotification*)notification
{
    CGRect keybordFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    float endheight = keybordFrame.size.height;
    if (self.viewFrameWithInit.size.height > 0) {
        self.visibleViewHeight = self.viewFrameWithInit.size.height - endheight;;//在调出照相机的时候会隐藏摄像头，导致self.view变化
    }
    else
    {
        self.visibleViewHeight = self.view.frame.size.height - endheight;//在调出照相机的时候会隐藏摄像头，导致self.view变化
    }
    //NSLog(@"keyboardWillShow>>self.visibleViewHeight = %f,keybordFrame.height = %f,self.view = %@",self.visibleViewHeight,endheight,self.view);
    
    [self viewsFrameChange];
}

-(void)keyboardDidShow:(NSNotification*)notification
{
//    CGRect keybordFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
//    float endheight = keybordFrame.size.height;
//    CGFloat tempVisiableHeight = self.view.frame.size.height - endheight;
//    NSLog(@"keyboardDidShow>>self.visibleViewHeight = %f,tempVisiableHeight= %f,endheight = %f,self.view = %@",self.visibleViewHeight,tempVisiableHeight,endheight,self.view);
}

-(void)keyboardWillHide:(NSNotification*)notification
{
    //此处可能会调用很多次，不适合在此加入代码
    //在失去焦点的时候，键盘快要消失的时候调用，防止随键盘变化的空间位置突然变化
    if (self.isClickEmoji) {
        return;
    }
    CGRect keybordFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    float endheight = keybordFrame.size.height;
    
    self.visibleViewHeight = self.view.frame.size.height;
    [self viewsFrameChange];
}

-(void)keyboardDidHide:(NSNotification*)notification
{
    
    CGRect keybordFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    float endheight = keybordFrame.size.height;
    
    self.visibleViewHeight = self.view.frame.size.height;
    [self viewsFrameChange];
}

#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *selectImage = [info valueForKey:@"UIImagePickerControllerOriginalImage"];
    UIImage *tempImage = nil;
    if (selectImage.imageOrientation != UIImageOrientationUp) {
        UIGraphicsBeginImageContext(selectImage.size);
        [selectImage drawInRect:CGRectMake(0, 0, selectImage.size.width, selectImage.size.height)];
        tempImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }else{
        tempImage = selectImage;
    }
    if (self.originImages.count < 9) {
        [self.originImages addObject:tempImage];
        [self handleOriginImages:@[tempImage]];
    }
}

- (void)setUpPicker
{
    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
    if (author == kCLAuthorizationStatusRestricted || author == kCLAuthorizationStatusDenied)
    {
        [[[UIAlertView alloc] initWithTitle:nil message:UMComLocalizedString(@"um_com_photoAlbumAuthentication", @"本应用无访问照片的权限，如需访问，可在设置中修改") delegate:nil cancelButtonTitle:UMComLocalizedString(@"um_com_ok", @"好的") otherButtonTitles:nil, nil] show];
        return;
    }
    if([UMImagePickerController isAccessible])
    {
        UMImagePickerController *imagePickerController = [[UMImagePickerController alloc] init];
        imagePickerController.minimumNumberOfSelection = 1;
        imagePickerController.maximumNumberOfSelection = 9 - [self.addImgView.arrayImages count];
        
        [imagePickerController setFinishHandle:^(BOOL isCanceled,NSArray *assets){
            if(!isCanceled)
            {
                [self dealWithAssets:assets];
            }
        }];
        
        UMComNavigationController *navigationController = [[UMComNavigationController alloc] initWithRootViewController:imagePickerController];
        [self presentViewController:navigationController animated:YES completion:NULL];
    }
}


- (void)dealWithAssets:(NSArray *)assets
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSMutableArray *array = [NSMutableArray array];
        for(ALAsset *asset in assets)
        {
            UIImage *image = [UIImage imageWithCGImage:[asset thumbnail]];
            if (image) {
                [array addObject:image];
            }
            if ([asset defaultRepresentation]) {
                //这里把图片压缩成fullScreenImage分辨率上传，可以修改为fullResolutionImage使用原图上传
                UIImage *originImage = [UIImage
                                        imageWithCGImage:[asset.defaultRepresentation fullScreenImage]
                                        scale:[asset.defaultRepresentation scale]
                                        orientation:UIImageOrientationUp];
                if (originImage) {
                    [self.originImages addObject:originImage];
                }
            } else {
                UIImage *image = [UIImage imageWithCGImage:[asset thumbnail]];
                image = [self compressImage:image];
                if (image) {
                    [self.originImages addObject:image];
                }
            }
            
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self handleOriginImages:array];
        });
    });
}

- (UIImage *)compressImage:(UIImage *)image
{
    UIImage *resultImage  = image;
    if (resultImage.CGImage) {
        NSData *tempImageData = UIImageJPEGRepresentation(resultImage,0.9);
        if (tempImageData) {
            resultImage = [UIImage imageWithData:tempImageData];
        }
    }
    return image;
}

#pragma mark - EditMenuViewSelected
-(void)showImagePicker:(id)sender
{
    if(self.originImages.count >= 9){
        [[[UIAlertView alloc] initWithTitle:UMComLocalizedString(@"um_com_sorry", @"抱歉")  message:UMComLocalizedString(@"um_com_selectTooManyImages",@"图片最多只能选9张") delegate:nil cancelButtonTitle:UMComLocalizedString(@"um_com_ok",@"好") otherButtonTitles:nil] show];
        return;
    }
    [self setUpPicker];
}

-(void)takePhoto:(id)sender
{
    if(self.originImages.count >= 9){
        [[[UIAlertView alloc] initWithTitle:UMComLocalizedString(@"um_com_sorry", @"抱歉")  message:UMComLocalizedString(@"um_com_selectTooManyImages",@"图片最多只能选9张") delegate:nil cancelButtonTitle:UMComLocalizedString(@"um_com_ok",@"好") otherButtonTitles:nil] show];
        return;
    }
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        AVAuthorizationStatus authStatus =  [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (authStatus == AVAuthorizationStatusDenied || authStatus == AVAuthorizationStatusRestricted)
        {
            [[[UIAlertView alloc] initWithTitle:nil message:UMComLocalizedString(@"um_com_photoAlbumAuthentication", @"本应用无访问照片的权限，如需访问，可在设置中修改") delegate:nil cancelButtonTitle:UMComLocalizedString(@"um_com_ok",@"好") otherButtonTitles:nil, nil] show];
            return;
        }
    }else{
        ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
        if (author == kCLAuthorizationStatusRestricted || author == kCLAuthorizationStatusDenied)
        {
            [[[UIAlertView alloc] initWithTitle:nil message:UMComLocalizedString(@"um_com_photoAlbumAuthentication", @"本应用无访问照片的权限，如需访问，可在设置中修改") delegate:nil cancelButtonTitle:UMComLocalizedString(@"um_com_ok",@"好") otherButtonTitles:nil, nil] show];
            return;
        }
    }
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
        imagePicker.delegate = self;
        [self presentViewController:imagePicker animated:YES completion:^{
            
        }];
    }
}

-(void)showLocationPicker:(id)sender
{
    __weak typeof(self) weakSelf = self;
    UMComLocationListController *locationViewController = [[UMComLocationListController alloc] initWithLocationSelectedComplectionBlock:^(UMComLocationModel *locationModel) {
        if (locationModel) {
            weakSelf.editFeedEntity.location = [[CLLocation alloc] initWithLatitude:locationModel.coordinate.latitude longitude:locationModel.coordinate.longitude];
            weakSelf.editFeedEntity.locationDescription = locationModel.name;
            [weakSelf.locationView.label setText:self.editFeedEntity.locationDescription];
            weakSelf.locationView.hidden = NO;
            [weakSelf updateImageAddedImageView];
            [weakSelf.contentTextView becomeFirstResponder];
        }
    }];
    [self.navigationController pushViewController:locationViewController animated:YES];
}


- (void)topicsAddOneTopic:(UMComTopic *)topic
{
    NSMutableArray *topics = [NSMutableArray array];
    if (self.editFeedEntity.topics) {
        [topics addObjectsFromArray:self.editFeedEntity.topics];
    }
    if ([topic isKindOfClass:[UMComTopic class]]) {
        BOOL isInclude = NO;
        for (NSString *name in [self.editFeedEntity.topics valueForKeyPath:@"name"]) {
            if ([name isEqualToString:topic.name]) {
                isInclude = YES;
            }
        }
        if (isInclude == NO) {
            [topics addObject:topic];
        }
    }
    self.editFeedEntity.topics = topics;
}

-(void)changeOrAddTopic:(UMComTopic *)topic
{
    if (!topic) {
        return;
    }
    self.topic = topic;
    [self topicsAddOneTopic:self.topic];
}


#pragma mark - UITextViewDelegate

- (void)editTextViewDidEndEditing:(UMComEditTextView *)textView
{

}

- (BOOL)editTextView:(UMComEditTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text complection:(void (^)())block
{
    return YES;

}



- (BOOL)isString:(NSString *)string
{
    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (string.length > 0) {
        return YES;
    }
    return NO;
}

/**
 *  判断当前是否能发送feed
 *
 *  @return YES 能发送
 *          NO  不能发送
 */
-(BOOL) checkPostContent
{
    //标题，内容，图片三者只要一样为真就满足发送条件
    if((self.titleTextView.text && self.titleTextView.text.length > 0) ||
       (self.contentTextView.text && self.contentTextView.text.length > 0) ||
       (self.originImages && self.originImages.count > 0)
       )
    {
        return YES;
    }
    
    return NO;
}

#pragma mark - creatFeed
- (void)postContent
{
//    //对话题检测
//    if (!self.topic) {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:UMComLocalizedString(@"um_com_sorry", @"抱歉")  message:UMComLocalizedString(@"um_com_selectionTopicPrompt",@"请选择所属话题") delegate:nil cancelButtonTitle:UMComLocalizedString(@"um_com_ok",@"好") otherButtonTitles:nil];
//        [alertView show];
//        return;
//    }
    
    /**
     *  屏蔽标题，正文，图片三者存在其一就可以发送
     */
    
    BOOL isok = [self checkPostContent];
    if (!isok) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:UMComLocalizedString(@"um_com_sorry", @"抱歉")  message:UMComLocalizedString(@"标题,正文,图片三者不能同时为空",@"标题,正文,图片三者不能同时为空") delegate:nil cancelButtonTitle:UMComLocalizedString(@"um_com_ok",@"好") otherButtonTitles:nil];
        [alertView show];
        [self.titleTextView becomeFirstResponder];
        return;
    }
    
    
    /**
     *  屏蔽对标题的检测
     */
    if (!self.titleTextView.text || self.titleTextView.text.length == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:UMComLocalizedString(@"um_com_sorry", @"抱歉")  message:UMComLocalizedString(@"um_com_emptyTitileTip",@"标题内容不能为空") delegate:nil cancelButtonTitle:UMComLocalizedString(@"um_com_ok",@"好") otherButtonTitles:nil];
        [alertView show];
        return;
    }
     
    
    if (self.topic) {
        self.editFeedEntity.topics = @[self.topic];
    }
    self.editFeedEntity.title = self.titleTextView.text;
    self.editFeedEntity.images = self.originImages;

    /**
     *  屏蔽对正文内容的检测
     */
    
    
    if (!self.contentTextView.text || self.contentTextView.text.length == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:UMComLocalizedString(@"um_com_sorry", @"抱歉")  message:UMComLocalizedString(@"Empty_ContentText",@"文字内容不能为空") delegate:nil cancelButtonTitle:UMComLocalizedString(@"um_com_ok",@"好") otherButtonTitles:nil];
        [alertView show];
        [self.contentTextView becomeFirstResponder];
        return;
    }
    
    
    if ([self.contentTextView getRealTextLength] < MinTextLength && self.originImages.count == 0) {
        NSString *tooShortNotice = [NSString stringWithFormat:@"发布的内容太少啦，再多写点内容。"];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:UMComLocalizedString(@"um_com_sorry", @"抱歉")  message:UMComLocalizedString(@"The content is too long",tooShortNotice) delegate:nil cancelButtonTitle:UMComLocalizedString(@"um_com_ok",@"好") otherButtonTitles:nil];
        [alertView show];
        [self.contentTextView becomeFirstResponder];
        return;
    }
    
    if (self.contentTextView.text && [self.contentTextView getRealTextLength] > self.contentTextView.maxTextLenght) {
        NSString *tooLongNotice = [NSString stringWithFormat:@"内容过长,超出%d个字符",(int)[self.contentTextView getRealTextLength] - (int)self.contentTextView.maxTextLenght];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:UMComLocalizedString(@"um_com_sorry", @"抱歉")  message:UMComLocalizedString(@"The content is too long",tooLongNotice) delegate:nil cancelButtonTitle:UMComLocalizedString(@"um_com_ok",@"好") otherButtonTitles:nil];
        [alertView show];
        [self.contentTextView becomeFirstResponder];
        return;
    }
    
    
    //对话题检测
    if (!self.topic) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:UMComLocalizedString(@"um_com_sorry", @"抱歉")  message:UMComLocalizedString(@"um_com_selectionTopicPrompt",@"请选择所属话题") delegate:nil cancelButtonTitle:UMComLocalizedString(@"um_com_ok",@"好") otherButtonTitles:nil];
        [alertView show];
        [self.titleTextView becomeFirstResponder];
        return;
    }
    
    self.editFeedEntity.text = self.contentTextView.text;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSMutableArray *postImages = [NSMutableArray array];
    //iCloud共享相册中的图片没有原图
    for (UIImage *image in self.originImages) {
        UIImage *originImage = [self compressImage:image];
        [postImages addObject:originImage];
    }
    
    //隐藏键盘，防止发送失败的时候看不到最下面的提示文字
    [self.titleTextView resignFirstResponder];
    [self.contentTextView resignFirstResponder];
    
    //加入等待框
    UMComProgressHUD *hud = [UMComProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.label.text = UMComLocalizedString(@"um_com_postingContent",@"发送中...");
    hud.label.backgroundColor = [UIColor clearColor];
    
    __weak typeof(self) weakself = self;
    [self postEditContentWithImages:postImages response:^(id responseObject, NSError *error) {
        [hud hideAnimated:YES];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [weakself dealWhenPostFeedFinish:responseObject error:error];
        if (!error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                //如果没有错误就返回
                [weakself onClickClose:nil];
            });
        }
    }];
}



- (void)dealWhenPostFeedFinish:(NSArray *)responseObject error:(NSError *)error
{
    if (error) {
        [UMComShowToast showFetchResultTipWithError:error];
    } else if([responseObject isKindOfClass:[NSArray class]] && responseObject.count > 0) {
        if (self.postCreatedFinish) {
            self.postCreatedFinish(responseObject.firstObject);
        }
        UMComFeed *feed = responseObject.firstObject;
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPostFeedResultNotification object:feed];
        [UMComShowToast createFeedSuccess];
    }
}


- (void)postEditContentWithImages:(NSArray *)images
                         response:(void (^)(id responseObject,NSError *error))response
{
    __weak typeof(self) weakSelf = self;
    self.editFeedEntity.images = images;
    if ([self isPermission_bulletin]) {
        self.selectedFeedTypeBlock = ^(NSNumber *type){
            [UMComPushRequest postWithFeed:weakSelf.editFeedEntity completion:^(id responseObject, NSError *error) {
                if (response) {
                    response(responseObject, error);
                }
                if (error) {
                    //一旦发送失败会保存到草稿箱
                    [UMComSession sharedInstance].draftFeed = weakSelf.editFeedEntity;
                } else {
                    [UMComSession sharedInstance].draftFeed = nil;
                }
            }];
        };
        [self showFeedTypeNotice];
    }else{
        
        self.editFeedEntity.uid = @"575cda1cb51b2d2cc63aa9f1";
        NSLog(@"self = %@",self.editFeedEntity.uid);
        
        [UMComPushRequest postWithFeed:self.editFeedEntity completion:^(id responeObject,NSError *error) {
            if (error) {
                //一旦发送失败会保存到草稿箱
                [UMComSession sharedInstance].draftFeed = weakSelf.editFeedEntity;
            } else {
                [UMComSession sharedInstance].draftFeed = nil;
            }
            
            if (response) {
                response(responeObject, error);
            }
        }];
    }
}


- (BOOL)isPermission_bulletin
{
    UMComUser *user = [UMComSession sharedInstance].loginUser;
    BOOL isPermission_bulletin = NO;
    if ([[UMComSession sharedInstance].loginUser.atype intValue] == 1 && [user isPermissionBulletin]) {
        isPermission_bulletin = YES;
    }
    return isPermission_bulletin;
}

- (void)showFeedTypeNotice
{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:UMComLocalizedString(@"um_com_publicFeed", @"是否需要将本条内容标记为公告？") delegate:self cancelButtonTitle:UMComLocalizedString(@"um_com_no", @"否") otherButtonTitles:UMComLocalizedString(@"um_com_yes", @"是"), nil];
    alertView.tag = 10001;
    [alertView show];
}

- (void)showResetFeedTypeNotice
{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:UMComLocalizedString(@"um_com_noPrivilegeCreatFeed", @"你没有发公告的权限，是否标记为非公告重新发送？")  delegate:self cancelButtonTitle:UMComLocalizedString(@"um_com_no", @"否") otherButtonTitles:UMComLocalizedString(@"um_com_yes", @"是"), nil];
    alertView.tag = 10002;
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSNumber *type = @0;
    if (alertView.tag == 10001) {
        type = [NSNumber numberWithInteger:buttonIndex];
        if (self.selectedFeedTypeBlock) {
            self.editFeedEntity.type = type;
            self.selectedFeedTypeBlock(type);
        }
    }
    else if(alertView.tag == 11111)//点击确定按钮
    {
        if (buttonIndex == 1)
        {
            //iOS 8.0，dismiss alert view时系统会尝试恢复之前的keyboard input,导致界面消失了，键盘会闪现,
            //此处延迟0.5秒就是为了让键盘弹出，再做onClickClose的关闭操作
            [self performSelector:@selector(onClickClose:) withObject:nil afterDelay:0.5];
            //[self onClickClose:nil];
        }
    }
    else{
        if (buttonIndex == 1) {
            if (self.selectedFeedTypeBlock) {
                self.editFeedEntity.type = type;
                self.selectedFeedTypeBlock(type);
            }
        }
    }

}

- (void)postForwardFeed:(UMComFeed *)forwardFeed
               response:(void (^)(id responseObject,NSError *error))response
{
    NSMutableArray *atUsers = [NSMutableArray arrayWithCapacity:1];
    for (UMComUser *user in self.editFeedEntity.atUsers) {
        [atUsers addObject:user];
    }
    UMComFeed *originFeed = forwardFeed;
    while (originFeed.origin_feed) {
        if (![atUsers containsObject:originFeed.creator]) {
            [atUsers addObject:originFeed.creator];
        }
        originFeed = originFeed.origin_feed;
    }
    self.editFeedEntity.atUsers = atUsers;
    [UMComPushRequest forwardWithFeed:forwardFeed newFeed:self.editFeedEntity completion:^(id responseObject, NSError *error) {
        if (response) {
            response(responseObject,error);
        }
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//#ifdef NewEditTopic
/*
-(void) createTitleTextView
{
    NSArray *regexArray = [NSArray arrayWithObjects:UserRulerString, TopicRulerString,UrlRelerSring, nil];
    self.titleTextView = [[UMComEditTextView alloc]initWithFrame:CGRectMake(g_template_leftMargin, 0, self.view.frame.size.width - g_template_leftMargin, g_template_titleTextViewHeight) checkWords:nil regularExStrArray:regexArray];
    self.titleTextView.editDelegate = self;
    self.titleTextView.maxTextLenght = 30;
    [self.titleTextView setFont:textFont];
    [self.view addSubview:self.titleTextView];
    self.titleTextView.placeholderLabel.text = @"请输入标题呗,限30字";
    self.titleTextView.textAlignment = NSTextAlignmentLeft;
}
 */

-(void) createTopicNoticeView
{
    //高度不变，宽度保证两边都有Margin
    CGFloat width = self.view.bounds.size.width - g_template_NoticeViewLeftMargin - g_template_NoticeViewRightMargin;
    CGFloat orgin_x = (self.view.bounds.size.width - width)/2;
    CGFloat orgin_y = (self.view.bounds.size.height - g_template_NoticeViewHeight)/2;
    
    self.topicNoticeView = [[UMComTopicNoticeView alloc] initWithFrame:CGRectMake(orgin_x, orgin_y, width, g_template_NoticeViewHeight)];
    [self.patentView addSubview:self.topicNoticeView];
    self.topicNoticeView.hidden = YES;
}

-(void) createBackgroudScrollView
{
    self.backgroudScrollView =  [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.backgroudScrollView.backgroundColor = [UIColor whiteColor];
    
    self.backgroudScrollView.contentSize = self.view.bounds.size;
    [self.view addSubview:self.backgroudScrollView];
}

-(void) createTitleTextView
{
    NSArray *regexArray = [NSArray arrayWithObjects:UserRulerString, TopicRulerString,UrlRelerSring, nil];
    self.titleTextView = [[UMComEditTextView alloc]initWithFrame:CGRectMake(g_ForumTemplate_leftMargin, 0, self.view.frame.size.width - g_ForumTemplate_leftMargin, g_ForumTemplate_titleTextViewHeight) checkWords:nil regularExStrArray:regexArray];
    self.titleTextView.editDelegate = self;
    self.titleTextView.maxTextLenght = 30;
    [self.titleTextView setFont:textFont];
    [self.patentView addSubview:self.titleTextView];
    self.titleTextView.placeholderLabel.text = UMComLocalizedString(@"Forum_Edit_TitleTextView_PlaceholderLabel", @"请输入标题呗,限30字");
    self.titleTextView.textAlignment = NSTextAlignmentLeft;
}

/*
-(void) createContentTextView
{
    NSArray *regexArray = [NSArray arrayWithObjects:UserRulerString, TopicRulerString,UrlRelerSring, nil];
    self.contentTextView = [[UMComEditTextView alloc]initWithFrame:CGRectMake(g_template_leftMargin, self.titleTextView.frame.origin.y + self.titleTextView.frame.size.height, self.view.frame.size.width-g_template_leftMargin, g_template_contentTextViewHeight) checkWords:nil regularExStrArray:regexArray];
    self.contentTextView.editDelegate = self;
    self.contentTextView.maxTextLenght = [UMComSession sharedInstance].maxFeedLength;
    [self.contentTextView setFont:textFont];
    [self.view addSubview:self.contentTextView];
    self.contentTextView.placeholderLabel.text = @"请写点什么吧";
    
    UIView* separateView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 1)];
    separateView.backgroundColor = UMComColorWithColorValueString(@"eeeff3");
    [self.contentTextView addSubview:separateView];
    
}
 */

-(void) createContentTextView
{
    NSArray *regexArray = [NSArray arrayWithObjects:UserRulerString, TopicRulerString,UrlRelerSring, nil];
    self.contentTextView = [[UMComEditTextView alloc]initWithFrame:CGRectMake(g_ForumTemplate_leftMargin, self.titleTextView.frame.origin.y + self.titleTextView.frame.size.height, self.view.frame.size.width-g_ForumTemplate_leftMargin, g_ForumTemplate_contentTextViewHeight) checkWords:nil regularExStrArray:regexArray];
    self.contentTextView.editDelegate = self;
    self.contentTextView.maxTextLenght = [UMComSession sharedInstance].maxFeedLength;
    [self.contentTextView setFont:textFont];
    [self.patentView addSubview:self.contentTextView];
    self.contentTextView.placeholderLabel.text = UMComLocalizedString(@"um_com_Forum_Edit_ContentTextView_PlaceholderLabel", @"请写点什么吧");
    
    UIView* separateView = [[UIView alloc] initWithFrame:CGRectMake(self.contentTextView.frame.origin.x, self.contentTextView.frame.origin.y, self.view.bounds.size.width, 1)];
    separateView.backgroundColor = UMComColorWithColorValueString(@"eeeff3");
    [self.patentView addSubview:separateView];
}

-(void) createTopicNavigationItem
{
    MAIN_NAV
    /*
    UMComBarButtonItem *leftButtonItem = [[UMComBarButtonItem alloc] initWithTitle:UMComLocalizedString(@"um_com_cancel", @"取消")  target:self action:@selector(onClickClose:)];
    [self.navigationItem setLeftBarButtonItem:leftButtonItem];
    leftButtonItem.customButtonView.frame = CGRectMake(0, 0, 35, 35);
    [leftButtonItem.customButtonView setTitleColor:UMComColorWithColorValueString(@"b5b5b5") forState:UIControlStateNormal];
    leftButtonItem.customButtonView.titleLabel.font = UMComFontNotoSansLightWithSafeSize(15);
    
    UMComBarButtonItem* rightButtonItem = [[UMComBarButtonItem alloc] initWithTitle:@"提交" target:self action:@selector(postContent)];
    rightButtonItem.customButtonView.frame = CGRectMake(0, 0, 35, 35);
    [rightButtonItem.customButtonView setTitleColor:UMComColorWithColorValueString(@"008bea") forState:UIControlStateNormal];
    rightButtonItem.customButtonView.titleLabel.font = UMComFontNotoSansLightWithSafeSize(15);
    [self.navigationItem setRightBarButtonItem:rightButtonItem];
     */
    
    //和微博版的按钮样式一致
//    UIBarButtonItem *leftButtonItem = [[UMComBarButtonItem alloc] initWithNormalImageName:@"cancelx" target:self action:@selector(onClickClose:)];
//    [self.navigationItem setLeftBarButtonItem:leftButtonItem];
//    
//    UIBarButtonItem *rightButtonItem = [[UMComBarButtonItem alloc] initWithNormalImageName:@"sendx" target:self action:@selector(postContent)];
//    [self.navigationItem setRightBarButtonItem:rightButtonItem];
    UMComButton* leftCustomButtonView = [[UMComButton alloc] initWithNormalImageName:@"um_edit_cancel" target:self action:@selector(onClickCloseForprompting:)];
    leftCustomButtonView.frame = CGRectMake(0, 0, 14, 14);
    UIBarButtonItem *leftButtonItem =  [[UMComBarButtonItem alloc] initWithCustomView:leftCustomButtonView];
    [self.navigationItem setLeftBarButtonItem:leftButtonItem];
    
    UMComButton* rightCustomButtonView = [[UMComButton alloc] initWithNormalImageName:@"um_edit_send" target:self action:@selector(postContent)];
    rightCustomButtonView.frame = CGRectMake(0, 0, 20, 14);
    UIBarButtonItem *rightButtonItem =  [[UMComBarButtonItem alloc] initWithCustomView:rightCustomButtonView];
    [self.navigationItem setRightBarButtonItem:rightButtonItem];
    
    
    //设置中间文本
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:self.navigationController.navigationBar.bounds];
    titleLabel.text = UMComLocalizedString(@"um_com_forumEditTitleText", @"发帖");
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = UMComFontNotoSansLightWithSafeSize(18);
    titleLabel.textColor =  UMComColorWithColorValueString(@"FFFFFF");
    [self.navigationItem setTitleView:titleLabel];
}

-(void) createSeparateLineBelowRect:(CGRect)frame
{
    UIView* separateView = [[UIView alloc] initWithFrame:CGRectMake(0, frame.origin.y + frame.size.height + 2, self.view.bounds.size.width, 2)];
    
    separateView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:separateView];
}

/*
-(void) createAddedImageView
{
    self.addImgView = [[UMComAddedImageView alloc] initWithFrame:CGRectMake(0, self.contentTextView.frame.origin.y + self.contentTextView.frame.size.height, self.view.bounds.size.width, g_template_addImgViewHeight)];
    [self.view addSubview:self.addImgView];
    self.addImgView.isUsingForumMethod = YES;
    self.addImgView.isAddImgViewShow = YES;
    self.addImgView.isDashWithBorder = YES;
    self.addImgView.deleteViewType = UMComActionDeleteViewType_Rectangle;
    
    //提前算好一行4个图片的高度和宽度，
    int itemSpace = 10;//每个图片的间隔为10像素
    int countPerLine = 4;//每行四个图片
    int itemWidth = (self.addImgView.bounds.size.width - 5 * itemSpace)/countPerLine;
    self.addImgView.itemSize = CGSizeMake(itemWidth, itemWidth);
    
//    //算出每个图片的高度后，必须保证一个完整地图片显示，所以此处需要调整整个addImgView的位置，以保证显示一张完整地图片
//    CGRect orgFrame = self.addImgView.frame;
//    orgFrame.size.height = itemWidth + itemSpace*2 + 2.0;//再加两个像素为了，让用户看到下面也有图片
//    self.addImgView.frame = orgFrame;

    [self.addImgView addImages:[NSArray array]];
    
     __weak typeof(self) weakSelf = self;
    [self.addImgView setPickerAction:^{
        //[weakSelf setUpPicker];
        //[weakSelf takePhoto:nil];
        [weakSelf popActionSheetForAddImageView];
    }];
    self.addImgView.imagesChangeFinish = ^(){
        [weakSelf updateImageAddedImageView];
    };
    self.addImgView.imagesDeleteFinish = ^(NSInteger index){
        [weakSelf.originImages removeObjectAtIndex:index];
    };
}
 */

-(void) createAddedImageView
{
    CGSize mainScreenSize = [UIScreen mainScreen].bounds.size;
    CGFloat addImgViewHeight = g_ForumTemplate_AddImageViewHeight;
    addImgViewHeight = mainScreenSize.height * g_ForumTemplate_AddImageViewHeight/g_ForumTemplate_MainScreenHeight;
    
    self.addImgViewHeightWithkeyboard = addImgViewHeight;
    
    self.addImgView = [[UMComAddedImageView alloc] initWithFrame:CGRectMake(0, self.contentTextView.frame.origin.y + self.contentTextView.frame.size.height, self.view.bounds.size.width, self.addImgViewHeightWithkeyboard)];
    [self.patentView addSubview:self.addImgView];
    self.addImgView.isUsingForumMethod = YES;
    self.addImgView.isAddImgViewShow = YES;
    self.addImgView.isDashWithBorder = YES;
    self.addImgView.deleteViewType = UMComActionDeleteViewType_Rectangle;
    
    CGFloat itemWidth = g_ForumTemplate_AddImageViewItemSize;
    itemWidth = mainScreenSize.width * g_ForumTemplate_AddImageViewItemSize / g_ForumTemplate_MainScreenWidth;
    
    self.addImgView.itemSize = CGSizeMake(itemWidth, itemWidth);
    
    [self.addImgView addImages:[NSArray array]];
    
    __weak typeof(self) weakSelf = self;
    [self.addImgView setPickerAction:^{
        [weakSelf popActionSheetForAddImageView];
    }];
    self.addImgView.imagesChangeFinish = ^(){
        [weakSelf updateImageAddedImageView];
    };
    self.addImgView.imagesDeleteFinish = ^(NSInteger index){
        [weakSelf.originImages removeObjectAtIndex:index];
        [weakSelf viewsFrameChange];
    };
}

/*
-(void) createLocationView
{
    self.locationView = [[UMComLocationView alloc]initWithFrame:CGRectMake(0, self.addImgView.frame.origin.y + self.addImgView.frame.size.height, self.view.frame.size.width, g_template_locationViewHeight)];
    [self.view addSubview:self.locationView];
    
    UIView* separateView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.locationView.bounds.size.width, 1)];
    separateView.backgroundColor = UMComColorWithColorValueString(@"eeeff3");
    [self.locationView addSubview:separateView];
    
    [self.locationView relayoutChildControlsWithLocation:@""];
    
    __weak typeof(self) weakSelf = self;
    self.locationView.locationBlock = ^{
        UMComLocationListController *locationViewController = [[UMComLocationListController alloc] initWithLocationSelectedComplectionBlock:^(UMComLocationModel *locationModel) {
            if (locationModel) {
                weakSelf.editFeedEntity.location = [[CLLocation alloc] initWithLatitude:locationModel.coordinate.latitude longitude:locationModel.coordinate.longitude];
                weakSelf.editFeedEntity.locationDescription = locationModel.name;
                [weakSelf.locationView relayoutChildControlsWithLocation:weakSelf.editFeedEntity.locationDescription];

            }
        }];
        [weakSelf.navigationController pushViewController:locationViewController animated:YES];
    };
    
}
 */

-(void) createLocationView
{
    self.locationView = [[UMComLocationView alloc]initWithFrame:CGRectMake(0, self.addImgView.frame.origin.y + self.addImgView.frame.size.height, self.view.frame.size.width, g_ForumTemplate_LocationViewHeight)];
    [self.patentView addSubview:self.locationView];
    
    UIView* separateView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.locationView.bounds.size.width, 1)];
    separateView.backgroundColor = UMComColorWithColorValueString(@"eeeff3");
    [self.locationView addSubview:separateView];
    
    [self.locationView relayoutChildControlsWithLocation:nil];
    
    __weak typeof(self) weakSelf = self;
    self.locationView.locationBlock = ^{
        UMComLocationListController *locationViewController = [[UMComLocationListController alloc] initWithLocationSelectedComplectionBlock:^(UMComLocationModel *locationModel) {
            if (locationModel) {
                weakSelf.editFeedEntity.location = [[CLLocation alloc] initWithLatitude:locationModel.coordinate.latitude longitude:locationModel.coordinate.longitude];
                weakSelf.editFeedEntity.locationDescription = locationModel.name;
                [weakSelf.locationView relayoutChildControlsWithLocation:weakSelf.editFeedEntity.locationDescription];
                
            }
        }];
        [weakSelf.navigationController pushViewController:locationViewController animated:YES];
    };
}

-(void) createSelectTopicView
{
    self.selectTopicView = [[UMComSelectTopicView alloc]initWithFrame:CGRectMake(0, self.locationView.frame.origin.y + self.locationView.frame.size.height, self.view.frame.size.width, g_ForumTemplate_SelectTopicViewHeight)];
    [self.patentView addSubview:self.selectTopicView];
    
    UIView* separateView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.locationView.bounds.size.width, 1)];
    separateView.backgroundColor = UMComColorWithColorValueString(@"eeeff3");
    [self.selectTopicView addSubview:separateView];
    
    UIView* separateViewBottom = [[UIView alloc] initWithFrame:CGRectMake(0, self.locationView.bounds.size.height-1, self.locationView.bounds.size.width, 1)];
    separateViewBottom.backgroundColor = UMComColorWithColorValueString(@"eeeff3");
    [self.selectTopicView addSubview:separateViewBottom];
    
    [self.selectTopicView relayoutChildControlsWithTopicName:nil];
    
    __weak typeof(self) weakSelf = self;
    self.selectTopicView.seletctedTopicBlock = ^{
        //选择话题的block
       UMComSelectionTopicViewController* selectionTopicViewController =  [[UMComSelectionTopicViewController alloc] init];
        selectionTopicViewController.selectionTopicComplete = ^(UMComTopic* topic,NSError* error){
            if (topic) {
                weakSelf.topicState = TopicState_Modifed;
                [weakSelf.selectTopicView relayoutChildControlsWithTopicName:topic.name];
            }
            [weakSelf changeOrAddTopic:topic];
        };
       [weakSelf.navigationController pushViewController:selectionTopicViewController animated:YES];
    };
}

-(void)createMenuView
{
    [self createMenuViewForTitleView];
    [self createMenuViewForContentView];
    
    self.titleTextView.inputAccessoryView = self.menuViewForTitleView;
    self.contentTextView.inputAccessoryView = self.menuViewForContentView;
}

-(void) createMenuViewForTitleView
{
    self.menuViewForTitleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, g_ForumTemplate_EditMenuViewViewHeight)];
    self.menuViewForTitleView.backgroundColor = [UIColor whiteColor];
    
    UIButton* emojiBtn =  [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat emojiBtn_y = (g_ForumTemplate_EditMenuViewViewHeight -30)/2;
    emojiBtn.frame = CGRectMake(g_ForumTemplate_leftMargin,emojiBtn_y,30,30);
    
    [emojiBtn addTarget:self action:@selector(handleBtnChangeEmojiBtnImgForTitleView:) forControlEvents:UIControlEventTouchUpInside];
    
    //显示表情
    [emojiBtn setBackgroundImage:UMComImageWithImageName(@"um_edit_emoji_normal") forState:UIControlStateNormal];
    [emojiBtn setBackgroundImage:UMComImageWithImageName(@"um_edit_emoji_highlight") forState:UIControlStateHighlighted];
    
    [self.menuViewForTitleView addSubview:emojiBtn];
    self.emojiBtnForTitleView = emojiBtn;
    
    //创建关闭输入法的按钮
    CGFloat closeKeyboardBtnWidth = 22;
    CGFloat closeKeyboardBtnHeight = 12;
    CGFloat tailMarginTemplate = 13;//右边空白区域
    UIButton* closeKeyboardBtn =  [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat closeKeyboard_x = self.menuViewForTitleView.bounds.size.width - closeKeyboardBtnWidth - tailMarginTemplate;
    CGFloat closeKeyboard_y = (g_ForumTemplate_EditMenuViewViewHeight -closeKeyboardBtnHeight)/2;
    closeKeyboardBtn.frame = CGRectMake(closeKeyboard_x,closeKeyboard_y,closeKeyboardBtnWidth,closeKeyboardBtnHeight);
    
    [closeKeyboardBtn setBackgroundImage:UMComImageWithImageName(@"um_dropdowngray_forum") forState:UIControlStateNormal];
    [closeKeyboardBtn setBackgroundImage:UMComImageWithImageName(@"um_dropdownblue_forum") forState:UIControlStateHighlighted];
    
    [closeKeyboardBtn addTarget:self action:@selector(handleCloseKeyboardBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuViewForTitleView addSubview:closeKeyboardBtn];
    
    
    UIButton* maskBtn =  [UIButton buttonWithType:UIButtonTypeCustom];
    maskBtn.frame = CGRectMake(closeKeyboard_x,closeKeyboard_y,closeKeyboardBtnWidth + tailMarginTemplate,self.menuViewForTitleView.bounds.size.height);
    [maskBtn addTarget:self action:@selector(handleCloseKeyboardBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuViewForTitleView addSubview:maskBtn];
    
    
    UIView* separateView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 1)];
    separateView.backgroundColor = UMComColorWithColorValueString(@"eeeff3");
    [self.menuViewForTitleView addSubview:separateView];
    
}

-(void) createMenuViewForContentView
{
    self.menuViewForContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, g_ForumTemplate_EditMenuViewViewHeight)];
    self.menuViewForContentView.backgroundColor = [UIColor whiteColor];
    
    UIButton* emojiBtn =  [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat emojiBtn_y = (g_ForumTemplate_EditMenuViewViewHeight -30)/2;
    emojiBtn.frame = CGRectMake(g_ForumTemplate_leftMargin,emojiBtn_y,30,30);

    
    [emojiBtn addTarget:self action:@selector(handleBtnChangeEmojiBtnImgForContentView:) forControlEvents:UIControlEventTouchUpInside];
    
    //显示表情
    [emojiBtn setBackgroundImage:UMComImageWithImageName(@"um_edit_emoji_normal") forState:UIControlStateNormal];
    [emojiBtn setBackgroundImage:UMComImageWithImageName(@"um_edit_emoji_highlight") forState:UIControlStateHighlighted];
    
    [self.menuViewForContentView addSubview:emojiBtn];
    self.emojiBtnForContentView = emojiBtn;
    
    //创建关闭输入法的按钮
    CGFloat closeKeyboardBtnWidth = 22;
    CGFloat closeKeyboardBtnHeight = 12;
    CGFloat tailMarginTemplate = 13;//右边空白区域
    UIButton* closeKeyboardBtn =  [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat closeKeyboard_x = self.menuViewForTitleView.bounds.size.width - closeKeyboardBtnWidth - tailMarginTemplate;
    CGFloat closeKeyboard_y = (g_ForumTemplate_EditMenuViewViewHeight -closeKeyboardBtnHeight)/2;
    closeKeyboardBtn.frame = CGRectMake(closeKeyboard_x,closeKeyboard_y,closeKeyboardBtnWidth,closeKeyboardBtnHeight);
    
    [closeKeyboardBtn setBackgroundImage:UMComImageWithImageName(@"um_dropdowngray_forum") forState:UIControlStateNormal];
    [closeKeyboardBtn setBackgroundImage:UMComImageWithImageName(@"um_dropdownblue_forum") forState:UIControlStateHighlighted];
    
    [closeKeyboardBtn addTarget:self action:@selector(handleCloseKeyboardBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuViewForContentView addSubview:closeKeyboardBtn];
    
    UIButton* maskBtn =  [UIButton buttonWithType:UIButtonTypeCustom];
    maskBtn.frame = CGRectMake(closeKeyboard_x,closeKeyboard_y,closeKeyboardBtnWidth + tailMarginTemplate,self.menuViewForContentView.bounds.size.height);
    [maskBtn addTarget:self action:@selector(handleCloseKeyboardBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuViewForContentView addSubview:maskBtn];
    
    UIView* separateView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 1)];
    separateView.backgroundColor = UMComColorWithColorValueString(@"eeeff3");
    [self.menuViewForContentView addSubview:separateView];
}

/*
-(void) relayoutChildView
{
    if (self.visibleViewHeight <= 0) {
        return;
    }
    
    //计算标题控件坐标比例
    CGFloat temp_titleTextViewHeight = g_template_titleTextViewHeight*self.visibleViewHeight/g_template_visiableViewHeight;
    CGRect temp_titleTextViewOrgRect = self.titleTextView.frame;
    temp_titleTextViewOrgRect.size.height = (int)temp_titleTextViewHeight;
    self.titleTextView.frame = temp_titleTextViewOrgRect;
    
    //计算内容控件的坐标比例
    CGFloat temp_contentTextViewHeight = g_template_contentTextViewHeight*self.visibleViewHeight/g_template_visiableViewHeight;
    CGRect temp_contentTextViewOrgRect = self.contentTextView.frame;
    temp_contentTextViewOrgRect.size.height = (int)temp_contentTextViewHeight;
    temp_contentTextViewOrgRect.origin.y = temp_titleTextViewOrgRect.origin.y + temp_titleTextViewOrgRect.size.height;
    self.contentTextView.frame = temp_contentTextViewOrgRect;
    
    //计算添加图片的坐标比例
    CGFloat temp_addImgViewHeight = g_template_addImgViewHeight*self.visibleViewHeight/g_template_visiableViewHeight;
    CGRect temp_addImgViewOrgRect = self.addImgView.frame;
    temp_addImgViewOrgRect.size.height = (int)temp_addImgViewHeight;
    temp_addImgViewOrgRect.origin.y = temp_contentTextViewOrgRect.origin.y + temp_contentTextViewOrgRect.size.height;
    self.addImgView.frame = temp_addImgViewOrgRect;
    
    //提前算好一行4个图片的高度和宽度，
    int itemSpace = 10;//每个图片的间隔为10像素
    int countPerLine = 4;//每行四个图片
    int tempspace = g_template_addImgViewSpaceHeight*self.visibleViewHeight/g_template_visiableViewHeight;
    int temp_itemWidth = (self.addImgView.bounds.size.width - 5 * itemSpace)/countPerLine;
    int itemWidth = temp_itemWidth < self.addImgView.frame.size.height ?  temp_itemWidth :  (self.addImgView.frame.size.height -tempspace);
    self.addImgView.itemSize = CGSizeMake(itemWidth, itemWidth);
    if (self.isFristHaveImgData) {
        self.isFristHaveImgData = YES;
        [self.addImgView addImages:self.originImages];//强制改变+的大小
    }
    else
    {
        [self.addImgView addImages:[NSArray array]];//强制改变+的大小
    }
    
    
    //添加位置控件的坐标比例
    CGFloat temp_locationViewHeight = g_template_locationViewHeight*self.visibleViewHeight/g_template_visiableViewHeight;
    CGRect temp_locationViewOrgRect = self.locationView.frame;
    temp_locationViewOrgRect.size.height = (int)temp_locationViewHeight;
    temp_locationViewOrgRect.origin.y = temp_addImgViewOrgRect.origin.y + temp_addImgViewOrgRect.size.height;
    self.locationView.frame = temp_locationViewOrgRect;
    
    [self.locationView relayoutChildControlsWithLocation:self.editFeedEntity.locationDescription];
}
 */

-(void)relayoutChildView
{
    if (self.visibleViewHeight <= 0) {
        return;
    }
    //标题控件的高度不会变化

    //计算addimg的位置
    if ([self.titleTextView isFirstResponder] || [self.contentTextView isFirstResponder]) {
        [self.addImgView setIntrinsicSize:CGSizeMake(self.addImgView.frame.size.width, self.addImgViewHeightWithkeyboard)];
    }
    else{
        [self.addImgView setIntrinsicSize:CGSizeMake(self.addImgView.frame.size.width, 0)];
    }
    
    //内容控件高度会随着键盘和控件的高度变化
    CGFloat contentViewHeight = self.visibleViewHeight -self.addImgView.frame.size.height - self.locationView.frame.size.height - self.titleTextView.frame.size.height;
    if (contentViewHeight <= 0) {
        contentViewHeight = 0;
    }
    CGRect contentTextViewRC = self.contentTextView.frame;
    contentTextViewRC.size.height = contentViewHeight;
    self.contentTextView.frame = contentTextViewRC;
    
    CGRect addImgViewRC = self.addImgView.frame;
    addImgViewRC.origin.y = self.contentTextView.frame.origin.y +  self.contentTextView.frame.size.height;
    self.addImgView.frame = addImgViewRC;
    
    //计算locationview的位置
   CGRect locationViewRC =  self.locationView.frame;
    locationViewRC.origin.y =  self.addImgView.frame.origin.y +  self.addImgView.frame.size.height;
    self.locationView.frame = locationViewRC;
    
    [self.locationView relayoutChildControlsWithLocation:self.editFeedEntity.locationDescription];
}

//#endif

-(void)relayoutChildViewForBelowAddIMG
{
    [self.addImgView setIntrinsicSize:CGSizeMake(self.addImgView.frame.size.width, 0)];
    
    CGRect addImgViewRC = self.addImgView.frame;
    addImgViewRC.origin.y = self.contentTextView.frame.origin.y +  self.contentTextView.frame.size.height;
    self.addImgView.frame = addImgViewRC;
    
    //计算locationview的位置
    CGRect locationViewRC =  self.locationView.frame;
    locationViewRC.origin.y =  self.addImgView.frame.origin.y +  self.addImgView.frame.size.height;
    self.locationView.frame = locationViewRC;
    
    [self.locationView relayoutChildControlsWithLocation:self.editFeedEntity.locationDescription];
    
    //计算selectTopicView的位置
    CGRect selectTopicViewRC = self.selectTopicView.frame;
    selectTopicViewRC.origin.y = self.locationView.frame.origin.y + self.locationView.frame.size.height;
    self.selectTopicView.frame = selectTopicViewRC;
    
    UMComTopic* topic = (UMComTopic*)self.editFeedEntity.topics.firstObject;
    [self.selectTopicView relayoutChildControlsWithTopicName:topic.name];
    
    //设置backgroudScrollView的contentSize
    CGSize contentSize = self.backgroudScrollView.contentSize;
    contentSize.height = self.selectTopicView.frame.origin.y + self.selectTopicView.frame.size.height;
    self.backgroudScrollView.contentSize = contentSize;
}

#pragma mark -UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0://拍照
            [self takePhoto:nil];
            break;
        case 1://相册
            [self setUpPicker];
            break;
        case 2://取消
        {
            id object = objc_getAssociatedObject(actionSheet, g_ForumActionSheetWithFirstResponder);
            if (object && [object isKindOfClass:[UITextView class]]) {
                UITextView* textView = (UITextView*)object;
                [textView becomeFirstResponder];
            }
        }
            break;
        default:
            break;
    }
}

-(void) popActionSheetForAddImageView
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:UMComLocalizedString(@"um_com_selectImageSource",@"请选择图片源:")
                                                       delegate:self
                                              cancelButtonTitle:UMComLocalizedString(@"um_com_cancel", @"取消")
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:UMComLocalizedString(@"um_com_camera",@"拍照"),UMComLocalizedString(@"um_com_album", @"相册"),nil];
    
    
    
    id object = nil;
    if ([self.titleTextView isFirstResponder]) {
        object = self.titleTextView;
        [self.titleTextView resignFirstResponder];
        
    }
    else if ([self.contentTextView isFirstResponder]){
        object = self.contentTextView;
        [self.contentTextView resignFirstResponder];
    }
    //关联一个弱引用的对象
    objc_setAssociatedObject(sheet,g_ForumActionSheetWithFirstResponder,object,OBJC_ASSOCIATION_ASSIGN);
    [sheet showInView:self.view];
}

#pragma mark - 表情相关函数

-(void) createEmojiKeyboardView
{
    [self createEmojiKeyboardViewForTitleView];
    [self createEmojiKeyboardViewForContentView];
}

-(void) createEmojiKeyboardViewForTitleView
{
    if (!self.emojiKeyboardViewForTitleView) {
        //添加表情控件
        UMComEmojiKeyboardView *emojiKeyboardView = [[UMComEmojiKeyboardView alloc] initWithFrame:CGRectMake(0, 300, self.view.frame.size.width, 216) dataSource:nil];
        emojiKeyboardView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        emojiKeyboardView.delegate = self;
        self.emojiKeyboardViewForTitleView = emojiKeyboardView;
    }
}
-(void) createEmojiKeyboardViewForContentView
{
    if (!self.emojiKeyboardViewForContentView) {
        //添加表情控件
        UMComEmojiKeyboardView *emojiKeyboardView = [[UMComEmojiKeyboardView alloc] initWithFrame:CGRectMake(0, 300, self.view.frame.size.width, 216) dataSource:nil];
        emojiKeyboardView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        emojiKeyboardView.delegate = self;
        self.emojiKeyboardViewForContentView = emojiKeyboardView;
    }
}


-(void) showEmojiKeyboardViewWithTextView:(UITextView*)textview
{
    self.isClickEmoji = YES;
    if (textview == self.titleTextView) {
        //当是标题控件的时候
        if (self.titleTextView.inputView == nil) {
            self.titleTextView.inputView = self.emojiKeyboardViewForTitleView;
            [self.titleTextView resignFirstResponder];
            [self.titleTextView becomeFirstResponder];
            [self changeEmojiBtnImg:NO withTextView:self.titleTextView];
        } else {
            self.titleTextView.inputView = nil;
            [self.titleTextView resignFirstResponder];
            [self.titleTextView becomeFirstResponder];
            [self changeEmojiBtnImg:YES withTextView:self.titleTextView];
        }
    }
    else if (textview == self.contentTextView)
    {
        //当是内容控件
        if (self.contentTextView.inputView == nil) {
            self.contentTextView.inputView = self.emojiKeyboardViewForContentView;
            [self.contentTextView resignFirstResponder];
            [self.contentTextView becomeFirstResponder];
            [self changeEmojiBtnImg:NO withTextView:self.contentTextView];
        } else {
            self.contentTextView.inputView = nil;
            [self.contentTextView resignFirstResponder];
            [self.contentTextView becomeFirstResponder];
            [self changeEmojiBtnImg:YES withTextView:self.contentTextView];
        }
    }
    else{}
    self.isClickEmoji = NO;
    
}

-(void) changeEmojiBtnImg:(BOOL)isEmoji withTextView:(UITextView*)textview
{
    if (textview == self.titleTextView)
    {
        if (isEmoji) {
            //显示表情
            [self.emojiBtnForTitleView setBackgroundImage:UMComImageWithImageName(@"um_edit_emoji_normal") forState:UIControlStateNormal];
            [self.emojiBtnForContentView setBackgroundImage:UMComImageWithImageName(@"um_edit_emoji_highlight") forState:UIControlStateHighlighted];
        }
        else
        {
            //显示键盘
            [self.emojiBtnForTitleView  setBackgroundImage:UMComImageWithImageName(@"um_edit_keyboard_normal") forState:UIControlStateNormal];
            [self.emojiBtnForTitleView  setBackgroundImage:UMComImageWithImageName(@"um_edit_keyboard_highlight") forState:UIControlStateHighlighted];
        }
    }
    else if (textview == self.contentTextView)
    {
        if (isEmoji) {
            //显示表情
            [self.emojiBtnForContentView setBackgroundImage:UMComImageWithImageName(@"um_edit_emoji_normal") forState:UIControlStateNormal];
            [self.emojiBtnForContentView setBackgroundImage:UMComImageWithImageName(@"um_edit_emoji_highlight") forState:UIControlStateHighlighted];
        }
        else
        {
            //显示键盘
            [self.emojiBtnForContentView  setBackgroundImage:UMComImageWithImageName(@"um_edit_keyboard_normal") forState:UIControlStateNormal];
            [self.emojiBtnForContentView  setBackgroundImage:UMComImageWithImageName(@"um_edit_keyboard_highlight") forState:UIControlStateHighlighted];
        }
    }
    else{}
}

-(void)handleCloseKeyboardBtn:(UIButton*)target
{
    [self.titleTextView resignFirstResponder];
    [self.contentTextView resignFirstResponder];
}


-(void)handleBtnChangeEmojiBtnImgForTitleView:(UIButton*)target
{
    [self showEmojiKeyboardViewWithTextView:self.titleTextView];
}

-(void)handleBtnChangeEmojiBtnImgForContentView:(UIButton*)target
{
    [self showEmojiKeyboardViewWithTextView:self.contentTextView];
}


#pragma mark - UMComEmojiKeyboardViewDelegate


/**
 Delegate method called when user taps an emoji button
 
 @param emojiKeyBoardView EmojiKeyBoardView object on which user has tapped.
 
 @param emoji Emoji used by user
 */
- (void)emojiKeyBoardView:(UMComEmojiKeyboardView *)emojiKeyBoardView
              didUseEmoji:(NSString *)emoji
{
    if (emojiKeyBoardView == self.emojiKeyboardViewForTitleView)
    {
        [self appendEmoji:emoji withUITextView:self.titleTextView];
    }
    else if (emojiKeyBoardView == self.emojiKeyboardViewForContentView)
    {
        [self appendEmoji:emoji withUITextView:self.contentTextView];
    }
    else{}
}

-(void) appendEmoji:(NSString*)emoji withUITextView:(UMComEditTextView*)textview;
{
    if (!emoji  || !textview) {
        return;
    }
    
    NSRange orgRange = textview.selectedRange;
    
    NSRange rangeBefore;
    rangeBefore.location = 0;
    rangeBefore.length = orgRange.location;
    NSString* orgBefore = [textview.text substringWithRange:[textview.text rangeOfComposedCharacterSequencesForRange:rangeBefore]];
    
    NSRange rangeAfter;
    rangeAfter.location = rangeBefore.location + rangeBefore.length;
    if (orgBefore) {
        //直接
        rangeAfter.length = textview.text.length - orgBefore.length;
    }
    else
    {
        //如果用rangeBefore.length操作，可能会有问题
        rangeAfter.length = textview.text.length -  rangeBefore.length;
    }
    
    NSString* orgAfter = [textview.text substringWithRange:[textview.text rangeOfComposedCharacterSequencesForRange:rangeAfter]];
    
    NSUInteger resultLocation = 0;
    NSMutableString* resultString = [[NSMutableString alloc] initWithCapacity:10];
    if (orgBefore) {
        
        [resultString appendString:orgBefore];
        resultLocation += orgBefore.length;
    }
    
    if (emoji) {
        [resultString appendString:emoji];
        resultLocation += emoji.length;
    }
    
    if (orgAfter) {
        [resultString appendString:orgAfter];
    }
    
    if (![textview checkMaxLength:resultString]) {
        textview.text = resultString;
        textview.selectedRange = NSMakeRange(resultLocation, 0);
    }
}

/**
 Delegate method called when user taps on the backspace button
 
 @param emojiKeyBoardView EmojiKeyBoardView object on which user has tapped.
 */
- (void)emojiKeyBoardViewDidPressBackSpace:(UMComEmojiKeyboardView *)emojiKeyBoardView
{
    if (emojiKeyBoardView == self.emojiKeyboardViewForTitleView) {
        [self.titleTextView deleteBackward];
    }
    else if (emojiKeyBoardView == self.emojiKeyboardViewForContentView)
    {
        [self.contentTextView deleteBackward];
    }
    else{}
}

@end


