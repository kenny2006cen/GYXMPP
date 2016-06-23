
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

#import "GYHDNewChatModel.h"
#import "GYHDRightChatTextCell.h"

@interface GYHDRightChatTextCell ()
/**用户头像*/
@property(nonatomic, strong) UIImageView *iconImageView;
/**接收时间*/
//@property(nonatomic, weak)UILabel *chatRecvTimeLabel;
/**聊天背景*/
@property(nonatomic, strong) UIImageView *chatbackgroundView;
/**聊天文字类容*/
@property(nonatomic, strong) UILabel *chatCharacterLabel;

/**发送内容状态*/
@property(nonatomic, strong) UIButton *chatStateButton;
@end

@implementation GYHDRightChatTextCell

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
    
    
    // 1. 发送时间
    self.chatRecvTimeLabel = [[UILabel alloc] init];
    
     [self.chatRecvTimeLabel setFrame:CGRectMake(0, 0, kScreenWidth, 20)];
    self.chatRecvTimeLabel.backgroundColor=[UIColor blackColor];
    self.chatRecvTimeLabel.textAlignment = NSTextAlignmentCenter;
    self.chatRecvTimeLabel.font = [UIFont systemFontOfSize:11.0];
    self.chatRecvTimeLabel.textColor = [UIColor colorWithRed:153.0 / 255.0f
                                                       green:153.0 / 255.0f
                                                        blue:153.0 / 255.0f
                                                       alpha:1];
    [self.contentView addSubview: self.chatRecvTimeLabel];
    
  // 1. 聊天背景
   self.chatbackgroundView = [[UIImageView alloc] init];
    
    UIImage *tempImage = [UIImage imageNamed:@"icon-ltk3"];

    self.chatbackgroundView.image =tempImage;
    
   // self.chatbackgroundView.image=[tempImage stretchableImageWithLeftCapWidth:15 topCapHeight:15];
    
  [self.contentView addSubview:self.chatbackgroundView];
  
    // 2 .头像
    self.iconImageView = [[UIImageView alloc] init];
    
    [self.iconImageView setFrame:CGRectMake(kScreenWidth-44-10, self.chatRecvTimeLabel.frame.origin.y+10, 44, 44)];
    
    self.iconImageView.image = kLoadPng(@"defaultheadimg");
    self.iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    self.iconImageView.userInteractionEnabled = YES;
    self.iconImageView.layer.masksToBounds = YES;
    self.iconImageView.layer.cornerRadius = 3;
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc]
                                     initWithTarget:self
                                     action:@selector(iconImageViewClick:)];
    [ self.iconImageView addGestureRecognizer:tapGR];
    [self.contentView addSubview: self.iconImageView];

  // 2. 文本聊天视图
 self.chatCharacterLabel = [[UILabel alloc] init];
 self.
    
  self.chatCharacterLabel.userInteractionEnabled = YES;
  self.chatCharacterLabel.numberOfLines = 0;
  //self.chatCharacterLabel.text = @"11";
   
    self.chatCharacterLabel.textColor=[UIColor whiteColor];

  self.chatCharacterLabel.lineBreakMode = NSLineBreakByTruncatingTail;

  UILongPressGestureRecognizer *longTap = [[UILongPressGestureRecognizer alloc]
      initWithTarget:self
              action:@selector(chatCharacterLabelLongtap:)];
  [self.chatCharacterLabel addGestureRecognizer:longTap];

  [self.contentView addSubview:self.chatCharacterLabel];

  



    // 3. 消息状态
  self.chatStateButton = [[UIButton alloc] init];
  [self.chatStateButton addTarget:self
                      action:@selector(chatStateButtonClick:)
            forControlEvents:UIControlEventTouchUpInside];
   self.chatStateButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
   self.chatStateButton.imageView.animationDuration = 1.4f;

  NSMutableArray *imageArray = [NSMutableArray array];
  for (int i = 1; i < 13; i++) {
    UIImage *image =
        [UIImage imageNamed:[NSString stringWithFormat:@"loading_%d", i]];
    if (image != nil) {
      [imageArray addObject:image];
    }
  }
   self.chatStateButton.imageView.animationImages = imageArray;
  [self.chatStateButton setImage:[UIImage imageNamed:@"hd_failure"]
                   forState:UIControlStateNormal];
    
  [self.contentView addSubview: self.chatStateButton];

    
}


