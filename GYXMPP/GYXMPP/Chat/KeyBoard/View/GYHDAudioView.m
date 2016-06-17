//
//  GYHDAudioView.m
//  HSConsumer
//
//  Created by shiang on 16/2/2.
//  @深圳市归一科技研发有限公司_iOS
//  @版权所有  禁止传播
//  @级别：绝密
//  Copyright © 2016年 SHENZHEN GUIYI SCIENCE AND TECHNOLOGY DEVELOP CO.,LTD.
//  All rights reserved.
//

#import "GYHDAudioTool.h"
#import "GYHDAudioView.h"
#import "UIAlertView+Blocks.h"

@interface GYHDAudioView () {

  UILongPressGestureRecognizer *localTapPress;
}
@property(nonatomic, strong) GYHDAudioTool *audioTool;
/**音波图像数组*/
@property(nonatomic, strong) NSArray *recordFluctuationImageArray;
/**录音时长*/
@property(nonatomic, copy) NSString *recordTimeString;
/**开始录音View*/
@property(nonatomic, strong) UIView *startRecordView;
/**开始录音标题*/
@property(nonatomic, strong) UILabel *startRecordTitleLabel;
/**删除录音*/
@property(nonatomic, strong) UIButton *deleteRecordButton;
/**开始播放按钮*/
@property(nonatomic, strong) UIButton *startPlayRecordButton;
/**开始录音*/
@property(nonatomic, strong) UIImageView *startImageView;
/**时长波动*/
@property(nonatomic, strong) UIButton *startRecordTimerButton;

/**结束录音View*/
@property(nonatomic, strong) UIView *endRecordView;
/**播放录音*/
@property(nonatomic, strong) UIButton *endplayRecordButton;
/**结束音波*/
@property(nonatomic, strong) UIButton *endRecordTimerButton;
/**提示title定时器*/
@property(nonatomic, strong) NSTimer *recordtimer;
/**录音按钮选择时长*/
@property(nonatomic, assign) NSTimeInterval recordSelectTimeInterval;

/**录音时长*/
@property(nonatomic, assign) CGFloat timeLen;

@end
static NSString const *startRecordString = @"00:00";
@implementation GYHDAudioView

- (GYHDAudioTool *)audioTool {
  if (!_audioTool) {
            _audioTool = [GYHDAudioTool sharedInstance];
//    _audioTool = [GYHDAudioTool new];
  }
  return _audioTool;
}
- (NSArray *)recordFluctuationImageArray {
  if (!_recordFluctuationImageArray) {
    NSMutableArray *arrayM = [NSMutableArray array];
    for (int i = 1; i < 7; ++i) {
      [arrayM
          addObject:[UIImage
                        imageNamed:[NSString
                                       stringWithFormat:@"icon-sbxg-%d", i]]];
    }
    _recordFluctuationImageArray = arrayM;
  }
  return _recordFluctuationImageArray;
}
- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (!self)
    return self;
  self.backgroundColor = [UIColor blueColor];

  [self setupStartRecordView];
  [self setupEndRecordingView];
  return self;
}
/**
 * 开始录音界面
 */
