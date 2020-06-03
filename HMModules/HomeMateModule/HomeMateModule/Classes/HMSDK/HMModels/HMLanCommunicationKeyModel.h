//
//  HMLanCommunicationKeyModel.h
//  HomeMateSDK
//
//  Created by 2049lzc on 2018/8/28.
//  Copyright © 2018年 orvibo. All rights reserved.
//

#import "HMBaseModel.h"

@interface HMLanCommunicationKeyModel : HMBaseModel

@property (nonatomic,strong) NSString *lanCommunicationKey;

+ (NSString *)lanCommunicationKeyOfFamilyId:(NSString *)familyId;

@end
