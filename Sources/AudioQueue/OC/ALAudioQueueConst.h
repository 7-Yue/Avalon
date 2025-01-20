#ifndef ALAudioQueueConst_h
#define ALAudioQueueConst_h

#define kBufferCount 3

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-function"
static AudioStreamBasicDescription ALStandardPCMAudioStreamBasicDescription(void) {
    AudioStreamBasicDescription audioFormat;
    memset(&audioFormat, 0, sizeof(audioFormat));
    audioFormat.mFormatID = kAudioFormatLinearPCM;
    audioFormat.mSampleRate = 44100.0;
    audioFormat.mChannelsPerFrame = 1;
    audioFormat.mBitsPerChannel = 16;
    audioFormat.mBytesPerFrame = audioFormat.mBitsPerChannel / 8 * audioFormat.mChannelsPerFrame;
    audioFormat.mFramesPerPacket = 1;
    audioFormat.mBytesPerPacket = audioFormat.mFramesPerPacket * audioFormat.mBytesPerFrame;
    audioFormat.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    return audioFormat;
}
#pragma clang diagnostic pop

#endif /* ALAudioQueueConst_h */
