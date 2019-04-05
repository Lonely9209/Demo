//
//  UIImage+Color.h
//  WZBColorPickerViewDemo
//
//  Created by Lonely920 on 2019/3/28.
//  Copyright © 2019 Lonely920. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Color)

// 获取图片某一点的颜色
- (UIColor *)colorAtPixel:(CGPoint)point;

@end
