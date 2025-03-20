#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface ALAudioQueuePlayer: NSObject

+ (instancetype _Nonnull)shareInstance;

- (void)playerPrepareWithSampleRate:(Float64)             mSampleRate
                           formatID:(AudioFormatID)       mFormatID
                        formatFlags:(AudioFormatFlags)    mFormatFlags
                     bytesPerPacket:(UInt32)              mBytesPerPacket
                    framesPerPacket:(UInt32)              mFramesPerPacket
                      bytesPerFrame:(UInt32)              mBytesPerFrame
                   channelsPerFrame:(UInt32)              mChannelsPerFrame
                     bitsPerChannel:(UInt32)              mBitsPerChannel
                        maxDataSize:(UInt32)              maxDataSize;

- (void)enqueueData:(NSData * _Nullable) data;

- (void)start;
- (void)pause;
- (void)stopAndReset;

@end

void ALAudioPlayerOutputCallback(void * _Nullable userData,
                                 AudioQueueRef _Nonnull queueRef,
                                 AudioQueueBufferRef _Nonnull queueBufferRef);


