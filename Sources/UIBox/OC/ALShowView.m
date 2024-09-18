#import "ALShowView.h"

@interface ALShowView ()

@property (nonatomic, strong) UIView *tempView;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;

@end

@implementation ALShowView

+ (void)initialize {
    if (self != [ALShowView class]) {
        [NSException raise:NSInternalInconsistencyException
                    format:@"Subclassing ALShowView is not allowed."];
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self al_reloadShowViewoConfig];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self al_reloadShowViewoConfig];
}

- (void)al_reloadShowViewoConfig {
    UIRectCorner v = 0;
    
    if ((self.corners & ALShowViewCornerAllCorners) == ALShowViewCornerAllCorners) {
        v = UIRectCornerAllCorners;
    } else if (self.corners == ALShowViewCornerEmpty){
        
    } else {
        if (self.corners & ALShowViewCornerTopLeft) {
            v = v | UIRectCornerTopLeft;
        }
        if (self.corners & ALShowViewCornerTopRight) {
            v = v | UIRectCornerTopRight;
        }
        if (self.corners & ALShowViewCornerBottomLeft) {
            v = v | UIRectCornerBottomLeft;
        }
        if (self.corners & ALShowViewCornerBottomRight) {
            v = v | UIRectCornerBottomRight;
        }
    }
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                               byRoundingCorners:v
                                                     cornerRadii:(CGSizeMake(self.cornerRadius, self.cornerRadius))];
    if (self.corners == ALShowViewCornerEmpty) {
        self.layer.shadowPath = nil;
    } else {
        self.layer.shadowPath = path.CGPath;
    }
    
    if (self.cornerRadius && self.corners) {
        [self addSubview:self.tempView];
        [self insertSubview:self.tempView atIndex:0];
        self.tempView.frame = self.bounds;
        CAShapeLayer *mask = [CAShapeLayer layer];
        mask.path = path.CGPath;
        self.tempView.layer.mask = mask;
        self.tempView.backgroundColor = self.cornerLayerColor;
    } else {
        [self.tempView removeFromSuperview];
    }
    
    if (self.gradientColors) {
        if (self.tempView.superview) {
            [self.tempView.layer addSublayer:self.gradientLayer];
        } else {
            [self.layer addSublayer:self.gradientLayer];
        }
        self.gradientLayer.frame = self.bounds;
        NSMutableArray *array = [NSMutableArray array];
        [self.gradientColors enumerateObjectsUsingBlock:^(UIColor * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [array addObject:(__bridge id)(obj.CGColor)];
        }];
        self.gradientLayer.locations = self.gradientLocations;
        self.gradientLayer.colors = array;
        NSString *t = @"";
        switch (self.gradientType) {
            case ALShowViewGradientLayerTypeAxial:
                t = kCAGradientLayerAxial;
                break;
            case ALShowViewGradientLayerTypeRadial:
                t = kCAGradientLayerRadial;
                break;
            case ALShowViewGradientLayerTypeConic:
                t = kCAGradientLayerConic;
                break;
            default:
                t = kCAGradientLayerAxial;
                break;
        }
        self.gradientLayer.type = t;
        self.gradientLayer.startPoint = self.gradientStartPoint;
        self.gradientLayer.endPoint = self.gradientEndPoint;
    } else {
        [self.gradientLayer removeFromSuperlayer];
        self.tempView.backgroundColor = self.cornerLayerColor;
    }
    [self.tempView.layer masksToBounds];
    [self.layer masksToBounds];
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
}

- (void)setCorners:(ALShowViewCorner)corners {
    _corners = corners;
}

- (void)setCornerLayerColor:(UIColor *)cornerLayerColor {
    _cornerLayerColor = cornerLayerColor;
}

- (void)setShadowColor:(UIColor *)shadowColor {
    _shadowColor = shadowColor;
    self.layer.shadowColor = shadowColor.CGColor;
}

- (void)setShadowOffset:(CGSize)shadowOffset {
    _shadowOffset = shadowOffset;
    self.layer.shadowOffset = shadowOffset;
}

- (void)setShadowRadius:(CGFloat)shadowRadius {
    _shadowRadius = shadowRadius;
    self.layer.shadowRadius = shadowRadius;
}

- (void)setShadowOpacity:(CGFloat)shadowOpacity {
    _shadowOpacity = shadowOpacity;
    self.layer.shadowOpacity = shadowOpacity;
}

- (void)setGradientColors:(NSArray<UIColor *> *)gradientColors {
    _gradientColors = gradientColors;
}

- (void)setGradientLocations:(NSArray<NSNumber *> *)gradientLocations {
    _gradientLocations = gradientLocations;
}

- (void)setGradientStartPoint:(CGPoint)gradientStartPoint {
    _gradientStartPoint = gradientStartPoint;
}

- (void)setGradientEndPoint:(CGPoint)gradientEndPoint {
    _gradientEndPoint = gradientEndPoint;
}

- (void)setGradientType:(ALShowViewGradientLayerType)gradientType {
    _gradientType = gradientType;
}

- (UIView *)tempView {
    if(!_tempView) {
        _tempView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _tempView;
}

- (CAGradientLayer *)gradientLayer {
    if(!_gradientLayer) {
        _gradientLayer = [CAGradientLayer layer];
    }
    return _gradientLayer;
}

@end
