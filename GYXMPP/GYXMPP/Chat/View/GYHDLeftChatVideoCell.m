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

#import "GYHDLeftChatVideoCell.h"
#import "GYHDNewChatModel.h"

@interface GYHDLeftChatVideoCell ()
/**用户头像*/
@property(nonatomic, weak) UIImageView *iconImageView;
/**接收时间*/
//@property(nonatomic, weak)UILabel *chatRecvTimeLabel;
/**图片*/
@property(nonatomic, weak) UIImageView *chatPictureImageView;
/**图片状态*/
@property(nonatomic, weak) UIImageView *chatVideoReadyState;
@end

@implementation GYHDLeftChatVideoCell

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
              action:@selector(chatVideoViewTap:)];
  [chatPictureImageView addGestureRecognizer:tap];
  chatPictureImageView.userInteractionEnabled = YES;
  chatPictureImageView.contentMode = UIViewContentModeScaleAspectFill;
  chatPictureImageView.clipsToBounds = YES;
  [self.contentView addSubview:chatPictureImageView];
  _chatPictureImageView = chatPictureImageView;

  UIImageView *chatVideoReadyState = [[UIImageView alloc] init];
  chatVideoReadyState.image = [UIImage imageNamed:@"red_point"];
  [self.contentView addSubview:chatVideoReadyState];
  _chatVideoReadyState = chatVideoReadyState;
}
/*
- (void)setChatModel:(GYHDNewChatModel *)chatModel {
  _chatModel = chatModel;
  //    self.chatRecvTimeLabel.text = chatModel.chatRecvTime;
  self.chatRecvTimeLabel.text = [self changeTimeShow:chatModel.chatRecvTime];

  NSDictionary *bodyDict = [Utils stringToDictionary:chatModel.chatBody];
  NSURL *url = [NSURL URLWithString:bodyDict[@"msg_icon"]];
  [self.iconImageView setImageWithURL:url placeholder:kLoadPng(@"defaultheadimg") options:kNilOptions completion:nil ];
  UIImage *image = [UIImage imageNamed:@"hd_chat_other_back"];
  UIImageView *ImageView = [[UIImageView alloc] init];
  ImageView.frame = CGRectMake(0, 0, 170, 120);
  [ImageView
      setImage:[image stretchableImageWithLeftCapWidth:17 topCapHeight:17]];

    @weakify(self);
  [self.chatPictureImageView setImageWithURL:[NSURL URLWithString:bodyDict[@"msg_imageNail"]] placeholder:[UIImage imageNamed:@"placeholder_image"] options:kNilOptions completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
      @strongify(self);
     
      CALayer *layer = ImageView.layer;
      layer.frame = (CGRect){{0, 0}, ImageView.layer.frame.size};
      self.chatPictureImageView.layer.mask = layer;
  }];
 

  NSDictionary *saveDict = [Utils stringToDictionary:chatModel.chatDataString];
  if ([saveDict[@"read"] integerValue]) {
    self.chatVideoReadyState.hidden = YES;
  } else {
    self.chatVideoReadyState.hidden = NO;
  }
}
 */
- (void)setupAuto {

    WSHD(weakSelf);
    
  [self.chatRecvTimeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.top.left.right.mas_equalTo(0);
  }];

  [self.iconImageView mas_remakeConstraints:^(MASConstraintMaker *make) {

    make.left.mas_equalTo(10);
    make.height.width.mas_equalTo(44);
    make.top.equalTo(weakSelf.chatRecvTimeLabel.mas_bottom).offset(25);
  }];

  self.iconImageView.contentMode = UIViewContentModeScaleAspectFit;

  [self.chatPictureImageView mas_remakeConstraints:^(MASConstraintMaker *make) {

    make.top.equalTo(weakSelf.iconImageView);
    make.left.equalTo(weakSelf.iconImageView.mas_right).offset(5);
    make.width.mas_equalTo(170);
    make.height.mas_equalTo(120);
    make.bottom.mas_equalTo(-20);
  }];

  [self.chatVideoReadyState mas_remakeConstraints:^(MASConstraintMaker *make) {
    
    make.size.mas_equalTo(CGSizeMake(5, 5));
    make.top.equalTo(weakSelf.chatPictureImageView);
    make.left.equalTo(weakSelf.chatPictureImageView.mas_right);
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

- (void)chatVideoViewTap:(UITapGestureRecognizer *)longTap {
  self.chatVideoReadyState.hidden = YES;
  if ([self.delegate
          respondsToSelector:@selector(GYHDChatView:tapType:chatModel:)]) {
    [self.delegate GYHDChatView:self
                        tapType:GYHDChatTapChatVideo
                      chatModel:self.chatModel];
  }
}
- (void)chatPictureImageViewLongTap:(UILongPressGestureRecognizer *)longTap {
  if (longTap.state == UIGestureRecognizerStateBegan) {
    //根据余乐要求，暂时屏蔽删除功能
    //        [self becomeFirstResponder];
    //        UIMenuController *menu=[UIMenuController sharedMenuController];
    //
    //
    //        UIMenuItem *deleteItem = [[UIMenuItem alloc]
    //        initWithTitle:kLocalized(@"HD_chat_delete")
    //        action:@selector(deleteItemClicked:)];
    //        [menu setMenuItems:[NSArray arrayWithObjects:deleteItem,nil]];
    //        [menu setTargetRect:self.chatPictureImageView.bounds
    //        inView:self.chatPictureImageView];
    //        [menu setMenuVisible:YES animated:YES];
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
#pragma mark 实现成为第一响应者方法
- (BOOL)canBecomeFirstResponder {
  return YES;
}
- (void)deleteItemClicked:(id)sender {
  if ([self.delegate respondsToSelector:@selector(GYHDChatView:
                                                   longTapType:
                                                  selectOption:
                                                 chatMessageID:)]) {
    [self.delegate GYHDChatView:self
                    longTapType:GYHDChatTapChatVideo
                   selectOption:GYHDChatSelectDelete
                  chatMessageID:self.chatModel.chatMessageID];
  }
}
- (void)copyItemClicked:(id)sender {
//  UIPasteboard *pboard = [UIPasteboard generalPasteboard];
//  NSDictionary *dict = [Utils stringToDictionary:self.chatModel.chatBody];
//  pboard.string = dict[@"msg_content"];
}

@end
