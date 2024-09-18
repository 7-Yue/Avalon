#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ALAssociationPolicy) {
    ALAssociationPolicy_Assign              = 1,
    ALAssociationPolicy_Weak                = 2,
    ALAssociationPolicy_Copy                = 3,
    ALAssociationPolicy_CopyNonantomic      = 4,
    ALAssociationPolicy_Retain              = 5,
    ALAssociationPolicy_RetainNonantomic    = 6
} NS_SWIFT_UNAVAILABLE("仅OC可用");


/// 方法交换【❗目前测试下来，在swift里无法对oc的子类进行swift里创造的函数进行方法交换，只能在oc侧实现】
/// - Parameters:
///   - cls: 交换类
///   - originalSelector: 原始方法
///   - swizzledSelector: 交换方法
///   - isClassMethod: 是否是类方法
FOUNDATION_EXTERN void SwizzleMethod(Class _Nonnull cls,
                                     SEL _Nonnull originalSelector,
                                     SEL _Nonnull swizzledSelector,
                                     BOOL isClassMethod) NS_SWIFT_UNAVAILABLE("仅OC可用");

@interface NSObject (Extension)

/// 设置当前对象的关联属性
/// - Parameters:
///   - value: 关联值
///   - key: 关联key
///   - policy: 关联策略
- (void)al_setAssociatedValue:(id _Nullable) value
                          key:(NSString * _Nonnull) key
                       policy:(ALAssociationPolicy) policy NS_SWIFT_UNAVAILABLE("仅OC可用");


/// 获取关联值
/// - Parameter key: 关联key
- (id _Nullable)al_getAssociatedValueWithKey:(NSString * _Nonnull) key NS_SWIFT_UNAVAILABLE("仅OC可用");

@end

