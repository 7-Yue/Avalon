#import "TestUIViewOCVC.h"
#import <AvalonFramework/AvalonFramework.h>
#import "Masonry.h"

@interface TestUIViewOCVC ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) UIView *v1;
@property (nonatomic, strong) UIView *v2;
@property (nonatomic, strong) UIView *v3;
@property (nonatomic, strong) UIView *v4;
@property (nonatomic, strong) ALShowView *v5;

@end

@implementation TestUIViewOCVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [UIView new];
    self.view.backgroundColor = UIColor.whiteColor;
    
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.contentView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.scrollView);
        make.centerX.equalTo(self.scrollView);
        make.width.equalTo(self.scrollView);
        make.bottom.equalTo(self.scrollView).with.priorityLow();
    }];
    
    [self demoCode];
}

- (void)demoCode {
    {
        self.v1 = [[UIView alloc] initWithFrame:CGRectZero];
        self.v1.backgroundColor = UIColor.redColor;
        [self.contentView addSubview:self.v1];
        [self.v1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.contentView);
            make.top.equalTo(self.contentView).offset(20);
            make.width.equalTo(@100);
            make.height.equalTo(@30);
            make.bottom.lessThanOrEqualTo(self.contentView).offset(-20);
        }];
        
        [self.v1 al_configCornerWithRadius:15 masksToBounds:YES];
    }

    {
        self.v2 = [[UIView alloc] initWithFrame:CGRectZero];
        self.v2.backgroundColor = UIColor.yellowColor;
        [self.contentView addSubview:self.v2];
        [self.v2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.contentView);
            make.top.equalTo(self.v1.mas_bottom).offset(20);
            make.width.equalTo(@100);
            make.height.equalTo(@30);
            make.bottom.lessThanOrEqualTo(self.contentView).offset(-20);
        }];
        
        __weak __typeof(self)weakSelf = self;
        self.v2.al_layoutCallback = ^(){
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            [strongSelf.v2 al_configShadowWithColor:UIColor.blackColor
                                             offset:CGSizeZero
                                             radius:10
                                            opacity:0.5
                                               path:nil];
        };
    }
    
    {
        self.v3 = [[UIView alloc] initWithFrame:CGRectZero];
        self.v3.backgroundColor = UIColor.blueColor;
        [self.contentView addSubview:self.v3];
        [self.v3 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.contentView);
            make.top.equalTo(self.v2.mas_bottom).offset(20);
            make.width.equalTo(@100);
            make.height.equalTo(@30);
            make.bottom.lessThanOrEqualTo(self.contentView).offset(-20);
        }];
        
        __weak __typeof(self)weakSelf = self;
        self.v3.al_layoutCallback = ^(){
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            [strongSelf.v3 al_configCornerWithCorners:ALViewCornerTopLeft | ALViewCornerBottomRight
                                               radius:15
                                        masksToBounds:YES];
        };
    }
    
    {
        self.v4 = [[UIView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.v4];
        [self.v4 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.contentView);
            make.top.equalTo(self.v3.mas_bottom).offset(20);
            make.width.equalTo(@100);
            make.height.equalTo(@30);
            make.bottom.lessThanOrEqualTo(self.contentView).offset(-20);
        }];
        
        __weak __typeof(self)weakSelf = self;
        self.v4.al_layoutCallback = ^(){
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            [strongSelf.v4 al_configGradientAndColors:@[
                UIColor.redColor,
                UIColor.whiteColor
            ]
                                            locations:@[
                @0,
                @1
            ]
                                           startPoint:CGPointMake(0, 0.5)
                                             endPoint:CGPointMake(1, 0.5)
                                                 type:ALGradientLayerTypeAxial];
        };
    }
    
    {
        self.v5 = [[ALShowView alloc] initWithFrame:CGRectZero];
        self.v5.backgroundColor = UIColor.clearColor;
        [self.contentView addSubview:self.v5];
        [self.v5 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.contentView);
            make.top.equalTo(self.v4.mas_bottom).offset(20);
            make.width.equalTo(@100);
            make.height.equalTo(@30);
            make.bottom.lessThanOrEqualTo(self.contentView).offset(-20);
        }];
        self.v5.shadowColor = UIColor.blueColor;
        self.v5.shadowOffset = CGSizeMake(0, 0);
        self.v5.shadowRadius = 5;
        self.v5.shadowOpacity = 1;
        self.v5.cornerRadius = 15;
        self.v5.corners = ALShowViewCornerAllCorners;
        self.v5.cornerLayerColor = UIColor.brownColor;
        self.v5.gradientType = ALShowViewGradientLayerTypeAxial;
        self.v5.gradientColors = @[UIColor.redColor,UIColor.yellowColor];
        self.v5.gradientLocations = @[@0,@1];
        self.v5.gradientStartPoint = CGPointMake(0.5, 0);
        self.v5.gradientEndPoint = CGPointMake(0.5, 1);
    }
}

- (UIScrollView *)scrollView {
    if(!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.v5];
        [self.v5 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.contentView);
            make.top.equalTo(self.v4.mas_bottom).offset(20);
            make.width.equalTo(@100);
            make.height.equalTo(@30);
            make.bottom.lessThanOrEqualTo(self.contentView).offset(-20);
        }];
    }
    return _scrollView;
}

- (UIView *)contentView {
    if(!_contentView) {
        _contentView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _contentView;
}

@end
