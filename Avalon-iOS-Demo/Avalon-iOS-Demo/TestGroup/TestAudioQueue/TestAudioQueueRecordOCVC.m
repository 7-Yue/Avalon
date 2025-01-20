#import "TestAudioQueueRecordOCVC.h"
#import "Masonry.h"
#import <AvalonFramework/AvalonFramework.h>

@interface TestAudioQueueRecordOCVC ()

@property (nonatomic, strong) NSMutableArray *dataList;

@end

@implementation TestAudioQueueRecordOCVC

- (NSMutableArray *)dataList {
    if(!_dataList) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = UIColor.whiteColor;

    {
        UIButton *prepare = [self createButtonWithTitle:@"准备" sel:@selector(_prepareAction)];
        [self.view addSubview:prepare];
        [prepare mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.top.equalTo(self.view).offset(100);
            make.width.equalTo(@100);
            make.height.equalTo(@40);
        }];
    }

    {
        UIButton *callback = [self createButtonWithTitle:@"配置回调" sel:@selector(_callbackAction)];
        [self.view addSubview:callback];
        [callback mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.top.equalTo(self.view).offset(150);
            make.width.equalTo(@100);
            make.height.equalTo(@40);
        }];
    }

    {
        UIButton *record = [self createButtonWithTitle:@"录制" sel:@selector(_recordAction)];
        [self.view addSubview:record];
        [record mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.top.equalTo(self.view).offset(200);
            make.width.equalTo(@100);
            make.height.equalTo(@40);
        }];
    }

    {
        UIButton *pause = [self createButtonWithTitle:@"暂停" sel:@selector(_pauseAction)];
        [self.view addSubview:pause];
        [pause mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.top.equalTo(self.view).offset(250);
            make.width.equalTo(@100);
            make.height.equalTo(@40);
        }];
    }

    {
        UIButton *stop = [self createButtonWithTitle:@"停止" sel:@selector(_stopAction)];
        [self.view addSubview:stop];
        [stop mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.top.equalTo(self.view).offset(300);
            make.width.equalTo(@100);
            make.height.equalTo(@40);
        }];
    }

    {
        UIButton *prepare = [self createButtonWithTitle:@"play准备" sel:@selector(_play_prepareAction)];
        [self.view addSubview:prepare];
        [prepare mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.top.equalTo(self.view).offset(400);
            make.width.equalTo(@100);
            make.height.equalTo(@40);
        }];
    }

    {
        UIButton *play = [self createButtonWithTitle:@"播放" sel:@selector(_play_playAction)];
        [self.view addSubview:play];
        [play mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.top.equalTo(self.view).offset(450);
            make.width.equalTo(@100);
            make.height.equalTo(@40);
        }];
    }

    {
        UIButton *enqueue = [self createButtonWithTitle:@"塞入" sel:@selector(_play_enqueueAction)];
        [self.view addSubview:enqueue];
        [enqueue mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.top.equalTo(self.view).offset(500);
            make.width.equalTo(@100);
            make.height.equalTo(@40);
        }];
    }

    {
        UIButton *pause = [self createButtonWithTitle:@"暂停" sel:@selector(_play_pauseAction)];
        [self.view addSubview:pause];
        [pause mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.top.equalTo(self.view).offset(550);
            make.width.equalTo(@100);
            make.height.equalTo(@40);
        }];
    }

    {
        UIButton *stop = [self createButtonWithTitle:@"停止" sel:@selector(_play_stopAction)];
        [self.view addSubview:stop];
        [stop mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.top.equalTo(self.view).offset(600);
            make.width.equalTo(@100);
            make.height.equalTo(@40);
        }];
    }

}

- (UIButton *)createButtonWithTitle:(NSString *) title sel:(SEL) sel {
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectZero];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [btn addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
    btn.layer.borderColor = UIColor.blackColor.CGColor;
    btn.layer.borderWidth = 1.0;
    return btn;
}

- (void)_prepareAction {
    AudioStreamBasicDescription des = ALStandardPCMAudioStreamBasicDescription();
    [[ALAudioQueueRecoder shareInstance] recoderPrepareWithSampleRate:des.mSampleRate
                                                             formatID:des.mFormatID
                                                          formatFlags:des.mFormatFlags
                                                       bytesPerPacket:des.mBytesPerPacket
                                                      framesPerPacket:des.mFramesPerPacket
                                                        bytesPerFrame:des.mBytesPerFrame
                                                     channelsPerFrame:des.mChannelsPerFrame
                                                       bitsPerChannel:des.mBitsPerChannel
                                                          maxDataSize:8000];
    NSLog(@"%s",__PRETTY_FUNCTION__);
}

- (void)_recordAction {
    [[ALAudioQueueRecoder shareInstance] start];
    NSLog(@"%s",__PRETTY_FUNCTION__);
}

- (void)_callbackAction {
    [[ALAudioQueueRecoder shareInstance] recodCallback:^(NSData * _Nonnull data) {
        NSLog(@"Data size: %ld", data.length);
        [self.dataList addObject: data];
    }];
    NSLog(@"%s",__PRETTY_FUNCTION__);
}

- (void)_pauseAction {
    [[ALAudioQueueRecoder shareInstance] pause];
    NSLog(@"%s",__PRETTY_FUNCTION__);
}

- (void)_stopAction {
    [[ALAudioQueueRecoder shareInstance] stop];
    NSLog(@"%s",__PRETTY_FUNCTION__);
}

- (void)_play_prepareAction {
    AudioStreamBasicDescription des = ALStandardPCMAudioStreamBasicDescription();
    [[ALAudioQueuePlayer shareInstance] playerPrepareWithSampleRate:des.mSampleRate
                                                           formatID:des.mFormatID
                                                        formatFlags:des.mFormatFlags
                                                     bytesPerPacket:des.mBytesPerPacket
                                                    framesPerPacket:des.mFramesPerPacket
                                                      bytesPerFrame:des.mBytesPerFrame
                                                   channelsPerFrame:des.mChannelsPerFrame
                                                     bitsPerChannel:des.mBitsPerChannel
                                                        maxDataSize:8000];
    NSLog(@"%s",__PRETTY_FUNCTION__);
}

- (void)_play_playAction {
    [[ALAudioQueuePlayer shareInstance] start];
    NSLog(@"%s",__PRETTY_FUNCTION__);
}

- (void)_play_enqueueAction {
    [self.dataList enumerateObjectsUsingBlock:^(NSData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [[ALAudioQueuePlayer shareInstance] enqueueData:obj];
    }];
    NSLog(@"%s",__PRETTY_FUNCTION__);
}

- (void)_play_pauseAction {
    [[ALAudioQueuePlayer shareInstance] pause];
    NSLog(@"%s",__PRETTY_FUNCTION__);
}

- (void)_play_stopAction {
    [[ALAudioQueuePlayer shareInstance] stop];
    NSLog(@"%s",__PRETTY_FUNCTION__);
}


@end
