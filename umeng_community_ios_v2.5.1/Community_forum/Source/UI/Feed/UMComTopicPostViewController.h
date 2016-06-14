//
//  UMComTopicPostViewController.h
//  UMCommunity
//
//  Created by umeng on 12/2/15.
//  Copyright © 2015 Umeng. All rights reserved.
//

#import "UMComViewController.h"

@class UMComTopic;

/**
 *  选中单个话题的入口ViewController
 */
@interface UMComTopicPostViewController : UMComViewController

- (instancetype)initWithTopic:(UMComTopic *)topic;

@end
