//
//  GYHDAudioTool.m
//  HSConsumer
//
//  Created by shiang on 16/2/4.
//  @深圳市归一科技研发有限公司_iOS
//  @版权所有  禁止传播
//  @级别：绝密
//  Copyright © 2016年 SHENZHEN GUIYI SCIENCE AND TECHNOLOGY DEVELOP CO.,LTD.
//  All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "GYHDAudioTool.h"
#import "lame.h"

@interface GYHDAudioTool ()<AVAudioRecorderDelegate, AVAudioPlayerDelegate>
/**当前音频长度*/
@property(nonatomic, assign) NSTimeInterval deviceCurrentTime;
/**总音频时长*/
@property(nonatomic, assign) NSTimeInterval duration;
/**返回录制的MP3Data*/
@property(nonatomic, strong) NSData *mp3Data;
/**mp3路劲*/
@property(nonatomic, copy) NSString *mp3Path;
/**mp3名字*/
@property(nonatomic, copy) NSString *mp3Name;
/**caf路劲*/
@property(nonatomic, copy) NSString *cafPath;
/**录音*/
@property(nonatomic, strong) AVAudioRecorder *recorder;  //处理录音操作
/**播放*/
@property(nonatomic, strong) AVAudioPlayer *
    player;  //播放器，它支持多种音频格式，而且能够进行进度、音量、播放速度等控制，只能播放本地文件

@end

/**录音时长*/
static const NSTimeInterval timelen = 30.0f;  //最长30秒录制时间

@implementation GYHDAudioTool
static id instance;

+ (instancetype)sharedInstance {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    instance = [[self alloc] init];

  });
  return instance;
}

