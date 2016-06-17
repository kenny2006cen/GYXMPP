//
//  GYHDInputView.m
//  HSConsumer
//
//  Created by shiang on 16/2/2.
//  @深圳市归一科技研发有限公司_iOS
//  @版权所有  禁止传播
//  @级别：绝密
//  Copyright © 2016年 SHENZHEN GUIYI SCIENCE AND TECHNOLOGY DEVELOP CO.,LTD.
//  All rights reserved.
//

#import "GYHDAudioView.h"
#import "GYHDCameraView.h"
#import "GYHDEmojiView.h"
#import "GYHDInputView.h"
#import "GYHDMessageTextView.h"
#import "GYHDPhotoView.h"
#import "GYHDVideoView.h"
#import "IQKeyboardManager.h"
//#import "UIView+Toast.h"

#import "EmojiTextAttachment.h"

@interface GYHDInputView ()<UITextViewDelegate,
                            GYHDKeyboardSelectBaseViewDelegate,
                            GYHDEmojiViewDelegate>
/**消息输入*/
@property(nonatomic, weak) GYHDMessageTextView *messageTextView;
/**发送按钮*/
//@property(nonatomic, weak) UIButton *sendButton;
/**录音按钮*/
@property(nonatomic, weak) UIButton *audioButton;
/**录像按钮*/
@property(nonatomic, weak) UIButton *videoButton;
/**相册按钮*/
@property(nonatomic, weak) UIButton *photoButton;
/**相机按钮*/
@property(nonatomic, weak) UIButton *cameraButton;
/**GPS定位图片按钮*/
@property(nonatomic, weak) UIButton *GPSButton;
/**表情按钮*/
@property(nonatomic, weak) UIButton *emojiButton;
/**选中的按钮*/
@property(nonatomic, weak) UIButton *selectedButton;
/**录音展示*/
@property(nonatomic, weak) UIView *showChildView;
/**录音view*/
@property(nonatomic, weak) UIImageView *startImageView;
/**等待字符串*/
@property(nonatomic, weak) UILabel *placeholderLabel;
/**父View*/
@property(nonatomic, weak) UIView *mySuperView;
/**快捷回复*/
@property(nonatomic, weak) UIButton *quickReplyButton;
@end

@implementation GYHDInputView

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self setup];
  }
  return self;
}

