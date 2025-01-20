#import "ALAudioQueueRecoder.h"

@interface ALAudioQueueRecoder()

@end

@implementation ALAudioQueueRecoder

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    static ALAudioQueueRecoder *obj = nil;
    dispatch_once(&onceToken, ^{
        obj = [[ALAudioQueueRecoder alloc] init];
    });
    return obj;
}

@end
