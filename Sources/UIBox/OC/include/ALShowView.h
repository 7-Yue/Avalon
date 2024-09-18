#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSUInteger, ALShowViewCorner) {
    ALShowViewCornerEmpty       = 0,
    ALShowViewCornerTopLeft     = 1 << 0,
    ALShowViewCornerTopRight    = 1 << 1,
    ALShowViewCornerBottomLeft  = 1 << 2,
    ALShowViewCornerBottomRight = 1 << 3,
    ALShowViewCornerAllCorners  = ALShowViewCornerTopLeft|
                                  ALShowViewCornerTopRight|
                                  ALShowViewCornerBottomLeft|
                                  ALShowViewCornerBottomRight
} NS_SWIFT_UNAVAILABLE("仅OC可用");

typedef NS_ENUM(NSUInteger, ALShowViewGradientLayerType) {
    ALShowViewGradientLayerTypeAxial = 1,
    ALShowViewGradientLayerTypeRadial = 2,
    ALShowViewGradientLayerTypeConic = 3,
} NS_SWIFT_UNAVAILABLE("仅OC可用");


__attribute__((objc_subclassing_restricted))
NS_SWIFT_UNAVAILABLE("仅OC可用")
/// 支持圆角、阴影、渐变色的View
@interface ALShowView : UIView

//  圆角
@property(nonatomic, assign) CGFloat cornerRadius;
@property(nonatomic, assign) ALShowViewCorner corners;
@property(nonatomic, strong, nullable) UIColor *cornerLayerColor;
//  阴影
@property(nonatomic, strong, nullable) UIColor *shadowColor;
@property(nonatomic, assign) CGSize shadowOffset;
@property(nonatomic, assign) CGFloat shadowRadius;
@property(nonatomic, assign) CGFloat shadowOpacity;
//  渐变色
@property(nonatomic, copy, nullable) NSArray<UIColor *> *gradientColors;
@property(nonatomic, copy, nullable) NSArray<NSNumber *> *gradientLocations;
@property(nonatomic, assign) CGPoint gradientStartPoint;
@property(nonatomic, assign) CGPoint gradientEndPoint;
@property(nonatomic, assign) ALShowViewGradientLayerType gradientType;

- (_Nonnull instancetype)initWithFrame:(CGRect)frame NS_DESIGNATED_INITIALIZER;
- (_Nonnull instancetype)initWithCoder:(NSCoder * _Nullable)coder  __attribute__((unavailable("不可用")));
- (_Nonnull instancetype)new __attribute__((unavailable("不可用")));

@end

