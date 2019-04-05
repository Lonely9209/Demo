//
//  WZBTitleBGScrollerView.m
//  WZBTitleBGScrollerView
//
//  Created by Lonely920 on 2018/11/30.
//  Copyright © 2018 Lonely920. All rights reserved.
//

#import "WZBTitleBGScrollerView.h"

#define kDefaultNorColor UIColorFromRGBA(0x1a1a1a, 0.5)
#define kDefaultSelColor UIColorFromRGB(0x0074fc)

@interface WZBCommonTitleLabel : UILabel

+ (instancetype)commonTitleLabelWithTitle:(NSString *)title;

- (CGFloat)textWidth;

@end

@implementation WZBCommonTitleLabel

+ (instancetype)commonTitleLabelWithTitle:(NSString *)title {
    WZBCommonTitleLabel *titleLabel = [[WZBCommonTitleLabel alloc] init];
    titleLabel.text = title;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:15];
    titleLabel.userInteractionEnabled = YES;
    return titleLabel;
}

- (CGFloat)textWidth {
    return [self.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: self.font} context:nil].size.width + 4;
}

@end


@interface WZBTitleBGScrollerView ()

/** 下划线 */
@property (nonatomic, strong) UIView *underLineView;
/** 默认选中下标 */
@property (nonatomic, assign) NSInteger defIndex;
/** 当前选中Tag值 */
@property (nonatomic, assign) NSInteger selTagValue;
@end

// WZBFixedType模式下行Item默认数
static const NSInteger defaultItemCount = 4;
// WZBFixedType模式下Item默认间隔
static const NSInteger defaultFixedItemMargin = 0;
// WZBCompactType模式下Item默认间隔
static const NSInteger defaultCompactItemMargin = 15;
// Item初始Tag值
static const NSInteger startTagValue = 12345;
// 下划线默认高度
static const CGFloat underLineDefaultH = 3;

@implementation WZBTitleBGScrollerView

+ (instancetype)titleBGScrollerViewWithFrame:(CGRect)frame
                                   dataArray:(NSArray *)dataArray
                               titleDelegate:(id)titleDelegate {
    return [WZBTitleBGScrollerView titleBGScrollerViewWithFrame:frame dataArray:dataArray norColor:kDefaultNorColor selColor:kDefaultSelColor titleDelegate:titleDelegate defIndex:0];
}

+ (instancetype)titleBGScrollerViewWithFrame:(CGRect)frame
                                   dataArray:(NSArray *)dataArray
                               titleDelegate:(id)titleDelegate
                                    defIndex:(NSInteger)defIndex {
    return [WZBTitleBGScrollerView titleBGScrollerViewWithFrame:frame dataArray:dataArray norColor:kDefaultNorColor selColor:kDefaultSelColor titleDelegate:titleDelegate defIndex:defIndex];
}

+ (instancetype)titleBGScrollerViewWithFrame:(CGRect)frame
                                   dataArray:(NSArray *)dataArray
                                    norColor:(UIColor *)norColor
                                    selColor:(UIColor *)selColor
                               titleDelegate:(id)titleDelegate
                                    defIndex:(NSInteger)defIndex {
    WZBTitleBGScrollerView *scrollerView = [[WZBTitleBGScrollerView alloc] initWithFrame:frame];
    scrollerView.norColor = norColor;
    scrollerView.selColor = selColor;
    scrollerView.defIndex = MAX(defIndex, 0);
    scrollerView.titleDelegate = titleDelegate;
    scrollerView.dataArray = dataArray;
    return scrollerView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setDefaultVlue];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setDefaultVlue];
    }
    return self;
}

- (void)setDefaultVlue {
    self.norColor = kDefaultNorColor;
    self.selColor = kDefaultSelColor;
    self.scrollsToCenter = YES;
    self.animation = YES;
    self.hideUnderLineView = NO;
    self.supportReplaceClick = NO;
    self.showType = WZBFixedType;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (!self.dataArray || self.dataArray.count == 0) {
        return ;
    }
    switch (self.showType) {
        case WZBFixedType:
            [self layoutFixedItem];
            break;
        case WZBCompactType:
            [self layoutCompactItem];
            break;
        default:
            break;
    }
    if (_underLineView && _selTagValue != 0) {
        WZBCommonTitleLabel *titleLabel = (WZBCommonTitleLabel *)[self viewWithTag:_selTagValue];
        if (titleLabel.textWidth > CGRectGetWidth(titleLabel.frame) + 4) {
            CGRect frame = self.underLineView.frame;
            frame.size.width = CGRectGetWidth(titleLabel.frame) + 4;
            self.underLineView.frame = frame;
        }
        CGPoint center = _underLineView.center;
        center.x = titleLabel.center.x;
        _underLineView.center = center;
    }
}

