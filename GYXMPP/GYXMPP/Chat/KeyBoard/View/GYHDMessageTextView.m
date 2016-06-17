//
//  GYHDMessageTextView.m
//  HSConsumer
//
//  Created by shiang on 16/3/5.
//  @深圳市归一科技研发有限公司_iOS
//  @版权所有  禁止传播
//  @级别：绝密
//  Copyright © 2016年 SHENZHEN GUIYI SCIENCE AND TECHNOLOGY DEVELOP CO.,LTD.
//  All rights reserved.
//

#import "GYHDMessageTextView.h"

@implementation GYHDMessageTextView
- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    self.backgroundColor = [UIColor clearColor];

    self.returnKeyType = UIReturnKeySend;
    self.font = [UIFont systemFontOfSize:16.0];
    self.scrollEnabled = NO;
  }
  return self;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
  if (action == @selector(paste:)) {
    return YES;
  } else {
    return [super canPerformAction:action withSender:sender];
  }
}

- (void)paste:(id)sender {
    /*
  NSRange range = self.selectedRange;
  UIPasteboard *board = [UIPasteboard generalPasteboard];

  //当前已经存在的富文本
  NSMutableAttributedString *attString = [[NSMutableAttributedString alloc]
      initWithAttributedString:self.attributedText];

  //剪切板的富文本

  NSAttributedString *insertAttString = [[GYHDMessageCenter sharedInstance]
      attStringWithString:board.string
               imageFrame:CGRectMake(0, 0, 16.0, 16.0)
               attributes:nil
             WithoutSpace:YES];

  [attString insertAttributedString:insertAttString
                            atIndex:self.selectedRange.location];
  self.attributedText = attString;
  self.selectedRange = NSMakeRange(range.location + insertAttString.length, 0);
     */
}

@end
