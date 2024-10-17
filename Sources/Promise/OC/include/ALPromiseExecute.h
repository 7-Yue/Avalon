#import <Foundation/Foundation.h>
#import "ALPromiseDeclaration.h"

NS_SWIFT_UNAVAILABLE("仅OC可用");
@protocol ALPromiseExecuteProtocol <NSObject>
-(void)executeWithQueue:(dispatch_queue_t _Nonnull) queue
              preResult:(ALPromiseResult * _Nullable) preResult
                promise:(ALPromise * _Nullable)promise;
@end

NS_SWIFT_UNAVAILABLE("仅OC可用");
@interface ALPromiseAllExecute : NSObject <ALPromiseExecuteProtocol>
@property (nonatomic, copy, nonnull) NSArray<ALPromise *> *promiseList;
@end

NS_SWIFT_UNAVAILABLE("仅OC可用");
@interface ALPromiseAllSettledExecute : NSObject <ALPromiseExecuteProtocol>
@property (nonatomic, copy, nonnull) NSArray<ALPromise *> *promiseList;
@end

NS_SWIFT_UNAVAILABLE("仅OC可用");
@interface ALPromiseAnyExecute : NSObject <ALPromiseExecuteProtocol>
@property (nonatomic, copy, nonnull) NSArray<ALPromise *> *promiseList;
@end

NS_SWIFT_UNAVAILABLE("仅OC可用");
@interface ALPromiseRaceExecute : NSObject <ALPromiseExecuteProtocol>
@property (nonatomic, copy, nonnull) NSArray<ALPromise *> *promiseList;
@end

NS_SWIFT_UNAVAILABLE("仅OC可用");
@interface ALPromiseCreateExecute : NSObject <ALPromiseExecuteProtocol>
@property (nonatomic, copy, nonnull) ALPromiseCreate block;
@end

NS_SWIFT_UNAVAILABLE("仅OC可用");
@interface ALPromiseThenExecute : NSObject <ALPromiseExecuteProtocol>
@property (nonatomic, copy, nonnull) ALPromiseThen block;
@end

NS_SWIFT_UNAVAILABLE("仅OC可用");
@interface ALPromiseDetectExecute : NSObject <ALPromiseExecuteProtocol>
@property (nonatomic, copy, nonnull) ALPromiseDetect block;
@end

NS_SWIFT_UNAVAILABLE("仅OC可用");
@interface ALPromiseFinallyExecute : NSObject <ALPromiseExecuteProtocol>
@property (nonatomic, copy, nonnull) ALPromiseFinaly block;
@end
