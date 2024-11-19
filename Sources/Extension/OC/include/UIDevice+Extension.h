#import <UIKit/UIKit.h>

@interface UIDevice (Extension)

/// 是否是刘海屏
+ (BOOL)al_isNotchScreen NS_SWIFT_UNAVAILABLE("仅OC可用");

// ???: ❗安全距离top高度 ≠ 状态栏高度，目前iphone有三种【20、44、54】
/// 状态栏高度，横竖屏、状态栏显示隐藏都有影响
+ (double)al_statusBarHeight NS_SWIFT_UNAVAILABLE("仅OC可用");

/// 设备当前安全距离值，横竖屏有影响
+ (UIEdgeInsets)al_safeAreaEdgeInsets;

// ???: ❗目前iphone有两种【44，32很少见了】
/// 系统常规导航栏高度 44
+ (double)al_systemNavbarHeight NS_SWIFT_UNAVAILABLE("仅OC可用");

/// 设备 宽/高
+ (double)al_whRatio NS_SWIFT_UNAVAILABLE("仅OC可用");

/// 将一个size，以设备宽为基准，缩放自身尺寸
/// - Parameter oriSize: 原始size
+ (CGSize)al_zoomSizeOnDeviceWidthWithOriSize:(CGSize) oriSize NS_SWIFT_UNAVAILABLE("仅OC可用");

/// 将一个size，以设备高度为基准，缩放自身尺寸
/// - Parameter oriSize: 原始size
+ (CGSize)al_zoomSizeOnDeviceHeightWithOriSize:(CGSize) oriSize NS_SWIFT_UNAVAILABLE("仅OC可用");

/// 系统给予的设备类型
+ (NSString * _Nullable)al_deviceSysTypeName NS_SWIFT_UNAVAILABLE("仅OC可用");

/// 设备的产品名
+ (NSString * _Nonnull)al_deviceProductName NS_SWIFT_UNAVAILABLE("仅OC可用");

/// 设备当前网络类型
+ (NSString * _Nonnull)al_networkType NS_SWIFT_UNAVAILABLE("仅OC可用");

@end

