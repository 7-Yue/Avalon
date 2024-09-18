#import "UIView+Extension.h"
#import "NSObject+Extension.h"
#import <objc/runtime.h>

@implementation UIView (Extension)

+ (void)load {
    SwizzleMethod(UIView.class,
                  @selector(layoutSubviews),
                  @selector(al_layoutSubviews),
                  NO);
}

- (void)al_layoutSubviews {
    [self al_layoutSubviews];
    if (self.al_layoutCallback) {
        self.al_layoutCallback();
    }
}

- (void(^ _Nullable)(void))al_layoutCallback {
    return objc_getAssociatedObject(self, @selector(al_layoutCallback));
}

- (void)setAl_layoutCallback:(void(^ _Nonnull)(void))callback {
    objc_setAssociatedObject(self,
                             @selector(al_layoutCallback),
                             callback,
                             OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)al_configCornerWithRadius:(CGFloat) cornerRadius
                    masksToBounds:(BOOL) masksToBounds {
    self.layer.cornerRadius = cornerRadius;
    self.layer.masksToBounds = masksToBounds;
}

- (void)al_configCornerWithCorners:(ALViewCorner) corners
                            radius:(CGFloat) radius
                     masksToBounds:(BOOL) masksToBounds {
    UIRectCorner v = 0;
    
    if ((corners & ALViewCornerAllCorners) == ALViewCornerAllCorners) {
        v = UIRectCornerAllCorners;
    } else if (corners == ALViewCornerEmpty){
        self.layer.mask = nil;
        return;
    } else {
        if (corners & ALViewCornerTopLeft) {
            v = v | UIRectCornerTopLeft;
        }
        if (corners & ALViewCornerTopRight) {
            v = v | UIRectCornerTopRight;
        }
        if (corners & ALViewCornerBottomLeft) {
            v = v | UIRectCornerBottomLeft;
        }
        if (corners & ALViewCornerBottomRight) {
            v = v | UIRectCornerBottomRight;
        }
    }
    CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
    shapeLayer.path = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                            byRoundingCorners:v
                                                  cornerRadii:(CGSizeMake(radius, radius))].CGPath;
    self.layer.mask = shapeLayer;
    self.layer.masksToBounds = masksToBounds;
}

- (void)al_configShadowWithColor:(UIColor *_Nullable) color
                          offset:(CGSize) offset
                          radius:(CGFloat) radius
                         opacity:(CGFloat) opacity
                            path:(UIBezierPath *_Nullable) path {
    self.layer.shadowColor = color.CGColor;
    self.layer.shadowOffset = offset;
    self.layer.shadowRadius = radius;
    self.layer.shadowOpacity = opacity;
    self.layer.shadowPath = path.CGPath;
}


- (void)al_configGradientAndColors:(NSArray <UIColor *> *_Nullable) colors
                         locations:(NSArray<NSNumber *> * _Nullable) locations
                        startPoint:(CGPoint) startPoint
                          endPoint:(CGPoint) endPoint
                              type:(ALGradientLayerType) type {
    CAGradientLayer *gradient = [self al_getAssociatedValueWithKey:@"alGradient"];
    if (!gradient) {
        gradient = [CAGradientLayer layer];
        [self al_setAssociatedValue:gradient key:@"alGradient" policy:ALAssociationPolicy_RetainNonantomic];
    }
    gradient.frame = self.bounds;
    NSMutableArray *array = [NSMutableArray array];
    [colors enumerateObjectsUsingBlock:^(UIColor * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [array addObject:(__bridge id)(obj.CGColor)];
    }];
    gradient.locations = locations;
    gradient.colors = array;
    NSString *t = @"";
    switch (type) {
        case ALGradientLayerTypeAxial:
            t = kCAGradientLayerAxial;
            break;
        case ALGradientLayerTypeRadial:
            t = kCAGradientLayerRadial;
            break;
        case ALGradientLayerTypeConic:
            t = kCAGradientLayerConic;
            break;
        default:
            t = kCAGradientLayerAxial;
            break;
    }
    gradient.type = t;
    gradient.startPoint = startPoint;
    gradient.endPoint = endPoint;
    [self.layer addSublayer:gradient];
    [self.layer insertSublayer:gradient atIndex:0];
}

@end
