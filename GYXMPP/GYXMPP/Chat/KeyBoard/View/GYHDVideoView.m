//
//  GYHDVideoView.m
//  HSConsumer
//
//  Created by shiang on 16/2/15.
//  @深圳市归一科技研发有限公司_iOS
//  @版权所有  禁止传播
//  @级别：绝密
//  Copyright © 2016年 SHENZHEN GUIYI SCIENCE AND TECHNOLOGY DEVELOP CO.,LTD.
//  All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "GYHDPlayVideoView.h"
#import "GYHDRecordVideoTool.h"
#import "GYHDVideoView.h"
#import "UIAlertView+Blocks.h"

typedef NS_ENUM(NSUInteger, VideoStatus) {
    VideoStatusNormal,//初始化状态
    VideoStatusPlay, //播放
    VideoStatusDelete,   //删除
    VideoStatusSend, //发送
};


@interface GYHDVideoView ()<GYHDRecordVideoDelegate, GYHDPlayVideoViewDelegate>

/**相机展示图层*/
@property(nonatomic, weak) UIView *showVideoView;
/**录制界面*/
@property(nonatomic, weak) UIView *startRecordVideoView;
/**试看按钮*/
@property(nonatomic, weak) UIButton *startPlayRecordButton;
/**开始录制*/
@property(nonatomic, weak) UIImageView *startImageView;
/**删除按钮*/
@property(nonatomic, weak) UIButton *deleteRecordButton;
/**录制视频工具*/
@property(nonatomic, strong) GYHDRecordVideoTool *recordViewTool;
/**录音提示*/
@property(nonatomic, weak) UILabel *recordNoticeLabel;
/**录音时长提示*/
@property(nonatomic, weak) UIButton *recordTimeCountButton;
/**进度条白色View*/
@property(nonatomic, weak) UIView *progressWhiteView;
/**进度条背景View*/
@property(nonatomic, weak) UIView *progressBackgroundView;
/**进度条蓝色View*/
@property(nonatomic, weak) UIView *progressBlueView;
/**是否为发送*/
@property(nonatomic, assign, getter=isSendVideo) BOOL sendVideo;
@property(nonatomic, assign) BOOL isVideoDelete;

@property(nonatomic,assign)VideoStatus status;//视频需要执行的状态

@property(nonatomic, strong) NSDictionary *sendDict;
@end

@implementation GYHDVideoView

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (!self) return self;
  self.backgroundColor = [UIColor blackColor];

  [self setuptUp];
  [self setupCenter];
  [self setupDown];

  return self;
}
- (void)layoutSubviews {
  [super layoutSubviews];
  self.recordViewTool =
      [[GYHDRecordVideoTool alloc] initWithView:self.showVideoView];
  self.recordViewTool.delegate = self;
}

/**顶部*/
- (void)setuptUp {
  UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [cancelButton setBackgroundImage:[UIImage imageNamed:@"btn-qx_n"]
                          forState:UIControlStateNormal];
  [cancelButton setBackgroundImage:[UIImage imageNamed:@"btn-qx_h"]
                          forState:UIControlStateHighlighted];
  [cancelButton addTarget:self
                   action:@selector(cancelButtonClick)
         forControlEvents:UIControlEventTouchUpInside];
  [self addSubview:cancelButton];

  [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.mas_equalTo(20);
    make.top.mas_equalTo(20);
    make.size.mas_equalTo(CGSizeMake(35, 35));
  }];

  UIButton *changeCameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [changeCameraButton setBackgroundImage:[UIImage imageNamed:@"btn-qh_n"]
                                forState:UIControlStateNormal];
  [changeCameraButton setBackgroundImage:[UIImage imageNamed:@"btn-qh_h"]
                                forState:UIControlStateHighlighted];
  [changeCameraButton addTarget:self
                         action:@selector(changeCameraButtonClick)
               forControlEvents:UIControlEventTouchUpInside];
  [self addSubview:changeCameraButton];
  [changeCameraButton mas_makeConstraints:^(MASConstraintMaker *make) {
    make.right.mas_equalTo(-20);
    make.top.mas_equalTo(20);
    make.size.mas_equalTo(CGSizeMake(35, 35));
  }];
}

