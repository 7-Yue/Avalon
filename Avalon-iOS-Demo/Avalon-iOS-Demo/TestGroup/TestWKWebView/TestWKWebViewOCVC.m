#import "TestWKWebViewOCVC.h"
#import <WebKit/WKWebView.h>
#import <AvalonFramework/AvalonFramework.h>

@interface TestWKWebViewOCVC ()

@property (nonatomic, strong) WKWebView *webView;
@end

@implementation TestWKWebViewOCVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;

    [self.view addSubview:self.webView];
    self.webView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 300);


}

- (WKWebView *)webView {
    if(!_webView) {
        _webView = [[WKWebView alloc] initWithFrame:CGRectZero];
        NSURL *url = [[NSURL alloc] initWithString:@"https://www.baidu.com"];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
        [_webView loadRequest:request];
    }
    return _webView;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    _webView = nil;
}


@end
