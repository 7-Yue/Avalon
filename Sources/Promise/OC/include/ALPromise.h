#import <Foundation/Foundation.h>
#import <AvalonFramework/ALPromiseDeclaration.h>

NS_SWIFT_UNAVAILABLE("仅OC可用")
@interface ALPromise : NSObject

@property (readonly, nullable, class) ALPromise * _Nonnull (^reject)(NSError * _Nullable);
@property (readonly, nullable, class) ALPromise * _Nonnull (^resolve)(id _Nullable);
@property (readonly, nullable, class) ALPromise * _Nonnull (^create)(ALPromiseCreate _Nullable);
@property (readonly, nullable, class) ALPromise * _Nonnull (^all)(NSArray<ALPromise *> * _Nullable);
@property (readonly, nullable, class) ALPromise * _Nonnull (^allSettled)(NSArray<ALPromise *> * _Nullable);
@property (readonly, nullable, class) ALPromise * _Nonnull (^any)(NSArray<ALPromise *> * _Nullable);
@property (readonly, nullable, class) ALPromise * _Nonnull (^race)(NSArray<ALPromise *> * _Nullable);

@property (readonly, nullable) ALPromise * _Nonnull (^then)(ALPromiseThen _Nullable);
@property (readonly, nullable) ALPromise * _Nonnull (^detect)(ALPromiseDetect _Nullable);
@property (readonly, nullable) ALPromise * _Nonnull (^finaly)(ALPromiseFinaly _Nullable);

@end

NS_SWIFT_UNAVAILABLE("仅OC可用");
@interface ALPromiseResult : NSObject

@property (nonatomic, readonly, assign) BOOL havePromise;
@property (nonatomic, readonly, strong, nullable) ALPromise *promise;
@property (nonatomic, readonly, assign) BOOL haveData;
@property (nonatomic, readonly, strong, nullable) id data;
@property (nonatomic, readonly, assign) BOOL haveError;
@property (nonatomic, readonly, strong, nullable) NSError *error;

@property (readonly, nullable, class) ALPromiseResult * _Nonnull (^fillPromise)(ALPromise * _Nullable);
@property (readonly, nullable, class) ALPromiseResult * _Nonnull (^fillData)(id _Nullable);
@property (readonly, nullable, class) ALPromiseResult * _Nonnull (^fillError)(NSError * _Nullable);

@end
