//
//  HMThirdAccountId.h
//  HomeMate
//
//  Created by orvibo on 16/3/31.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "HMBaseModel+Extension.h"

@interface HMThirdAccountId : HMBaseModel

@property(nonatomic,strong)NSString *thirdAccountId;
@property(nonatomic,strong)NSString *userId;
@property(nonatomic,strong)NSString *thirdId;
@property(nonatomic,strong)NSString *thirdUserName;
@property(nonatomic,strong)NSString *token;
@property(nonatomic,strong)NSString *file;
@property(nonatomic,strong)NSString *phone;
@property(nonatomic,assign)int userType;
@property(nonatomic,assign)int registerType;

+ (NSString *)selectUserIdByThirdId:(NSString *)thirdId;
+ (NSMutableArray *)selectRegisterTypeByUserId:(NSString *)userId;
+ (NSMutableArray *)selectThirdAccountIdByUserId:(NSString *)userId;
+ (NSString *)getUrlStringByUserId:(NSString *)userId;
+ (HMThirdAccountId *)selectThirdAccountByUserId:(NSString *)userId AndRegiseterType:(int )registerType;
@end