- (void)setupStartRecordView {

    WSHD(weakSelf);
    
  _startRecordView = [[UIView alloc] init];
  [self addSubview:self.startRecordView];

  [self.startRecordView mas_makeConstraints:^(MASConstraintMaker *make) {
   
    make.top.left.bottom.right.equalTo(weakSelf);
  }];
  self.startRecordView.backgroundColor = [UIColor colorWithRed:236.0f / 255.0f
                                                         green:237.0f / 255.0f
                                                          blue:241.0f / 255.0f
                                                         alpha:1];
  // 标题
  _startRecordTitleLabel = [[UILabel alloc] init];

  _startRecordTitleLabel.font = [UIFont systemFontOfSize:17.0];
  _startRecordTitleLabel.textColor = [UIColor colorWithRed:132.0 / 255.0f
                                                     green:141.0f / 255.0f
                                                      blue:153.0f / 255.0f
                                                     alpha:1];
  _startRecordTitleLabel.textAlignment = NSTextAlignmentCenter;
  _startRecordTitleLabel.text = @"按住说话";
  [self.startRecordView addSubview:_startRecordTitleLabel];

  [_startRecordTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    
    make.top.mas_equalTo(20);
    make.right.left.equalTo(weakSelf.startRecordView);
  }];
  // 开始按钮
  UIImageView *startImageView = [[UIImageView alloc] init];
  startImageView.userInteractionEnabled = YES;
  [startImageView setImage:[UIImage imageNamed:@"btn-yy_big_2-1"]];
  _startImageView = startImageView;
  [self.startRecordView addSubview:startImageView];

  [startImageView mas_makeConstraints:^(MASConstraintMaker *make) {
    
    make.size.mas_equalTo(CGSizeMake(107, 107));
    make.center.equalTo(weakSelf.startRecordView);
  }];
  localTapPress = [[UILongPressGestureRecognizer alloc]
      initWithTarget:self
              action:@selector(tapPress:)];
  localTapPress.minimumPressDuration = 0;
  [startImageView addGestureRecognizer:localTapPress];

  // 试听按钮
  UIButton *startPlayRecordButton =
      [UIButton buttonWithType:UIButtonTypeCustom];
  [startPlayRecordButton setImage:[UIImage imageNamed:@"icon-yy_st_normal"]
                         forState:UIControlStateNormal];
  [startPlayRecordButton setImage:[UIImage imageNamed:@"icon-yy_st_selected"]
                         forState:UIControlStateSelected];
  [self.startRecordView addSubview:startPlayRecordButton];
  _startPlayRecordButton = startPlayRecordButton;
  [startPlayRecordButton mas_makeConstraints:^(MASConstraintMaker *make) {

    make.top.mas_equalTo(45);
    make.left.mas_equalTo(5);
    make.size.mas_equalTo(CGSizeMake(70.0f, 70.0f));
  }];
  startPlayRecordButton.hidden = YES;
  /**删除录音*/
  UIButton *deleteRecordButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [deleteRecordButton setImage:[UIImage imageNamed:@"icon-yy_sc_normal"]
                      forState:UIControlStateNormal];
  [deleteRecordButton setImage:[UIImage imageNamed:@"icon-yy_sc_selected"]
                      forState:UIControlStateSelected];
  [self.startRecordView addSubview:deleteRecordButton];
  _deleteRecordButton = deleteRecordButton;
  [deleteRecordButton mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.mas_equalTo(45);
    make.right.mas_equalTo(-5);
    make.size.mas_equalTo(CGSizeMake(70.0f, 70.0f));
  }];
  deleteRecordButton.hidden = YES;
  // 录音波荡
  UIButton *startRecordTimerButton =
      [UIButton buttonWithType:UIButtonTypeCustom];
  startRecordTimerButton.userInteractionEnabled = NO;
  startRecordTimerButton.titleLabel.font = [UIFont systemFontOfSize:12.0f];
  [startRecordTimerButton setTitleColor:[UIColor colorWithRed:132.0 / 255.0f
                                                        green:141.0f / 255.0f
                                                         blue:153.0f / 255.0f
                                                        alpha:1]
                               forState:UIControlStateNormal];
  [startRecordTimerButton setTitle:startRecordString.copy
                          forState:UIControlStateNormal];
  [startRecordTimerButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -25)];
  [startRecordTimerButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 125)];
  [startRecordTimerButton setImage:[UIImage imageNamed:@"icon-sbxg-1"]
                          forState:UIControlStateNormal];
  startRecordTimerButton.imageView.animationImages =
      self.recordFluctuationImageArray;
  startRecordTimerButton.imageView.animationDuration = 0.6;
  startRecordTimerButton.imageView.contentMode = UIViewContentModeCenter;
  [self.startRecordView addSubview:startRecordTimerButton];
  _startRecordTimerButton = startRecordTimerButton;
  startRecordTimerButton.hidden = YES;
  [startRecordTimerButton mas_makeConstraints:^(MASConstraintMaker *make) {
   
    make.left.right.equalTo(weakSelf.startRecordView);
    make.top.mas_equalTo(20);
  }];
}
/**
 * 结束录音界面
 */
