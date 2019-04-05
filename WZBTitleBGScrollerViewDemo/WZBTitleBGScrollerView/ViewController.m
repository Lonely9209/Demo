//
//  ViewController.m
//  WZBTitleBGScrollerView
//
//  Created by Lonely920 on 2018/11/30.
//  Copyright © 2018 Lonely920. All rights reserved.
//

#import "ViewController.h"
#import "WZBTitleBGScrollerView.h"

@interface ViewController ()<WZBTitleBGScrollerViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    WZBTitleBGScrollerView *scrollerView = [WZBTitleBGScrollerView titleBGScrollerViewWithFrame:CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, 100) dataArray:@[@"第一一一一一一天", @"第二二二二二二二天", @"第三天", @"第四天", @"第五天", @"第六天", @"第七天", @"第八天", @"第九天", @"第十天", @"第十一天"] titleDelegate:self defIndex:0];
    scrollerView.contentInset = UIEdgeInsetsMake(20, 20, 40, 20);
    [self.view addSubview:scrollerView];
    scrollerView.showType = WZBCompactType;
    scrollerView.itemMargin = 5;
    scrollerView.showType = WZBFixedType;
    scrollerView.lineItemCount = 4;
    scrollerView.itemMargin = 20;
}

- (void)titleBGScrollerView:(WZBTitleBGScrollerView *)bgScrollerView didSelectIndex:(NSInteger)selIndex {
    NSLog(@"点击了----第%@天", @(selIndex + 1));
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
