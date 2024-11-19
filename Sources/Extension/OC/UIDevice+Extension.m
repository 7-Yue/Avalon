#import "UIDevice+Extension.h"
#import <sys/utsname.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <Network/Network.h>

@implementation UIDevice (Extension)

+ (BOOL)al_isNotchScreen {
    UIInterfaceOrientation orientation = UIApplication.sharedApplication.statusBarOrientation;
    if (@available(iOS 13.0, *)) {
        //  iOS 13+
        UIWindow *keyWindow;
        for (UIWindowScene *scene in UIApplication.sharedApplication.connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive) {
                for (UIWindow *window in scene.windows) {
                    if (window.isKeyWindow) {
                        keyWindow = window;
                    }
                }
            }
        }
        CGFloat targetInset = 0;
        switch (orientation) {
            case UIInterfaceOrientationPortrait:
                targetInset = keyWindow.safeAreaInsets.top;
                break;
            case UIInterfaceOrientationLandscapeLeft:
                targetInset = keyWindow.safeAreaInsets.right;
                break;
            case UIInterfaceOrientationLandscapeRight:
                targetInset = keyWindow.safeAreaInsets.left;
                break;
            default:
                targetInset = 0;
                break;
        }
        return targetInset > 20.0;
    } else if (@available(iOS 11.0, *)) {
        //  iOS 11 - iOS 13
        UIWindow *mainWindow = UIApplication.sharedApplication.keyWindow;
        CGFloat targetInset = 0;
        switch (orientation) {
            case UIInterfaceOrientationPortrait:
                targetInset = mainWindow.safeAreaInsets.top;
                break;
            case UIInterfaceOrientationLandscapeLeft:
                targetInset = mainWindow.safeAreaInsets.right;
                break;
            case UIInterfaceOrientationLandscapeRight:
                targetInset = mainWindow.safeAreaInsets.left;
                break;
            default:
                targetInset = 0;
                break;
        }
        return targetInset > 20.0;
    } else {
        //  iOS 11- 没有刘海屏，iPhone X第一次使用刘海屏
        return NO;
    }
}

+ (double)al_statusBarHeight {
    if (@available(iOS 13.0, *)) {
        // iOS 13+
        UIWindow *keyWindow;
        for (UIWindowScene *scene in UIApplication.sharedApplication.connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive) {
                for (UIWindow *window in scene.windows) {
                    if (window.isKeyWindow) {
                        keyWindow = window;
                    }
                }
            }
        }

        return keyWindow.windowScene.statusBarManager.statusBarFrame.size.height;
    } else {
        return [UIApplication sharedApplication].statusBarFrame.size.height;
    }
}

+ (UIEdgeInsets)al_safeAreaEdgeInsets {
    if (@available(iOS 13.0, *)) {
        // iOS 13+
        UIWindow *keyWindow;
        for (UIWindowScene *scene in UIApplication.sharedApplication.connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive) {
                for (UIWindow *window in scene.windows) {
                    if (window.isKeyWindow) {
                        keyWindow = window;
                    }
                }
            }
        }
        return keyWindow.safeAreaInsets;
    } else if (@available(iOS 11.0, *)) {
        // iOS 11 - iOS 12
        UIWindow *mainWindow = UIApplication.sharedApplication.keyWindow;
        return mainWindow.safeAreaInsets;
    } else {
        // iOS 11
        return UIEdgeInsetsZero;
    }
}

+ (double)al_systemNavbarHeight {
    return 44.0;
}

+ (double)al_whRatio {
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat screenWidth = MIN(screenSize.width, screenSize.height);
    CGFloat screenHeight = MAX(screenSize.width, screenSize.height);
    return screenWidth/screenHeight;
}

+ (CGSize)al_zoomSizeOnDeviceWidthWithOriSize:(CGSize) oriSize {
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat screenWidth = MIN(screenSize.width, screenSize.height);
    return CGSizeMake(screenWidth, screenWidth * oriSize.height / oriSize.width);
}

+ (CGSize)al_zoomSizeOnDeviceHeightWithOriSize:(CGSize) oriSize {
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat screenHeight = MAX(screenSize.width, screenSize.height);
    return CGSizeMake(screenHeight * oriSize.width / oriSize.height, screenHeight);
}

