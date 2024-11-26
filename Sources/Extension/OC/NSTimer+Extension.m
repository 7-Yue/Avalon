#import "NSTimer+Extension.h"

@interface AL_WeakTimerContainer : NSObject
@property(nonatomic, weak) id weakTarget;
@property(nonatomic, weak) NSTimer *weakTimer;
@end

@implementation AL_WeakTimerContainer

- (instancetype)initWithWeakTarget:(id)weakTarget {
    self = [super init];
    if (self) {
        self.weakTarget = weakTarget;
    }
    return self;
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    return _weakTarget;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    if (!self.weakTarget) {
        [self.weakTimer invalidate];
    }
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    return [_weakTarget respondsToSelector:aSelector];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    if (_weakTarget) {
        return [super methodSignatureForSelector:aSelector];
    }
    return [NSMethodSignature signatureWithObjCTypes:"v@:"];
}

@end

@implementation NSTimer (Extension)

+ (NSTimer *)al_scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                    weakTarget:(_Nonnull id)weakTarget
                                      selector:(SEL)aSelector
                                      userInfo:(nullable id)userInfo
                                        repeat:(BOOL)isRepeat {
    AL_WeakTimerContainer *obj = [[AL_WeakTimerContainer alloc] initWithWeakTarget:weakTarget];
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:interval
                                                      target:obj
                                                    selector:aSelector
                                                    userInfo:userInfo
                                                     repeats:isRepeat];
    obj.weakTimer = timer;
    return timer;
}

@end
