//
//  WZBTitleBGScrollerView.h
//  WZBTitleBGScrollerView
//
//  Created by Lonely920 on 2018/11/30.
//  Copyright © 2018 Lonely920. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WZBTitleBGScrollerView;

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0 blue:((float)(rgbValue & 0xFF)) / 255.0 alpha:1.0]
#define UIColorFromRGBA(rgbValue, Alpha) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0 blue:((float)(rgbValue & 0xFF)) / 255.0 alpha:Alpha]

typedef enum : NSUInteger {
    WZBFixedType = 1,   // 行固定Item数，每行Item数固定
    WZBCompactType,     // 紧凑型，固定间隔
} WZBShowType;

@protocol WZBTitleBGScrollerViewDelegate <NSObject>


/**
 点击某个Item

 @param bgScrollerView WZBTitleBGScrollerView
 @param selIndex 选中下标
 */
- (void)titleBGScrollerView:(WZBTitleBGScrollerView *)bgScrollerView didSelectIndex:(NSInteger)selIndex;

@end

@interface WZBTitleBGScrollerView : UIScrollView
/** 代理 */
@property (nonatomic, weak) id<WZBTitleBGScrollerViewDelegate> titleDelegate;
/** 数据源 */
@property (nonatomic, strong) NSArray <NSString *> *dataArray;
/** 展示类型 (设置类型后itemMargin将会重置，需要的话请之后设置) */
@property (nonatomic, assign) WZBShowType showType;
/** 每行固定Item数(仅WZBFixedType模式下有效),当数据源小于此数，以数据源个数为准，即保证数据源铺满整行 */
@property (nonatomic, assign) NSInteger lineItemCount;  // default 3
/** Item间隔 (WZBFixedType default 0; WZBCompactType default 15) */
@property (nonatomic, assign) CGFloat itemMargin;

/** NorColor */
@property (nonatomic, strong) UIColor *norColor;
/** SelColor */
@property (nonatomic, strong) UIColor *selColor;

/** 当前选中下标 */
@property (nonatomic, assign, readonly) NSInteger selIndex;
/** 是否滚动到中心位置 */
@property (nonatomic, assign) BOOL scrollsToCenter; // default YES
/** 是否动画 */
@property (nonatomic, assign, getter=isAnimation) BOOL animation; // default YES
/** 是否隐藏下划线 */
@property (nonatomic, assign, getter=isHideUnderLineView) BOOL hideUnderLineView; // default NO
/** 是否支持重复点击 */
@property (nonatomic, assign, getter=isSupportReplaceClick) BOOL supportReplaceClick; // default NO
/** WZBFixedType类型Font是否自适应 default:YES */
@property (nonatomic, assign) BOOL autoAdjustFontToFit;

/**
 创建WZBTitleBGScrollerView,选中下标/Item普通/选中颜色均为默认值

 @param frame WZBTitleBGScrollerView的Frame
 @param dataArray 数据源
 @param titleDelegate 代理
 @return WZBTitleBGScrollerView
 */
+ (instancetype)titleBGScrollerViewWithFrame:(CGRect)frame
                                   dataArray:(NSArray *)dataArray
                               titleDelegate:(id)titleDelegate;


/**
 创建WZBTitleBGScrollerView,Item普通/选中颜色均为默认值,选中下标为参数可自行设置

 @param frame WZBTitleBGScrollerView的Frame
 @param dataArray 数据源
 @param titleDelegate 代理
 @param defIndex 默认选中下标
 @return WZBTitleBGScrollerView
 */
+ (instancetype)titleBGScrollerViewWithFrame:(CGRect)frame
                                   dataArray:(NSArray *)dataArray
                               titleDelegate:(id)titleDelegate
                                    defIndex:(NSInteger)defIndex;


/**
 创建WZBTitleBGScrollerView,选中下标/Item普通/选中颜色均可自行设置

 @param frame WZBTitleBGScrollerView的Frame
 @param dataArray 数据源
 @param norColor Item普通状态下颜色
 @param selColor Item选中状态下颜色
 @param titleDelegate 代理
 @param defIndex 默认选中下标
 @return WZBTitleBGScrollerView
 */
+ (instancetype)titleBGScrollerViewWithFrame:(CGRect)frame
                                   dataArray:(NSArray *)dataArray
                                    norColor:(UIColor *)norColor
                                    selColor:(UIColor *)selColor
                               titleDelegate:(id)titleDelegate
                                    defIndex:(NSInteger)defIndex;

@end