- (void)setupEndRecordingView {
  
    WSHD(weakSelf);
    
  // 显示的控制器
  UIView *endRecordView = [[UIView alloc] init];
  [self addSubview:endRecordView];
  _endRecordView = endRecordView;
  [endRecordView mas_makeConstraints:^(MASConstraintMaker *make) {
    
    make.top.left.bottom.right.equalTo(self);
  }];
  self.endRecordView.hidden = YES;
  endRecordView.backgroundColor = [UIColor colorWithRed:236.0f / 255.0f
                                                  green:237.0f / 255.0f
                                                   blue:241.0f / 255.0f
                                                  alpha:1];

  // 1.声音波动图
  UIButton *endRecordTimerButton = [UIButton buttonWithType:UIButtonTypeCustom];
  endRecordTimerButton.userInteractionEnabled = NO;
  endRecordTimerButton.titleLabel.font = [UIFont systemFontOfSize:12.0f];
  [endRecordTimerButton setTitleColor:[UIColor colorWithRed:132.0 / 255.0f
                                                      green:141.0f / 255.0f
                                                       blue:153.0f / 255.0f
                                                      alpha:1]
                             forState:UIControlStateNormal];
  [endRecordTimerButton setTitle:startRecordString.copy
                        forState:UIControlStateNormal];
  [endRecordTimerButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -25)];
  [endRecordTimerButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 125)];
  [endRecordTimerButton setImage:[UIImage imageNamed:@"icon-sbxg-1"]
                        forState:UIControlStateNormal];
  endRecordTimerButton.imageView.animationImages =
      self.recordFluctuationImageArray;
  endRecordTimerButton.imageView.animationDuration = 0.6;
  endRecordTimerButton.imageView.contentMode = UIViewContentModeCenter;
  [endRecordView addSubview:endRecordTimerButton];
  _endRecordTimerButton = endRecordTimerButton;
  [endRecordTimerButton mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.right.equalTo(endRecordView);
    make.top.mas_equalTo(20);
  }];
  // 4. 播放按钮
  UIButton *endplayRecordButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [endRecordView addSubview:endplayRecordButton];
  [endplayRecordButton setBackgroundImage:[UIImage imageNamed:@"btn-yy_big_3"]
                                 forState:UIControlStateNormal];
  [endplayRecordButton setBackgroundImage:[UIImage imageNamed:@"btn-yy_2"]
                                 forState:UIControlStateSelected];

  [endplayRecordButton addTarget:self
                          action:@selector(playRecordButtonClick:)
                forControlEvents:UIControlEventTouchUpInside];

  _endplayRecordButton = endplayRecordButton;
  [endplayRecordButton mas_makeConstraints:^(MASConstraintMaker *make) {
    make.size.mas_equalTo(CGSizeMake(107, 107));
    make.center.equalTo(endRecordView);
  }];
  // 取消按钮
  UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [endRecordView addSubview:cancelButton];
  [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
  [cancelButton setTitleColor:kLightRedColor forState:UIControlStateNormal];
  [cancelButton setBackgroundImage:[UIImage imageNamed:@"btn-n_l_normal"]
                          forState:UIControlStateNormal];
  [cancelButton setBackgroundImage:[UIImage imageNamed:@"btn-n_l_selected"]
                          forState:UIControlStateHighlighted];
  [cancelButton addTarget:self
                   action:@selector(cancelButtonClick:)
         forControlEvents:UIControlEventTouchUpInside];
  [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.bottom.equalTo(endRecordView);
    make.height.mas_equalTo(30);
    make.width.equalTo(endRecordView).multipliedBy(0.5);
  }];
  // 发送按钮
  UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [endRecordView addSubview:sendButton];
  [sendButton setTitle:@"发送" forState:UIControlStateNormal];
  [sendButton setTitleColor:kLightRedColor forState:UIControlStateNormal];
  [sendButton setBackgroundImage:[UIImage imageNamed:@"btn-n_r_normal"]
                        forState:UIControlStateNormal];
  [sendButton setBackgroundImage:[UIImage imageNamed:@"btn-n_r_selected"]
                        forState:UIControlStateHighlighted];
  [sendButton addTarget:self
                 action:@selector(sendButtonClick:)
       forControlEvents:UIControlEventTouchUpInside];
  [sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
    make.right.bottom.equalTo(endRecordView);
    make.height.mas_equalTo(30);
    make.width.equalTo(endRecordView).multipliedBy(0.5);
  }];
}

