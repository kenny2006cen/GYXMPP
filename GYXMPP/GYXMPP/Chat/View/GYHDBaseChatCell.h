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
#import "GYMessage.h"
#import "UIImageView+WebCache.h"
#import "NSString+dictionaryToJsonString.h"

@interface GYHDBaseChatCell : UITableViewCell

@property(nonatomic,strong)GYMessage *chatMessage;

@property(nonatomic, strong) UILabel *chatRecvTimeLabel;

- (NSString *)changeTimeShow:(NSString *)timeStr;

- (void)timeWithinTwoMinute:(GYHDNewChatModel *)lastModel
               CurrentModel:(GYHDNewChatModel *)chatModel;

-(void)loadChatMessage:(GYMessage *)chatMessage;

@end
