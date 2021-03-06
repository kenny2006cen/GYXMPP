//
//  GYHDLeftChatTextCell.m
//  HSConsumer
//
//  Created by shiang on 16/3/1.
//  @深圳市归一科技研发有限公司_iOS
//  @版权所有  禁止传播
//  @级别：绝密
//  Copyright © 2016年 SHENZHEN GUIYI SCIENCE AND TECHNOLOGY DEVELOP CO.,LTD.
//  All rights reserved.
//

#import "GYHDLeftChatTextCell.h"
#import "GYHDNewChatModel.h"

@interface GYHDLeftChatTextCell ()
/**用户头像*/
@property(nonatomic, weak) UIImageView *iconImageView;
/**接收时间*/
//@property(nonatomic, weak)UILabel *chatRecvTimeLabel;
/**聊天背景*/
@property(nonatomic, weak) UIImageView *chatbackgroundView;
/**聊天文字类容*/
@property(nonatomic, weak) UILabel *chatCharacterLabel;
@end

@implementation GYHDLeftChatTextCell

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

  // 1. 聊天背景
  UIImageView *chatbackgroundView = [[UIImageView alloc] init];
  chatbackgroundView.image = [UIImage imageNamed:@"hd_chat_other_back"];
  [self.contentView addSubview:chatbackgroundView];
  _chatbackgroundView = chatbackgroundView;
  // 2. 文本聊天视图
  UILabel *chatCharacterLabel = [[UILabel alloc] init];
  chatCharacterLabel.userInteractionEnabled = YES;
  chatCharacterLabel.numberOfLines = 0;
  chatCharacterLabel.text = @"11";
  UILongPressGestureRecognizer *longTap = [[UILongPressGestureRecognizer alloc]
      initWithTarget:self
              action:@selector(chatCharacterLabelLongtap:)];
  [chatCharacterLabel addGestureRecognizer:longTap];
  [self.contentView addSubview:chatCharacterLabel];
  _chatCharacterLabel = chatCharacterLabel;
  // 3 .头像
  UIImageView *iconImageView = [[UIImageView alloc] init];
  iconImageView.layer.masksToBounds = YES;
  iconImageView.layer.cornerRadius = 3;
  iconImageView.image = kLoadPng(@"defaultheadimg");
  iconImageView.contentMode = UIViewContentModeScaleAspectFit;
  iconImageView.userInteractionEnabled = YES;
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
}

-(void)loadChatMessage:(GYMessage *)chatMessage{
    
    self.chatMessage = chatMessage;
    
    //    self.chatRecvTimeLabel.text = chatModel.chatRecvTime;
    self.chatRecvTimeLabel.text = [self changeTimeShow:chatMessage.msgRecTime];
    
    
    
    NSAttributedString *attributeString = [[NSAttributedString alloc]initWithString:chatMessage.msgBody];
    
    // modify by jianglincen
    
    self.chatCharacterLabel.attributedText = attributeString;
    
    [self.iconImageView sd_setImageWithPreviousCachedImageWithURL:nil placeholderImage:[UIImage imageNamed:@"defaultheadimg"] options:kNilOptions progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
    }];
    
}
/*
- (void)setChatModel:(GYHDNewChatModel *)chatModel {
  _chatModel = chatModel;
  //    self.chatRecvTimeLabel.text = chatModel.chatRecvTime;
  self.chatRecvTimeLabel.text = [self changeTimeShow:chatModel.chatRecvTime];

  NSDictionary *dict = [Utils stringToDictionary:chatModel.chatBody];
  NSURL *url = [NSURL URLWithString:dict[@"msg_icon"]];
  [self.iconImageView setImageWithURL:url placeholder:kLoadPng(@"defaultheadimg") options:kNilOptions completion:nil];
  self.chatCharacterLabel.attributedText = chatModel.chatContentAttString;
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
    make.top.equalTo(self.chatRecvTimeLabel.mas_bottom).offset(25);
  }];

  self.iconImageView.contentMode = UIViewContentModeScaleAspectFit;

  [self.chatCharacterLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
  
    make.top.equalTo(weakSelf.iconImageView).offset(6);
    make.left.equalTo(weakSelf.iconImageView.mas_right).offset(20);
    make.right.mas_lessThanOrEqualTo(-50);
    make.bottom.mas_equalTo(-20);
  }];

  [self.chatbackgroundView mas_remakeConstraints:^(MASConstraintMaker *make) {
    
    make.top.equalTo(weakSelf.chatCharacterLabel).offset(-5);
    make.left.equalTo(weakSelf.chatCharacterLabel).offset(-15);
    make.right.equalTo(weakSelf.chatCharacterLabel).offset(10);
    make.height.mas_greaterThanOrEqualTo(weakSelf.iconImageView);
    make.bottom.equalTo(weakSelf.chatCharacterLabel).offset(5);
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
- (void)chatCharacterLabelLongtap:(UILongPressGestureRecognizer *)longTap {
  if (longTap.state == UIGestureRecognizerStateBegan) {
    [self becomeFirstResponder];
    UIMenuController *menu = [UIMenuController sharedMenuController];

    UIMenuItem *copyItem =
        [[UIMenuItem alloc] initWithTitle:@"复制"                                   action:@selector(copyItemClicked:)];
    //        UIMenuItem *deleteItem = [[UIMenuItem alloc]
    //        initWithTitle:kLocalized(@"HD_chat_delete")
    //        action:@selector(deleteItemClicked:)];
    //
    //        [menu setMenuItems:[NSArray
    //        arrayWithObjects:copyItem,deleteItem,nil]];

    //根据余乐要求，暂时屏蔽删除功能 by jianglilncen
    [menu setMenuItems:[NSArray arrayWithObjects:copyItem, nil]];
    [menu setTargetRect:self.chatCharacterLabel.bounds
                 inView:self.chatCharacterLabel];
    [menu setMenuVisible:YES animated:YES];
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
                    longTapType:GYHDChatTapChatText
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
