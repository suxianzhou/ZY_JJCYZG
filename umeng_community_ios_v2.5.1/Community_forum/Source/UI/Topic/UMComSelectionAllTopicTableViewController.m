//
//  UMComSelectionAllTopicTableViewController.m
//  UMCommunity
//
//  Created by 张军华 on 16/3/29.
//  Copyright © 2016年 Umeng. All rights reserved.
//

#import "UMComSelectionAllTopicTableViewController.h"
#import "UMComPullRequest.h"
#import "UMComSelectionTopicTableViewCell.h"
#import "UMComTopic.h"


@interface UMComSelectionAllTopicTableViewController ()

@end

@implementation UMComSelectionAllTopicTableViewController

- (void)viewDidLoad {
    
    self.fetchRequest = [[UMComAllTopicsRequest alloc]initWithCount:BatchSize];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView.separatorColor = UMComColorWithColorValueString(@"EEEFF3");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource & tableViewDelegate
-(void) layoutCell:(UMComSelectionTopicTableViewCell*)cell cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (cell) {
        if (indexPath.row < self.dataArray.count) {
            UMComTopic *topic = self.dataArray[indexPath.row];
            if (topic) {
                static NSString* topicTemplate = @"#%@#";
                static NSString* topicDefault = nil;
                if (!topicDefault) {
                    NSString* temp_topicDefault = UMComLocalizedString(@"um_com_nullTopicName", @"话题内容为空");
                    topicDefault = temp_topicDefault;
                }
                NSString* labelText = nil;
                if (topic.name) {
                    labelText = [[NSString alloc] initWithFormat:topicTemplate,topic.name];
                }
                else{
                    labelText = [[NSString alloc] initWithFormat:topicTemplate,topicDefault];
                }
                cell.textLabel.text = labelText;
            }
            else
            {
                cell.textLabel.text = nil;
            }
        }
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *seletionCellReuseIdentifier = @"SelectionAllTopic_TopicTypeCellID";
    
    UMComSelectionTopicTableViewCell* cell = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:seletionCellReuseIdentifier];
    if (!cell) {
        cell = [[UMComSelectionTopicTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:seletionCellReuseIdentifier];
        
    }
    [self layoutCell:cell cellForRowAtIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (self.selectionTopicDelegate && [self.selectionTopicDelegate respondsToSelector:@selector(didSeletionTopic:error:)]) {
        UMComTopic *topic = self.dataArray[indexPath.row];
        [self.selectionTopicDelegate didSeletionTopic:topic error:nil];
    }
}



@end