- (void)sendButtonClick:(UIButton *)button {
  [self.audioTool stopPlaying];
  [_recordtimer invalidate];
  self.endplayRecordButton.selected = NO;
  [self.endRecordTimerButton setTitle:startRecordString.copy
                             forState:UIControlStateNormal];
  self.endRecordView.hidden = YES;
  [self.endRecordTimerButton.imageView stopAnimating];
  if ([self.delegate
          respondsToSelector:@selector(GYHDKeyboardSelectBaseView:
                                                         sendDict:
                                                         SendType:)]) {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"mp3"] = [self.audioTool mp3NameString];
    dict[@"mp3Len"] = [NSString stringWithFormat:@"%f", self.audioTool.gettime];

    [self.delegate GYHDKeyboardSelectBaseView:self
                                     sendDict:dict
                                     SendType:GYHDKeyboardSelectBaseSendAudio];
  }
}
- (void)cancelButtonClick:(UIButton *)button {
  self.endRecordView.hidden = YES;
  [self.audioTool stopPlaying];
  [_recordtimer invalidate];
  self.endplayRecordButton.selected = NO;
  [self.endRecordTimerButton.imageView stopAnimating];
  [self.endRecordTimerButton setTitle:startRecordString.copy
                             forState:UIControlStateNormal];
}
/**播放按钮*/
- (void)playRecordButtonClick:(UIButton *)button {
  button.selected = !button.selected;
  if (button.selected) {
    [self.audioTool startPlayingWithData:nil complete:nil];
    _recordtimer =
        [NSTimer scheduledTimerWithTimeInterval:1.0
                                         target:self
                                       selector:@selector(listenRecord)
                                       userInfo:nil
                                        repeats:YES];
    [self.endRecordTimerButton.imageView startAnimating];
    [self.endRecordTimerButton setTitle:startRecordString.copy
                               forState:UIControlStateNormal];
  } else {
    [self.audioTool stopPlaying];
    [_recordtimer invalidate];
    [self.endRecordTimerButton.imageView stopAnimating];
    [self.endRecordTimerButton setTitle:self.recordTimeString
                               forState:UIControlStateNormal];
  }
}

