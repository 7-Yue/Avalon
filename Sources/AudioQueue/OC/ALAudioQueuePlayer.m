#import "ALAudioQueuePlayer.h"

#define Log(format, ...) NSLog((@"❌ %s [Line %d] " format), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#define kBufferCount 3

// MARK: -- ALAudioQueueBufferRefWrapper
@interface ALAudioQueueBufferRefWrapper : NSObject

@property (nonatomic, strong) NSData *data;

@end

@implementation ALAudioQueueBufferRefWrapper

- (instancetype)initWithData:(NSData *) data {
    self = [super init];
    if (self) {
        self.data = data;
    }
    return self;
}

@end

// MARK: -- ALAudioQueuePlayer
@interface ALAudioQueuePlayer ()
@property(nonatomic, assign) BOOL isPrepared;
@property(nonatomic, assign) BOOL isRunning;
@property(nonatomic, strong) NSMutableArray<ALAudioQueueBufferRefWrapper *> *bufferList;
@end

@implementation ALAudioQueuePlayer {
    AudioQueueRef audioQueueRef;
    AudioStreamBasicDescription inFormat;
    AudioQueueBufferRef audioBuffers[kBufferCount];
}

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    static ALAudioQueuePlayer *obj = nil;
    dispatch_once(&onceToken, ^{
      obj = [[ALAudioQueuePlayer alloc] init];
    });
    return obj;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.isRunning = NO;
        self.isPrepared = NO;
    }
    return self;
}

- (NSMutableArray<ALAudioQueueBufferRefWrapper *> *)bufferList {
    if(!_bufferList) {
        _bufferList = [NSMutableArray array];
    }
    return _bufferList;
}

- (void)_playBufferCallBack:(AudioQueueBufferRef) queueBufferRef {
    @synchronized(self.bufferList) {
        ALAudioQueueBufferRefWrapper *nextWrapper = self.bufferList.firstObject;
        if (nextWrapper) {
            [self.bufferList removeObject:nextWrapper];
            queueBufferRef->mUserData = (__bridge void *)(nextWrapper);
            if (nextWrapper.data.length > queueBufferRef->mAudioDataBytesCapacity) {
                Log(@"maxDataSize less than data length");
                return;
            }
            memcpy(queueBufferRef->mAudioData, nextWrapper.data.bytes, nextWrapper.data.length);
            queueBufferRef->mAudioDataByteSize = (UInt32)nextWrapper.data.length;
            OSStatus status = AudioQueueEnqueueBuffer(self->audioQueueRef, queueBufferRef, 0, NULL);
            if (status != noErr) {
                Log(@"【AudioQueueEnqueueBuffer】 error code %d", status);
                return;
            }
        } else {
            queueBufferRef->mUserData = NULL;
            queueBufferRef->mAudioDataByteSize = 0;
            if (self.isRunning) {
                AudioQueueStop(self->audioQueueRef, false);
                self.isRunning = NO;
            }
        }
    }
}

- (void)playerPrepareWithSampleRate:(Float64)             mSampleRate
                           formatID:(AudioFormatID)       mFormatID
                        formatFlags:(AudioFormatFlags)    mFormatFlags
                     bytesPerPacket:(UInt32)              mBytesPerPacket
                    framesPerPacket:(UInt32)              mFramesPerPacket
                      bytesPerFrame:(UInt32)              mBytesPerFrame
                   channelsPerFrame:(UInt32)              mChannelsPerFrame
                     bitsPerChannel:(UInt32)              mBitsPerChannel
                        maxDataSize:(UInt32)              maxDataSize {
    if (self->audioQueueRef) {
        AudioQueueDispose(self->audioQueueRef, true);
        self->audioQueueRef = NULL;
        self.isRunning = NO;
        [self.bufferList removeAllObjects];
        for (int i = 0; i < kBufferCount; i++) {
            self->audioBuffers[i] = NULL;
        }
    }
    // 采样率hz
    self->inFormat.mSampleRate = mSampleRate;
    // 编解码类型
    self->inFormat.mFormatID = mFormatID;
    // 编解码指定标记特性
    self->inFormat.mFormatFlags = mFormatFlags;
    // 每个音频帧的通道数
    self->inFormat.mChannelsPerFrame = mChannelsPerFrame;
    // 每个数据包的音频帧数
    self->inFormat.mFramesPerPacket = mFramesPerPacket;
    // 每个数据包的字节数
    self->inFormat.mBytesPerFrame = mBytesPerFrame;
    // 每个音频帧的字节数
    self->inFormat.mBytesPerPacket = mBytesPerPacket;
    // 每个通道的比特数
    self->inFormat.mBitsPerChannel = mBitsPerChannel;
    // 使用player的内部线程播放
    OSStatus status = AudioQueueNewOutput(&self->inFormat,
                                          ALAudioPlayerAQInputCallback,
                                          (__bridge void *)self,
                                          NULL,
                                          kCFRunLoopCommonModes,
                                          0,
                                          &self->audioQueueRef);
    if (status != noErr) {
        Log(@"【AudioQueueNewOutput】 error code %d", status);
        return;
    }

    for (int i = 0; i < kBufferCount; i++) {
        OSStatus status = AudioQueueAllocateBuffer(self->audioQueueRef, maxDataSize, &(self->audioBuffers[i]));
        if (status != noErr) {
            Log(@"【AudioQueueAllocateBuffer】 error code %d", status);
            return;
        }
    }

    self.isPrepared = YES;
}