- (void)cancelButtonClick {
  [self disMiss];
}
/**中间*/
- (void)setupCenter {
  UIView *showVideoView = [[UIView alloc] init];
  [self addSubview:showVideoView];
  _showVideoView = showVideoView;

    WSHD(weakSelf);
    
    [showVideoView mas_makeConstraints:^(MASConstraintMaker *make) {
    
    make.center.equalTo(weakSelf);
    make.size.mas_equalTo(CGSizeMake(kScreenWidth, kScreenWidth * 2 / 3));
  }];
}
/**底部*/
- (void)setupDown {
  // 1. 录制界面
  UIView *startRecordVideoView = [[UIView alloc] init];
  [self addSubview:startRecordVideoView];
  _startRecordVideoView = startRecordVideoView;
 
    WSHD(weakSelf);
    
  [startRecordVideoView mas_makeConstraints:^(MASConstraintMaker *make) {
    
    make.left.bottom.right.mas_equalTo(0);
    make.top.equalTo(weakSelf.showVideoView.mas_bottom);
  }];
  startRecordVideoView.backgroundColor = [UIColor blackColor];

  // 开始按钮
  UIImageView *startImageView = [[UIImageView alloc] init];
  startImageView.userInteractionEnabled = YES;
  [startImageView setImage:[UIImage imageNamed:@"red_point"]];
  _startImageView = startImageView;
  [startRecordVideoView addSubview:startImageView];
  [startImageView mas_makeConstraints:^(MASConstraintMaker *make) {

    if (kScreenWidth == 320) {
      make.size.mas_equalTo(CGSizeMake(65, 65));
      make.bottom.mas_equalTo(-20);
      make.centerX.equalTo(startRecordVideoView);
    } else {
      make.size.mas_equalTo(CGSizeMake(105, 105));
      make.center.equalTo(startRecordVideoView);
    }
  }];
  UILongPressGestureRecognizer *tapPress = [[UILongPressGestureRecognizer alloc]
      initWithTarget:self
              action:@selector(tapPress:)];
  tapPress.minimumPressDuration = 0;
  [startImageView addGestureRecognizer:tapPress];

  // 试看按钮
  UIButton *startPlayRecordButton =
      [UIButton buttonWithType:UIButtonTypeCustom];
  [startPlayRecordButton setImage:[UIImage imageNamed:@"btn-lx_yl_n"]
                         forState:UIControlStateNormal];
  [startPlayRecordButton setImage:[UIImage imageNamed:@"btn-lx_yl_h"]
                         forState:UIControlStateSelected];
  [startRecordVideoView addSubview:startPlayRecordButton];
  _startPlayRecordButton = startPlayRecordButton;

  [startPlayRecordButton mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.mas_equalTo(45);
    make.left.mas_equalTo(10);
    make.size.mas_equalTo(CGSizeMake(70, 70));
  }];
  startPlayRecordButton.hidden = YES;
  /**删除录像*/
  UIButton *deleteRecordButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [deleteRecordButton setImage:[UIImage imageNamed:@"btn-ps_sc_n"]
                      forState:UIControlStateNormal];
  [deleteRecordButton setImage:[UIImage imageNamed:@"btn-ps_sc_h"]
                      forState:UIControlStateSelected];
  [startRecordVideoView addSubview:deleteRecordButton];
  _deleteRecordButton = deleteRecordButton;

  [deleteRecordButton mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.mas_equalTo(45);
    make.right.mas_equalTo(-10);
    make.size.mas_equalTo(CGSizeMake(70, 70));
  }];
  deleteRecordButton.hidden = YES;

  // 标题
  UILabel *titleLabel = [[UILabel alloc] init];
  titleLabel.font = [UIFont systemFontOfSize:17.0];
  titleLabel.textColor = [UIColor colorWithRed:132.0 / 255.0f
                                         green:141.0f / 255.0f
                                          blue:153.0f / 255.0f
                                         alpha:1];
  titleLabel.textAlignment = NSTextAlignmentCenter;
  titleLabel.text = @"按住录像";
  [startRecordVideoView addSubview:titleLabel];
  _recordNoticeLabel = titleLabel;
  [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.mas_equalTo(20);
    make.right.left.equalTo(startRecordVideoView);
  }];

  // 录音提示
  UIButton *recordTimeCountButton =
      [UIButton buttonWithType:UIButtonTypeCustom];
  [recordTimeCountButton
      setBackgroundImage:[UIImage imageNamed:@"icon_timeCount_normal"]
                forState:UIControlStateNormal];
  [recordTimeCountButton setImage:[UIImage imageNamed:@"icon_timtCount_show"]
                         forState:UIControlStateNormal];
  [recordTimeCountButton setTitle:@" 1\"" forState:UIControlStateNormal];
  recordTimeCountButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
  [self addSubview:recordTimeCountButton];
  _recordTimeCountButton = recordTimeCountButton;
  [recordTimeCountButton mas_makeConstraints:^(MASConstraintMaker *make) {
    
    make.top.equalTo(self.showVideoView).offset(12);
    make.left.mas_equalTo(12);
    make.size.mas_equalTo(CGSizeMake(35, 16));
  }];
  recordTimeCountButton.hidden = YES;

  // 录像进入条
  UIView *progressBackgroundView = [[UIView alloc] init];
  progressBackgroundView.backgroundColor =
      [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
  [self addSubview:progressBackgroundView];
  [progressBackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
    
    make.left.right.equalTo(weakSelf);
    make.bottom.equalTo(weakSelf.startRecordVideoView.mas_top);
    make.size.mas_equalTo(CGSizeMake(kScreenWidth, 5));
  }];

  UIView *progressBlueView = [[UIView alloc] init];
  progressBlueView.backgroundColor = [UIColor colorWithRed:97.0f / 255.0f
                                                     green:208.0f / 255.0f
                                                      blue:224.0f / 255.0f
                                                     alpha:1];
  [progressBackgroundView addSubview:progressBlueView];
  _progressBlueView = progressBlueView;
  [progressBlueView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.top.mas_equalTo(0);
    make.size.mas_equalTo(CGSizeMake(0, 5));

  }];

  UIView *progressWhiteView = [[UIView alloc] init];
  progressWhiteView.backgroundColor = [UIColor whiteColor];
  [progressBackgroundView addSubview:progressWhiteView];
  _progressWhiteView = progressWhiteView;
  [progressWhiteView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(progressBlueView.mas_right);
    make.top.mas_equalTo(0);
    make.height.mas_equalTo(5);
    make.width.mas_equalTo(5);
  }];
}
/**录音*/
#pragma mark -UILongPressGestureRecognizer method
- (void)tapPress:(UILongPressGestureRecognizer *)tapPress {
  switch (tapPress.state) {
    case UIGestureRecognizerStateBegan: {
      // 开始录制视频
      [self.recordViewTool startRecordVideoForDuration:15.0f];

      [self.startImageView setImage:[UIImage imageNamed:@"btn-lx_lz_h"]];
      self.startPlayRecordButton.hidden = NO;
      self.deleteRecordButton.hidden = NO;
      self.recordTimeCountButton.hidden = NO;

      [UIView animateWithDuration:15.0f
                       animations:^{
                         [self.progressBlueView
                             mas_remakeConstraints:^(MASConstraintMaker *make) {
                               make.top.mas_equalTo(0);
                               make.left.mas_equalTo(0);
                               make.height.mas_equalTo(5);
                               make.width.mas_equalTo(kScreenWidth - 5);
                             }];
                         [self layoutIfNeeded];
                       }];
      break;
    }
    case UIGestureRecognizerStateChanged: {
      CGPoint point = [tapPress locationInView:self];
        
      CGFloat pad = [UIScreen mainScreen].bounds.size.width / 3.0f;
      if (point.x < pad) {  // 左滑

        self.startPlayRecordButton.selected = YES;
        self.deleteRecordButton.selected = NO;
        self.recordNoticeLabel.hidden = NO;
        self.recordNoticeLabel.text = @"松手预览";
          
          self.isVideoDelete=NO;

          self.status = VideoStatusPlay;
      }
      else if (point.x > pad * 2) {  // 右滑

        self.startPlayRecordButton.selected = NO;
        self.deleteRecordButton.selected = YES;
        self.recordNoticeLabel.hidden = NO;
          
          self.status = VideoStatusNormal;
      }
      else {
        self.startPlayRecordButton.selected = NO;
        self.deleteRecordButton.selected = NO;
        self.recordNoticeLabel.hidden = YES;
        self.recordNoticeLabel.text = @"松手删除";
          
          self.isVideoDelete=YES;
          
          self.status = VideoStatusDelete;

      }

      break;
    }
    case UIGestureRecognizerStateEnded: {
      [self.progressBlueView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.height.mas_equalTo(5);
        make.width.mas_equalTo(0);
      }];

      
      if (self.startPlayRecordButton.selected ||
          self.deleteRecordButton.selected) {
          self.sendVideo = NO;
         [self.recordViewTool stopRecordVideo];
      } else {
         self.sendVideo = YES;
          
          [self.recordViewTool stopRecordVideo];

      }
      // 结束录制
      [self.recordViewTool stopRecordVideo];
        
        [self resumeUI];
      
      break;
    }

    default:
      break;
  }
}
- (void)changeCameraButtonClick {
  [self.recordViewTool changeCamera];
}

