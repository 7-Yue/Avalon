#import "ALAudioQueueRecoder.h"
#import "ALAudioQueueConst.h"

@interface ALAudioQueueRecoder()

@property(nonatomic, assign) BOOL isPrepared;
@property(nonatomic, assign) BOOL isRunning;
@property(nonatomic, copy) void(^callback)(NSData *);

@end

@implementation ALAudioQueueRecoder {
    AudioQueueRef audioQueueRef;
    AudioStreamBasicDescription inFormat;
    AudioQueueBufferRef audioBuffers[kBufferCount];
}


+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    static ALAudioQueueRecoder *obj = nil;
    dispatch_once(&onceToken, ^{
        obj = [[ALAudioQueueRecoder alloc] init];
    });
    return obj;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.isPrepared = NO;
        self.isRunning = NO;
    }
    return self;
}

- (void)_recordBufferCallBackWithUserData:(void *_Nullable)userData
                                 queueRef:(AudioQueueRef _Nonnull)queueRef
                           queueBufferRef:(AudioQueueBufferRef _Nonnull)queueBufferRef
                                startTime:(const AudioTimeStamp *_Nonnull)startTime
                                packetNum:(UInt32)packetNum
                        packetDescription:(const AudioStreamPacketDescription * _Nullable)packetDes {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSData *data = [[NSData alloc] initWithBytes:queueBufferRef->mAudioData
                                              length:queueBufferRef->mAudioDataByteSize];
        if (self.callback) {
            self.callback(data);
        }
    });

    OSStatus status = AudioQueueEnqueueBuffer(self->audioQueueRef, queueBufferRef, 0, NULL);
    if (status != noErr) {
        Log(@"【AudioQueueEnqueueBuffer】 error code %d", status);
    }
}

- (void)recoderPrepareWithSampleRate:(Float64)             mSampleRate
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
        for (int i = 0; i < kBufferCount; i++) {
            self->audioBuffers[i] = NULL;
        }
        memset(&self->inFormat, 0, sizeof(self->inFormat));
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
    // 使用recoder的内部线程播放
    OSStatus status = AudioQueueNewInput(&self->inFormat,
                                          ALAudioQueueInputCallback,
                                          (__bridge void *)self,
                                          NULL,
                                          kCFRunLoopCommonModes,
                                          0,
                                          &self->audioQueueRef);
    if (status != noErr) {
        Log(@"【AudioQueueNewInput】 error code %d", status);
        return;
    }

    for (int i = 0; i < kBufferCount; i++) {
        OSStatus status = AudioQueueAllocateBuffer(self->audioQueueRef, maxDataSize, &audioBuffers[i]);
        if (status != noErr) {
            Log(@"【AudioQueueAllocateBuffer】 error code %d", status);
            return;
        }

        status = AudioQueueEnqueueBuffer(self->audioQueueRef, audioBuffers[i], 0, NULL);
        if (status != noErr) {
            Log(@"【AudioQueueEnqueueBuffer】 error code %d", status);
            return;
        }
    }

    self.isPrepared = YES;
}

- (void)recodCallback:(void(^)(NSData *)) callback {
    self.callback = callback;
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

- (void)stopAndReset {
    self.isPrepared = NO;
    OSStatus status = AudioQueueStop(self->audioQueueRef, true);
    if (status != noErr) {
        Log(@"【AudioQueueStop】 error code %d", status);
        return;
    }
    self.isRunning = NO;
    AudioQueueDispose(self->audioQueueRef, true);
    self->audioQueueRef = NULL;
    for (int i = 0; i < kBufferCount; i++) {
        self->audioBuffers[i] = NULL;
    }
    memset(&self->inFormat, 0, sizeof(self->inFormat));
}

@end

void ALAudioQueueInputCallback(void * __nullable userData,
                               AudioQueueRef _Nonnull queueRef,
                               AudioQueueBufferRef _Nonnull queueBufferRef,
                               const AudioTimeStamp * _Nonnull startTime,
                               UInt32 packetNum,
                               const AudioStreamPacketDescription * __nullable packetDes) {
    ALAudioQueueRecoder *o = (__bridge ALAudioQueueRecoder *)userData;
    [o _recordBufferCallBackWithUserData:userData
                                queueRef:queueRef
                          queueBufferRef:queueBufferRef
                               startTime:startTime
                               packetNum:packetNum
                       packetDescription:packetDes];
}
