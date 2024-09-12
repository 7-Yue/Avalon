#import "UIView+Extension.h"
#import "NSObject+Extension.h"

@implementation UIView (Extension)

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


- (void)al_configCornerAndShadowWithCorners:(ALViewCorner) corners
                               cornerRadius:(CGFloat) cornerRadius
                              masksToBounds:(BOOL) masksToBounds
                                      color:(UIColor *_Nullable) color
                                     offset:(CGSize) offset
                               shadowRadius:(CGFloat) shadowRadius
                                    opacity:(CGFloat) opacity
                                       path:(UIBezierPath *_Nullable) path {
    self.layer.shadowColor = color.CGColor;
    self.layer.shadowOffset = offset;
    self.layer.shadowRadius = shadowRadius;
    self.layer.shadowOpacity = opacity;
    self.layer.shadowPath = path.CGPath;
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
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
    maskLayer.path = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                           byRoundingCorners:v
                                                 cornerRadii:(CGSizeMake(cornerRadius, cornerRadius))].CGPath;
    [self.layer addSublayer:maskLayer];
    [self.layer insertSublayer:maskLayer atIndex:0];
}

@end
