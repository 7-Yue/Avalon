#import "NSArray+Extension.h"
#import <objc/runtime.h>

@implementation NSArray (Extension)

+ (void)load {
    Class arrayClass = NSClassFromString(@"__NSArray0");

    NSArray *methods = @[
        @"objectAtIndex:",
        @"objectAtIndexedSubscript:",
    ];

    for (NSString *methodName in methods) {
        SEL originalSelector = NSSelectorFromString(methodName);
        SEL safeSelector = NSSelectorFromString([@"al_safe_" stringByAppendingString:methodName]);

        Method originalMethod = class_getInstanceMethod(arrayClass, originalSelector);
        Method safeMethod = class_getInstanceMethod(arrayClass, safeSelector);

        method_exchangeImplementations(originalMethod, safeMethod);
    }
}

- (id)al_safe_objectAtIndex:(NSUInteger)index {
    if (index < self.count) {
         return [self al_safe_objectAtIndex:index];
    } else {
        NSAssert(NO, @"获取异常%@",NSStringFromSelector(_cmd));
        return nil;
    }
}

- (id)al_safe_objectAtIndexedSubscript:(NSUInteger)index {
    if (index < self.count) {
         return [self al_safe_objectAtIndexedSubscript:index];
    } else {
        NSAssert(NO,  @"获取异常%@",NSStringFromSelector(_cmd));
        return nil;
    }
}

@end

@implementation NSMutableArray (Extension)

+ (void)load {
    Class arrayClass = NSClassFromString(@"__NSArrayM");

    NSArray *methods = @[
        @"addObject:",
        @"insertObject:atIndex:",
        @"removeObjectAtIndex:",
        @"objectAtIndex:",
        @"objectAtIndexedSubscript:",
    ];

    for (NSString *methodName in methods) {
        SEL originalSelector = NSSelectorFromString(methodName);
        SEL safeSelector = NSSelectorFromString([@"al_safe_" stringByAppendingString:methodName]);

        Method originalMethod = class_getInstanceMethod(arrayClass, originalSelector);
        Method safeMethod = class_getInstanceMethod(arrayClass, safeSelector);

        method_exchangeImplementations(originalMethod, safeMethod);
    }
}

- (void)al_safe_addObject:(id)object {
    if (object) {
        [self al_safe_addObject:object];
    } else {
        NSAssert(NO, @"添加异常");
    }
}

- (void)al_safe_insertObject:(id)object atIndex:(NSUInteger)index {
    if (object && index <= self.count) {
        [self al_safe_insertObject:object atIndex:index];
    } else {
        NSAssert(NO, @"插入异常");
    }
}

- (void)al_safe_removeObjectAtIndex:(NSUInteger)index {
    if (index < self.count) {
        [self al_safe_removeObjectAtIndex:index];
    } else {
        NSAssert(NO, @"删除异常");
    }
}

- (id)al_safe_objectAtIndex:(NSUInteger)index {
    if (index < self.count) {
         return [self al_safe_objectAtIndex:index];
    } else {
        NSAssert(NO, @"获取异常%@",NSStringFromSelector(_cmd));
        return nil;
    }
}

- (id)al_safe_objectAtIndexedSubscript:(NSUInteger)index {
    if (index < self.count) {
         return [self al_safe_objectAtIndexedSubscript:index];
    } else {
        NSAssert(NO,  @"获取异常%@",NSStringFromSelector(_cmd));
        return nil;
    }
}

@end
