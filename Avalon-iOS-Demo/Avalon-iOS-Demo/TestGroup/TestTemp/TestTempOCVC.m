#import "TestTempOCVC.h"

@interface KEY : NSObject

@end
@implementation KEY

- (void)dealloc {
    NSLog(@"%@ %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
}

@end

@interface VALUE : NSObject

@end

@implementation VALUE

- (void)dealloc {
    NSLog(@"%@ %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
}

@end

@interface TestTempOCVC ()

@property(nonatomic, strong) NSMapTable *mapTable;
@property(nonatomic, strong) KEY *key;

@end

@implementation TestTempOCVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;

    self.key = [KEY new];
    [self.mapTable setObject:[VALUE new] forKey:self.key ];

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"%@", self.mapTable);
    self.key = nil;
    NSLog(@"%@", self.mapTable);
    for (id key in self.mapTable) {
        NSLog(@"%@", key);
    }
    NSEnumerator *r = [self.mapTable objectEnumerator];
    id object;
    while ((object = [r nextObject])) {
        NSLog(@"%@", object);
    }

}

- (NSMapTable *)mapTable {
    if(!_mapTable) {
        _mapTable = [NSMapTable weakToStrongObjectsMapTable];
    }
    return _mapTable;
}

@end