- (void)enqueueData:(NSData * _Nullable) data {
    if (!self.isPrepared) {
        Log(@"please call【playerPrepare】");
        return;
    }
    @synchronized(self.bufferList) {
        if(!self.isRunning) {
            OSStatus status = AudioQueueStart(self->audioQueueRef, NULL);
            if (status != noErr) {
                Log(@"【AudioQueueStart】 error code %d", status);
            }
            self.isRunning = YES;
        }

        BOOL haveCanUseBuffer = NO;
        for (int i = 0; i < kBufferCount; i++) {
            AudioQueueBufferRef ref = self->audioBuffers[i];
            if (!ref->mUserData) {
                ALAudioQueueBufferRefWrapper *wrapper = [[ALAudioQueueBufferRefWrapper alloc] initWithData:data];
                haveCanUseBuffer = YES;
                ref->mUserData = (__bridge void * _Nullable)(wrapper);
                if (data.length > ref->mAudioDataBytesCapacity) {
                    Log(@"maxDataSize less than data length");
                    return;
                }
                memcpy(ref->mAudioData, data.bytes, data.length);
                ref->mAudioDataByteSize = (UInt32)data.length;
                OSStatus status = AudioQueueEnqueueBuffer(self->audioQueueRef, ref, 0, NULL);
                if (status != noErr) {
                    Log(@"【AudioQueueEnqueueBuffer】 error code %d", status);
                    return;
                }
                return;
            }
        }

        if (!haveCanUseBuffer) {
            ALAudioQueueBufferRefWrapper *wrapper = [[ALAudioQueueBufferRefWrapper alloc] initWithData:data];
            [self.bufferList addObject:wrapper];
        }
    }
}

- (void)start {
    if(!self.isRunning) {
        OSStatus status = AudioQueueStart(self->audioQueueRef, NULL);
        if (status != noErr) {
            Log(@"【AudioQueueStart】 error code %d", status);
            return;
        }
        self.isRunning = YES;
    } else {
        Log(@"Already is running!");
    }
}

- (void)pause {
    if(self.isRunning) {
        OSStatus status = AudioQueuePause(self->audioQueueRef);
        if (status != noErr) {
            Log(@"【AudioQueuePause】 error code %d", status);
            return;
        }
        self.isRunning = NO;
    } else {
        Log(@"Already is stopping!");
    }
}

- (void)stop {
    self.isPrepared = NO;
    OSStatus status = AudioQueueStop(self->audioQueueRef, true);
    if (status != noErr) {
        Log(@"【AudioQueueStop】 error code %d", status);
        return;
    }
    self.isRunning = NO;
    AudioQueueDispose(self->audioQueueRef, true);
    self->audioQueueRef = NULL;
    [self.bufferList removeAllObjects];
    for (int i = 0; i < kBufferCount; i++) {
        self->audioBuffers[i] = NULL;
    }
}

@end

void ALAudioPlayerAQInputCallback(void *userData,
                                  AudioQueueRef queueRef,
                                  AudioQueueBufferRef queueBufferRef) {
    ALAudioQueuePlayer *o = (__bridge ALAudioQueuePlayer *)userData;
    [o _playBufferCallBack:queueBufferRef];
}