-(void)loadChatMessage:(GYMessage *)chatMessage{

    self.chatMessage = chatMessage;
    
    self.contentView.backgroundColor=[UIColor grayColor];
//    self.chatRecvTimeLabel.text = [self changeTimeShow:chatMessage.msgRecTime];
   
    self.chatRecvTimeLabel.text = @"2016-06-1";
    NSAttributedString *attributeString = [[NSAttributedString alloc]initWithString:@"abcsdfdsfhskdfjsadkfjsakdffsdsjfsdfjsakfjsakfjksdjfdskfjksafjkjkjfkfjdsakfjaslkfjsl"];
    
    // modify by jianglincen
    
    self.chatCharacterLabel.attributedText = attributeString;
    

    
    [self.iconImageView sd_setImageWithPreviousCachedImageWithURL:nil placeholderImage:[UIImage imageNamed:@"defaultheadimg"] options:kNilOptions progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
    }];
    
    switch (chatMessage.deliveryState) {
        case MessageDeliveryState_Delivering:{
            //发送中
            [self.chatStateButton.imageView startAnimating];
            self.chatStateButton.hidden = NO;
            
        }break;
        case MessageDeliveryState_Delivered:{
        
            // 发送成功
            [self.chatStateButton.imageView stopAnimating];
            self.chatStateButton.hidden = YES;
           
        }break;
        case MessageDeliveryState_Failure:{
            //发送失败
            [self.chatStateButton.imageView stopAnimating];
            self.chatStateButton.hidden = NO;
           
        }break;
        default:
            break;
    }
    
    
   // [self.chatCharacterLabel updateConstraintsIfNeeded];
    
    [self layoutIfNeeded];
   // [self layoutSubviews];
}


- (void)setupAuto {

    WSHD(weakSelf);
   
  [self.chatRecvTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.left.right.mas_equalTo(0);
      make.height.mas_equalTo(20);
  }];

  [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
    
    make.right.mas_equalTo(-10);
    make.height.width.mas_equalTo(44);
    make.top.equalTo(weakSelf.chatRecvTimeLabel.mas_bottom).offset(20);
  }];
  self.iconImageView.contentMode = UIViewContentModeScaleAspectFit;

    
//    
//    [self.chatCharacterLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    
   
    
  [self.chatCharacterLabel mas_makeConstraints:^(MASConstraintMaker *make) {
   
    make.top.equalTo(weakSelf.iconImageView).offset(6);
    make.left.mas_greaterThanOrEqualTo(50);
    make.right.equalTo(weakSelf.iconImageView.mas_left).offset(-20);
    //下一句一定要加
    make.height.mas_greaterThanOrEqualTo(44);
   //   make.height.mas_equalTo(100);
    make.bottom.mas_equalTo(-10);
  }];


    
  [self.chatbackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
    
    make.top.equalTo(weakSelf.chatCharacterLabel).offset(-5);
    make.left.equalTo(weakSelf.chatCharacterLabel).offset(-5);
    make.right.equalTo(weakSelf.chatCharacterLabel).offset(15);
    make.height.mas_greaterThanOrEqualTo(weakSelf.iconImageView);
    make.bottom.equalTo(weakSelf.chatCharacterLabel).offset(5);
  }];
  [self.chatStateButton mas_makeConstraints:^(MASConstraintMaker *make) {
   
    make.centerY.equalTo(weakSelf.chatbackgroundView);
    make.right.equalTo(weakSelf.chatbackgroundView.mas_left).offset(-10);
    
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
- (void)chatStateButtonClick:(UIButton *)button {
  if ([self.delegate
          respondsToSelector:@selector(GYHDChatView:tapType:chatModel:)]) {
    [self.delegate GYHDChatView:self
                        tapType:GYHDChatTapResendButton
                      chatModel:self.chatModel];
  }
}

-(void)layoutSubviews{

    [super layoutSubviews];
    
}

- (void)chatCharacterLabelLongtap:(UILongPressGestureRecognizer *)longTap {
  if (longTap.state == UIGestureRecognizerStateBegan) {
    [self becomeFirstResponder];
    UIMenuController *menu = [UIMenuController sharedMenuController];
    UIMenuItem *copyItem =
        [[UIMenuItem alloc] initWithTitle:@"复制"
                                   action:@selector(copyItemClicked:)];
    //  UIMenuItem *deleteItem = [[UIMenuItem alloc]
    //  initWithTitle:kLocalized(@"HD_chat_delete")
    //  action:@selector(deleteItemClicked:)];
    //   [menu setMenuItems:[NSArray arrayWithObjects:copyItem,deleteItem,nil]];
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