- (NSString *)cafPath {
  if (!_cafPath) {
    _cafPath = [NSHomeDirectory()
        stringByAppendingPathComponent:@"Documents/downloadFilecaf.caf"];
  }
  return _cafPath;
}
/**创建播放*/
- (AVAudioPlayer *)createPlayerWithData:(NSData *)data;
{
  if (!data) {
    data = [NSData dataWithContentsOfFile:self.mp3Path];
  }
  AVAudioSession *audioSession = [AVAudioSession sharedInstance];
  //默认情况下扬声器播放,启动音频会话,设置后台播放AVAudioSessionCategoryPlayback
  [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
  [audioSession setActive:YES error:nil];

  [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker
                                  error:nil];

  AVAudioPlayer *player =
      [[AVAudioPlayer alloc] initWithData:data
                             fileTypeHint:AVFileTypeMPEGLayer3
                                    error:nil];

  /* numberOfLoops
   循环播放次数，如果为0则不循环，如果小于0则无限循环，大于0则表示循环次数
   */
  [player setNumberOfLoops:0];

  [player prepareToPlay];
  return player;
}
- (AVAudioRecorder *)createRecorder {
  // 1. 设置音频会话，允许录音
  AVAudioSession *session = [AVAudioSession sharedInstance];
  [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
  // 激活分类
  [session setActive:YES error:nil];

  //由于之前使用过同一路径存self.cafPath储临时录音，故每次录音时先删除之

  NSFileManager *fileManager = [NSFileManager defaultManager];

  if ([fileManager fileExistsAtPath:self.cafPath]) {
    [fileManager removeItemAtPath:self.cafPath error:nil];
  }

  NSURL *url = [NSURL fileURLWithPath:self.cafPath];  //录制文件初始化存储路径

  // 2) 录音文件设置的字典（设置音频的属性，例如音轨数量，音频格式等）
  //录音设置
  NSMutableDictionary *settings = [[NSMutableDictionary alloc] init];
  //录音格式 无法使用??
  [settings setValue:[NSNumber numberWithInt:kAudioFormatLinearPCM]
              forKey:AVFormatIDKey];
  //采样率 8000是电话采样率，对于一般录音已经够了
  [settings setValue:[NSNumber numberWithFloat:11025.0]
              forKey:AVSampleRateKey];  // 44100.0
  //通道数 2为双声道,1 为单声道
  [settings setValue:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
  //线性采样位数
  //[recordSettings setValue :[NSNumber numberWithInt:16] forKey:
  // AVLinearPCMBitDepthKey];
  //音频质量,采样质量
  [settings setValue:[NSNumber numberWithInt:AVAudioQualityMin]
              forKey:AVEncoderAudioQualityKey];

  //是否使用浮点数采样
  //  [settings setObject:@(YES) forKey:AVLinearPCMIsFloatKey];

  NSError *error = nil;
  AVAudioRecorder *recorder =
      [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];

  if (error) {
  //  DDLogWarn(@"创建录音机对象时发生错误，错误信息：%@",
   //           error.localizedDescription);
  }

  recorder.delegate = self;

  [recorder prepareToRecord];

  return recorder;
}

- (NSString *)mp3pathName {
  return self.mp3Path;
}

- (NSString *)mp3NameString {
  return self.mp3Name;
}
- (void)startRecord:(completeRecordBlock)block {
  if ([self.recorder isRecording]) {
    //此处不严谨，待修改
    return;
  }
  if (block) {
    _recordBlock = block;
    AVAudioSession *session = [AVAudioSession sharedInstance];

    //首先判断是否开启录音权限
    if ([session respondsToSelector:@selector(requestRecordPermission:)]) {
      [session requestRecordPermission:^(BOOL available) {
        if (!available) {
          //如果没开启，跳转到GYHDAudioView去显示相关信息
          _recordBlock(GYHDAudioToolRecordProhibit);
        }
      }];
    }
  }
  self.recorder = [self createRecorder];
  // 2. 如果当前正在播放录音
  if ([self.player isPlaying]) {
    [self.player stop];
  }

  [self.recorder
      recordForDuration:timelen];  // recordForDuration:按指定的时长开始录音
  // deviceCurrentTime
  // 输出设备播放音频的时间，注意如果播放中被暂停此时间也会继续累加
  // currentTime 当前播放时长
  self.deviceCurrentTime = self.recorder.deviceCurrentTime;  //
}

- (void)startRecord {
  if ([self.recorder isRecording]) {
    //此处不严谨，待修改
    return;
  }
  self.recorder = [self createRecorder];
  // 2. 如果当前正在播放录音
  if ([self.player isPlaying]) {
    [self.player stop];
  }

  [self.recorder recordForDuration:timelen];
}
- (void)stopRecord {
  if ([self.recorder isRecording]) {
    [self.recorder stop];
      
      /*
      //设置音频存储路径
      NSInteger timeNumber =
      arc4random_uniform(1000) + [[NSDate date] timeIntervalSince1970];
      
      NSString *mp3Name =
      [NSString stringWithFormat:@"audio%lu.mp3", (long)timeNumber];
      NSString *mp3Path = [NSString pathWithComponents:@[
                                                         [[GYHDMessageCenter sharedInstance] mp3folderNameString],
                                                         mp3Name
                                                         ]];
      
      self.mp3Path = mp3Path;
      self.mp3Name = mp3Name;  //用时间戳保存音频名称
      
      //暂时放置于主线程操作，避免传送数据时为空,因为后台没有做音频data上传的有效性验证
      [self audio_PCMUrl:self.cafPath toMP3:self.mp3Path];
      
      self.mp3Data = [NSData dataWithContentsOfFile:self.mp3Path];
      
      self.duration = self.recorder.deviceCurrentTime - self.deviceCurrentTime;
      
 */
  }
      
}
#pragma mark - AVAudioRecorder Delegate
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder
                           successfully:(BOOL)flag {
 
    /*
    //设置音频存储路径
  NSInteger timeNumber =
      arc4random_uniform(1000) + [[NSDate date] timeIntervalSince1970];

  NSString *mp3Name =
      [NSString stringWithFormat:@"audio%lu.mp3", (long)timeNumber];
  NSString *mp3Path = [NSString pathWithComponents:@[
    [[GYHDMessageCenter sharedInstance] mp3folderNameString],
    mp3Name
  ]];
    
  self.mp3Path = mp3Path;
  self.mp3Name = mp3Name;  //用时间戳保存音频名称

  self.mp3Data = [NSData dataWithContentsOfFile:self.mp3Path];

  self.duration = self.recorder.deviceCurrentTime - self.deviceCurrentTime;

    //如果上一步停止的时候还没有数据，再转换一次
    if (!self.mp3Data) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                       ^{
                           // get save path
                           
            [self audio_PCMUrl:self.cafPath toMP3:self.mp3Path];
                           
                       });
    }
 
     */
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder
                                   error:(NSError *__nullable)error {
}

- (NSData *)mp3Data {
  return _mp3Data;
}

- (NSTimeInterval)gettime {
  return self.duration;
}
/**
 * caf 转MP3
 为了达到 iPhone 与 Android 实现音频互通. 使用Mp3格式的音频文件.
 至于能够转换成Amr 是最好,10秒 的 一个Amr文件 只有5K左右的大小.
 这里主要用到lame,一款非常棒的Mp3音频编码器.
 */
- (void)audio_PCMUrl:(NSString *)cafFilePath toMP3:(NSString *)mp3FilePath {
  NSFileManager *fileManager = [NSFileManager defaultManager];
  [fileManager removeItemAtPath:mp3FilePath error:nil];
  @try {
    int read, write;

    FILE *pcm = fopen([cafFilePath cStringUsingEncoding:1],
                      "rb");         // source 被转换的音频文件位置
    fseek(pcm, 4 * 1024, SEEK_CUR);  // skip file header
    FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:1],
                      "wb");  // output 输出生成的Mp3文件位置

    const int PCM_SIZE = 8192;
    const int MP3_SIZE = 8192;
    short int pcm_buffer[PCM_SIZE * 2];
    unsigned char mp3_buffer[MP3_SIZE];

    lame_t lame = lame_init();
    lame_set_in_samplerate(lame, 11025.0);
    lame_set_VBR(lame, vbr_default);
    lame_init_params(lame);

    do {
      read = fread(pcm_buffer, 2 * sizeof(short int), PCM_SIZE, pcm);
      if (read == 0)
        write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
      else
        write = lame_encode_buffer_interleaved(lame, pcm_buffer, read,
                                               mp3_buffer, MP3_SIZE);

      fwrite(mp3_buffer, write, 1, mp3);

    } while (read != 0);

    lame_close(lame);
    fclose(mp3);
    fclose(pcm);
  } @catch (NSException *exception) {
   // DDLogCError(@"%@", [exception description]);
  }

  @finally {
    // DDLogCError(@MP3生成成功: %@,mp3FilePath);
  }
}

#pragma mark - 播放method
/**播放MP3文件*/
- (void)playMp3WithFilePath:(NSString *)filePath
                   complete:(completePlayeBlock)block {
  self.playerBlock = block;
  if ([self.player isPlaying]) {
    [self.player stop];
  }
    
    UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
   
    AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,
                            sizeof(sessionCategory),
                            &sessionCategory);
    
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,
                             sizeof (audioRouteOverride),
                             &audioRouteOverride);

  AVAudioSession *audioSession = [AVAudioSession sharedInstance];
  //默认情况下扬声器播放
  [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
  [audioSession setActive:YES error:nil];
 
    [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker
                                  error:nil];
 
    NSURL *url = [NSURL fileURLWithPath:filePath];
 
    AVAudioPlayer *audioPlayer =
      [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
  audioPlayer.delegate = self;
  [audioPlayer setNumberOfLoops:0];
  [audioPlayer prepareToPlay];

    self.player = audioPlayer;

  [self handleNotification:YES];

  [self.player play];
}

#pragma mark - 监听听筒or扬声器
- (void) handleNotification:(BOOL)state
{
    [[UIDevice currentDevice] setProximityMonitoringEnabled:state]; //建议在播放之前设置yes，播放结束设置NO，这个功能是开启红外感应
    
    if(state)//添加监听
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(sensorStateChange:) name:@"UIDeviceProximityStateDidChangeNotification"
                                                   object:nil];
    else//移除监听
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIDeviceProximityStateDidChangeNotification" object:nil];
}

//处理监听触发事件
-(void)sensorStateChange:(NSNotificationCenter *)notification;
{
    //如果此时手机靠近面部放在耳朵旁，那么声音将通过听筒输出，并将屏幕变暗
    if ([[UIDevice currentDevice] proximityState] == YES)
    {
      //  DDLogInfo(@"Device is close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    }
    else
    {
       // DDLogInfo(@"Device is not close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
}

- (void)startPlayingWithData:(NSData *)data complete:(completePlayeBlock)block {
  // 1) 实例化播放器
  if ([self.player isPlaying]) {
    [self.player stop];
  }
  self.player = [self createPlayerWithData:data];
  [self.player play];
}

- (void)stopPlaying {
  if ([self.player isPlaying]) {
    [self.player stop];
  }
}

- (BOOL)isPlaying {
  return self.player.isPlaying;
}

#pragma mark - AVAudioPlayer Delegate
//播放成功
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player
                       successfully:(BOOL)flag {
  self.playerBlock(GYHDAudioToolPlayerSuccess);
}
//音频解码失败 add by jianglincen
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player
                                 error:(NSError *)error {
  self.playerBlock(GYHDAudioToolPlayerFailure);
}

@end