//UI恢复原状
-(void)resumeUI{

    self.recordNoticeLabel.text = @"按住录像";
    self.recordNoticeLabel.hidden = NO;
    [self.startImageView setImage:[UIImage imageNamed:@"red_point"]];
    self.startPlayRecordButton.hidden = YES;
    self.deleteRecordButton.hidden = YES;
    self.recordTimeCountButton.hidden = YES;
    [self.recordTimeCountButton setTitle:@" 1\""
                                forState:UIControlStateNormal];
    self.deleteRecordButton.selected = NO;
    self.startPlayRecordButton.selected = NO;
}

// add by jiang lincen
#pragma mark - Auth Method
+ (BOOL)isCameraAuth {
  NSString *mediaType = AVMediaTypeVideo;

    
  AVAuthorizationStatus authStatus =
      [AVCaptureDevice authorizationStatusForMediaType:mediaType];

  if (authStatus == AVAuthorizationStatusRestricted ||
      authStatus == AVAuthorizationStatusDenied) {
  //  DDLogWarn(@"相机权限受限");

    return NO;
  }

    NSString *audioType = AVMediaTypeAudio;

    AVAuthorizationStatus audioStatus =
    [AVCaptureDevice authorizationStatusForMediaType:audioType];
    
    if (audioStatus == AVAuthorizationStatusRestricted ||
        audioStatus == AVAuthorizationStatusDenied) {
      //  DDLogWarn(@"音频权限受限");
        
        return NO;
    }
    
  return YES;
}

