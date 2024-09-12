#import "NSObject+Extension.h"
#import <objc/runtime.h>

void SwizzleMethod(Class cls,
                   SEL originalSelector,
                   SEL swizzledSelector,
                   BOOL isClassMethod) {
    Method originalMethod;
    Method swizzledMethod;
    
    if (isClassMethod) {
        originalMethod = class_getClassMethod(cls, originalSelector);
        swizzledMethod = class_getClassMethod(cls, swizzledSelector);
    } else {
        originalMethod = class_getInstanceMethod(cls, originalSelector);
        swizzledMethod = class_getInstanceMethod(cls, swizzledSelector);
    }

    BOOL didAddMethod = class_addMethod(cls,
                                        originalSelector,
                                        method_getImplementation(swizzledMethod),
                                        method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(cls,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@implementation NSObject (Extension)

- (void)al_setAssociatedValue:(id _Nullable) value key:(NSString * _Nonnull) key policy:(ALAssociationPolicy) policy {
    NSString *k = [NSString stringWithFormat:@"al_oc_%@", key];
    switch (policy) {
        case ALAssociationPolicy_Assign:
            objc_setAssociatedObject(self, NSSelectorFromString(k), value, OBJC_ASSOCIATION_ASSIGN);
            break;
        case ALAssociationPolicy_Weak: {
            __weak id w_value = value;
            id _Nullable (^handler)(void) = ^() {
                return w_value;
            };
            objc_setAssociatedObject(self, NSSelectorFromString(k), handler, OBJC_ASSOCIATION_COPY_NONATOMIC);
            break;
        }
        case ALAssociationPolicy_Copy:
            objc_setAssociatedObject(self, NSSelectorFromString(k), value, OBJC_ASSOCIATION_COPY);
            break;
        case ALAssociationPolicy_CopyNonantomic:
            objc_setAssociatedObject(self, NSSelectorFromString(k), value, OBJC_ASSOCIATION_COPY_NONATOMIC);
            break;
        case ALAssociationPolicy_Retain:
            objc_setAssociatedObject(self, NSSelectorFromString(k), value, OBJC_ASSOCIATION_RETAIN);
            break;
        case ALAssociationPolicy_RetainNonantomic:
            objc_setAssociatedObject(self, NSSelectorFromString(k), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            break;
    }
}

- (id _Nullable)al_getAssociatedValueWithKey:(NSString * _Nonnull) key {
    NSString *k = [NSString stringWithFormat:@"al_oc_%@", key];
    id value = objc_getAssociatedObject(self, NSSelectorFromString(k));
    if ([value isKindOfClass:NSClassFromString(@"__NSMallocBlock__")]) {
        id _Nullable (^handler)(void) = value;
        return handler();
    }
    return value;
}

@end
