//
//  HMOauth2ClientsModel.h
//  HomeMateSDK
//
//  Created by orvibo on 2019/9/29.
//  Copyright © 2019 orvibo. All rights reserved.
//

#import "HMBaseModel.h"

@interface HMOauth2ClientsModel : HMBaseModel

@property (nonatomic, strong) NSString * userId;
@property (nonatomic, strong) NSString * clientId;
@property (nonatomic, strong) NSString * skillName;

@property (nonatomic, strong) NSString * loginArgUrl;
@property (nonatomic, strong) NSString * logoUrl;

@property (nonatomic, strong) NSString * skillProfile;
@property (nonatomic, strong) NSString * company;

@property (nonatomic, assign) int skillNo;
@property (nonatomic, assign) int flag;



@end
