//
//  HMCustomPicture.h
//  HomeMate
//
//  Created by liqiang on 16/9/12.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "HMBaseModel+Extension.h"

@interface HMCustomPicture : HMBaseModel
@property (nonatomic, copy) NSString * imageInfoId;
@property (nonatomic, copy) NSString * userId;
@property (nonatomic, copy) NSString * customId;
@property (nonatomic, copy) NSString * imageURL;

+ (HMCustomPicture *)objectFromDictionary:(NSDictionary *)dict;
@end
