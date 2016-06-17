//
//  GYHDBaseChatCell.m
//  company
//
//  Created by User on 16/5/25.
//  Copyright © 2016年 SHENZHEN GUIYI SCIENCE AND TECHNOLOGY DEVELOP CO.,LTD.
//  All rights reserved.
//

#import "GYHDBaseChatCell.h"

@implementation GYHDBaseChatCell

- (NSString *)changeTimeShow:(NSString *)timeStr {
//  return [[GYHDMessageCenter sharedInstance]
//      messageTimeStrFromTimerString:timeStr];
    return nil;
}
static NSDateFormatter *chatfmt = nil;

- (void)timeWithinTwoMinute:(GYHDNewChatModel *)lastChatModel
               CurrentModel:(GYHDNewChatModel *)chatModel {
  if (!chatfmt) {
    chatfmt = [[NSDateFormatter alloc] init];
  }
  chatfmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";

  NSDate *currerDate = [chatfmt dateFromString:chatModel.chatRecvTime];
  NSDate *lastDate = [chatfmt dateFromString:lastChatModel.chatRecvTime];

  if ([currerDate timeIntervalSince1970] <
      [lastDate timeIntervalSince1970] + 10) {
    // chatModel.chatRecvTime = @"";

    self.chatRecvTimeLabel.text = @"";
  }
}

- (void)awakeFromNib {
  // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];

  // Configure the view for the selected state
}

@end
