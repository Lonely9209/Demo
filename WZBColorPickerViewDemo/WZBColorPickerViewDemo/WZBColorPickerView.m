//
//  WZBColorPickerView.m
//  WZBColorPickerViewDemo
//
//  Created by Lonely920 on 2019/3/28.
//  Copyright © 2019 Lonely920. All rights reserved.
//

#import "WZBColorPickerView.h"
#import "UIImage+Color.h"

// moveView默认宽度比率
#define MoveViewWidthRate 0.125
// moveView移动时默认放大系数
#define MoveViewZoomScale 1.2
// moveView默认边框宽度
#define MoveViewBorderWidth 2
// 内圆半径比率（占半宽）
#define InnerRingRate 0.5
// 内圆半径比率（占半宽）
#define OuterRingRate 1.0
// 色温默认最小值
#define ColorTemperatureMinValue 2000
// 色温默认最大值
#define ColorTemperatureMaxValue 5000
// ImageView中点
#define CenterP CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame) / 2)

static NSString *AnimationKey = @"MoveViewAnimation";

@interface WZBColorPickerView () <CAAnimationDelegate>
{
    // 最小色温值
    CGFloat m_minColorTemperature;
    // 最大色温值
    CGFloat m_maxColorTemperature;
    // 内圆半径
    CGFloat m_innerR;
    // 外圆半径
    CGFloat m_outerR;
    // 圆环中心圆半径，当为色盘时为接受，色盘上显示范围最大的圆半径
    CGFloat m_centerR;
    // 小圆圈View的宽度
    CGFloat m_moveViewW;
    // 小圆圈View边框宽度
    CGFloat m_moveViewBorderW;
    // moveView移动时放大系数
    CGFloat m_moveViewZoomScale;
}
/** 取色(温)器样式 */
@property (nonatomic, assign) WZBColorStyle colorStyle;
/** 移动小圆圈 */
@property (nonatomic, strong) UIView *moveView;
/** 色温值显示Label */
@property (nonatomic, strong) UILabel *cctLabel;
/** 内圆 */
@property (nonatomic, strong) UIBezierPath *innerRing;
/** 外圆 */
@property (nonatomic, strong) UIBezierPath *outerRing;
/** 当前所选Color */
@property (nonatomic, strong) UIColor *selColor;
/** 当前所选色温 */
@property (nonatomic, assign) CGFloat selColorTemperature;
/** 所选色温值方向 */
@property (nonatomic, assign) WZBColorTemperatureDirection direction;
/** 色温模式是否上大下小 */
@property (nonatomic, assign) BOOL isUpBig;
/** MoveView是否缩放 */
@property (nonatomic, assign) BOOL isZoom;
@end

@implementation WZBColorPickerView

+ (instancetype)pickerViewWithFrame:(CGRect)frame colorStyle:(WZBColorStyle)colorStyle {
    WZBColorPickerView *pickerView = [[WZBColorPickerView alloc] initWithFrame:frame];
    pickerView.colorStyle = colorStyle;
    pickerView.userInteractionEnabled = YES;
    pickerView.supportZoomScale = YES;
    return pickerView;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (_moveView) {
        CGFloat moveViewW = self.isZoom ? m_moveViewW * m_moveViewZoomScale : m_moveViewW;
        CGPoint center = self.moveView.center;
        CGRect frame = self.moveView.frame;
        frame.size = CGSizeMake(moveViewW, moveViewW);
        self.moveView.frame = frame;
        self.moveView.center = center;
        self.moveView.layer.cornerRadius = moveViewW / 2;
    }
}

// 初始化相关配置信息
- (void)setupConfigData {
    if (self.colorStyle == WZBColorStyleColorPan) {
        // 默认整个点击区域
        [self configPickerViewResponseAreas:WZBPickerViewResponseAreasInner | WZBPickerViewResponseAreasCenter | WZBPickerViewResponseAreasOuter
                                  innerRate:0
                                  outerRate:OuterRingRate
                                 centerRate:OuterRingRate];
    } else {
        // 默认圆环区域(centerRate根据实际需要设置)
        [self configPickerViewResponseAreas:WZBPickerViewResponseAreasCenter
                                  innerRate:InnerRingRate
                                  outerRate:OuterRingRate
                                 centerRate:0.94];
        if (self.colorStyle == WZBColorStyleColorTemperature) {
            [self configMinColorTemperature:ColorTemperatureMinValue
                        maxColorTemperature:ColorTemperatureMaxValue
                                    isUpBig:NO];
        }
    }
    [self configMoveViewWidthRate:MoveViewWidthRate borderWidth:MoveViewBorderWidth zoomScale:MoveViewZoomScale];
}

