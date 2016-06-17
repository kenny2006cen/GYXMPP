//
//  GYHDRecordVideoTool.m
//  HSConsumer
//
//  Created by shiang on 16/2/16.
//  @深圳市归一科技研发有限公司_iOS
//  @版权所有  禁止传播
//  @级别：绝密
//  Copyright © 2016年 SHENZHEN GUIYI SCIENCE AND TECHNOLOGY DEVELOP CO.,LTD.
//  All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "GYHDRecordVideoTool.h"
//#import "UIImage+GYExtension.h"

typedef void (^PropertyChangeBlock)(AVCaptureDevice *captureDevice);
@interface GYHDRecordVideoTool ()<AVCaptureFileOutputRecordingDelegate>

@property(strong, nonatomic)
    AVCaptureSession *captureSession;  //负责输入和输出设置之间的数据传递
@property(strong, nonatomic) AVCaptureDeviceInput
    *captureDeviceInput;  //负责从AVCaptureDevice获得输入数据
@property(strong, nonatomic)
    AVCaptureMovieFileOutput *captureMovieFileOutput;  //视频输出流
@property(strong, nonatomic)
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;  //相机拍摄预览图层
@property(assign, nonatomic)
    UIBackgroundTaskIdentifier backgroundTaskIdentifier;  //后台任务标识
@property(strong, nonatomic)
    AVCaptureStillImageOutput *captureStillImageOutput;  //照片输出流
@property(nonatomic, copy) NSString *movPath;
@property(nonatomic, copy) NSString *mp4Path;
/**录音总时长*/
@property(nonatomic, assign) NSTimeInterval recordTimeCount;
/**当前录音时长*/
@property(nonatomic, assign) NSTimeInterval currentCecordTime;
/**录音定时器*/
@property(nonatomic, strong) NSTimer *recordtimer;
/**播放录像*/
@property(nonatomic, strong) AVPlayer *playerRecordVideo;
/**相片*/
@property(nonatomic, strong) NSData *photoData;
@end

@implementation GYHDRecordVideoTool

- (NSString *)movPath {
  if (!_movPath) {
    _movPath = [NSHomeDirectory()
        stringByAppendingPathComponent:@"Documents/downloadFileMov.mov"];
  }
  return _movPath;
}

/**初始化相机*/
- (instancetype)initWithCameraView:(UIView *)view {
  self = [super init];
  if (!self) return self;

  //初始化会话
  _captureSession = [[AVCaptureSession alloc] init];
  //获得输入设备
  AVCaptureDevice *captureDevice =
      [self getCameraDeviceWithPosition:
                AVCaptureDevicePositionBack];  //取得后置摄像头
  if (!captureDevice) {
   // DDLogCError(@"取得后置摄像头时出现问题.");
  }

  NSError *error = nil;
  //根据输入设备初始化设备输入对象，用于获得输入数据
  _captureDeviceInput =
      [[AVCaptureDeviceInput alloc] initWithDevice:captureDevice error:&error];
  if (error) {
   // DDLogCError(@"取得设备输入对象时出错，错误原因：%@", error.localizedDescription);

    if ([error.localizedDescription isEqualToString:@"无"
                                                    @"法使用“背面相机”"]) {
    }
  }
  //初始化设备输出对象，用于获得输出数据
  _captureStillImageOutput = [[AVCaptureStillImageOutput alloc] init];
  NSDictionary *outputSettings = @{AVVideoCodecKey : AVVideoCodecJPEG};
  [_captureStillImageOutput setOutputSettings:outputSettings];  //输出设置

  //将设备输入添加到会话中
  if ([_captureSession canAddInput:_captureDeviceInput]) {
    [_captureSession addInput:_captureDeviceInput];
  }

  //将设备输出添加到会话中
  if ([_captureSession canAddOutput:_captureStillImageOutput]) {
    [_captureSession addOutput:_captureStillImageOutput];
  }

  //创建视频预览层，用于实时展示摄像头状态
  _captureVideoPreviewLayer =
      [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];

  CALayer *layer = view.layer;
  layer.masksToBounds = YES;

  _captureVideoPreviewLayer.frame = layer.bounds;
  _captureVideoPreviewLayer.videoGravity =
      AVLayerVideoGravityResizeAspectFill;  //填充模式
  //将视频预览层添加到界面中
  [layer addSublayer:_captureVideoPreviewLayer];
  //        [layer insertSublayer:_captureVideoPreviewLayer
  //        below:self.focusCursor.layer];

  [self addNotificationToCaptureDevice:captureDevice];
  //        [self addGenstureRecognizer];
  //        [self setFlashModeButtonStatus];
  [self.captureSession startRunning];

  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(playbackFinished:)
             name:AVPlayerItemDidPlayToEndTimeNotification
           object:self.playerRecordVideo.currentItem];

  return self;
}

