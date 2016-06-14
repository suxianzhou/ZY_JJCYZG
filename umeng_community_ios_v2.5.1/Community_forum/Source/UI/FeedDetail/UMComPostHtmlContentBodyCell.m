//
//  UMComPostHtmlContentBodyCell.m
//  UMCommunity
//
//  Created by 张军华 on 16/3/23.
//  Copyright © 2016年 Umeng. All rights reserved.
//

#import "UMComPostHtmlContentBodyCell.h"
#import "UMComWebView.h"
#import "UMComImageView.h"
#import "UMComTools.h"
#import "UMComFeed.h"
#import "UMComFeed+UMComManagedObject.h"
#import "UMComLocationModel.h"
#import "UMComTopic.h"
#import "UMComUser.h"
#import "UMComForumUserCenterViewController.h"

#define UMCom_Forum_Feed_WebViewDefaultHeight 0 //webView的默认高度
#define UMComScaleX 1
#define UMComPostPad 10
#define UMComPostOriginX (10 * UMComScaleX)

#define UMCom_Forum_Feed_LocationCollor @"#A5A5A5"//feed位置的颜色

#define UMCom_Forum_Feed_LocationNameMaxWidth 60
#define UMCom_Forum_Feed_LocationNameMaxHeight 15

#define UMCom_Forum_Feed_SpaceBetweenLocationNameAndIMG 2 //水平方向地理位置和图片的间距

#define UMCom_Forum_Feed_LocationIMGWidth 10
#define UMCom_Forum_Feed_LocationIMGHeight 15

@interface UMComPostHtmlContentBodyCell ()<UMComWebViewDelegate>

-(void) createWebView;
-(void) createloacationIMG;
-(void) createloacationName;
-(void) layoutLocationIMGAndName;

@property(nonatomic,readwrite ,assign)CGFloat headerHeight;//body上半部分标题的的高度
@property(nonatomic,readwrite ,assign)CGFloat userInfoHeight;//body上半部分头像的高度
@property(nonatomic,readwrite,assign)CGFloat webviewHeight;//body中间部分的高度
@property(nonatomic,readwrite,assign)CGFloat footerrHeight;//body下半部分部分的高度
@property(nonatomic,readwrite,assign)CGFloat totalHeight;//body的总高度

@end

@implementation UMComPostHtmlContentBodyCell

#pragma mark - overide method
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self createWebView];
        [self createloacationIMG];
        [self createloacationName];
    }
    return self;
}

- (CGFloat)refreshHeaderLayout
{
    CGFloat headerHeight = 0;
    headerHeight = [super refreshHeaderLayout];
    self.headerHeight = headerHeight;
    //布局locationde 位置（需要通过self.headerHeight的高度来布局location的位置）
    [self layoutLocationIMGAndName];
    return headerHeight;
}

- (CGFloat)refreshUserInfoBar
{
    CGFloat userInfoHeight = 0;
    userInfoHeight = [super refreshUserInfoBar];
    self.userInfoHeight = userInfoHeight;
    return userInfoHeight;
}

- (CGFloat)refreshImageLayout
{
    //由webview控件替代
    return 0.f;
}

