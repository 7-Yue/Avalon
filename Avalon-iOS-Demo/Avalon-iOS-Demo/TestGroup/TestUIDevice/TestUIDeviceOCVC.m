#import "TestUIDeviceOCVC.h"
#import <AvalonFramework/AvalonFramework.h>

@interface TestUIDeviceOCVC ()

@end

@implementation TestUIDeviceOCVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;


    UIView *v1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, UIApplication.sharedApplication.statusBarFrame.size.height)];
    v1.backgroundColor = UIColor.yellowColor;
    [self.view addSubview:v1];

    UIView *v2 = [[UIView alloc] initWithFrame:CGRectMake(120, 0, 100, UIApplication.sharedApplication.keyWindow.safeAreaInsets.top)];
    v2.backgroundColor = UIColor.blueColor;
    [self.view addSubview:v2];

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"是否是刘海屏:%@", [UIDevice al_isNotchScreen] ? @"YES" : @"NO");
    NSLog(@"状态栏高度:%lf", [UIDevice al_statusBarHeight]);
    NSLog(@"安全区域:%@", NSStringFromUIEdgeInsets([UIDevice al_safeAreaEdgeInsets]));
    NSLog(@"设备类型名:%@", [UIDevice al_deviceSysTypeName]);
    NSLog(@"设备产品名:%@", [UIDevice al_deviceProductName]);
    NSLog(@"设备网络:%@", [UIDevice al_networkType]);
}

@end