#pragma mark - method
/**界面基本布局*/
- (void)setup {
  //  [[NSNotificationCenter defaultCenter] addObserver:self
  //  selector:@selector(keyboardWillChangeFrame:)
  //  name:UIKeyboardWillChangeFrameNotification object:nil];
  // [[NSNotificationCenter defaultCenter] addObserver:self
  // selector:@selector(keyboardDidShow) name:UIKeyboardDidShowNotification
  // object:nil];

  //给键盘注册通知
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(inputKeyboardWillShow:)
             name:UIKeyboardWillShowNotification
           object:nil];

  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(inputKeyboardWillHide:)
             name:UIKeyboardWillHideNotification
           object:nil];

  self.backgroundColor = [UIColor whiteColor];

  IQKeyboardManager *manager = [IQKeyboardManager sharedManager];
  manager.enable = NO;
  manager.shouldResignOnTouchOutside = NO;
  manager.shouldToolbarUsesTextFieldTintColor = NO;
  manager.enableAutoToolbar = NO;
  // 发送
 
    WSHD(weakSelf);
    
  CGFloat WH = (kScreenWidth) / 7;
  //显示View
  UIView *showView = [[UIView alloc] init];
  [self addSubview:showView];
  _showChildView = showView;
  [showView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.bottom.right.left.mas_equalTo(0);
    make.height.mas_equalTo(211);
  }];

  UIView *grayLineView1 = [[UIView alloc] init];
  grayLineView1.backgroundColor = [UIColor colorWithRed:204 / 255.0f
                                                  green:204 / 255.0f
                                                   blue:204 / 255.0f
                                                  alpha:1];
  [self addSubview:grayLineView1];
  [grayLineView1 mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.right.mas_equalTo(0);
    make.height.mas_equalTo(1);
    make.bottom.equalTo(showView.mas_top);
  }];

  // 音频
  UIButton *audioButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [audioButton setImage:[UIImage imageNamed:@"hd_audio_btn_normal"]
               forState:UIControlStateNormal];
  [audioButton setImage:[UIImage imageNamed:@"btn-yy_2"]
               forState:UIControlStateSelected];
  [audioButton addTarget:self
                  action:@selector(buttonClick:)
        forControlEvents:UIControlEventTouchDown];
  [self addSubview:audioButton];
  _audioButton = audioButton;
  [audioButton mas_makeConstraints:^(MASConstraintMaker *make) {
    make.size.mas_equalTo(CGSizeMake(WH, WH));
    make.bottom.equalTo(showView.mas_top);
  }];

  // 录像
  UIButton *videoButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [videoButton setImage:[UIImage imageNamed:@"hd_video_btn_normal"]
               forState:UIControlStateNormal];
  [videoButton setImage:[UIImage imageNamed:@"btn-sp"]
               forState:UIControlStateHighlighted];
  [videoButton addTarget:self
                  action:@selector(buttonClick:)
        forControlEvents:UIControlEventTouchUpInside];
  [self addSubview:videoButton];
  _videoButton = videoButton;
  [videoButton mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.width.height.equalTo(audioButton);
    make.left.equalTo(audioButton.mas_right);
  }];

  // 相册
  UIButton *photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [photoButton setImage:[UIImage imageNamed:@"hd_photo_btn_normal"]
               forState:UIControlStateNormal];
  [photoButton setImage:[UIImage imageNamed:@"btn-tp-2"]
               forState:UIControlStateSelected];
  [photoButton addTarget:self
                  action:@selector(buttonClick:)
        forControlEvents:UIControlEventTouchDown];
  [self addSubview:photoButton];
  _photoButton = photoButton;
  [photoButton mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.width.height.equalTo(audioButton);
    make.left.equalTo(videoButton.mas_right);
  }];
  // 相机
  UIButton *cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [cameraButton setImage:[UIImage imageNamed:@"hd_camera_btn_normal"]
                forState:UIControlStateNormal];
  [cameraButton setImage:[UIImage imageNamed:@"btn-ps-2"]
                forState:UIControlStateHighlighted];
  [cameraButton addTarget:self
                   action:@selector(buttonClick:)
         forControlEvents:UIControlEventTouchUpInside];
  [self addSubview:cameraButton];
  _cameraButton = cameraButton;
  [cameraButton mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.width.height.equalTo(audioButton);
    make.left.equalTo(photoButton.mas_right);
  }];

  // 表情
  UIButton *emojiButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [emojiButton setImage:[UIImage imageNamed:@"hd_emoji_btn_normal"]
               forState:UIControlStateNormal];
  [emojiButton setImage:[UIImage imageNamed:@"btn-bq-2"]
               forState:UIControlStateSelected];
  [emojiButton addTarget:self
                  action:@selector(buttonClick:)
        forControlEvents:UIControlEventTouchDown];
  [self addSubview:emojiButton];
  _emojiButton = emojiButton;
  [emojiButton mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.width.height.equalTo(audioButton);
    make.left.equalTo(cameraButton.mas_right);
  }];

 

  UIView *blueLineView = [[UIView alloc] init];
  blueLineView.backgroundColor = [UIColor colorWithRed:0.0 / 255.0
                                                 green:166.0 / 255.0
                                                  blue:214.0 / 255.0
                                                 alpha:1.0];
  [self addSubview:blueLineView];
  [blueLineView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.mas_equalTo(10);
    make.right.mas_equalTo(-10);
    make.height.mas_equalTo(1);
    make.bottom.equalTo(audioButton.mas_top);
  }];
  // 输入条
  GYHDMessageTextView *messageTextView = [[GYHDMessageTextView alloc] init];

  //使用该语句，会导致输入框在切换输入源时输入框上移
  //  messageTextView.textContainer.lineFragmentPadding = 0.0f;
  //  messageTextView.textContainerInset = UIEdgeInsetsZero;

  messageTextView.delegate = self;
  [self addSubview:messageTextView];

  [messageTextView addObserver:self
                    forKeyPath:@"attributedText"
                       options:NSKeyValueObservingOptionNew
                       context:nil];
  _messageTextView = messageTextView;
  [messageTextView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.bottom.equalTo(blueLineView.mas_top);
    make.left.mas_equalTo(10);
    make.right.mas_equalTo(-10);
    make.top.mas_equalTo(2);

  }];

  UILabel *placeholderLabel = [[UILabel alloc] init];
  //placeholderLabel.text = kLocalized(@"HD_please_enter_text");
  placeholderLabel.font = [UIFont systemFontOfSize:16.0];
  placeholderLabel.textColor = [UIColor colorWithRed:153 / 255.0f
                                               green:153 / 255.0f
                                                blue:153 / 255.0f
                                               alpha:1];
  [self addSubview:placeholderLabel];
  _placeholderLabel = placeholderLabel;
  [placeholderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.bottom.right.equalTo(messageTextView);
    make.left.equalTo(messageTextView).offset(2);
  }];

  UIView *grayLineView = [[UIView alloc] init];
  grayLineView.backgroundColor = [UIColor colorWithRed:204 / 255.0f
                                                 green:204 / 255.0f
                                                  blue:204 / 255.0f
                                                 alpha:1];
  [self addSubview:grayLineView];
  [grayLineView mas_makeConstraints:^(MASConstraintMaker *make) {
   
    make.left.right.mas_equalTo(0);
    make.height.mas_equalTo(1);
    make.top.equalTo(weakSelf.mas_top);
  }];
}

