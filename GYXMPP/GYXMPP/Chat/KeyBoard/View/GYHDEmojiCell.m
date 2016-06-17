//
//  GYHDEmojiCell.m
//  HSConsumer
//
//  Created by shiang on 16/2/24.
//  @深圳市归一科技研发有限公司_iOS
//  @版权所有  禁止传播
//  @级别：绝密
//  Copyright © 2016年 SHENZHEN GUIYI SCIENCE AND TECHNOLOGY DEVELOP CO.,LTD.
//  All rights reserved.
//

#import "GYHDEmojiCell.h"

@interface GYHDEmojiCell ()
/**测试*/
@property(nonatomic, weak) UIImageView *emojiImageView;
@end

@implementation GYHDEmojiCell

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    [self setup];
  }
  return self;
}
- (void)setup {
  UIImageView *emojiImageView = [[UIImageView alloc] init];
  emojiImageView.backgroundColor = [UIColor whiteColor];
  emojiImageView.contentMode = UIViewContentModeScaleToFill;
  [self addSubview:emojiImageView];
  _emojiImageView = emojiImageView;
  [emojiImageView mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.top.left.bottom.right.mas_equalTo(0);
    make.top.mas_equalTo(20);
    make.left.mas_equalTo(10);
    make.right.mas_equalTo(-10);
    make.bottom.mas_equalTo(0);
  }];
}

- (void)setimageName:(NSString *)imageName {
  UIImage *image = [UIImage imageNamed:imageName];
  self.emojiImageView.image = image;
}
@end
