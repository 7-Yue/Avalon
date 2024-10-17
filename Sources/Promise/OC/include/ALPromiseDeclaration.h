#import <Foundation/Foundation.h>

@class ALPromise;
@class ALPromiseResult;

#ifndef ALPromiseDeclaration_h
#define ALPromiseDeclaration_h

#define AL_FAST_MAIN_BLOCK(block) \
    if ([NSThread isMainThread]) { \
        block(); \
    } else { \
        dispatch_async(dispatch_get_main_queue(), block); \
    }

#define AL_FAST_GLOBAL_BLOCK(block) \
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);

typedef NS_ENUM(NSUInteger, ALPromiseStatus) {
    ALPromiseStatusPending = 0,
    ALPromiseStatusFulfilled = 1,
    ALPromiseStatusRejected = 2,
} NS_SWIFT_UNAVAILABLE("仅OC可用");

typedef void (^ALPromiseCallback)(ALPromiseResult * _Nullable) NS_SWIFT_UNAVAILABLE("仅OC可用");
typedef void (^ALPromiseCreate)(ALPromiseCallback _Nullable) NS_SWIFT_UNAVAILABLE("仅OC可用");
typedef ALPromiseResult * _Nullable (^ALPromiseThen)(id _Nullable) NS_SWIFT_UNAVAILABLE("仅OC可用");
typedef void (^ALPromiseDetect)(NSError * _Nullable) NS_SWIFT_UNAVAILABLE("仅OC可用");
typedef void (^ALPromiseFinaly)(void) NS_SWIFT_UNAVAILABLE("仅OC可用");


#endif