- (CGFloat)refreshBodyWithMutiText:(UMComMutiText *)textObj
{
    
    UMComFeed *feed = self.feed;
    if (feed) {
        NSString* orginRichText = feed.rich_text;
        if (!orginRichText) {
            orginRichText = @"<html>                     \
            <head>  \
            </head> \
            <body>                           \
            <p>内容为空。</p>            \
            </body>                     \
            </html>                     \
            ";
        }
        
        NSString* htmlString = nil;
        if (![orginRichText hasPrefix:@"<html>"] || ![orginRichText hasSuffix:@"</html>"]) {
            NSMutableString* realRichText =  [NSMutableString stringWithCapacity:10];
            
            [realRichText appendString:@"<html><head></head><body>"];
            [realRichText appendString:orginRichText];
            [realRichText appendString:@"</body></html>"];
            htmlString = realRichText;
        }
        else
        {
            htmlString = orginRichText;
        }
        
        
        //test1
        /*
         htmlString = @"<html>                     \
         <head>  \
         <script type=\"text/javascript\"> \
         function disp_alert()           \
         {                           \
         alert(\"我是警告框！！\") \
         }                               \
         </script>   \
         </head> \
         <body>                      \
         <p>这是段落1。</p>            \
         <p>这是段落2。</p>            \
         \
         <input type=\"button\" onclick=\"disp_alert()\" value=\"显示警告框\" /> \
         <p>这是段落3。</p>            \
         \
         <img src=\"http://img.ivsky.com/img/tupian/t/201512/11/weimei_hongye-001.jpg\" />                                   \
         <p>这是段落4是大图，显示不了。</p>\
         <img src=\"http://p3.so.qhimg.com/t0180d87c6f3cdccaa8.jpg\" /> \
         <p>这是段落5是大图，壁纸。</p>    \
         <img src=\"http://pics.sc.chinaz.com/files/pic/pic9/201602/apic18885.jpg\"> \
         <p>这是段落5。</p> \
         <img src=\"http://n.sinaimg.cn/news/20160308/BAgi-fxqafha0461772.jpg\" /> \
         <p>这是淘宝网。</p> \
         <a href=\"https://www.taobao.com\">淘宝网站</a> \
         <p>这是优酷。</p> \
         <a href =\"http://www.youku.com\">优酷</a> \
         <p>段落元素由 p 标签定义。</p> \
         </body>                     \
         </html>                     \
         ";
         */
        
        NSError* error;
        [self.webView loadHTMLString:htmlString baseURL:nil error:&error];
        if (error) {
        }
    }
    else{}

    //NSLog(@"self.cellHeight>>>before:%lu",(unsigned long)self.cellHeight);
    CGRect frame = self.webView.frame;
    frame.origin = CGPointMake(self.drawOriginX, self.cellHeight);
    frame.size = self.webView.frame.size;
    frame.size.width = self.contentView.bounds.size.width - UMComPostOriginX*2;
    self.webView.frame = frame;
    self.cellHeight += self.webView.frame.size.height + UMComPostPad * 1.5;
    //NSLog(@"self.cellHeight>>>after:%lu self.webView:%f:%f",(unsigned long)self.cellHeight,self.webView.frame.size.width,self.webView.frame.size.height);
    
    CGFloat bodyHeight = self.webView.frame.size.height + UMComPostPad * 1.5;
    self.webviewHeight = bodyHeight;
    return bodyHeight;
}

- (CGFloat)refreshFooterLayout
{
    CGFloat footerHeight = 0;
    footerHeight = [super refreshFooterLayout];
    self.footerrHeight = footerHeight;
    return footerHeight;
}


#pragma mark - private method
-(void)createWebView
{
    self.webView = [[UMComWebView alloc]initWithFrame:CGRectMake(UMComPostOriginX, 0, self.bounds.size.width - UMComPostOriginX*2, UMCom_Forum_Feed_WebViewDefaultHeight)];
    
    self.webView.UMComWebViewDelegate = self;
    [self.contentView addSubview:self.webView];
}

-(void) createloacationIMG
{
    self.loacationIMG = [[UMComImageView alloc] init];
    self.loacationIMG.contentMode = UIViewContentModeScaleAspectFit;
    self.loacationIMG.image = UMComImageWithImageName(@"um_forum_location");
    self.loacationIMG.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:self.loacationIMG];
}

-(void) createloacationName
{
    self.loacationName = [[UILabel alloc] init];
    self.loacationName.font = UMComFontNotoSansLightWithSafeSize(14);
    self.loacationName.textColor = UMComColorWithColorValueString(UMCom_Forum_Feed_LocationCollor);
    [self.contentView addSubview:self.loacationName];
}

-(void) layoutLocationIMGAndName
{
    //布局location
    NSString* locationName = self.feed.locationModel.name;
    if (!locationName) {
        locationName = @"";
        self.loacationName.text = locationName;
        self.loacationIMG.hidden = YES;
        self.loacationName.hidden = YES;
    }
    else
    {
        self.loacationIMG.hidden = NO;
        self.loacationName.hidden = NO;
        CGSize textSize = [locationName sizeWithFont:self.loacationName.font];
        CGFloat MaxLocationNameWidth =[UIScreen mainScreen].bounds.size.width -(UMCom_Forum_Feed_LocationIMGWidth  +  UMComPostOriginX*2);
        if (textSize.width > MaxLocationNameWidth) {
            textSize.width = MaxLocationNameWidth;
        }
//        if (textSize.width > UMCom_Forum_Feed_LocationNameMaxWidth) {
//            textSize.width = UMCom_Forum_Feed_LocationNameMaxWidth;
//        }
        
        //此处self.headerHeight的高度，在基类加了两次UMComPostPad,所以需要减去两次才能得到location的orginy
        self.loacationName.frame = CGRectMake(self.contentView.bounds.size.width - textSize.width - UMComPostOriginX,self.headerHeight - UMCom_Forum_Feed_LocationNameMaxHeight - UMComPostPad*2  , textSize.width, UMCom_Forum_Feed_LocationNameMaxHeight);
        
        self.loacationName.text = locationName;
        
        self.loacationIMG.frame = CGRectMake(self.loacationName.frame.origin.x -UMCom_Forum_Feed_LocationIMGWidth -UMCom_Forum_Feed_SpaceBetweenLocationNameAndIMG,self.headerHeight - UMCom_Forum_Feed_LocationNameMaxHeight - UMComPostPad*2,UMCom_Forum_Feed_LocationIMGWidth,UMCom_Forum_Feed_LocationIMGHeight);
    }
}