/**初始化*/
- (instancetype)initWithView:(UIView *)view {
  self = [super init];
  if (!self) return self;
  //初始化会话
  _captureSession = [[AVCaptureSession alloc] init];
  if ([_captureSession
          canSetSessionPreset:AVCaptureSessionPreset640x480]) {  //设置分辨率
    _captureSession.sessionPreset = AVCaptureSessionPreset640x480;
  }
  //获得输入设备
  AVCaptureDevice *captureDevice =
      [self getCameraDeviceWithPosition:
                AVCaptureDevicePositionBack];  //取得后置摄像头
  if (!captureDevice) {
  //  DDLogCError(@"取得后置摄像头时出现问题.");
  }
  //添加一个音频输入设备
  AVCaptureDevice *audioCaptureDevice =
      [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];

  NSError *error = nil;
  //根据输入设备初始化设备输入对象，用于获得输入数据
  _captureDeviceInput =
      [[AVCaptureDeviceInput alloc] initWithDevice:captureDevice error:&error];
  if (error) {
  //  DDLogCError(@"取得设备输入对象时出错，错误原因：%@", error.localizedDescription);
  }
  AVCaptureDeviceInput *audioCaptureDeviceInput =
      [[AVCaptureDeviceInput alloc] initWithDevice:audioCaptureDevice
                                             error:&error];
  if (error) {
  //  DDLogCError(@"取得设备输入对象时出错，错误原因：%@", error.localizedDescription);
  }
  //初始化设备输出对象，用于获得输出数据
  _captureMovieFileOutput = [[AVCaptureMovieFileOutput alloc] init];

  //将设备输入添加到会话中
  if ([_captureSession canAddInput:_captureDeviceInput]) {
    [_captureSession addInput:_captureDeviceInput];
    [_captureSession addInput:audioCaptureDeviceInput];
    AVCaptureConnection *captureConnection =
        [_captureMovieFileOutput connectionWithMediaType:AVMediaTypeVideo];
    if ([captureConnection isVideoStabilizationSupported]) {
      captureConnection.preferredVideoStabilizationMode =
          AVCaptureVideoStabilizationModeAuto;
    }
  }

  //将设备输出添加到会话中
  if ([_captureSession canAddOutput:_captureMovieFileOutput]) {
    [_captureSession addOutput:_captureMovieFileOutput];
  }

  //创建视频预览层，用于实时展示摄像头状态
  _captureVideoPreviewLayer =
      [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];

  CALayer *layer = view.layer;
  layer.masksToBounds = YES;

  _captureVideoPreviewLayer.frame = layer.bounds;
  _captureVideoPreviewLayer.videoGravity =
      AVLayerVideoGravityResizeAspectFill;  //填充模式
  //将视频预览层添加到界面中
  [layer addSublayer:_captureVideoPreviewLayer];
  //    [layer insertSublayer:_captureVideoPreviewLayer
  //    below:self.focusCursor.layer];

  //    _enableRotation=YES;
  [self addNotificationToCaptureDevice:captureDevice];
  //    [self addGenstureRecognizer];
  [self.captureSession startRunning];
  return self;
}
/**开始录制照片*/
- (void)startRecordCamera {
  AVCaptureConnection *captureConnection =
      [self.captureStillImageOutput connectionWithMediaType:AVMediaTypeVideo];
  //根据连接取得设备输出的数据

    WSHD(weakSelf);

  [self.captureStillImageOutput
      captureStillImageAsynchronouslyFromConnection:captureConnection
                                  completionHandler:^(
                                      CMSampleBufferRef imageDataSampleBuffer,
                                      NSError *error) {
                                  
                                    if (imageDataSampleBuffer) {
                                      weakSelf.photoData = [AVCaptureStillImageOutput
                                          jpegStillImageNSDataRepresentation:
                                              imageDataSampleBuffer];
                                    }

                                  }];
}

