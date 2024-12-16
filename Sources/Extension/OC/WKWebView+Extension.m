#import "WKWebView+Extension.h"
#import "NSObject+Extension.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

#if DEBUG
void WKPreferencesSetWebSecurityEnabled(id, bool);

@interface ALFakeWebKitPointer: NSObject
@property (nonatomic) void* _apiObject;
@end
@implementation ALFakeWebKitPointer
@end

void ALBSetWebSecurityEnabled(WKPreferences* prefs, bool enabled) {
    Ivar ivar = class_getInstanceVariable([WKPreferences class], "_preferences");
    void* realPreferences = (void*)(((uintptr_t)prefs) + ivar_getOffset(ivar));
    ALFakeWebKitPointer* fake = [ALFakeWebKitPointer new];
    fake._apiObject = realPreferences;
    WKPreferencesSetWebSecurityEnabled(fake, enabled);
}
#endif

@implementation WKWebView (Extension)

#if DEBUG

+ (void)load {
    SwizzleMethod(WKWebView.class,
                  @selector(initWithFrame:configuration:),
                  @selector(al_initWithFrame:configuration:),
                  NO);
}

- (instancetype)al_initWithFrame:(CGRect)frame configuration:(WKWebViewConfiguration *)configuration  {
    WKWebView *i = [self al_initWithFrame:frame configuration:configuration];

//  允许safari调试
    if (@available(iOS 16.4, *)) {
        i.inspectable = YES;
    }
//  解决webview的跨域问题
    WKPreferences* prefs = i.configuration.preferences;
    ALBSetWebSecurityEnabled(prefs, NO);

    return i;
}

#endif

@end