// 布局WZBFixedType型子Item
- (void)layoutFixedItem {
    NSInteger itemCount = MIN(self.dataArray.count, self.lineItemCount);
    CGFloat itemX = 0;
    CGFloat itemH = CGRectGetHeight(self.frame) - self.contentInset.top - self.contentInset.bottom;
    CGFloat itemW = (CGRectGetWidth(self.frame) - self.contentInset.left - self.contentInset.right - self.itemMargin * (itemCount - 1)) / itemCount;
    if (itemW <= 0) {
        // 设置itemMargin导致itemW异常，将自动itemMargin重置为默认值
        _itemMargin = defaultFixedItemMargin;
        itemW = (CGRectGetWidth(self.frame) - self.contentInset.left - self.contentInset.right - self.itemMargin * (itemCount - 1)) / itemCount;
    }
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:[WZBCommonTitleLabel class]]) {
            WZBCommonTitleLabel *titleLabel = (WZBCommonTitleLabel *)subview;
            titleLabel.adjustsFontSizeToFitWidth = self.autoAdjustFontToFit;
            titleLabel.frame = CGRectMake(itemX, 0, itemW, itemH);
            itemX += itemW + self.itemMargin;
        }
    }
    self.contentSize = CGSizeMake(itemX - self.itemMargin, 0);
}

// 布局WZBCompactType型子Item
- (void)layoutCompactItem {
    CGFloat itemX = 0;
    CGFloat itemH = CGRectGetHeight(self.frame) - self.contentInset.top - self.contentInset.bottom;
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:[WZBCommonTitleLabel class]]) {
            WZBCommonTitleLabel *titleLabel = (WZBCommonTitleLabel *)subview;
            [titleLabel sizeToFit];
            titleLabel.frame = CGRectMake(itemX, 0, CGRectGetWidth(titleLabel.bounds), itemH);
            itemX += CGRectGetWidth(titleLabel.bounds) + self.itemMargin;
        }
    }
    self.contentSize = CGSizeMake(itemX - self.itemMargin, 0);
}

// 添加子Item
- (void)addSubItems {
    int tagValue = startTagValue;
    for (NSString *title in self.dataArray) {
        WZBCommonTitleLabel *titleLabel = [WZBCommonTitleLabel commonTitleLabelWithTitle:title];
        titleLabel.textColor = self.norColor;
        titleLabel.tag = tagValue++;
        [self addSubview:titleLabel];
        
        // 添加手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemClick:)];
        [titleLabel addGestureRecognizer:tap];
    }
    // 设置默认选中项
    self.selTagValue = startTagValue + self.defIndex;
}

// 移除所有子View
- (void)removeAllSubviews {
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if (_underLineView) {
        _underLineView = nil;
    }
}

// 点击Item
- (void)itemClick:(UITapGestureRecognizer *)tapGesture {
    WZBCommonTitleLabel *titleLabel = (WZBCommonTitleLabel *)tapGesture.view;
    self.selTagValue = titleLabel.tag;
}

// 调整ScrollerView(动画)
- (void)adjustScrollerView {
    WZBCommonTitleLabel *titleLabel = (WZBCommonTitleLabel *)[self viewWithTag:_selTagValue];
    if (self.scrollsToCenter) {
        CGFloat offsetX = titleLabel.center.x - (CGRectGetWidth(self.frame) - self.contentInset.left - self.contentInset.right) / 2 - self.contentInset.left;
        CGFloat offsetXMax = self.contentSize.width > CGRectGetWidth(self.frame) ? self.contentSize.width - CGRectGetWidth(self.frame) + self.contentInset.right : - self.contentInset.left;
        if (offsetX < - self.contentInset.left) {
            offsetX = - self.contentInset.left;
        }
        if (offsetX > offsetXMax) {
            offsetX = offsetXMax;
        }
        [self setContentOffset:CGPointMake(offsetX, - self.contentInset.top) animated:self.isAnimation];
    }
}

