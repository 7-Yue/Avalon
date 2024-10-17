#import "ALPromise.h"
#import "ALPromiseExecute.h"

static int ALPromiseCount = 0;

@interface ALPromise ()

@property(nonatomic, readwrite, strong) dispatch_queue_t queue;
@property(nonatomic, readwrite, assign) ALPromiseStatus status;
@property(nonatomic, readwrite, strong, nullable) ALPromiseResult *result;
@property(nonatomic, readwrite, strong, nullable) id<ALPromiseExecuteProtocol> execute;
@property(nonatomic, readwrite, copy, nullable) NSMutableArray<ALPromise *> *promiseList;
@end

@implementation ALPromise

- (void)dealloc {
#ifdef DEBUG
    ALPromiseCount -= 1;
    NSLog(@"ALPromise--释放--%d", ALPromiseCount);
#endif
}

- (instancetype)init {
    self = [super init];
    if (self) {
#ifdef DEBUG
        ALPromiseCount += 1;
        NSLog(@"ALPromise--创建--%d", ALPromiseCount);
#endif
        self.status = ALPromiseStatusPending;
    }
    return self;
}

- (dispatch_queue_t)queue {
    if (!_queue) {
        _queue = dispatch_queue_create(NULL, DISPATCH_QUEUE_SERIAL);
    }
    return _queue;
}

- (NSMutableArray<ALPromise *> *)promiseList {
    if (!_promiseList) {
        _promiseList = [NSMutableArray array];
    }
    return _promiseList;
}

- (void)_addPromise:(ALPromise *)promise {
    dispatch_async(self.queue, ^{
      [self.promiseList addObject:promise];
    });
}

- (void)_executeFirstPromise {
    dispatch_async(self.queue, ^{
      [self.execute executeWithQueue:self.queue
                           preResult:self.result
                             promise:self];
    });
}

- (void)_executePromise:(ALPromise *)promise {
    dispatch_async(self.queue, ^{
      switch (self.status) {
      case ALPromiseStatusPending:
          break;
      case ALPromiseStatusRejected:
      case ALPromiseStatusFulfilled: {
          [promise.execute executeWithQueue:promise.queue
                                  preResult:self.result
                                    promise:promise];
          break;
      }
      }
    });
}

- (void)_executePromiseList {
    dispatch_async(self.queue, ^{
      [self.promiseList
          enumerateObjectsUsingBlock:^(ALPromise *_Nonnull obj, NSUInteger idx,
                                       BOOL *_Nonnull stop) {
            switch (self.status) {
            case ALPromiseStatusPending:
                break;
            case ALPromiseStatusRejected:
            case ALPromiseStatusFulfilled: {
                [obj.execute executeWithQueue:obj.queue
                                    preResult:self.result
                                      promise:obj];
                break;
            }
            }
          }];
    });
}

- (void)_completeWithPromise:(ALPromise *)promise
                      result:(ALPromiseResult *_Nullable)result {
    self.result = result;
    if (self.result.haveError) {
        self.status = ALPromiseStatusRejected;
    } else {
        self.status = ALPromiseStatusFulfilled;
    }
    [self _executePromiseList];
}

+ (ALPromise *_Nonnull (^)(id _Nullable))resolve {
    return ^ALPromise *(id _Nullable data) {
      ALPromise *p = [[ALPromise alloc] init];
      p.status = ALPromiseStatusFulfilled;
      p.result = ALPromiseResult.fillData(data);
      return p;
    };
}

+ (ALPromise *_Nonnull (^)(NSError *_Nullable))reject {
    return ^ALPromise *(NSError *_Nullable error) {
      ALPromise *p = [[ALPromise alloc] init];
      p.status = ALPromiseStatusRejected;
      p.result = ALPromiseResult.fillError(error);
      return p;
    };
}

+ (ALPromise *_Nonnull (^)(NSArray<ALPromise *> *_Nullable))all {
    return ^ALPromise *(NSArray<ALPromise *> *_Nullable list) {
      ALPromiseAllExecute *execute = [[ALPromiseAllExecute alloc] init];
      execute.promiseList = list;

      ALPromise *p = [[ALPromise alloc] init];
      p.execute = execute;
      [p _executeFirstPromise];
      return p;
    };
}