- (void)buttonClick:(UIButton *)button {
  if ([self.selectedButton isEqual:button] &&
      ![button isEqual:self.videoButton] &&
      ![button isEqual:self.cameraButton]) {
    self.selectedButton.selected = NO;
    self.selectedButton = nil;
    dispatch_after(
        dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)),
        dispatch_get_main_queue(), ^{

          [UIView animateWithDuration:0.25
                           animations:^{
                             [self mas_updateConstraints:^(
                                       MASConstraintMaker *make) {
                               make.bottom.mas_equalTo(211);
                             }];
                             [self.mySuperView layoutIfNeeded];
                           }];

        });
  } else {
    if (![button isEqual:self.videoButton] &&
        ![button isEqual:self.cameraButton]) {
      self.selectedButton.selected = NO;
      button.selected = YES;
      self.selectedButton = button;
    }
    if ([button isEqual:self.audioButton]) {  // 录音

      for (UIView *childView in self.showChildView.subviews) {
        [childView removeFromSuperview];
      }
      GYHDAudioView *audioView = [[GYHDAudioView alloc] init];
      audioView.delegate = self;
      [self.showChildView addSubview:audioView];
      [audioView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.mas_equalTo(0);
      }];
      [self showBottomView];
    } else if ([button isEqual:self.videoButton]) {  // 录像

      //是否开启相机权限
      if ([GYHDVideoView isCameraAuth]) {
        GYHDVideoView *videoView = [[GYHDVideoView alloc] init];
        videoView.delegate = self;
        [videoView show];
      } else {
        [GYHDVideoView showAuthInfo];
      }

    } else if ([button isEqual:self.photoButton]) {
      for (UIView *childView in self.showChildView.subviews) {
        [childView removeFromSuperview];
      }

      GYHDPhotoView *photoView = [[GYHDPhotoView alloc] init];
      photoView.delegate = self;
      [self.showChildView addSubview:photoView];
      [photoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.mas_equalTo(0);
      }];
      [self showBottomView];
    } else if ([button isEqual:self.cameraButton]) {
      GYHDCameraView *cameraView = [[GYHDCameraView alloc] init];
      cameraView.delegate = self;
      [cameraView show];

    } else if ([button isEqual:self.GPSButton]) {
    } else if ([button isEqual:self.emojiButton]) {
      for (UIView *childView in self.showChildView.subviews) {
        [childView removeFromSuperview];
      }
      GYHDEmojiView *emojiView = [[GYHDEmojiView alloc] init];
      emojiView.delegate = self;
      [self.showChildView addSubview:emojiView];
      [emojiView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.mas_equalTo(0);
      }];
      [self showBottomView];
    } else if ([button isEqual:self.quickReplyButton]) {
      
     
      [self showBottomView];
    }
  }
  [self.messageTextView endEditing:YES];
}
- (void)showToSuperView:(UIView *)mySuperView {
 
    self.mySuperView = mySuperView;

  [mySuperView addSubview:self];
 
    WSHD(weakSelf);
    
  [self mas_makeConstraints:^(MASConstraintMaker *make) {
   
    make.left.right.equalTo(weakSelf.mySuperView);
    make.bottom.mas_equalTo(211);
  }];
    
}