- (NSDictionary *)imagePathDict {
  // get save path
/*
  NSInteger timeNumber =
      arc4random_uniform(1000) + [[NSDate date] timeIntervalSince1970];
  NSString *imageName =
      [NSString stringWithFormat:@"originalImage%ld.jpg", (long)timeNumber];
  NSString *imagePath = [NSString pathWithComponents:@[
    [[GYHDMessageCenter sharedInstance] imagefolderNameString],
    imageName
  ]];


  UIImage *tempImage = [UIImage imageWithData:self.photoData];

  UIImage *image = [tempImage fixOrientation];

  //    UIImage *image=[UIImage imageWithData:self.photoData];

  //    UIImage *tempthumbnailsImage=[Utils imageCompressForWidth:image
  //    targetWidth:150];;
  //
  //    UIImage *tempthumbnailsImageData=[tempthumbnailsImage fixOrientation];

  self.photoData = UIImagePNGRepresentation(image);

  UIImage *thumbnailsImage =
      [Utils imageCompressForWidth:image targetWidth:150];
  //   UIImage *thumbnailsImage = tempthumbnailsImageData;

  NSData *thumbnailsImageData = nil;
  if (UIImageJPEGRepresentation(thumbnailsImage, 1)) {
    thumbnailsImageData = UIImageJPEGRepresentation(thumbnailsImage, 1);
  } else {
    thumbnailsImageData = UIImagePNGRepresentation(thumbnailsImage);
  }

  [self.photoData writeToFile:imagePath atomically:YES];

  NSString *thumbnailsImageName =
      [NSString stringWithFormat:@"thumbnailsImage%ld.jpg", (long)timeNumber];
  NSString *thumbnailsImageNamePath = [NSString pathWithComponents:@[
    [[GYHDMessageCenter sharedInstance] imagefolderNameString],
    thumbnailsImageName
  ]];
  [thumbnailsImageData writeToFile:thumbnailsImageNamePath atomically:YES];
  NSMutableDictionary *dict = [NSMutableDictionary dictionary];
  dict[@"originalName"] = imageName;
  dict[@"thumbnailsName"] = thumbnailsImageName;
  return dict;
 */
    return nil;
}
/**开始录制*/
- (void)startRecordVideo {
  //根据设备输出获得连接
  AVCaptureConnection *captureConnection =
      [self.captureMovieFileOutput connectionWithMediaType:AVMediaTypeVideo];
  //如果支持多任务则则开始多任务
  if ([[UIDevice currentDevice] isMultitaskingSupported]) {
    self.backgroundTaskIdentifier = [[UIApplication sharedApplication]
        beginBackgroundTaskWithExpirationHandler:nil];
  }
  //预览图层和视频方向保持一致
  captureConnection.videoOrientation =
      [self.captureVideoPreviewLayer connection].videoOrientation;
  NSURL *fileUrl = [NSURL fileURLWithPath:self.movPath];
  NSFileManager *fileManager = [NSFileManager defaultManager];
  [fileManager removeItemAtPath:self.movPath error:nil];

  if (fileUrl) {
    [self.captureMovieFileOutput startRecordingToOutputFileURL:fileUrl
                                             recordingDelegate:self];
  }
}

/**开始录制30秒*/
- (void)startRecordVideoForDuration:(NSTimeInterval)duration {
  _recordTimeCount = duration;
  _currentCecordTime = 0.0f;
  _recordtimer =
      [NSTimer scheduledTimerWithTimeInterval:1.0
                                       target:self
                                     selector:@selector(listenRecordTime:)
                                     userInfo:nil
                                      repeats:YES];
  [self startRecordVideo];
}
- (void)listenRecordTime:(NSTimer *)timer {
  _currentCecordTime++;
  if (_currentCecordTime >= _recordTimeCount) {
    [_recordtimer invalidate];
    [self stopRecordVideo];
  } else {
    dispatch_async(dispatch_get_main_queue(), ^{
      if ([self.delegate
              respondsToSelector:@selector(recordViewTimeInterval:)]) {
        [self.delegate recordViewTimeInterval:_currentCecordTime];
      }
    });
  }
}
/**停止录制*/
- (void)stopRecordVideo {
  [_recordtimer invalidate];
  [self.captureMovieFileOutput stopRecording];
}

