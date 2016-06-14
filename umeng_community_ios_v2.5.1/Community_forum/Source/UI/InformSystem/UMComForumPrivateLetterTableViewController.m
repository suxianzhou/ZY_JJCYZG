//
//  UMComPrivateLetterTableViewController.m
//  UMCommunity
//
//  Created by umeng on 15/11/30.
//  Copyright © 2015年 Umeng. All rights reserved.
//

#import "UMComForumPrivateLetterTableViewController.h"
#import "UMComImageView.h"
#import "UMComPullRequest.h"
#import "UMComSession.h"
#import "UMComUser+UMComManagedObject.h"
#import "UMComPrivateLetter.h"
#import "UMComPrivateMessage.h"
#import "UMComForumPrivateChatTableViewController.h"
#import "UMComUser+UMComManagedObject.h"
#import "UIViewController+UMComAddition.h"
#import "UMComImageUrl.h"
#import "UMComShowToast.h"
#import "UMComSysPrivateLetterCell.h"


#define UMCom_Forum_LetterList_Cell_Height 64
#define UMCom_Forum_LetterList_IconName_Space 10
#define UMCom_Forum_LetterList_Icon_TopEdge 10
#define UMCom_Forum_LetterList_Icon_LeftEdge 10
#define UMCom_Forum_LetterList_Name_TextFont 16
#define UMCom_Forum_LetterList_Name_TextColor @"#333333"
#define UMCom_Forum_LetterList_Message_TextFont 13
#define UMCom_Forum_LetterList_Message_TextColor @"#999999"
#define UMCom_Forum_LetterList_Date_TextFont 12
#define UMCom_Forum_LetterList_Date_TextColor @"#A5A5A5"
#define UMCom_Forum_LetterList_DateLabel_Width 100
#define UMCom_Forum_LetterList_RedDot_Diameter 20
#define UMCom_Forum_LetterList_RedDot_TextFont 11
#define UMCom_Forum_letterList_RedDot_TextColor @"#FFFFFF"
#define UMCom_Forum_letterList_CellItems_RightEdge 10


@interface UMComForumPrivateLetterTableViewController ()

@end

@implementation UMComForumPrivateLetterTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.rowHeight = UMCom_Forum_LetterList_Cell_Height;
    
    [self setForumUITitle:UMComLocalizedString(@"um_com_privateLetterTitle", @"私信管理员")];
    self.fetchRequest = [[UMComPrivateLetterRequest alloc]initWithCount:BatchSize];
    [self loadAllData:nil fromServer:^(NSArray *data, BOOL haveNextPage, NSError *error) {
    }];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cellID";
    UMComSysPrivateLetterCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UMComSysPrivateLetterCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID cellSize:CGSizeMake(tableView.frame.size.width, tableView.rowHeight)];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    [cell reloadCellWithPrivateLetter:self.dataArray[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UMComForumPrivateChatTableViewController *privateViewController = [[UMComForumPrivateChatTableViewController alloc]initWithPrivateLetter:self.dataArray[indexPath.row]];//
    [self.navigationController pushViewController:privateViewController animated:YES];
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