#pragma mark - Public
// 配置PickerView可点击区域
- (void)configPickerViewResponseAreas:(WZBPickerViewResponseAreas)areas
                            innerRate:(CGFloat)innerRate
                            outerRate:(CGFloat)outerRate
                           centerRate:(CGFloat)centerRate {
    self.areas = areas;
    m_innerR = (CGRectGetWidth(self.frame) / 2) * innerRate;
    m_outerR = (CGRectGetWidth(self.frame) / 2) * outerRate;
    m_centerR = (CGRectGetWidth(self.frame) / 2) * centerRate;
}

// 配置小圆圈View的宽度比率
- (void)configMoveViewWidthRate:(CGFloat)moveViewWRate borderWidth:(CGFloat)borderWidth {
    m_moveViewW = CGRectGetWidth(self.frame) * moveViewWRate;
    m_moveViewBorderW = borderWidth;
}

// 配置小圆圈View的宽度比率及移动时的放大系数
- (void)configMoveViewWidthRate:(CGFloat)moveViewWRate borderWidth:(CGFloat)borderWidth zoomScale:(CGFloat)zoomScale {
    m_moveViewZoomScale = zoomScale;
    [self configMoveViewWidthRate:moveViewWRate borderWidth:borderWidth];
}

// 配置色温最大/小值
- (void)configMinColorTemperature:(CGFloat)minColorTemperature
              maxColorTemperature:(CGFloat)maxColorTemperature
                          isUpBig:(BOOL)isUpBig {
    if (self.colorStyle != WZBColorStyleColorTemperature) {
        // 样式不匹配
        return ;
    }
    m_minColorTemperature = minColorTemperature;
    m_maxColorTemperature = maxColorTemperature;
    self.isUpBig = isUpBig;
}

// 设置选中颜色
- (void)setColor:(UIColor *)color isAnimation:(BOOL)isAnimation {
    if (self.colorStyle == WZBColorStyleColorTemperature) {
        // 样式不匹配
        return ;
    }
    // 添加动画前确保已移除动画
    [self removewAnimationFromMoveView];
    // 根据Color计算弧度
    HSV hsv;
    [color getHue:&hsv.hu saturation:&hsv.sa brightness:&hsv.br alpha:&hsv.al];
    CGFloat angle = hsv.hu * 2 * M_PI;
    CGFloat scale = (self.colorStyle == WZBColorStyleColorPan) ? hsv.sa : 1;

    if (isAnimation && self.colorStyle == WZBColorStyleColorRing) {
        // 目前色环支持动画
        CGFloat startAngle = [self getAngleFromPoint:self.moveView.center];
        [self startAnimationWithStartAngle:startAngle endAngle:angle];
        return ;
    }

    if (angle < M_PI_2) {
        // 第一象限
        self.moveView.center = CGPointMake(CenterP.x + m_centerR * cos(angle) * scale, CenterP.y - m_centerR * sin(angle) * scale);
    } else if (angle < M_PI) {
        // 第二象限
        self.moveView.center = CGPointMake(CenterP.x - m_centerR * cos(M_PI - angle) * scale, CenterP.y - m_centerR * sin(M_PI - angle) * scale);
    } else if (angle < M_PI_2 * 3) {
        // 第三象限
        self.moveView.center = CGPointMake(CenterP.x - m_centerR * cos(angle - M_PI) * scale, CenterP.y + m_centerR * sin(angle - M_PI) * scale);
    } else if (angle < M_PI * 2) {
        // 第四象限
        self.moveView.center = CGPointMake(CenterP.x + m_centerR * cos(2 * M_PI - angle) * scale, CenterP.y + m_centerR * sin(2 * M_PI - angle) * scale);
    }
    [self getCurrentColor];
}

