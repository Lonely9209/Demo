//
//  WZBColorPickerView.h
//  WZBColorPickerViewDemo
//
//  Created by Lonely920 on 2019/3/28.
//  Copyright © 2019 Lonely920. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WZBColorPickerView;

struct HSV {
    // 色调(0-1，从右侧红色逆时针弧度值，需 * M_PI)
    CGFloat hu;
    // 饱和度
    CGFloat sa;
    // 明亮度
    CGFloat br;
    // 透明度
    CGFloat al;
};
typedef struct HSV HSV;

struct RGB {
    CGFloat R;
    CGFloat G;
    CGFloat B;
    CGFloat A;
};
typedef struct RGB RGB;

typedef NS_ENUM(NSUInteger, WZBColorStyle) {
    WZBColorStyleColorRing,             // 色彩环
    WZBColorStyleColorPan,              // 色彩盘
    WZBColorStyleColorTemperature,      // 色温环
};

typedef NS_ENUM(NSUInteger, WZBColorTemperatureDirection) {
    WZBColorTemperatureLeft,    // 左侧
    WZBColorTemperatureRight    // 右侧
};

typedef NS_ENUM(NSUInteger, WZBPickerViewResponseAreas) {
    WZBPickerViewResponseAreasInner     = (1 << 0), // 内圆区域
    WZBPickerViewResponseAreasCenter    = (1 << 1), // 圆环区域
    WZBPickerViewResponseAreasOuter     = (1 << 2), // 外圆以外
};

@protocol WZBColorPickerViewDelegate

@optional

// 取色值改变调用
- (void)pickerView:(WZBColorPickerView *)pickerView didChangeColor:(UIColor *)color;
// 取色结束调用
- (void)pickerView:(WZBColorPickerView *)pickerView didEndPickerColor:(UIColor *)color;

// 取色温值改变调用
- (void)pickerView:(WZBColorPickerView *)pickerView didChangeColorTemperature:(CGFloat)colorTemperature;
// 取色温结束调用
- (void)pickerView:(WZBColorPickerView *)pickerView didEndPickerColorTemperature:(CGFloat)colorTemperature;

@end

@interface WZBColorPickerView : UIImageView
/** WZBColorPickerViewDelegate */
@property (nonatomic, weak) id delegate;
/** 取色(温)器样式 */
@property (nonatomic, assign, readonly) WZBColorStyle colorStyle;
/** 可点击区域 */
@property (nonatomic, assign) WZBPickerViewResponseAreas areas;
/** MoveView移动时的是否放大(default:YES) */
@property (nonatomic, assign, getter=isSupportZoomScale) BOOL supportZoomScale;

+ (instancetype)pickerViewWithFrame:(CGRect)frame colorStyle:(WZBColorStyle)colorStyle;

/**
 配置PickerView可点击区域

 @param areas 可点击区域
 @param innerRate 内圆半径占半宽比率
 @param outerRate 外圆半径占半宽比率
 @param centerRate 图片中心半径占半宽比率（圆环的内外圆中心）
 */
- (void)configPickerViewResponseAreas:(WZBPickerViewResponseAreas)areas
                            innerRate:(CGFloat)innerRate
                            outerRate:(CGFloat)outerRate
                           centerRate:(CGFloat)centerRate;

/**
 配置小圆圈View的宽度比率

 @param moveViewWRate 宽度比率(占整个View宽度比率)
 @param borderWidth 边框宽度默认：2
 */
- (void)configMoveViewWidthRate:(CGFloat)moveViewWRate borderWidth:(CGFloat)borderWidth;

/**
 配置小圆圈View的宽度比率及移动时的放大系数

 @param moveViewWRate 宽度比率(占整个View宽度比率)
 @param borderWidth 边框宽度默认：2
 @param zoomScale 移动时的放大系数(需设置supportZoomScale为YES)
 */
- (void)configMoveViewWidthRate:(CGFloat)moveViewWRate borderWidth:(CGFloat)borderWidth zoomScale:(CGFloat)zoomScale;

/**
 配置色温最大/小值

 @param minColorTemperature 色温最小值
 @param maxColorTemperature 色温最大值
 @param isUpBig YES:上大下小(默认NO)
 */
- (void)configMinColorTemperature:(CGFloat)minColorTemperature
              maxColorTemperature:(CGFloat)maxColorTemperature
                          isUpBig:(BOOL)isUpBig;

/**
 设置选中颜色

 @param color 选中颜色
 @param isAnimation 是否动画
 */
- (void)setColor:(UIColor *)color isAnimation:(BOOL)isAnimation;

/**
 设置选中色温值

 @param colorTemperature 选中色温值
 @param direction 选中色温值方向
 @param isAnimation 是否动画
 */
- (void)setColorTemperature:(CGFloat)colorTemperature
                  direction:(WZBColorTemperatureDirection)direction
                isAnimation:(BOOL)isAnimation;
@end