- (void)changeCamera {
  AVCaptureDevice *currentDevice = [self.captureDeviceInput device];
  AVCaptureDevicePosition currentPosition = [currentDevice position];
  [self removeNotificationFromCaptureDevice:currentDevice];
  AVCaptureDevice *toChangeDevice;
  AVCaptureDevicePosition toChangePosition = AVCaptureDevicePositionFront;
  if (currentPosition == AVCaptureDevicePositionUnspecified ||
      currentPosition == AVCaptureDevicePositionFront) {
    toChangePosition = AVCaptureDevicePositionBack;
  }
  toChangeDevice = [self getCameraDeviceWithPosition:toChangePosition];
  [self addNotificationToCaptureDevice:toChangeDevice];
  //获得要调整的设备输入对象
  AVCaptureDeviceInput *toChangeDeviceInput =
      [[AVCaptureDeviceInput alloc] initWithDevice:toChangeDevice error:nil];

  //改变会话的配置前一定要先开启配置，配置完成后提交配置改变
  [self.captureSession beginConfiguration];
  //移除原有输入对象
  [self.captureSession removeInput:self.captureDeviceInput];
  //添加新的输入对象
  if ([self.captureSession canAddInput:toChangeDeviceInput]) {
    [self.captureSession addInput:toChangeDeviceInput];
    self.captureDeviceInput = toChangeDeviceInput;
  }
  //提交会话配置
  [self.captureSession commitConfiguration];
}

/**
 *  取得指定位置的摄像头
 *
 *  @param position 摄像头位置
 *
 *  @return 摄像头设备
 */
- (AVCaptureDevice *)getCameraDeviceWithPosition:
    (AVCaptureDevicePosition)position {
  NSArray *cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
  for (AVCaptureDevice *camera in cameras) {
    if ([camera position] == position) {
      return camera;
    }
  }
  return nil;
}

/**
 *  给输入设备添加通知
 */
- (void)addNotificationToCaptureDevice:(AVCaptureDevice *)captureDevice {
  //注意添加区域改变捕获通知必须首先设置设备允许捕获
  [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
    captureDevice.subjectAreaChangeMonitoringEnabled = YES;
  }];
  //捕获区域发生改变
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(areaChange:)
             name:AVCaptureDeviceSubjectAreaDidChangeNotification
           object:captureDevice];
}
- (void)removeNotificationFromCaptureDevice:(AVCaptureDevice *)captureDevice {
  NSNotificationCenter *notificationCenter =
      [NSNotificationCenter defaultCenter];
  [notificationCenter
      removeObserver:self
                name:AVCaptureDeviceSubjectAreaDidChangeNotification
              object:captureDevice];
}
/**
 *  改变设备属性的统一操作方法
 *
 *  @param propertyChange 属性改变操作
 */
- (void)changeDeviceProperty:(PropertyChangeBlock)propertyChange {
  AVCaptureDevice *captureDevice = [self.captureDeviceInput device];
  NSError *error;
  //注意改变设备属性前一定要首先调用lockForConfiguration:调用完之后使用unlockForConfiguration方法解锁
  if ([captureDevice lockForConfiguration:&error]) {
    propertyChange(captureDevice);
    [captureDevice unlockForConfiguration];
  } else {
    //DDLogCError(@"设置设备属性过程发生错误，错误信息：%@",
     //     error.localizedDescription);
  }
}