+ (NSString *)al_deviceSysTypeName {
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

+ (NSString *)al_deviceProductName {
    NSString *identifier = [UIDevice al_deviceSysTypeName];
    NSDictionary *deviceMap = @{
        @"i386"      : @"iPhone Simulator",
        @"x86_64"    : @"iPhone Simulator",
        @"arm64"     : @"iPhone Simulator",
        @"iPhone1,1" : @"iPhone",
        @"iPhone1,2" : @"iPhone 3G",
        @"iPhone2,1" : @"iPhone 3GS",
        @"iPhone3,1" : @"iPhone 4",
        @"iPhone3,2" : @"iPhone 4 GSM Rev A",
        @"iPhone3,3" : @"iPhone 4 CDMA",
        @"iPhone4,1" : @"iPhone 4S",
        @"iPhone5,1" : @"iPhone 5 (GSM)",
        @"iPhone5,2" : @"iPhone 5 (GSM+CDMA)",
        @"iPhone5,3" : @"iPhone 5C (GSM)",
        @"iPhone5,4" : @"iPhone 5C (Global)",
        @"iPhone6,1" : @"iPhone 5S (GSM)",
        @"iPhone6,2" : @"iPhone 5S (Global)",
        @"iPhone7,1" : @"iPhone 6 Plus",
        @"iPhone7,2" : @"iPhone 6",
        @"iPhone8,1" : @"iPhone 6s",
        @"iPhone8,2" : @"iPhone 6s Plus",
        @"iPhone8,4" : @"iPhone SE (GSM)",
        @"iPhone9,1" : @"iPhone 7",
        @"iPhone9,2" : @"iPhone 7 Plus",
        @"iPhone9,3" : @"iPhone 7",
        @"iPhone9,4" : @"iPhone 7 Plus",
        @"iPhone10,1": @"iPhone 8",
        @"iPhone10,2": @"iPhone 8 Plus",
        @"iPhone10,3": @"iPhone X Global",
        @"iPhone10,4": @"iPhone 8",
        @"iPhone10,5": @"iPhone 8 Plus",
        @"iPhone10,6": @"iPhone X GSM",
        @"iPhone11,2": @"iPhone XS",
        @"iPhone11,4": @"iPhone XS Max",
        @"iPhone11,6": @"iPhone XS Max Global",
        @"iPhone11,8": @"iPhone XR",
        @"iPhone12,1": @"iPhone 11",
        @"iPhone12,3": @"iPhone 11 Pro",
        @"iPhone12,5": @"iPhone 11 Pro Max",
        @"iPhone12,8": @"iPhone SE 2nd Gen",
        @"iPhone13,1": @"iPhone 12 Mini",
        @"iPhone13,2": @"iPhone 12",
        @"iPhone13,3": @"iPhone 12 Pro",
        @"iPhone13,4": @"iPhone 12 Pro Max",
        @"iPhone14,2": @"iPhone 13 Pro",
        @"iPhone14,3": @"iPhone 13 Pro Max",
        @"iPhone14,4": @"iPhone 13 Mini",
        @"iPhone14,5": @"iPhone 13",
        @"iPhone14,6": @"iPhone SE 3rd Gen",
        @"iPhone14,7": @"iPhone 14",
        @"iPhone14,8": @"iPhone 14 Plus",
        @"iPhone15,2": @"iPhone 14 Pro",
        @"iPhone15,3": @"iPhone 14 Pro Max",
        @"iPhone15,4": @"iPhone 15",
        @"iPhone15,5": @"iPhone 15 Plus",
        @"iPhone16,1": @"iPhone 15 Pro",
        @"iPhone16,2": @"iPhone 15 Pro Max",
        @"iPhone17,1": @"iPhone 16 Pro",
        @"iPhone17,2": @"iPhone 16 Pro Max",
        @"iPhone17,3": @"iPhone 16",
        @"iPhone17,4": @"iPhone 16 Plus"
    };
    return deviceMap[identifier] ?: @"unknowm";
}

+ (NSString *)al_networkType {
    __block NSString *networkType = @"";
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    nw_path_monitor_t monitor = nw_path_monitor_create();
    nw_path_monitor_set_update_handler(monitor, ^(nw_path_t path) {
        if (nw_path_uses_interface_type(path, nw_interface_type_wifi)) {
            networkType = @"WIFI";
        } else if (nw_path_uses_interface_type(path, nw_interface_type_wired)) {
            networkType = @"以太网";
        } else if (nw_path_uses_interface_type(path, nw_interface_type_cellular)) {
            CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
            NSString *radioAccessTechnology = networkInfo.serviceCurrentRadioAccessTechnology.allValues.firstObject;
            networkType = radioAccessTechnology;
        }
        dispatch_semaphore_signal(semaphore);
    });

    nw_path_monitor_set_queue(monitor, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
    nw_path_monitor_start(monitor);
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    nw_path_monitor_cancel(monitor);
    return networkType;
}

@end
