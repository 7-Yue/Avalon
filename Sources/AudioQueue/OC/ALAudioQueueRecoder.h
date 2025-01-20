#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface ALAudioQueueRecoder : NSObject

+ (instancetype _Nonnull)shareInstance;

- (void)recoderPrepareWithSampleRate:(Float64)             mSampleRate
                            formatID:(AudioFormatID)       mFormatID
                         formatFlags:(AudioFormatFlags)    mFormatFlags
                      bytesPerPacket:(UInt32)              mBytesPerPacket
                     framesPerPacket:(UInt32)              mFramesPerPacket
                       bytesPerFrame:(UInt32)              mBytesPerFrame
                    channelsPerFrame:(UInt32)              mChannelsPerFrame
                      bitsPerChannel:(UInt32)              mBitsPerChannel
                         maxDataSize:(UInt32)              maxDataSize;

- (void)recodCallback:(void(^ _Nullable)(NSData * _Nonnull)) callback;

- (void)start;
- (void)pause;
- (void)stop;

@end

void ALAudioQueueInputCallback(void * __nullable userData,
                               AudioQueueRef _Nonnull queueRef,
                               AudioQueueBufferRef _Nonnull queueBufferRef,
                               const AudioTimeStamp * _Nonnull startTime,
                               UInt32 packetNum,
                               const AudioStreamPacketDescription * __nullable packetDes);

