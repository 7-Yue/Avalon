#import "TestPromiseOCVC.h"
#import <AvalonFramework/AvalonFramework.h>

@interface TestPromiseOCVC ()

@end

@implementation TestPromiseOCVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = UIColor.whiteColor;

    //    [self demo1];
    //    [self demo2];
    //    [self demo3];
    //    [self demo4];
    //    [self demo5];
    //    [self demo6];
    //    [self demo7];
    [self demo8];
}

- (void)demo1 {
    ALPromise
        .create(^(ALPromiseCallback _Nullable callback) {
          NSLog(@"开始");
          dispatch_after(
              dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)),
              dispatch_get_main_queue(), ^{
                callback(ALPromiseResult.fillData(@1));
              });
        })
        .then(^ALPromiseResult *_Nullable(id _Nullable data) {
          return ALPromiseResult.fillData(data);
        })
        .detect(^(NSError *_Nullable error) {
          NSLog(@"%@", error);
        })
        .finaly(^{
          NSLog(@"--");
        });
}

- (void)demo2 {
    ALPromise
        .create(^(ALPromiseCallback _Nullable callback) {
          NSLog(@"开始");
          dispatch_after(
              dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)),
              dispatch_get_main_queue(), ^{
                NSError *e = [NSError errorWithDomain:@"error"
                                                 code:0
                                             userInfo:nil];
                callback(ALPromiseResult.fillError(e));
              });
        })
        .then(^ALPromiseResult *_Nullable(id _Nullable data) {
          return nil;
        })
        .detect(^(NSError *_Nullable error) {
          NSLog(@"%@", error);
        })
        .finaly(^{
          NSLog(@"--");
        });
}

- (void)demo3 {
    ALPromise *p1 = ALPromise.resolve(@1);
    ALPromise *p2 = ALPromise.create(^(ALPromiseCallback _Nullable callback) {
      dispatch_after(
          dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)),
          dispatch_get_main_queue(), ^{
            callback(ALPromiseResult.fillData(@2));
          });
    });
    ALPromise *p3 = ALPromise.resolve(@3);
    ALPromise.all(@[ p1, p2, p3 ])
        .then(^ALPromiseResult *_Nullable(id _Nullable data) {
          NSLog(@"%@", data);
          return nil;
        })
        .detect(^(NSError *_Nullable error) {
          NSLog(@"%@", error);
        })
        .finaly(^{
          NSLog(@"--");
        });
}

- (void)demo4 {
    ALPromise *p1 = ALPromise.resolve(@1);
    ALPromise *p2 = ALPromise.create(^(ALPromiseCallback _Nullable callback) {
      dispatch_after(
          dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)),
          dispatch_get_main_queue(), ^{
            callback(ALPromiseResult.fillError([NSError errorWithDomain:@"e"
                                                                   code:0
                                                               userInfo:nil]));
          });
    });
    ALPromise *p3 = ALPromise.resolve(@3);
    ALPromise.all(@[ p1, p2, p3 ])
        .then(^ALPromiseResult *_Nullable(id _Nullable data) {
          NSLog(@"%@", data);
          return nil;
        })
        .detect(^(NSError *_Nullable error) {
          NSLog(@"%@", error);
        })
        .finaly(^{
          NSLog(@"--");
        });
}

- (void)demo5 {
    ALPromise *p1 = ALPromise.resolve(@1);
    ALPromise *p2 = ALPromise.create(^(ALPromiseCallback _Nullable callback) {
      dispatch_after(
          dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)),
          dispatch_get_main_queue(), ^{
            callback(ALPromiseResult.fillError([NSError errorWithDomain:@"e"
                                                                   code:0
                                                               userInfo:nil]));
          });
    });
    ALPromise *p3 = ALPromise.resolve(@3);
    ALPromise.all(@[ p1, p2, p3 ])
        .then(^ALPromiseResult *_Nullable(id _Nullable data) {
          ALPromise *pa = ALPromise.resolve(@"hello");
          return ALPromiseResult.fillPromise(pa);
        })
        .then(^ALPromiseResult *_Nullable(id _Nullable data) {
          NSLog(@"%@", data);
          return ALPromiseResult.fillPromise(data);
        })
        .detect(^(NSError *_Nullable error) {
          NSLog(@"%@", error);
        })
        .finaly(^{
          NSLog(@"--");
        });
}

- (void)demo6 {
    ALPromise *p1 = ALPromise.resolve(@1);
    ALPromise *p2 = ALPromise.create(^(ALPromiseCallback _Nullable callback1) {
      ALPromise *p = ALPromise.create(^(ALPromiseCallback _Nullable callback2) {
        NSError *error = [NSError errorWithDomain:@"xx" code:0 userInfo:nil];
        callback2(ALPromiseResult.fillError(error));
      });
      callback1(ALPromiseResult.fillPromise(p));
    });
    ALPromise *p3 = ALPromise.reject([NSError errorWithDomain:@"yy"
                                                         code:0
                                                     userInfo:nil]);
    ALPromise.allSettled(@[ p1, p2, p3 ])
        .then(^ALPromiseResult *_Nullable(id _Nullable data) {
          NSLog(@"%@", data);
          return ALPromiseResult.fillPromise(data);
        })
        .detect(^(NSError *_Nullable error) {
          NSLog(@"%@", error);
        })
        .finaly(^{
          NSLog(@"--");
        });
}

- (void)demo7 {
    ALPromise *p1 = ALPromise.reject([NSError errorWithDomain:@"xx"
                                                         code:0
                                                     userInfo:nil]);
    ALPromise *p2 = ALPromise.create(^(ALPromiseCallback _Nullable callback) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            callback(ALPromiseResult.fillData(@1));
        });
    });
    ALPromise *p3 = ALPromise.create(^(ALPromiseCallback _Nullable callback) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            callback(ALPromiseResult.fillError([NSError errorWithDomain:@"yy"
                                                                   code:0
                                                               userInfo:nil]));
        });
    });
    ALPromise.any(@[ p1, p2, p3 ])
        .then(^ALPromiseResult *_Nullable(id _Nullable data) {
          NSLog(@"%@", data);
          return ALPromiseResult.fillPromise(data);
        })
        .detect(^(NSError *_Nullable error) {
          NSLog(@"%@", error);
        })
        .finaly(^{
          NSLog(@"--");
        });
}

- (void)demo8 {
    ALPromise *p1 = ALPromise.create(^(ALPromiseCallback _Nullable callback) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            callback(ALPromiseResult.fillData(@1));
        });
    });
    ALPromise *p2 = ALPromise.create(^(ALPromiseCallback _Nullable callback) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            callback(ALPromiseResult.fillError([NSError errorWithDomain:@"yy"
                                                                   code:0
                                                               userInfo:nil]));
        });
    });
    ALPromise *p3 = ALPromise.create(^(ALPromiseCallback _Nullable callback) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            callback(ALPromiseResult.fillData(@2));
        });
    });
    ALPromise.race(@[ p1, p2, p3 ])
        .then(^ALPromiseResult *_Nullable(id _Nullable data) {
          NSLog(@"%@", data);
          return ALPromiseResult.fillPromise(data);
        })
        .detect(^(NSError *_Nullable error) {
          NSLog(@"%@", error);
        })
        .finaly(^{
          NSLog(@"--");
        });
}

@end
