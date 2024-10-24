#import "ALPromiseExecute.h"
#import "ALPromise.h"

@interface ALPromise (ALPromiseInterface)
- (void)_completeWithPromise:(ALPromise *)promise
                      result:(ALPromiseResult *_Nullable)result;
@end

@interface ALPromiseAllExecute ()

@end
@implementation ALPromiseAllExecute

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)executeWithQueue:(dispatch_queue_t _Nonnull)queue
               preResult:(ALPromiseResult *_Nullable)preResult
                 promise:(ALPromise *_Nullable)promise {
    __weak typeof(promise) weakPromise = promise;
    NSMutableArray *result = [NSMutableArray array];
    [self.promiseList enumerateObjectsUsingBlock:^(ALPromise *obj,
                                                   NSUInteger idx,
                                                   BOOL *_Nonnull stop) {
      [result addObject:[NSNull null]];
    }];

    __block BOOL flag = NO;
    dispatch_group_t group = dispatch_group_create();
    [self.promiseList
        enumerateObjectsUsingBlock:^(ALPromise *_Nonnull obj,
                                     NSUInteger idx,
                                     BOOL *_Nonnull stop) {
          dispatch_group_enter(group);
          obj.then(^ALPromiseResult *_Nullable(id _Nullable data) {
              result[idx] = data ?: [NSNull null];
              dispatch_group_leave(group);
              return nil;
          });
          obj.detect(^(NSError *_Nullable error) {
              if (!flag) {
                  /*
                   这里注意循环引用，数组引用了promiseList，promiseList里promise持有了封装的block，
                   而参数promise的生命周期应该交给最后的gcd维护
                   */
                  [weakPromise _completeWithPromise:weakPromise
                                             result:ALPromiseResult.fillError(error)];
                  flag = YES;
              }
              dispatch_group_leave(group);
          });
        }];

    dispatch_group_notify(group, dispatch_get_global_queue(0, 0), ^{
        if (flag) {
            return;
        }
        NSMutableArray *values = [NSMutableArray array];
        [result enumerateObjectsUsingBlock:^(id obj,
                                             NSUInteger idx,
                                             BOOL *_Nonnull stop) {
          [values addObject:obj ? obj : [NSNull null]];
        }];
        [promise _completeWithPromise:promise
                               result:ALPromiseResult.fillData(values)];
    });
}

@end

@interface ALPromiseAllSettledExecute ()

@end
@implementation ALPromiseAllSettledExecute
- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)executeWithQueue:(dispatch_queue_t _Nonnull)queue
               preResult:(ALPromiseResult *_Nullable)preResult
                 promise:(ALPromise *_Nullable)promise {
    NSMutableArray *result = [NSMutableArray array];
    [self.promiseList enumerateObjectsUsingBlock:^(ALPromise *obj,
                                                   NSUInteger idx,
                                                   BOOL *_Nonnull stop) {
      [result addObject:[NSNull null]];
    }];

    dispatch_group_t group = dispatch_group_create();
    [self.promiseList
        enumerateObjectsUsingBlock:^(ALPromise *_Nonnull obj,
                                     NSUInteger idx,
                                     BOOL *_Nonnull stop) {
          dispatch_group_enter(group);
          obj.then(^ALPromiseResult *_Nullable(id _Nullable data) {
              result[idx] = data ?: [NSNull null];
              dispatch_group_leave(group);
            return nil;
          });
          obj.detect(^(NSError *_Nullable error) {
              result[idx] = error ?: [NSNull null];
              dispatch_group_leave(group);
          });
        }];

    dispatch_group_notify(group, dispatch_get_global_queue(0, 0), ^{
        NSMutableArray *values = [NSMutableArray array];
        [result enumerateObjectsUsingBlock:^(id obj,
                                             NSUInteger idx,
                                             BOOL *_Nonnull stop) {
          [values addObject:obj ? obj : [NSNull null]];
        }];
        [promise _completeWithPromise:promise
                               result:ALPromiseResult.fillData(values)];
    });
}

@end

@interface ALPromiseAnyExecute ()
@end
@implementation ALPromiseAnyExecute

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)executeWithQueue:(dispatch_queue_t _Nonnull)queue
               preResult:(ALPromiseResult *_Nullable)preResult
                 promise:(ALPromise *_Nullable)promise {
    __weak typeof(promise) weakPromise = promise;
    __block BOOL flag = NO;
    dispatch_group_t group = dispatch_group_create();
    [self.promiseList
        enumerateObjectsUsingBlock:^(ALPromise *_Nonnull obj,
                                     NSUInteger idx,
                                     BOOL *_Nonnull stop) {
          dispatch_group_enter(group);
          obj.then(^ALPromiseResult *_Nullable(id _Nullable data) {
              if (!flag) {
                  // 这里注意循环引用，同理
                  ALPromiseResult *res = ALPromiseResult.fillData(data ?: [NSNull null]);
                  [weakPromise _completeWithPromise:weakPromise
                                             result:res];
                  flag = YES;
              }
              dispatch_group_leave(group);
              return nil;
          });
          obj.detect(^(NSError *_Nullable error) {
              dispatch_group_leave(group);
          });
        }];

    dispatch_group_notify(group, dispatch_get_global_queue(0, 0), ^{
        if (flag) {
            return;
        }
        NSError *e = [NSError errorWithDomain:@"ALPromiseAnyError"
                                         code:-9999
                                     userInfo:nil];
        [promise _completeWithPromise:promise
                               result:ALPromiseResult.fillError(e)];
    });
}