// 设置选中色温值
- (void)setColorTemperature:(CGFloat)colorTemperature
                  direction:(WZBColorTemperatureDirection)direction
                isAnimation:(BOOL)isAnimation {
    if (self.colorStyle != WZBColorStyleColorTemperature) {
        // 样式不匹配
        return ;
    }
    // 移除动画
    [self removewAnimationFromMoveView];
    // 有效性校验
    colorTemperature = MAX(m_minColorTemperature, MIN(m_maxColorTemperature, colorTemperature));
    // 根据色温值计算弧度值
    self.selColorTemperature = floor(colorTemperature);
    CGFloat angle =  [self getAngleFromColorTemperature:self.selColorTemperature];

    if (isAnimation) {
        CGFloat startAngle = [self getAngleFromPoint:self.moveView.center];
        [self startAnimationWithStartAngle:startAngle endAngle:[self getStandardAngleFromColorTemperatureAngle:angle direction:direction]];
        return ;
    }

    if (direction == WZBColorTemperatureLeft) {
        if (angle < M_PI_2) {
            // 第二象限
            self.moveView.center = CGPointMake(CenterP.x - m_centerR * sin(angle), CenterP.y - m_centerR * cos(angle));
        } else {
            // 第三象限
            self.moveView.center = CGPointMake(CenterP.x - m_centerR * sin(M_PI - angle), CenterP.y + m_centerR * cos(M_PI - angle));
        }
    } else {
        if (angle < M_PI_2) {
            // 第一象限
            self.moveView.center = CGPointMake(CenterP.x + m_centerR * sin(angle), CenterP.y - m_centerR * cos(angle));
        } else {
            // 第四象限
            self.moveView.center = CGPointMake(CenterP.x + m_centerR * sin(M_PI - angle), CenterP.y + m_centerR * cos(M_PI - angle));
        }
    }
    self.direction = direction;
    [self getCurrentColor];
}

#pragma mark - 动画
- (void)startAnimationWithStartAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle {
    // 计算移动方向（逆/顺时针）
    BOOL clockWise = NO;
    CGFloat marginAngle = fabs(startAngle - endAngle);
    if (startAngle > endAngle) {
        clockWise = marginAngle < M_PI;
    } else {
        clockWise = marginAngle > M_PI;
    }
    // 此数Path的角度按照顺时针，而上面的角度都是逆时针方向，所以需要转换下
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CenterP radius:m_centerR startAngle:2 * M_PI - startAngle endAngle:2 * M_PI - endAngle clockwise:clockWise];
    marginAngle = marginAngle > M_PI ? (2 * M_PI - marginAngle) : marginAngle;

    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    animation.path = path.CGPath;
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    animation.repeatCount = 1;
    animation.duration = 0.5 + marginAngle / M_PI  * 0.5;
    animation.delegate = self;
    [self.moveView.layer addAnimation:animation forKey:AnimationKey];
}

// 移除动画
- (void)removewAnimationFromMoveView {
    if ([self.moveView.layer animationForKey:AnimationKey]) {
        [self.moveView.layer removeAnimationForKey:AnimationKey];
    }
}

#pragma mark - CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    NSLog(@"--animationDidStop");
    if (flag) {
        self.moveView.frame = self.moveView.layer.presentationLayer.frame;
        [self getCurrentColor];
    }
}

#pragma mark - 触摸事件
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    [self calculateMoveViewCenter:point isChange:YES];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    [self calculateMoveViewCenter:point isChange:YES];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    [self calculateMoveViewCenter:point isChange:NO];
}

// 计算MoveView的Center(即选中色温色彩值)
- (void)calculateMoveViewCenter:(CGPoint)point isChange:(BOOL)isChange {
    if (![self judgePointIsValidate:point]) {
        // 无效区域直接return
        return ;
    }
    // 添加动画前确保已移除动画
    [self removewAnimationFromMoveView];
    [self holderMoveViewZoom:isChange];
    if (self.colorStyle == WZBColorStyleColorPan && CGPathContainsPoint(self.outerRing.CGPath, NULL, point, NO)) {
        self.moveView.center = point;
    } else {
        // 计算交点(色盘模式超出外圆也要计算交点）
//        CGFloat distance = sqrt(pow(point.x - CenterP.x, 2) + pow(point.y - CenterP.y, 2));
        CGFloat distance = hypot(point.x - CenterP.x, point.y - CenterP.y);
        CGFloat joinX = CenterP.x + m_centerR / distance * (point.x - CenterP.x);
        CGFloat joinY = CenterP.y + m_centerR / distance * (point.y - CenterP.y);
        self.moveView.center = CGPointMake(joinX, joinY);
        if (self.colorStyle == WZBColorStyleColorTemperature) {
            self.selColorTemperature = floor([self getColorTemperatureWithPoint:self.moveView.center]);
        }
    }
    [self getCurrentColor];
    [self holderDelegateAction:isChange];
}

