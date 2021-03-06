//
//  GYHDLeftChatImageCell.m
//  HSConsumer
//
//  Created by shiang on 16/3/1.
//  @深圳市归一科技研发有限公司_iOS
//  @版权所有  禁止传播
//  @级别：绝密
//  Copyright © 2016年 SHENZHEN GUIYI SCIENCE AND TECHNOLOGY DEVELOP CO.,LTD.
//  All rights reserved.
//

#import "GYHDLeftChatImageCell.h"
#import "GYHDNewChatModel.h"

@interface GYHDLeftChatImageCell ()
/**用户头像*/
@property(nonatomic, weak) UIImageView *iconImageView;

/**图片*/
@property(nonatomic, weak) UIImageView *chatPictureImageView;

@end

@implementation GYHDLeftChatImageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier {
  if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
    [self setup];
    [self setupAuto];
  }
  return self;
}
- (void)setup {
  self.contentView.backgroundColor = [UIColor colorWithRed:245 / 255.0f
                                                     green:245 / 255.0f
                                                      blue:245 / 255.0f
                                                     alpha:1];
  [self setSelectionStyle:UITableViewCellSelectionStyleNone];
  // 3 .头像
  UIImageView *iconImageView = [[UIImageView alloc] init];
  iconImageView.image = kLoadPng(@"defaultheadimg");
  iconImageView.contentMode = UIViewContentModeScaleAspectFit;
  iconImageView.userInteractionEnabled = YES;
  iconImageView.layer.masksToBounds = YES;
  iconImageView.layer.cornerRadius = 3;
  UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc]
      initWithTarget:self
              action:@selector(iconImageViewClick:)];
  [iconImageView addGestureRecognizer:tapGR];
  [self.contentView addSubview:iconImageView];
  _iconImageView = iconImageView;

  // 4. 发送时间
  UILabel *recvTimeLabel = [[UILabel alloc] init];
  recvTimeLabel.textAlignment = NSTextAlignmentCenter;
  recvTimeLabel.font = [UIFont systemFontOfSize:11.0];
  recvTimeLabel.textColor = [UIColor colorWithRed:153.0 / 255.0f
                                            green:153.0 / 255.0f
                                             blue:153.0 / 255.0f
                                            alpha:1];
  [self.contentView addSubview:recvTimeLabel];
  self.chatRecvTimeLabel = recvTimeLabel;

  UIImageView *chatPictureImageView = [[UIImageView alloc] init];
  UILongPressGestureRecognizer *longTap = [[UILongPressGestureRecognizer alloc]
      initWithTarget:self
              action:@selector(chatPictureImageViewLongTap:)];
  [chatPictureImageView addGestureRecognizer:longTap];
  UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
      initWithTarget:self
              action:@selector(chatPictureImageViewTap:)];
  [chatPictureImageView addGestureRecognizer:tap];
  chatPictureImageView.userInteractionEnabled = YES;
  chatPictureImageView.contentMode = UIViewContentModeScaleAspectFill;
  chatPictureImageView.clipsToBounds = YES;
  [self.contentView addSubview:chatPictureImageView];
  _chatPictureImageView = chatPictureImageView;
}
/*
- (void)setChatModel:(GYHDNewChatModel *)chatModel {
  _chatModel = chatModel;
  //    self.chatRecvTimeLabel.text = chatModel.chatRecvTime;
  self.chatRecvTimeLabel.text = [self changeTimeShow:chatModel.chatRecvTime];

  NSDictionary *bodyDict = [Utils stringToDictionary:chatModel.chatBody];
  NSURL *url = [NSURL URLWithString:bodyDict[@"msg_icon"]];
  [self.iconImageView setImageWithURL:url
                          placeholder:kLoadPng(@"defaultheadimg")
                              options:kNilOptions
                           completion:nil];
  UIImage *image = [UIImage imageNamed:@"hd_chat_other_back"];
  UIImageView *backgroundImageView = [[UIImageView alloc] init];

  backgroundImageView.frame = CGRectMake(0, 0, 120, 120);

  [backgroundImageView
      setImage:[image stretchableImageWithLeftCapWidth:17 topCapHeight:17]];
  CALayer *layer = backgroundImageView.layer;
  layer.frame = (CGRect){{0, 0}, backgroundImageView.layer.frame.size};
  self.chatPictureImageView.layer.mask = layer;

  @weakify(self);
  [self.chatPictureImageView
      setImageWithURL:[NSURL URLWithString:bodyDict[@"msg_imageNailsUrl"]]
          placeholder:[UIImage imageNamed:@"placeholder_image"]
              options:kNilOptions
           completion:^(UIImage *_Nullable image, NSURL *_Nonnull url,
                        YYWebImageFromType from, YYWebImageStage stage,
                        NSError *_Nullable error) {
             @strongify(self);

             //                 CALayer *layer = ImageView.layer;
             //                 layer.frame = (CGRect){{0, 0},
             //                 ImageView.layer.frame.size};
             //                 self.chatPictureImageView.layer.mask = layer;
           }];
}
 */