#pragma mark - UMComWebViewDelegate

-(void) adjustCellWithWebviewLoadingFinish
{
    CGRect result_webViewframe = CGRectZero;
    CGRect org_webViewframe = self.webView.frame;
    
    CGRect frame = self.webView.frame;
    frame.size.height = 1;
    self.webView.frame = frame;
    
    //设置webview的范围
    CGSize fittingSize = [self.webView sizeThatFits:CGSizeZero];
    NSInteger height = [[self.webView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight"] integerValue];
    CGSize webviewContentSize = self.webView.scrollView.contentSize;
    //NSLog(@"fittingSize = %f:%f,webviewContentSize= %f:%f",fittingSize.width,fittingSize.height,webviewContentSize.width,webviewContentSize.height);

    result_webViewframe.size = fittingSize;
    result_webViewframe.origin = org_webViewframe.origin;
    self.webView.frame = result_webViewframe;
    //设置其不能滑动
    self.webView.scrollView.scrollEnabled = NO;
    
    self.webView.fullHeight = result_webViewframe.size.height;
    self.webviewHeight = result_webViewframe.size.height;
    
    self.totalHeight = self.headerHeight + self.userInfoHeight + self.webView.fullHeight + UMComPostPad * 1.5 + self.footerrHeight;//此处webview的高度还需要加入UMComPostPad * 1.5的间距
    
    //设置父窗口的范围
    CGRect contentViewFrame = self.contentView.frame;
    CGFloat contentViewHeight =  self.totalHeight;
    contentViewFrame.size.height = contentViewHeight;
    self.contentView.frame = contentViewFrame;
    
    CGRect cellFrame = self.frame;
    cellFrame.size.height = contentViewHeight + 1;
    self.frame = cellFrame;
}

- (void)UMComWebViewDidFinishLoad:(UIWebView *)webView
{
    [self adjustCellWithWebviewLoadingFinish];
    
    if (self.UMComHtmlBodyCellDelegate && [self.UMComHtmlBodyCellDelegate respondsToSelector:@selector(UMComHtmlBodyCellDidFinishLoad:)]) {
        [self.UMComHtmlBodyCellDelegate UMComHtmlBodyCellDidFinishLoad:self];
    }
}

- (void)UMComWebView:(UIWebView *)webView didFailLoadWithError:(nullable NSError *)error
{
    UIAlertView *alterview = [[UIAlertView alloc] initWithTitle:@"" message:[error localizedDescription]  delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alterview show];
}

- (BOOL)UMComWebView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString* hrefString =  request.URL.absoluteString;
    
    //论坛版本详情的点击事件，如果需要在此处处理
    //解析成字典类型
    NSDictionary* dic =  [UMComTools parseWebViewRequestString:hrefString];
    //通过字典类型的数据（topic_id 或者 uuid）判断跳转指定的话题还是指定的用户的个人中心
    NSString* topicID  = dic[@"topic_id"];
    NSString* uuid = dic[@"user_id"];
    if (topicID) {
        //根据topicID获得UMComTopic
        //topicID = @"56850244fe2cac0819fce1e6";//测试代码
        UMComTopic* umComTopic = [UMComTopic objectWithObjectId:topicID];
        if (umComTopic && self.UMComHtmlBodyCellDelegate && [self.UMComHtmlBodyCellDelegate respondsToSelector:@selector(handleClickCell:withDataObject:userInfo:)]) {
            [self.UMComHtmlBodyCellDelegate handleClickCell:self withDataObject:umComTopic userInfo:nil];
        }
    }
    else if (uuid){
        //根据uuid获得UMComUser
        //uuid = @"54c202db0bbbafc1d75e7553";//测试代码
        UMComUser* user = [UMComUser objectWithObjectId:uuid];
        if (user && self.UMComHtmlBodyCellDelegate && [self.UMComHtmlBodyCellDelegate respondsToSelector:@selector(handleClickCell:withDataObject:userInfo:)]) {
            [self.UMComHtmlBodyCellDelegate handleClickCell:self withDataObject:user userInfo:nil];
        }
    }
    else if(navigationType == UIWebViewNavigationTypeLinkClicked){
        if (self.UMComHtmlBodyCellDelegate && [self.UMComHtmlBodyCellDelegate respondsToSelector:@selector(handleClickCell:withDataObject:userInfo:)])
        {
            [self.UMComHtmlBodyCellDelegate handleClickCell:self withDataObject:request userInfo:nil];
        }
    }
    else{}
    
    return NO;
}

@end
