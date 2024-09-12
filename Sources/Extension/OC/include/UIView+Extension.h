#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

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


@interface UIView (Extension)

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


/// 阴影+圆角
/// - Parameters:
///   - corners: 圆角类型
///   - cornerRadius: 圆角弧度
///   - masksToBounds: 是否裁切
///   - color: 阴影颜色
///   - offset: 阴影偏移
///   - shadowRadius: 阴影半径
///   - opacity: 阴影不透明度
///   - path: 阴影路径
- (void)al_configCornerAndShadowWithCorners:(ALViewCorner) corners
                               cornerRadius:(CGFloat) cornerRadius
                              masksToBounds:(BOOL) masksToBounds
                                      color:(UIColor *_Nullable) color
                                     offset:(CGSize) offset
                               shadowRadius:(CGFloat) shadowRadius
                                    opacity:(CGFloat) opacity
                                       path:(UIBezierPath *_Nullable) path NS_SWIFT_UNAVAILABLE("仅OC可用");

@end

NS_ASSUME_NONNULL_END
