//
//  VoiceControlCmd.h
//  HomeMateSDK
//
//  Created by Feng on 2017/7/31.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "BaseCmd.h"

@interface VoiceControlCmd : BaseCmd
@property (nonatomic, copy) NSString *familyId;
@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, strong) NSDictionary * voice;

@end
