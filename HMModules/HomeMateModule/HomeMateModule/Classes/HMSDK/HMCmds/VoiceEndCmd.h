//
//  VoiceEndCmd.h
//  HomeMateSDK
//
//  Created by Feng on 2017/7/31.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "BaseCmd.h"

@interface VoiceEndCmd : BaseCmd
@property (nonatomic, copy) NSString *familyId;
@property (nonatomic, copy) NSString *token;
@end