/**视频截取*/
- (void)mergeAndExportVideosAtFileURLs:(NSArray *)fileURLArray {
    /*
  dispatch_async(
      dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error = nil;

        CGSize renderSize = CGSizeMake(0, 0);

        NSMutableArray *layerInstructionArray = [[NSMutableArray alloc] init];

        AVMutableComposition *mixComposition =
            [[AVMutableComposition alloc] init];

        CMTime totalDuration = kCMTimeZero;

        //先去assetTrack 也为了取renderSize
        NSMutableArray *assetTrackArray = [[NSMutableArray alloc] init];
        NSMutableArray *assetArray = [[NSMutableArray alloc] init];
        for (NSURL *fileURL in fileURLArray) {
          AVAsset *asset = [AVAsset assetWithURL:fileURL];

          if (!asset || [asset tracksWithMediaType:AVMediaTypeVideo].count == 0 ) {
            continue;
          }

          [assetArray addObject:asset];

          AVAssetTrack *assetTrack =
              [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
          [assetTrackArray addObject:assetTrack];

          renderSize.width =
              MAX(renderSize.width, assetTrack.naturalSize.height);
          renderSize.height =
              MAX(renderSize.height, assetTrack.naturalSize.width);
        }

        CGFloat renderW = MIN(renderSize.width, renderSize.height);

        for (int i = 0; i < [assetArray count] && i < [assetTrackArray count];
             i++) {
          AVAsset *asset = [assetArray objectAtIndex:i];
          AVAssetTrack *assetTrack = [assetTrackArray objectAtIndex:i];

          AVMutableCompositionTrack *audioTrack = [mixComposition
              addMutableTrackWithMediaType:AVMediaTypeAudio
                          preferredTrackID:kCMPersistentTrackID_Invalid];
          [audioTrack
              insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
                      ofTrack:[[asset tracksWithMediaType:AVMediaTypeAudio]
                                  objectAtIndex:0]
                       atTime:totalDuration
                        error:nil];

          AVMutableCompositionTrack *videoTrack = [mixComposition
              addMutableTrackWithMediaType:AVMediaTypeVideo
                          preferredTrackID:kCMPersistentTrackID_Invalid];

          [videoTrack
              insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
                      ofTrack:assetTrack
                       atTime:totalDuration
                        error:&error];

          // fix orientationissue
          AVMutableVideoCompositionLayerInstruction *layerInstruciton =
              [AVMutableVideoCompositionLayerInstruction
                  videoCompositionLayerInstructionWithAssetTrack:videoTrack];

          totalDuration = CMTimeAdd(totalDuration, asset.duration);

          CGFloat rate;
          rate = renderW / MIN(assetTrack.naturalSize.width,
                               assetTrack.naturalSize.height);

          CGAffineTransform layerTransform = CGAffineTransformMake(
              assetTrack.preferredTransform.a, assetTrack.preferredTransform.b,
              assetTrack.preferredTransform.c, assetTrack.preferredTransform.d,
              assetTrack.preferredTransform.tx * rate,
              assetTrack.preferredTransform.ty * rate);

          CGFloat y = 160;
          layerTransform = CGAffineTransformConcat(
              layerTransform,
              CGAffineTransformMake(1, 0, 0, 1, 0, -y));  //向上移动取中部影响

          [layerInstruciton setTransform:layerTransform atTime:kCMTimeZero];
          [layerInstruciton setOpacity:0.0 atTime:totalDuration];

          // data
          [layerInstructionArray addObject:layerInstruciton];
        }

        // get save path
        NSInteger timeNumber =
            arc4random_uniform(1000) + [[NSDate date] timeIntervalSince1970];

        NSString *mp4Name =
            [NSString stringWithFormat:@"%ld.mp4", (long)timeNumber];
        NSString *mp4Path = [NSString pathWithComponents:@[
          [[GYHDMessageCenter sharedInstance] mp4folderNameString],
          mp4Name
        ]];

        NSString *imageName =
            [NSString stringWithFormat:@"%ld.jpg", (long)timeNumber];
        NSString *imagePath = [NSString pathWithComponents:@[
          [[GYHDMessageCenter sharedInstance] imagefolderNameString],
          imageName
        ]];

        BOOL flag =
            [[self VideofristFrameData] writeToFile:imagePath atomically:YES];

        if (!flag) {
          DDLogInfo(@"视频帧首图写入失败.");
          if (self.delegate &&
              [self.delegate
                  respondsToSelector:
                      @selector(GYHDRecordVideoToolRecoredDidFailed)]) {
            [self.delegate GYHDRecordVideoToolRecoredDidFailed];

            return;
          }
        }

        else {
          DDLogInfo(@"视频帧首图写入成功.");

          NSURL *mergeFileURL = [NSURL fileURLWithPath:mp4Path];
          self.mp4Path = mp4Path;
          // export
          AVMutableVideoCompositionInstruction *mainInstruciton =
              [AVMutableVideoCompositionInstruction
                  videoCompositionInstruction];
          mainInstruciton.timeRange =
              CMTimeRangeMake(kCMTimeZero, totalDuration);
          mainInstruciton.layerInstructions = layerInstructionArray;
          AVMutableVideoComposition *mainCompositionInst =
              [AVMutableVideoComposition videoComposition];
          mainCompositionInst.instructions = @[ mainInstruciton ];
          mainCompositionInst.frameDuration = CMTimeMake(1, 30);
          mainCompositionInst.renderSize = CGSizeMake(480, 320);
          CGSizeMake(renderW, renderW);

          AVAssetExportSession *exporter = [[AVAssetExportSession alloc]
              initWithAsset:mixComposition
                 presetName:AVAssetExportPresetMediumQuality];
          exporter.videoComposition = mainCompositionInst;
          exporter.outputURL = mergeFileURL;
          exporter.outputFileType = AVFileTypeMPEG4;
          exporter.shouldOptimizeForNetworkUse = YES;
            
          [exporter exportAsynchronouslyWithCompletionHandler:^{

            dispatch_async(dispatch_get_main_queue(), ^{

              // add by jiang lincen iphone4录制失败，不调发送方法
              if (!mp4Name) {
                return [Utils showMassage:@"录制视频失败"];
              }
            
                switch (exporter.status) {
                    case AVAssetExportSessionStatusCompleted:{
                        if ([self.delegate
                             respondsToSelector:@selector(GYHDRecordVideoTool:
                                                          sendDict:)]) {
                                 NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                                 dict[@"mp4Name"] = mp4Name;
                                 dict[@"thumbnailsName"] = imageName;
                                 
                                 [self.delegate GYHDRecordVideoTool:self sendDict:dict];
                             }

                    }break;
                    case AVAssetExportSessionStatusFailed:{
                    }break;
                    case AVAssetExportSessionStatusCancelled:{
                    }break;
                    case AVAssetExportSessionStatusExporting:{
                    }break;
                    case AVAssetExportSessionStatusWaiting:{
                    
                    }break;
                    case AVAssetExportSessionStatusUnknown:{
                    }break;
                        
                    default:
                        break;
                }
            
//              if ([self.delegate
//                      respondsToSelector:@selector(GYHDRecordVideoTool:
//                                                              sendDict:)]) {
//                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
//                dict[@"mp4Name"] = mp4Name;
//                dict[@"thumbnailsName"] = imageName;
//
//                [self.delegate GYHDRecordVideoTool:self sendDict:dict];
//              }

            });
          }];
        }

        
      });
     
     */
}
- (NSString *)mp4pathString{
    return self.mp4Path;
}