// 调整下划线(动画)
- (void)adjustUnderLineView {
    WZBCommonTitleLabel *titleLabel = (WZBCommonTitleLabel *)[self viewWithTag:_selTagValue];
    [UIView animateWithDuration:self.isAnimation ? 0.25 : 0 animations:^{
        CGRect frame = self.underLineView.frame;
        frame.size.width = titleLabel.textWidth;
        self.underLineView.frame = frame;
        
        CGPoint center = self.underLineView.center;
        center.x = titleLabel.center.x;
        self.underLineView.center = center;
        
        titleLabel.textColor = self.selColor;
    }];
}

#pragma mark - setter
- (void)setDataArray:(NSArray *)dataArray {
    if (!dataArray || dataArray.count == 0) {
        // 数据源异常
        return ;
    }
    if (_dataArray.count > 0) {
        [self removeAllSubviews];
    }
    _dataArray = dataArray;
    _defIndex = MIN(dataArray.count - 1, _defIndex);
    [self addSubItems];
}

- (void)setShowType:(WZBShowType)showType {
    if (_showType == showType) {
        return ;
    }
    _showType = showType;
    switch (showType) {
        case WZBFixedType:
            _lineItemCount = defaultItemCount;
            _itemMargin = defaultFixedItemMargin;
            _autoAdjustFontToFit = YES;
            break;
        case WZBCompactType:
            _itemMargin = defaultCompactItemMargin;
            break;
        default:
            break;
    }
    [self layoutSubviews];
}

- (void)setSelTagValue:(NSInteger)selTagValue {
    if (_selTagValue == selTagValue && !self.isSupportReplaceClick) {
        // 重复点击
        return ;
    }
    if (_selTagValue != 0) {
        // 将之前选中项颜色还原
        WZBCommonTitleLabel *titleLabel = (WZBCommonTitleLabel *)[self viewWithTag:_selTagValue];
        titleLabel.textColor = self.norColor;
    }
    _selTagValue = selTagValue;
    // 重新刷新布局，确保滚动及动画准确性
    [self layoutIfNeeded];
    // 滚动及动画调整
    [self adjustScrollerView];
    [self adjustUnderLineView];
    if ([self.titleDelegate respondsToSelector:@selector(titleBGScrollerView:didSelectIndex:)]) {
        [self.titleDelegate titleBGScrollerView:self didSelectIndex:self.selIndex];
    }
}

- (void)setItemMargin:(CGFloat)itemMargin {
    _itemMargin = itemMargin;
    [self layoutSubviews];
    // 调整ScrollerView
    [self adjustScrollerView];
}

- (void)setLineItemCount:(NSInteger)lineItemCount {
    _lineItemCount = lineItemCount;
    if (self.showType == WZBFixedType) {
        // 其他模式下无效
        [self layoutSubviews];
        // 调整ScrollerView
        [self adjustScrollerView];
    }
}

- (void)setContentInset:(UIEdgeInsets)contentInset {
    [super setContentInset:contentInset];
    if (_underLineView) {
        CGRect frame = _underLineView.frame;
        frame.origin.y = CGRectGetHeight(self.frame) - self.contentInset.top - self.contentInset.bottom - underLineDefaultH;
        _underLineView.frame = frame;
    }
    [self layoutIfNeeded];
    // 调整ScrollerView
    [self adjustScrollerView];
}

- (void)setHideUnderLineView:(BOOL)hideUnderLineView {
    _hideUnderLineView = hideUnderLineView;
    if (_underLineView) {
        _underLineView.hidden = _hideUnderLineView;
    }
}

-(void)setAutoAdjustFontToFit:(BOOL)autoAdjustFontToFit {
    if (self.showType != WZBFixedType) {
        // 类型不匹配，直接返回
        return ;
    }
    _autoAdjustFontToFit = autoAdjustFontToFit;
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:[WZBCommonTitleLabel class]]) {
            WZBCommonTitleLabel *titleLabel = (WZBCommonTitleLabel *)subview;
            titleLabel.adjustsFontSizeToFitWidth = autoAdjustFontToFit;
        }
    }
}

- (NSInteger)selIndex {
    return self.selTagValue - startTagValue;
}

#pragma mark - lazy
- (UIView *)underLineView {
    if (!_underLineView) {
        _underLineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame) - underLineDefaultH, 0, underLineDefaultH)];
        _underLineView.backgroundColor = self.selColor;
        _underLineView.hidden = self.isHideUnderLineView;
        [self addSubview:_underLineView];
    }
    return _underLineView;
}

@end