+ (ALPromise *_Nonnull (^)(NSArray<ALPromise *> *_Nullable))allSettled {
    return ^ALPromise *(NSArray<ALPromise *> *_Nullable list) {
      ALPromiseAllSettledExecute *execute = [[ALPromiseAllSettledExecute alloc] init];
      execute.promiseList = list;

      ALPromise *p = [[ALPromise alloc] init];
      p.execute = execute;
      [p _executeFirstPromise];
      return p;
    };
}

+ (ALPromise *_Nonnull (^)(NSArray<ALPromise *> *_Nullable))any {
    return ^ALPromise *(NSArray<ALPromise *> *_Nullable list) {
      ALPromiseAnyExecute *execute = [[ALPromiseAnyExecute alloc] init];
      execute.promiseList = list;

      ALPromise *p = [[ALPromise alloc] init];
      p.execute = execute;
      [p _executeFirstPromise];
      return p;
    };
}

+ (ALPromise * _Nonnull (^)(NSArray<ALPromise *> * _Nullable))race {
    return ^ALPromise *(NSArray<ALPromise *> *_Nullable list) {
      ALPromiseRaceExecute *execute = [[ALPromiseRaceExecute alloc] init];
      execute.promiseList = list;

      ALPromise *p = [[ALPromise alloc] init];
      p.execute = execute;
      [p _executeFirstPromise];
      return p;
    };
}

+ (ALPromise *_Nonnull (^)(ALPromiseCreate _Nullable))create {
    return ^ALPromise *_Nonnull(ALPromiseCreate _Nullable block) {
        ALPromiseCreateExecute *execute = [[ALPromiseCreateExecute alloc] init];
        execute.block = block;

        ALPromise *p = [[ALPromise alloc] init];
        p.execute = execute;
        [p _executeFirstPromise];
        return p;
    };
}

- (ALPromise *_Nonnull (^)(ALPromiseThen _Nullable))then {
    return ^ALPromise *_Nonnull(ALPromiseThen _Nullable block) {
        ALPromiseThenExecute *execute = [[ALPromiseThenExecute alloc] init];
        execute.block = block;

        ALPromise *p = [[ALPromise alloc] init];
        p.execute = execute;
        [self _addPromise:p];
        [self _executePromise:p];
        return p;
    };
}

- (ALPromise *_Nonnull (^)(ALPromiseDetect _Nullable))detect {
    return ^ALPromise *_Nonnull(ALPromiseDetect _Nullable block) {
        ALPromiseDetectExecute *execute = [[ALPromiseDetectExecute alloc] init];
        execute.block = block;

        ALPromise *p = [[ALPromise alloc] init];
        p.execute = execute;
        [self _addPromise:p];
        [self _executePromise:p];
        return p;
    };
}

- (ALPromise *_Nonnull (^)(ALPromiseFinaly _Nullable))finaly {
    return ^ALPromise *_Nonnull(ALPromiseFinaly _Nullable block) {
        ALPromiseFinallyExecute *execute = [[ALPromiseFinallyExecute alloc] init];
        execute.block = block;

        ALPromise *p = [[ALPromise alloc] init];
        p.execute = execute;
        [self _addPromise:p];
        [self _executePromise:p];
        return p;
    };
}

@end

@interface ALPromiseResult ()
@property(nonatomic, readwrite, assign) BOOL havePromise;
@property(nonatomic, readwrite, strong, nullable) ALPromise *promise;
@property(nonatomic, readwrite, assign) BOOL haveData;
@property(nonatomic, readwrite, strong, nullable) id data;
@property(nonatomic, readwrite, assign) BOOL haveError;
@property(nonatomic, readwrite, strong, nullable) NSError *error;
@end

@implementation ALPromiseResult

+ (ALPromiseResult *_Nonnull (^)(ALPromise *_Nullable))fillPromise {
    return ^ALPromiseResult *_Nonnull(ALPromise *_Nullable promise) {
        ALPromiseResult *r = [[ALPromiseResult alloc] init];
        r.promise = promise;
        r.havePromise = YES;
        return r;
    };
}

+ (ALPromiseResult *_Nonnull (^)(id _Nullable))fillData {
    return ^ALPromiseResult *_Nonnull(id _Nullable data) {
        ALPromiseResult *r = [[ALPromiseResult alloc] init];
        r.data = data;
        r.haveData = YES;
        return r;
    };
}

+ (ALPromiseResult *_Nonnull (^)(NSError *_Nullable))fillError {
    return ^ALPromiseResult *_Nonnull(NSError *_Nullable error) {
        ALPromiseResult *r = [[ALPromiseResult alloc] init];
        r.error = error;
        r.haveError = YES;
        return r;
    };
}

@end
