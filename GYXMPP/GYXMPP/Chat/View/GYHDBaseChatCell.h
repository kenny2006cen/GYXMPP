//
//  GYHDBaseChatCell.h
//  company
//
//  Created by User on 16/5/25.
//  Copyright © 2016年 SHENZHEN GUIYI SCIENCE AND TECHNOLOGY DEVELOP CO.,LTD.
//  All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GYHDNewChatModel.h"

@interface GYHDBaseChatCell : UITableViewCell

@property(nonatomic, weak) UILabel *chatRecvTimeLabel;

- (NSString *)changeTimeShow:(NSString *)timeStr;

- (void)timeWithinTwoMinute:(GYHDNewChatModel *)lastModel
               CurrentModel:(GYHDNewChatModel *)chatModel;

@end
