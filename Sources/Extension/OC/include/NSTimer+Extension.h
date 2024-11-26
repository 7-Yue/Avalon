#import <Foundation/Foundation.h>

@interface NSTimer (Extension)

/// 定时器
/// - Parameters:
///   - interval: 间隔
///   - weakTarget: 弱引用的target，如果NSTimer还在运行target已经释放，timer会自动释放
///   - aSelector: 函数
///   - userInfo: 信息
///   - yesOrNo: 是否重复
+ (NSTimer *_Nonnull)al_scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                            weakTarget:(_Nonnull id)weakTarget
                                              selector:(_Nonnull SEL)aSelector
                                              userInfo:(nullable id)userInfo
                                                repeat:(BOOL)isRepeat NS_SWIFT_UNAVAILABLE("仅OC可用");

@end