// 处理代理方法
- (void)holderDelegateAction:(BOOL)isChange {
    if (isChange) {
        if (self.colorStyle == WZBColorStyleColorTemperature) {
            if ([self.delegate respondsToSelector:@selector(pickerView:didChangeColorTemperature:)]) {
                [self.delegate pickerView:self didChangeColorTemperature:self.selColorTemperature];
            }
        } else {
            if ([self.delegate respondsToSelector:@selector(pickerView:didChangeColor:)]) {
                [self.delegate pickerView:self didChangeColor:self.selColor];
            }
        }
    } else {
        if (self.colorStyle == WZBColorStyleColorTemperature) {
            if ([self.delegate respondsToSelector:@selector(pickerView:didEndPickerColorTemperature:)]) {
                [self.delegate pickerView:self didEndPickerColorTemperature:self.selColorTemperature];
            }
        } else {
            if ([self.delegate respondsToSelector:@selector(pickerView:didEndPickerColor:)]) {
                [self.delegate pickerView:self didEndPickerColor:self.selColor];
            }
        }
    }
}

// 处理MoveView缩放
- (void)holderMoveViewZoom:(BOOL)isZoom {
    if (!self.supportZoomScale) {
        // 不支持缩放
        return ;
    }
    self.isZoom = isZoom;
    [self setNeedsLayout];
}

// ImageView上的点转换为图片上的点,并获取颜色
- (void)getCurrentColor {
    CGPoint center = self.moveView.center;
    CGFloat xScale = self.image.size.width / CGRectGetWidth(self.frame);
    CGFloat yScale = self.image.size.height / CGRectGetHeight(self.frame);
    self.selColor = [self.image colorAtPixel:CGPointMake(center.x * xScale, center.y * yScale)];
    self.moveView.backgroundColor = self.selColor;
}

// 判断点击的点有效性
- (BOOL)judgePointIsValidate:(CGPoint)point {
    // 点在内圆区域
    BOOL isContainInner = CGPathContainsPoint(self.innerRing.CGPath, NULL, point, NO);
    if (isContainInner && (self.areas & WZBPickerViewResponseAreasInner)) {
        return YES;
    }

    // 点在圆环区域
    BOOL isContainOuter = CGPathContainsPoint(self.outerRing.CGPath, NULL, point, NO);
    if (isContainOuter && !isContainInner && (self.areas & WZBPickerViewResponseAreasCenter)) {
        return YES;
    }

    // 点在外圆以外
    if (!isContainOuter && (self.areas & WZBPickerViewResponseAreasOuter)) {
        return YES;
    }
    return NO;
}

// 根据有效点计算色温值
- (CGFloat)getColorTemperatureWithPoint:(CGPoint)point {
    CGFloat resultAngle = [self getAngleFromPoint:point];
    // 计算色温值
    if (resultAngle < M_PI_2 || resultAngle > M_PI_2 * 3) {
        // 第一/四象限
        self.direction = WZBColorTemperatureRight;
        resultAngle = (resultAngle < M_PI_2) ? (M_PI_2 - resultAngle) : (M_PI_2 * 5 - resultAngle);
    } else  {
        // 第二/三象限
        self.direction = WZBColorTemperatureLeft;
        resultAngle = resultAngle - M_PI_2;
    }
    return [self getColorTemperatureFromAngle:resultAngle];
}

// 根据弧度值计算色温值 isUpBig:上大下小为YES
- (CGFloat)getColorTemperatureFromAngle:(CGFloat)angle {
    if (self.isUpBig) {
        return m_maxColorTemperature - (m_maxColorTemperature - m_minColorTemperature) * angle / M_PI;
    } else {
        return m_minColorTemperature + (m_maxColorTemperature - m_minColorTemperature) * angle / M_PI;
    }
}

// 根据色温值计算弧度值(上 -> 下 0 - M_PI)
- (CGFloat)getAngleFromColorTemperature:(CGFloat)colorTemperature {
    if (self.isUpBig) {
        return (1 - (colorTemperature - m_minColorTemperature) / (m_maxColorTemperature - m_minColorTemperature)) * M_PI;
    } else {
        return (colorTemperature - m_minColorTemperature) / (m_maxColorTemperature - m_minColorTemperature) * M_PI;
    }
}