- (void)showBottomView {
 
    WSHD(weakSelf);
    
  dispatch_after(
      dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)),
      dispatch_get_main_queue(), ^{
        [UIView
            animateWithDuration:0.25
                     animations:^{
                      
                       [weakSelf mas_updateConstraints:^(MASConstraintMaker *make) {
                         make.bottom.mas_equalTo(0);
                       }];
                       [weakSelf.mySuperView layoutIfNeeded];
                     }];

      });
}
- (void)dismissKeyBoard {
    
  self.selectedButton.selected = NO;
  self.selectedButton = nil;
  [self.messageTextView resignFirstResponder];
}
- (void)keyboardDidShow {
  if (self.selectedButton) {
    self.selectedButton.selected = NO;
    self.selectedButton = nil;
  }
}
- (void)disMiss {
  [self dismissKeyBoard];
  self.selectedButton.selected = NO;
  self.selectedButton = nil;
  [self.messageTextView resignFirstResponder];

  [UIView animateWithDuration:0.25f
                   animations:^{

                     [self mas_updateConstraints:^(MASConstraintMaker *make) {
                       make.bottom.mas_equalTo(211);
                     }];
                     [self layoutIfNeeded];
                   }];
}

- (void)sendMessage {
    /*
  NSString *message = [[GYHDMessageCenter sharedInstance]
      stringWithAttString:self.messageTextView.attributedText];
  NSMutableDictionary *imageDict = [NSMutableDictionary dictionary];
  if ([message isEqualToString:@""] || message == nil) {
    return;
  }
  imageDict[@"string"] = message;
  if ([self.delegate
          respondsToSelector:@selector(GYHDInputView:sendDict:SendType:)]) {
    [self.delegate GYHDInputView:self
                        sendDict:imageDict
                        SendType:GYHDInputeViewSendText];
  }
  self.messageTextView.text = nil;
     */
}

/**
 * textview禁止滚动
 */
- (void)messageTextViewNoEnabled {
 
  self.messageTextView.scrollEnabled = NO;
 
    WSHD(weakSelf);
    
  [UIView animateWithDuration:0.25f
                   animations:^{
                     [weakSelf.messageTextView
                         mas_remakeConstraints:^(MASConstraintMaker *make) {
                          
                           make.bottom.equalTo(weakSelf.audioButton.mas_top);
                           make.left.mas_equalTo(10);
                           make.right.mas_equalTo(-10);
                           make.top.mas_equalTo(10);
                         }];
                     [weakSelf layoutIfNeeded];
                   }];
}
/**textView允许滚动*/
- (void)messageTextViewYesEnabled {
  CGFloat textViewHeight = self.messageTextView.frame.size.height;
  self.messageTextView.scrollEnabled = YES;
  [self.messageTextView mas_updateConstraints:^(MASConstraintMaker *make) {
    make.height.mas_equalTo(textViewHeight);
  }];
}