- (void)playRecordVideoWithView:(UIView *)view Data:(NSData *)data {
  NSString *urlStr = [NSHomeDirectory()
      stringByAppendingPathComponent:@"Documents/playerMp4.mp4"];
  [data writeToFile:urlStr atomically:YES];
  NSURL *movieUrl = [NSURL fileURLWithPath:urlStr];
  AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:movieUrl];
  self.playerRecordVideo = [[AVPlayer alloc] initWithPlayerItem:playerItem];

  AVPlayerLayer *playerLayer =
      [AVPlayerLayer playerLayerWithPlayer:self.playerRecordVideo];
  playerLayer.frame = view.bounds;
  [view.layer addSublayer:playerLayer];

  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(playbackFinished:)
             name:AVPlayerItemDidPlayToEndTimeNotification
           object:self.playerRecordVideo.currentItem];
}
- (void)playVideoWithView:(UIView *)view Url:(NSURL *)url {
  AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:url];
  self.playerRecordVideo = [[AVPlayer alloc] initWithPlayerItem:playerItem];

  AVPlayerLayer *playerLayer =
      [AVPlayerLayer playerLayerWithPlayer:self.playerRecordVideo];
  playerLayer.frame = view.bounds;
  [view.layer addSublayer:playerLayer];

  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(playbackFinished:)
             name:AVPlayerItemDidPlayToEndTimeNotification
           object:self.playerRecordVideo.currentItem];
}
/**暂停*/
- (void)pauseVideo {
  if (self.playerRecordVideo.rate != 0) {
    [self.playerRecordVideo pause];
  }
}
/**播放*/
- (void)playerVideo {
  if (self.playerRecordVideo.rate == 0) {
    [self.playerRecordVideo play];
  }
}
- (NSData *)movData {
  return [NSData dataWithContentsOfFile:self.movPath];
}