// 色温环上角度+位置转换为标准角度(逆时针，X轴正方向为0)
- (CGFloat)getStandardAngleFromColorTemperatureAngle:(CGFloat)angle direction:(WZBColorTemperatureDirection)direction {
    if (direction == WZBColorTemperatureLeft) {
        return angle + M_PI_2;
    } else {
        return angle <= M_PI_2 ? (M_PI_2 - angle) : (M_PI_2 * 5 - angle);
    }
}

// 根据颜色获取弧度(逆时针，X轴正方向为0)
- (CGFloat)getAngleFromColor:(UIColor *)color {
    HSV hsv;
    [color getHue:&hsv.hu saturation:&hsv.sa brightness:&hsv.br alpha:&hsv.al];
    return hsv.hu * 2 * M_PI;
}

// 获取地图上某点的弧度值(逆时针，X轴正方向为0)
- (CGFloat)getAngleFromPoint:(CGPoint)point {
    CGFloat resultAngle = 0;
    if (point.x < CenterP.x) {
        if (point.y < CenterP.y) {
            // 第二象限
            resultAngle = M_PI - atan((CenterP.y - point.y) / (CenterP.x - point.x));
        } else {
            // 第三象限
            resultAngle = atan((point.y - CenterP.y) / (CenterP.x - point.x)) + M_PI;
        }
    } else {
        if (point.y < CenterP.y) {
            // 第一象限
            resultAngle = atan((CenterP.y - point.y) / (point.x - CenterP.x));
        } else {
            // 第四象限
            resultAngle = 2 * M_PI - atan((point.y - CenterP.y) / (point.x - CenterP.x));
        }
    }
    return resultAngle;
}

- (void)setColorStyle:(WZBColorStyle)colorStyle {
    _colorStyle = colorStyle;
    // 初始化资源文件
    switch (colorStyle) {
        case WZBColorStyleColorRing:
            self.image = [UIImage imageNamed:@"color_ring"];
            break;
        case WZBColorStyleColorPan:
            self.image = [UIImage imageNamed:@"color_pan"];
            break;
        default:
            self.image = [UIImage imageNamed:@"color_temperature"];
            break;
    }
    // 初始化相关配置信息
    [self setupConfigData];
}

- (void)setSelColorTemperature:(CGFloat)selColorTemperature {
    _selColorTemperature = selColorTemperature;
    self.cctLabel.text = [NSString stringWithFormat:@"%@K", @(selColorTemperature)];
}

- (void)setIsUpBig:(BOOL)isUpBig {
    _isUpBig = isUpBig;
    if (_isUpBig) {
        self.image = [UIImage imageNamed:@"color_temperature"];
    } else {
        self.image = [UIImage imageNamed:@"color_temperature2"];
    }
}

#pragma mark - lazy
- (UIView *)moveView {
    if (!_moveView) {
        _moveView = [[UIView alloc] init];
        _moveView.layer.masksToBounds = YES;
        _moveView.layer.borderColor = [UIColor whiteColor].CGColor;
        _moveView.layer.borderWidth = m_moveViewBorderW;
        [self addSubview:_moveView];
    }
    return _moveView;
}

- (UILabel *)cctLabel {
    if (!_cctLabel) {
        _cctLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 30)];
        _cctLabel.textColor = [UIColor blackColor];
        _cctLabel.textAlignment = NSTextAlignmentCenter;
        _cctLabel.center = CenterP;
        [self addSubview:_cctLabel];
    }
    return _cctLabel;
}

- (UIBezierPath *)innerRing {
    if (!_innerRing) {
        _innerRing = [UIBezierPath bezierPathWithArcCenter:CenterP
                                                    radius:m_innerR
                                                startAngle:0
                                                  endAngle:2 * M_PI
                                                 clockwise:YES];
    }
    return _innerRing;
}

- (UIBezierPath *)outerRing {
    if (!_outerRing) {
        _outerRing = [UIBezierPath bezierPathWithArcCenter:CenterP
                                                    radius:m_outerR
                                                startAngle:0
                                                  endAngle:2 * M_PI
                                                 clockwise:YES];
    }
    return _outerRing;
}

@end