#pragma mark - UITextView Delegate
- (void)textViewDidChange:(UITextView *)textView {
  self.messageTextView.font = [UIFont systemFontOfSize:16.0];
  if (self.messageTextView.contentSize.height > 100) {
    [self messageTextViewYesEnabled];
  } else {
    [self messageTextViewNoEnabled];
  }
  if (![textView.text isEqualToString:@""]) {
    _placeholderLabel.hidden = YES;
  } else {
    _placeholderLabel.hidden = NO;
  }
}
- (BOOL)textView:(UITextView *)textView
    shouldChangeTextInRange:(NSRange)range
            replacementText:(NSString *)text {
  //考虑到安卓手机没有emoji,故而屏蔽之,不过测试发现可以识别
  //    if ([[[UITextInputMode currentInputMode]primaryLanguage]
  //    isEqualToString:@"emoji"]) {
  //        return NO;
  //    }

  if ([text isEqualToString:@"\n"]) {
    [self messageTextViewNoEnabled];
    [self sendMessage];
    return NO;
  }
  return YES;
}

#pragma mark - UITextView KVO
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
  if ([keyPath isEqualToString:@"attributedText"]) {
    self.messageTextView.font = [UIFont systemFontOfSize:16.0];
    if (self.messageTextView.contentSize.height > 100) {
      [self messageTextViewYesEnabled];
    } else {
      [self messageTextViewNoEnabled];
    }

    if (self.messageTextView.attributedText.length) {
      _placeholderLabel.hidden = YES;
    } else {
      _placeholderLabel.hidden = NO;
    }
    if (self.messageTextView.text == nil ||
        [self.messageTextView.text isEqualToString:@""]) {
      [self messageTextViewNoEnabled];
    }
    [self.messageTextView
        scrollRangeToVisible:NSMakeRange(self.messageTextView.text.length, 1)];
  }
}