/**视频第一帧*/
- (NSData *)VideofristFrameData {
  AVURLAsset *asset =
      [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:self.movPath]
                              options:nil];
  AVAssetImageGenerator *gen =
      [[AVAssetImageGenerator alloc] initWithAsset:asset];
  gen.appliesPreferredTrackTransform = YES;
  CMTime time = CMTimeMakeWithSeconds(0.0, 600);
  CGImageRef image = [gen copyCGImageAtTime:time actualTime:nil error:nil];
  CGImageRef imagePartRef = CGImageCreateWithImageInRect(
      image, CGRectMake(0, 16, 240, 160));
  UIImage *retImg = [UIImage imageWithCGImage:imagePartRef];
  CGImageRelease(image);
  UIImage *maskImage = [UIImage imageNamed:@"btn_lx_bf_n"];
  UIGraphicsBeginImageContext(retImg.size);
  [retImg drawInRect:CGRectMake(0, 0, retImg.size.width, retImg.size.height)];

  //四个参数为水印图片的位置
  [maskImage drawInRect:CGRectMake((240 / 2) - (58 / 2), (160 / 2) - (58 / 2),
                                   58.5, 58.5f)];
  UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();

  return UIImagePNGRepresentation(resultingImage);
}
- (NSData *)mp4Data {
  return [NSData dataWithContentsOfFile:self.mp4Path];
}
- (NSData *)imageData {
  return self.photoData;
}

#pragma mark - NSNotification通知
/**
 *  捕获区域改变
 *
 *  @param notification 通知对象
 */
- (void)areaChange:(NSNotification *)notification {
 // DDLogInfo(@"捕获区域改变...");
}

#pragma mark - AVCaptureFileOutputRecordingDelegate(视频输出代理)
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput
    didStartRecordingToOutputFileAtURL:(NSURL *)fileURL
                       fromConnections:(NSArray *)connections {
 // DDLogInfo(@"开始录制...");
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput
    didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL
                        fromConnections:(NSArray *)connections
                                  error:(NSError *)error {
  if (!error) {
  //  DDLogInfo(@"视频录制完成.");
    [_recordtimer invalidate];
    [self mergeAndExportVideosAtFileURLs:@[ outputFileURL ]];
  } else {
 //   DDLogInfo(@"视频录制失败.");
    if (self.delegate &&
        [self.delegate
            respondsToSelector:@selector(
                                   GYHDRecordVideoToolRecoredDidFailed)]) {
      [self.delegate GYHDRecordVideoToolRecoredDidFailed];
    }
  }
}

/**
 *  播放完成通知
 *
 *  @param notification 通知对象
 */
#pragma mark - Play NOtification
- (void)playbackFinished:(NSNotification *)notification {
 // DDLogInfo(@"视频播放完成.");

  // modify by jianglincen
  // 修改原来有bug的重复播放代码，导致自己发出的本地视频文件无法重复播放的问题
  AVPlayerItem *p = [notification object];
  //关键代码
  [p seekToTime:kCMTimeZero];

  [self.playerRecordVideo play];
  // 播放完成后重复播放
  // 跳到最新的时间点开始播放
  //  [self.playerRecordVideo seekToTime:CMTimeMake(0, 1)];
  // [self playerVideo];
}

#pragma mark - dealloc
- (void)dealloc {
  [self.captureSession stopRunning];
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