+ (void)showAuthInfo {
  NSString *appName =
      [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
  if (appName == nil) {
    appName =
        [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
  }

  [UIAlertView
          showWithTitle:@"无法获取摄像头"
                message:[NSString stringWithFormat:@"请在“设置-隐私-"
                                                   @"相机”选项中允许<< %@ "
                                                   @">>访问你的相机",
                                                   appName]
      cancelButtonTitle:@"确定"
      otherButtonTitles:nil
               tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {


               }];
}

#pragma mark-- 录音代理
/**录音中*/
- (void)recordViewTimeInterval:(NSTimeInterval)timelen {
  NSInteger time = timelen + 1;
  [self.recordTimeCountButton
      setTitle:[NSString stringWithFormat:@" %ld\"", (long)time]
      forState:UIControlStateNormal];
}
/**结束视频发送*/
#pragma mark--GYHDPlayVideoViewDelegate
- (void)GYHDPlayVideoView:(GYHDPlayVideoView *)playVideoView
              DidSendData:(NSData *)data {
  
  if ([self.delegate
          respondsToSelector:@selector(GYHDKeyboardSelectBaseView:
                                                         sendDict:
                                                         SendType:)]) {
    [self.delegate GYHDKeyboardSelectBaseView:self
                                     sendDict:self.sendDict
                                     SendType:GYHDKeyboardSelectBaseSendVideo];
  }
    [self disMiss];
}

#pragma mark - GYHDRecordVideo ToolDelegate
- (void)GYHDRecordVideoTool:(GYHDRecordVideoTool *)recordView
                   sendDict:(NSDictionary *)dict {
 
    self.sendDict = dict;
    
    if (self.sendDict==nil||[self.sendDict isKindOfClass:[NSNull class]]) {
        
        [UIAlertView showWithTitle:@"视频录制失败"
                           message:nil
                 cancelButtonTitle:@"确定"
                 otherButtonTitles:nil
                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                              
                              [self disMiss];
                          }];
        
        return;
    }
    
    //
    if (self.sendVideo) {
        
        if ([self.delegate
             respondsToSelector:@selector(GYHDKeyboardSelectBaseView:
                                          sendDict:
                                          SendType:)]) {
                 [self.delegate GYHDKeyboardSelectBaseView:self
                                                  sendDict:self.sendDict
                                                  SendType:GYHDKeyboardSelectBaseSendVideo];
                 [self disMiss];

             }

    }
    
    else if (self.isVideoDelete){
       // DDLogInfo(@"需要删除录制视频");
        /*
            中间做删除动作,然后置位视频是否删除状态 
         */
        self.isVideoDelete=NO;
    }
    
    else {
    
            GYHDPlayVideoView *playeView = [[GYHDPlayVideoView alloc]
                                                           initWithPlayMp4Data:[self.recordViewTool mp4Data]];
                    playeView.delegate = self;
                    [playeView show];
        
    }
    
    }

- (void)GYHDRecordVideoToolRecoredDidFailed {
  //
 // DDLogWarn(@"视频录制失败");

  [UIAlertView showWithTitle:@"视频录制失败"
                     message:nil
           cancelButtonTitle:@"确定"
           otherButtonTitles:nil
                    tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {

                      [self disMiss];
                    }];
}

#pragma mark - dealloc
- (void)dealloc {
}
@end