#pragma mark - KeyBoardNSNotification
- (void)keyboardWillChangeFrame:(NSNotification *)notification {
  NSDictionary *userInfo = notification.userInfo;
  // 动画的持续时间
  double duration =
      [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
  // 键盘的frame
  CGRect keyboardF = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
  // 执行动画
  CGFloat height = 211 - keyboardF.size.height;
  [UIView
      animateWithDuration:duration
               animations:^{
                 // 工具条的Y值 == 键盘的Y值 - 工具条的高度
                 if (height >
                     self.mySuperView.frame.size
                         .height) {  // 键盘的Y值已经远远超过了控制器view的高度
                   // 隐藏键盘
                   [self mas_updateConstraints:^(MASConstraintMaker *make) {
                     make.bottom.mas_equalTo(211);
                   }];
                 } else {
                   // 显示键盘
                   [self mas_updateConstraints:^(MASConstraintMaker *make) {
                     make.bottom.mas_equalTo(height);
                   }];
                 }
                 [self.mySuperView layoutIfNeeded];
               }];
}

- (void)inputKeyboardWillShow:(NSNotification *)notification {
  if (self.selectedButton) {
    self.selectedButton.selected = NO;
    self.selectedButton = nil;
  }

  NSDictionary *info = [notification userInfo];

  double duration = [info[UIKeyboardAnimationDurationUserInfoKey] doubleValue];

  NSValue *value = [info objectForKey:@"UIKeyboardFrameEndUserInfoKey"];
  CGSize keyboardSize = [value CGRectValue].size;  //获取键盘的size值

  float height = keyboardSize.height;

  [UIView animateWithDuration:duration
                   animations:^{

                     [self mas_updateConstraints:^(MASConstraintMaker *make) {
                       make.bottom.mas_equalTo(211 - height);
                     }];

                   }];
}

- (void)inputKeyboardWillHide:(NSNotification *)notification {
  NSDictionary *info = [notification userInfo];

  double duration = [info[UIKeyboardAnimationDurationUserInfoKey] doubleValue];

  [UIView animateWithDuration:duration
                   animations:^{

                     [self mas_updateConstraints:^(MASConstraintMaker *make) {
                       make.bottom.mas_equalTo(211);
                     }];
                     [self layoutIfNeeded];
                   }];
}

#pragma mark - GYHDInputViewDelegate;
- (void)GYHDKeyboardSelectBaseView:(GYHDKeyboardSelectBaseView *)view
                          sendDict:(NSDictionary *)dict
                          SendType:(GYHDKeyboardSelectBaseSendOption)type {
  if ([self.delegate
          respondsToSelector:@selector(GYHDInputView:sendDict:SendType:)]) {
    switch (type) {
      case GYHDKeyboardSelectBaseSendText:
        [self.delegate GYHDInputView:self
                            sendDict:dict
                            SendType:GYHDInputeViewSendText];
        break;
      case GYHDKeyboardSelectBaseSendAudio:
        [self.delegate GYHDInputView:self
                            sendDict:dict
                            SendType:GYHDInputeViewSendAudio];

        break;
      case GYHDKeyboardSelectBaseSendVideo:
        [self.delegate GYHDInputView:self
                            sendDict:dict
                            SendType:GYHDInputeViewSendVideo];

        break;
      case GYHDKeyboardSelectBaseSendPhoto:
        [self.delegate GYHDInputView:self
                            sendDict:dict
                            SendType:GYHDInputeViewSendPhoto];

        break;
      default:
        break;
    }
  }
}

- (void)GYHDEmojiView:(GYHDEmojiView *)emojiView
      selectEmojiName:(NSString *)emojiName {
  UIImage *image = [UIImage imageNamed:emojiName];
  if (!image) return;
  NSMutableAttributedString *attr = [[NSMutableAttributedString alloc]
      initWithAttributedString:self.messageTextView.attributedText];

  NSRange selectRange = self.messageTextView.selectedRange;

  if ([emojiName isEqualToString:@"del"]) {
    if (!selectRange.location) return;
    CGFloat location = selectRange.location - 1;

    [attr deleteCharactersInRange:NSMakeRange(location, 1)];
    selectRange = NSMakeRange(selectRange.location - 1, selectRange.length);

  } else {
    // modify by jianglincen
    if (1) {
      selectRange = NSMakeRange(selectRange.location + 1, selectRange.length);

      EmojiTextAttachment *imageMent = [[EmojiTextAttachment alloc] init];
      imageMent.image = image;
      //坑爹，emojiName和UIImage imageWithName方法中名称差个中括号
      //            imageMent.emojiName =emojiName;

      imageMent.emojiName = [NSString stringWithFormat:@"[%@]", emojiName];

      //    imageMent.emojiSize=CGSizeMake(25, 25);

      NSAttributedString *imageAttr =
          [NSAttributedString attributedStringWithAttachment:imageMent];

      [attr insertAttributedString:imageAttr
                           atIndex:self.messageTextView.selectedRange.location];
    }

    else {
      selectRange = NSMakeRange(selectRange.location + 1, selectRange.length);
      NSTextAttachment *imageMent = [[NSTextAttachment alloc] init];
      imageMent.image = image;
      imageMent.bounds = CGRectMake(0, -1, 16.0, 16.0);
      NSAttributedString *imageAttr =
          [NSAttributedString attributedStringWithAttachment:imageMent];
      [attr insertAttributedString:imageAttr
                           atIndex:self.messageTextView.selectedRange.location];
    }
  }
  self.messageTextView.attributedText = attr;
  self.messageTextView.selectedRange = selectRange;
}
- (void)GYHDemojiVIewSendMessage {
  [self sendMessage];
}
#pragma - mark - dealloc
- (void)dealloc {
  IQKeyboardManager *manager = [IQKeyboardManager sharedManager];
  manager.enable = YES;
  manager.shouldResignOnTouchOutside = YES;
  manager.shouldToolbarUsesTextFieldTintColor = YES;
  manager.enableAutoToolbar = YES;
  [self.messageTextView removeObserver:self forKeyPath:@"attributedText"];
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end