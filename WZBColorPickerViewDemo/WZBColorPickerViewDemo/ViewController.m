//
//  ViewController.m
//  WZBColorPickerViewDemo
//
//  Created by Lonely920 on 2019/3/28.
//  Copyright © 2019 Lonely920. All rights reserved.
//

#import "ViewController.h"
#import "WZBColorPickerView.h"

@interface ViewController () <WZBColorPickerViewDelegate>
/** 亮度遮罩View */
@property (nonatomic, strong) UIView *brightnessMaskView;
/** 亮度进度条 */
@property (nonatomic, strong) UISlider *slider;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    CGFloat pickerViewW = CGRectGetWidth(self.view.frame) -100;
    WZBColorPickerView *pickerView = [WZBColorPickerView pickerViewWithFrame:CGRectMake(0, 0, pickerViewW, pickerViewW)
                                                                  colorStyle:WZBColorStyleColorRing];
    pickerView.center = self.view.center;
    pickerView.delegate = self;
    [self.view addSubview:pickerView];

    [pickerView setColor:[UIColor colorWithHue:0.75 saturation:0.8 brightness:1 alpha:1] isAnimation:NO];
    // 色盘模式由于图片问题，滑倒顶部会显示黑色，此处设置centerRate0.99即可；
//    [pickerView configPickerViewResponseAreas:WZBPickerViewResponseAreasInner | WZBPickerViewResponseAreasCenter | WZBPickerViewResponseAreasOuter innerRate:0.5 outerRate:1 centerRate:0.99];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [pickerView setColor:[UIColor colorWithHue:0.5 saturation:0.8 brightness:1 alpha:1] isAnimation:YES];
    });

//    [pickerView configMinColorTemperature:2000 maxColorTemperature:4000 isUpBig:YES];
//    [pickerView setColorTemperature:4900.99 direction:WZBColorTemperatureLeft isAnimation:NO];
//
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [pickerView setColorTemperature:2300.99 direction:WZBColorTemperatureRight isAnimation:YES];
//    });

    self.slider.frame = CGRectMake(CGRectGetMinX(pickerView.frame), CGRectGetMaxY(pickerView.frame) + 30, pickerViewW, 30);
    [self brightnessValueChange:_slider];
}

#pragma mark - WZBColorPickerViewDelegate
// 取色值改变调用
- (void)pickerView:(WZBColorPickerView *)pickerView didChangeColor:(UIColor *)color {
    self.view.backgroundColor = color;
}
// 取色结束调用
- (void)pickerView:(WZBColorPickerView *)pickerView didEndPickerColor:(UIColor *)color {
    NSLog(@"-----End-----Color----");
    self.view.backgroundColor = color;
}

// 取色温值改变调用
- (void)pickerView:(WZBColorPickerView *)pickerView didChangeColorTemperature:(CGFloat)colorTemperature {
    NSLog(@"----change----%@----", @(colorTemperature));
}
// 取色温结束调用
- (void)pickerView:(WZBColorPickerView *)pickerView didEndPickerColorTemperature:(CGFloat)colorTemperature {
    NSLog(@"----end----%@----", @(colorTemperature));
}

- (void)brightnessValueChange:(UISlider *)slider {
    self.brightnessMaskView.alpha = (1 - slider.value) * 0.25;
}

#pragma mark - lazy
- (UIView *)brightnessMaskView {
    if (!_brightnessMaskView) {
        _brightnessMaskView = [[UIView alloc] initWithFrame:self.view.bounds];
        _brightnessMaskView.userInteractionEnabled = NO;
        _brightnessMaskView.backgroundColor = [UIColor blackColor];
        [self.view addSubview:_brightnessMaskView];
    }
    return _brightnessMaskView;
}

- (UISlider *)slider {
    if (!_slider) {
        _slider = [[UISlider alloc] init];
        _slider.continuous = YES;
        _slider.value = 1;
        [_slider addTarget:self action:@selector(brightnessValueChange:) forControlEvents:UIControlEventValueChanged];
        [self.view addSubview:_slider];
    }
    return _slider;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
