//
//  UMComSelectionTopicDelegate.h
//  UMCommunity
//
//  Created by 张军华 on 16/3/29.
//  Copyright © 2016年 Umeng. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UMComTopic;
/**
 *  选择话题的代理
 */
@protocol UMComSelectionTopicDelegate <NSObject>

@optional
-(void) didSeletionTopic:(UMComTopic*)topic error:(NSError*)error;

@end