- (void)setupAuto {

  [self.chatRecvTimeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.top.left.right.mas_equalTo(0);
  }];

  [self.iconImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.left.mas_equalTo(10);
    make.height.width.mas_equalTo(44);
    make.top.equalTo(self.chatRecvTimeLabel.mas_bottom).offset(25);
  }];

  self.iconImageView.contentMode = UIViewContentModeScaleAspectFit;

  [self.chatPictureImageView mas_remakeConstraints:^(MASConstraintMaker *make) {

      make.top.equalTo(self.iconImageView);
    make.left.equalTo(self.iconImageView.mas_right).offset(5);
    make.width.mas_equalTo(130);
    make.height.mas_equalTo(120);
    make.bottom.mas_equalTo(-20);
  }];
}
- (void)iconImageViewClick:(UITapGestureRecognizer *)tap {
  if ([self.delegate
          respondsToSelector:@selector(GYHDChatView:tapType:chatModel:)]) {
    [self.delegate GYHDChatView:self
                        tapType:GYHDChatTapUserIcon
                      chatModel:self.chatModel];
  }
}
- (void)chatPictureImageViewTap:(UITapGestureRecognizer *)longTap {
  if ([self.delegate
          respondsToSelector:@selector(GYHDChatView:tapType:chatModel:)]) {
    [self.delegate GYHDChatView:self
                        tapType:GYHDChatTapChatImage
                      chatModel:self.chatModel];
  }
}

- (void)chatPictureImageViewLongTap:(UILongPressGestureRecognizer *)longTap {
  if (longTap.state == UIGestureRecognizerStateBegan) {
  }
}
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
  if (action == @selector(copyItemClicked:)) {
    return YES;
  } else if (action == @selector(deleteItemClicked:)) {
    return YES;
  }
  return [super canPerformAction:action withSender:sender];
}
#pragma mark - 实现成为第一响应者方法
- (BOOL)canBecomeFirstResponder {
  return YES;
}
- (void)deleteItemClicked:(id)sender {
  if ([self.delegate respondsToSelector:@selector(GYHDChatView:
                                                   longTapType:
                                                  selectOption:
                                                 chatMessageID:)]) {
    [self.delegate GYHDChatView:self
                    longTapType:GYHDChatTapChatImage
                   selectOption:GYHDChatSelectDelete
                  chatMessageID:self.chatModel.chatMessageID];
  }
}
- (void)copyItemClicked:(id)sender {
    
//  UIPasteboard *pboard = [UIPasteboard generalPasteboard];
//  NSDictionary *dict = [Utils stringToDictionary:self.chatModel.chatBody];
//  pboard.string = dict[@"msg_content"];
}

/*
 
 - (void)progressChanged:(id)sender
 {
 [_progressView setProgress:_progressSlider.value animated:NO];
 }
 
 - (void)animateProgress:(id)sender
 {
 //Disable other controls
 _progressSlider.enabled = NO;
 _iconControl.enabled = NO;
 _indeterminateSwitch.enabled = NO;
 
 [self performSelector:@selector(setQuarter) withObject:Nil afterDelay:1];
 }
 
 - (void)setQuarter
 {
 [_progressView setProgress:.25 animated:YES];
 [self performSelector:@selector(setTwoThirds) withObject:nil afterDelay:3];
 }
 
 - (void)setTwoThirds
 {
 [_progressView setProgress:.66 animated:YES];
 [self performSelector:@selector(setThreeQuarters) withObject:nil afterDelay:1];
 }
 
 - (void)setThreeQuarters
 {
 [_progressView setProgress:.75 animated:YES];
 [self performSelector:@selector(setOne) withObject:nil afterDelay:1.5];
 }
 
 - (void)setOne
 {
 [_progressView setProgress:1.0 animated:YES];
 [self performSelector:@selector(setComplete) withObject:nil afterDelay:_progressView.animationDuration + .1];
 }
 
 - (void)setComplete
 {
 [_progressView performAction:M13ProgressViewActionSuccess animated:YES];
 [self performSelector:@selector(reset) withObject:nil afterDelay:1.5];
 }
 
 - (void)reset
 {
 [_progressView performAction:M13ProgressViewActionNone animated:YES];
 [_progressView setProgress:0 animated:YES];
 //Enable other controls
 _progressSlider.enabled = YES;
 _iconControl.enabled = YES;
 _indeterminateSwitch.enabled = YES;
 }
 
 - (void)iconChanged:(id)sender
 {
 if (_iconControl.selectedSegmentIndex == 0) {
 //Change progress view icon to none
 [_progressView performAction:M13ProgressViewActionNone animated:YES];
 } else if (_iconControl.selectedSegmentIndex == 1) {
 //Change progress view icon to success
 [_progressView performAction:M13ProgressViewActionSuccess animated:YES];
 } else if (_iconControl.selectedSegmentIndex == 2) {
 //Change to failure
 [_progressView performAction:M13ProgressViewActionFailure animated:YES];
 }
 }
 
 - (void)indeterminateChanged:(id)sender
 {
 if (_indeterminateSwitch.on) {
 _progressSlider.enabled = NO;
 _iconControl.enabled = NO;
 _animateButton.enabled = NO;
 //Set to indeterminate mode
 [_progressView setIndeterminate:YES];
 } else {
 _progressSlider.enabled = YES;
 _iconControl.enabled = YES;
 _animateButton.enabled = YES;
 //Disable indeterminate mode
 [_progressView setIndeterminate:NO];
 }
 }

 */

@end
