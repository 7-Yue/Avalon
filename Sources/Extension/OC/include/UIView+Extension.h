#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSUInteger, ALViewCorner) {
    ALViewCornerEmpty       = 0,
    ALViewCornerTopLeft     = 1 << 0,
    ALViewCornerTopRight    = 1 << 1,
    ALViewCornerBottomLeft  = 1 << 2,
    ALViewCornerBottomRight = 1 << 3,
    ALViewCornerAllCorners  = ALViewCornerTopLeft|
                              ALViewCornerTopRight|
                              ALViewCornerBottomLeft|
                              ALViewCornerBottomRight
} NS_SWIFT_UNAVAILABLE("仅OC可用");

typedef NS_ENUM(NSUInteger, ALGradientLayerType) {
    ALGradientLayerTypeAxial = 1,
    ALGradientLayerTypeRadial = 2,
    ALGradientLayerTypeConic = 3,
} NS_SWIFT_UNAVAILABLE("仅OC可用");


@interface UIView (Extension)

- (void(^ _Nullable)(void))al_layoutCallback;

- (void)setAl_layoutCallback:(void(^ _Nonnull)(void))callback;

/// 全圆角
/// - Parameters:
///   - cornerRadius: 圆角弧度
///   - masksToBounds: 是否裁切
- (void)al_configCornerWithRadius:(CGFloat) cornerRadius
                    masksToBounds:(BOOL) masksToBounds NS_SWIFT_UNAVAILABLE("仅OC可用");


/// 定制圆角
/// - Parameters:
///   - corners: 圆角类型
///   - radius: 圆角弧度
///   - masksToBounds: 是否裁切
- (void)al_configCornerWithCorners:(ALViewCorner) corners
                            radius:(CGFloat) radius
                     masksToBounds:(BOOL) masksToBounds NS_SWIFT_UNAVAILABLE("仅OC可用");


/// 阴影
/// - Parameters:
///   - color: 颜色
///   - offset: 偏移
///   - radius: 半径
///   - opacity: 不透明度
///   - path: 路径
- (void)al_configShadowWithColor:(UIColor *_Nullable) color
                          offset:(CGSize) offset
                          radius:(CGFloat) radius
                         opacity:(CGFloat) opacity
                            path:(UIBezierPath *_Nullable) path NS_SWIFT_UNAVAILABLE("仅OC可用");

/// 渐变色
/// - Parameters:
///   - colors: 颜色
///   - locations: 位置
///   - startPoint: 起点
///   - endPoint: 终点
///   - type: 样式
- (void)al_configGradientAndColors:(NSArray<UIColor *> *_Nullable) colors
                         locations:(NSArray<NSNumber *> *_Nullable) locations
                        startPoint:(CGPoint) startPoint
                          endPoint:(CGPoint) endPoint
                              type:(ALGradientLayerType) type NS_SWIFT_UNAVAILABLE("仅OC可用");

@end