//播放录音
- (void)listenRecord {
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  [formatter setDateFormat:@"mm:ss"];
  NSDate *date =
      [formatter dateFromString:self.endRecordTimerButton.currentTitle];
  NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:
                                [date timeIntervalSinceReferenceDate] + 1];
  [self.endRecordTimerButton setTitle:[formatter stringFromDate:newDate]
                             forState:UIControlStateNormal];
  if ([self.endRecordTimerButton.currentTitle
          isEqualToString:self.recordTimeString]) {
    [_recordtimer invalidate];
    [self.endRecordTimerButton.imageView stopAnimating];
    self.endplayRecordButton.selected = NO;
  }
}
/**录音*/
- (void)tapPress:(UILongPressGestureRecognizer *)tapPress {

    WSHD(weakSelf);
  // modify by jianglincen
  //修复循环引用

  switch (tapPress.state) {
  case UIGestureRecognizerStateBegan: {
    self.timeLen = 0.0;

    self.startPlayRecordButton.hidden = NO;
    self.deleteRecordButton.hidden = NO;
    self.startRecordTitleLabel.hidden = YES;
    self.startRecordTimerButton.hidden = NO;
    [self.startImageView setImage:[UIImage imageNamed:@"btn-yy_big_2-1"]];
    self.recordSelectTimeInterval = [NSDate timeIntervalSinceReferenceDate];
    [self.startRecordTimerButton.imageView startAnimating];
    [self layoutIfNeeded];

    self.recordtimer =
        [NSTimer scheduledTimerWithTimeInterval:0.1
                                         target:self
                                       selector:@selector(setrecordTitle:)
                                       userInfo:nil
                                        repeats:YES];

    [[NSRunLoop mainRunLoop] addTimer:self.recordtimer
                              forMode:NSDefaultRunLoopMode];

    [self.audioTool startRecord:^(GYHDAudioToolRecordState state) {

      switch (state) {
      case GYHDAudioToolRecordSurpass30Seconds: {

        [self.audioTool stopRecord];
        [self.recordtimer invalidate];

        [self.startRecordTimerButton.imageView stopAnimating];

//        UIWindow *window = [UIApplication sharedApplication].windows.lastObject;
//        [window makeToast:@"录音时间超过30秒"
//                 duration:1.0f
//                 position:CSToastPositionCenter];
        break;
      }
      case GYHDAudioToolRecordProhibit: {

        [self.recordtimer invalidate];
        [self.startRecordTimerButton.imageView stopAnimating];
        self.startPlayRecordButton.hidden = YES;
        self.deleteRecordButton.hidden = YES;
        self.startRecordTitleLabel.hidden = NO;
        self.startRecordTimerButton.hidden = YES;

        self.startRecordTitleLabel.text = @"按住说话";

        NSString *appName = [[NSBundle mainBundle]
            objectForInfoDictionaryKey:@"CFBundleDisplayName"];
        if (appName == nil) {
          appName = [[NSBundle mainBundle]
              objectForInfoDictionaryKey:@"CFBundleName"];
        }
          
          [UIAlertView
           showWithTitle:@"无法录音"
           message:[NSString stringWithFormat:
                    @"请在“设置-隐私-"
                    @"麦克风”选项中允许<< %@ "
                    @">>访问你的麦克风",
                    appName]
           cancelButtonTitle:@"确定"
           otherButtonTitles:nil
           tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
               
//               NSURL *url = [NSURL URLWithString:@"prefs:root=privacy"];
//               if ([[UIApplication sharedApplication] canOpenURL:url]) {
//                   [[UIApplication sharedApplication] openURL:url];
//               }
           }];
          
        break;
      }
      default:
        break;
      }

    }];

    break;
  }

  case UIGestureRecognizerStateChanged: {

    CGPoint point = [tapPress locationInView:self];
    CGFloat pad = [UIScreen mainScreen].bounds.size.width / 3.0f;
    if (point.x < pad) { // 左滑
      self.startPlayRecordButton.selected = YES;
      self.startRecordTimerButton.hidden = YES;
      self.startRecordTitleLabel.hidden = NO;
      self.startRecordTitleLabel.text = @"松手试听";
    } else if (point.x > pad * 2) { // 右滑
      self.deleteRecordButton.selected = YES;
      self.startRecordTimerButton.hidden = YES;
      self.startRecordTitleLabel.hidden = NO;
      self.startRecordTitleLabel.text = @"松手删除";
    } else {
      self.deleteRecordButton.selected = NO;
      self.startPlayRecordButton.selected = NO;
      self.startRecordTimerButton.hidden = NO;
      self.startRecordTitleLabel.hidden = YES;
      self.startRecordTitleLabel.text = @"按住说话";
    }
    break;
  }
  case UIGestureRecognizerStateEnded: {
    [self.audioTool stopRecord];
    [self.recordtimer invalidate];
    [self.startRecordTimerButton.imageView stopAnimating];
    [self.startImageView setImage:[UIImage imageNamed:@"btn-yy_big_2-1"]];

    if (self.deleteRecordButton.selected) { // 右边

      self.deleteRecordButton.selected = NO;
      self.startRecordTitleLabel.text = @"按住说话";
    } else if (self.startPlayRecordButton.selected) { // 左边
      self.recordTimeString = self.startRecordTimerButton.currentTitle;

      self.endRecordView.hidden = NO;
      [self.endRecordTimerButton setTitle:self.recordTimeString
                                 forState:UIControlStateNormal];
      self.startPlayRecordButton.selected = NO;
      self.startRecordTitleLabel.text = @"按住说话";
    } else { //中间

      self.startRecordTitleLabel.hidden = NO;
      self.startRecordTimerButton.hidden = YES;

      if ([NSDate timeIntervalSinceReferenceDate] -
              self.recordSelectTimeInterval <=
          1) {
//        UIWindow *window = [UIApplication sharedApplication].windows.lastObject;
//        [window makeToast:@"录音时间太短"
//                 duration:1.0f
//                 position:CSToastPositionCenter];
      } else {
        if ([self.delegate
                respondsToSelector:@selector(GYHDKeyboardSelectBaseView:
                                                               sendDict:
                                                               SendType:)]) {

          NSMutableDictionary *dict = [NSMutableDictionary dictionary];
          dict[@"mp3"] = [self.audioTool mp3NameString];

          dict[@"mp3Len"] = [NSString stringWithFormat:@"%d", (int)_timeLen];

          [self.delegate
              GYHDKeyboardSelectBaseView:self
                                sendDict:dict
                                SendType:GYHDKeyboardSelectBaseSendAudio];
        }
      }
    }
    self.startPlayRecordButton.hidden = YES;
    self.deleteRecordButton.hidden = YES;
    [self.startRecordTimerButton setTitle:startRecordString.copy
                                 forState:UIControlStateNormal];
    break;
  }
  default:
    break;
  }
}
/**改变显示时长*/
- (void)setrecordTitle:(NSTimer *)timer {

  CGFloat curTimeLen = _timeLen;

  _timeLen = timer.timeInterval + curTimeLen;

  // DDLogCError(@"当前记录时间:%f",_timeLen);

  [self.startRecordTimerButton
      setTitle:[NSString stringWithFormat:@"00:%02.0f", _timeLen]
      forState:UIControlStateNormal];

  if (_timeLen >= 30.0) {

    //到时间取消长按状态
    [localTapPress cancelsTouchesInView];

    self.audioTool.recordBlock(GYHDAudioToolRecordSurpass30Seconds);
  }

  //    [self.startRecordTimerButton setTitle:[NSString
  //    stringWithFormat:@"00:%02d",++_timeLen] forState:UIControlStateNormal];
}

- (void)dealloc {
}
@end
