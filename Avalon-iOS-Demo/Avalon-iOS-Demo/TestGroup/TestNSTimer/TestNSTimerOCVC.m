#import "TestNSTimerOCVC.h"
#import <AvalonFramework/AvalonFramework.h>

@interface TestNSTimerOCVC ()

@property (nonatomic, strong) NSTimer *timer1;

@end

@implementation TestNSTimerOCVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.timer1 = [NSTimer al_scheduledTimerWithTimeInterval:1.0 weakTarget:self selector:@selector(_countdown1) userInfo:nil repeat:YES];
}

- (void)_countdown1 {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}


@end