@end

@interface ALPromiseRaceExecute ()

@end

@implementation ALPromiseRaceExecute
- (instancetype)init {
    self = [super init];
    if (self) {

    }
    return self;
}

- (void)executeWithQueue:(dispatch_queue_t)queue
               preResult:(ALPromiseResult *)preResult
                 promise:(ALPromise *)promise {
    __weak typeof(promise) weakPromise = promise;
    __block BOOL flag = NO;
    dispatch_group_t group = dispatch_group_create();
    [self.promiseList enumerateObjectsUsingBlock:^(ALPromise *_Nonnull obj,
                                                   NSUInteger idx,
                                                   BOOL *_Nonnull stop) {
          dispatch_group_enter(group);
          obj.then(^ALPromiseResult *_Nullable(id _Nullable data) {
              if (!flag) {
                  // 这里注意循环引用，同理
                  ALPromiseResult *res = ALPromiseResult.fillData(data ?: [NSNull null]);
                  [weakPromise _completeWithPromise:weakPromise
                                             result:res];
                  flag = YES;
              }
              dispatch_group_leave(group);
              return nil;
          });
          obj.detect(^(NSError *_Nullable error) {
              if (!flag) {
                  // 这里注意循环引用，同理
                  ALPromiseResult *res = ALPromiseResult.fillError(error);
                  [weakPromise _completeWithPromise:weakPromise
                                             result:res];
                  flag = YES;
              }
              dispatch_group_leave(group);
          });
        }];

    dispatch_group_notify(group, dispatch_get_global_queue(0, 0), ^{
        if (flag) {
            return;
        }
        //  这里只是为了让gcd来管理promise的声明周期
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused"
        promise;
#pragma clang diagnostic pop
    });
}
@end

@interface ALPromiseCreateExecute ()
@end

@implementation ALPromiseCreateExecute

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)executeWithQueue:(dispatch_queue_t _Nonnull)queue
               preResult:(ALPromiseResult *_Nullable)preResult
                 promise:(ALPromise *_Nullable)promise {
    __block BOOL flag = NO;
    ALPromiseCallback callback = ^(ALPromiseResult *res) {
        if (flag) {
            return;
        }
        flag = YES;
        if (res.haveData || res.haveError) {
            [promise _completeWithPromise:promise result:res];
        } else if (res.havePromise) {
            res.promise.then(^ALPromiseResult *_Nullable(id _Nullable data) {
                ALPromiseResult *res = ALPromiseResult.fillData(data);
                [promise _completeWithPromise:promise
                                         result:res];
                return nil;
            });

            res.promise.detect(^(NSError *_Nullable error) {
                ALPromiseResult *res = ALPromiseResult.fillError(error);
                [promise _completeWithPromise:promise
                                         result:res];
            });
        } else {
            NSAssert(NO, @"异常结果");
        }
    };
    self.block(callback);
}

@end

@interface ALPromiseThenExecute ()
@end

@implementation ALPromiseThenExecute

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)executeWithQueue:(dispatch_queue_t _Nonnull)queue
               preResult:(ALPromiseResult *_Nullable)preResult
                 promise:(ALPromise *_Nullable)promise {
    __weak typeof(self) weakSelf = self;

    if (preResult.haveData) {
        [promise _completeWithPromise:promise
                               result:self.block(preResult.data)];
    } else if (preResult.haveError) {
        [promise _completeWithPromise:promise result:preResult];
    } else if (preResult.havePromise) {
        preResult.promise
            .then(^ALPromiseResult *_Nullable(id _Nullable data) {
                [promise _completeWithPromise:promise
                                       result:weakSelf.block(data)];
                return nil;
            })
            .detect(^(NSError *_Nullable error) {
                ALPromiseResult *res = ALPromiseResult.fillError(error);
                [promise _completeWithPromise:promise
                                         result:res];
            });
    } else {
        NSAssert(NO, @"异常结果");
    }
}

@end

@interface ALPromiseDetectExecute ()
@end

@implementation ALPromiseDetectExecute

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)executeWithQueue:(dispatch_queue_t _Nonnull)queue
               preResult:(ALPromiseResult *_Nullable)preResult
                 promise:(ALPromise *_Nullable)promise {
    if (preResult.haveError) {
        self.block(preResult.error);
    }
    [promise _completeWithPromise:promise result:preResult];
}

@end

@interface ALPromiseFinallyExecute ()
@end

@implementation ALPromiseFinallyExecute

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)executeWithQueue:(dispatch_queue_t _Nonnull)queue
               preResult:(ALPromiseResult *_Nullable)preResult
                 promise:(ALPromise *_Nullable)promise {
    self.block();
    [promise _completeWithPromise:promise result:preResult];
}

@end
