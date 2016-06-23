//
//  GYMessage.m
//  GYXMPP
//
//  Created by User on 16/6/14.
//  Copyright © 2016年 jianglincen. All rights reserved.
//

#import "GYMessage.h"

@implementation GYMessage

+(void)load{

    [GYMessage createTable];
}

+(NSArray*)findMessageListWithFriendId:(NSString*)friendId Page:(NSInteger)num{

    if (!num) {
        num=0;
    }
    
    NSArray  *mesArray =[self findByCondition:[NSString stringWithFormat:@"where msgFriendJid=='%@' order by msgSendTime limit 5 offset %ld",friendId,(long)num]];
    
    if (!mesArray||[mesArray isKindOfClass:[NSNull class]]) {
        
        mesArray =[NSArray new];
    }
    
    return mesArray;
}

@end
