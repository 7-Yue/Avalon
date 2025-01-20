#import "TestAudioQueuePlayOCVC.h"
#import "Masonry.h"
#import <AvalonFramework/AvalonFramework.h>

@interface TestAudioQueuePlayOCVC ()

@end

@implementation TestAudioQueuePlayOCVC

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
        UIButton *play = [self createButtonWithTitle:@"播放" sel:@selector(_playAction)];
        [self.view addSubview:play];
        [play mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.top.equalTo(self.view).offset(150);
            make.width.equalTo(@100);
            make.height.equalTo(@40);
        }];
    }

    {
        UIButton *enqueue = [self createButtonWithTitle:@"塞入" sel:@selector(_enqueueAction)];
        [self.view addSubview:enqueue];
        [enqueue mas_makeConstraints:^(MASConstraintMaker *make) {
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
    [[ALAudioQueuePlayer shareInstance] playerPrepareWithSampleRate:16000
                                                           formatID:kAudioFormatLinearPCM
                                                        formatFlags:kLinearPCMFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked
                                                     bytesPerPacket:16/8*1*1
                                                    framesPerPacket:1
                                                      bytesPerFrame:16/8*1
                                                   channelsPerFrame:1
                                                     bitsPerChannel:16
                                                        maxDataSize:8000];
    NSLog(@"%s",__PRETTY_FUNCTION__);
}

- (void)_playAction {
    [[ALAudioQueuePlayer shareInstance] start];
    NSLog(@"%s",__PRETTY_FUNCTION__);
}

- (void)_enqueueAction {
    NSInteger fileIndex = 0;
    while (true) {
        NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
        NSString *filePath = [bundlePath stringByAppendingPathComponent:[NSString stringWithFormat:@"data_%ld.dat", (long)fileIndex]];

        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            NSData *data = [NSData dataWithContentsOfFile:filePath];
            [[ALAudioQueuePlayer shareInstance] enqueueData:data];
        } else {
            break;
        }

        fileIndex++;
    }
    NSLog(@"%s",__PRETTY_FUNCTION__);
}

- (void)_pauseAction {
    [[ALAudioQueuePlayer shareInstance] pause];
    NSLog(@"%s",__PRETTY_FUNCTION__);
}

- (void)_stopAction {
    [[ALAudioQueuePlayer shareInstance] stop];
    NSLog(@"%s",__PRETTY_FUNCTION__);
}

@end
