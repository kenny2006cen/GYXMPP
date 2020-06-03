//
//  HMCommonChannelUtil.m
//  HomeMate
//
//  Created by liqiang on 2018/6/5.
//  Copyright © 2018年 Air. All rights reserved.
//

#import "HMCommonChannelUtil.h"
//#import "AFHTTPRequestOperationManager.h"
#import "HMUtil.h"

static NSInteger MAXGETTOKEN = 3;

@interface HMCommonChannelUtil ()
//@property (nonatomic, strong)AFHTTPRequestOperationManager *  manager;
@property (nonatomic, assign)NSInteger getTokenTimes;

@end

@implementation HMCommonChannelUtil


+ (HMCommonChannelUtil *)shareUtil {
    static HMCommonChannelUtil * util = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        util = [[HMCommonChannelUtil alloc] init];
    });
    return util;
}

- (instancetype)init {
    if (self = [super init]) {
        self.getTokenTimes = 0;
//        AFHTTPRequestOperationManager *  manager = [AFHTTPRequestOperationManager manager];
//        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json",@"text/javascript",@"text/html",@"text/plain",nil];
//        manager.requestSerializer = [AFJSONRequestSerializer serializer];
//        manager.requestSerializer.timeoutInterval = 10;
//        _manager = manager;
    }
    return self;
}
//http://192.168.2.248/channel?m=queryChannel&channelName=中央一台

- (void)queryChannel:(NSString *)channelName
            callback:(void(^)(HMCustomChannelStatus status,NSArray * data))callback {
    [self getCommonChannekToken:^(HMCustomChannelStatus status, NSString *token) {
        if (token.length) {
            NSString * hostUrl = Get_Common_Channel_Url;
            NSMutableDictionary * param = [NSMutableDictionary dictionary];
            [param setObject:@"queryChannel" forKey:@"m"];
            [param setObject:channelName forKey:@"channelName"];
            [self AFGetDataWithHostUrl:hostUrl params:param callback:^(HMCustomChannelStatus status,id object) {
                if (status == HMCustomChannelSuccess) {
                    if ([object isKindOfClass:[NSDictionary class]]) {
                        int status = [[object objectForKey:@"status"] intValue];
                        if (status == 0) {
                            NSArray * data = [object objectForKey:@"data"];
                            callback(HMCustomChannelSuccess,data);
                        }else if(status == 2) {
                            callback(HMCustomChannelTokenIsInvalid,nil);
                        }else if(status == 3) {
                            callback(HMCustomChannelUnboundDevice,nil);
                        }else {
                            callback(HMCustomChannelFail,nil);
                        }
                    }else {
                        callback(HMCustomChannelDataFormatError,nil);
                        
                    }
                }else {
                    callback(status,nil);
                }
                
            }];
        }else {
            callback(status,nil);
        }
    }];
}

- (void)deleteCustomChannel:(HMCustomChannel *)customChannel callback:(void(^)(HMCustomChannelStatus status))callback  {
    
    [self getCommonChannekToken:^(HMCustomChannelStatus status, NSString *token) {
        if (token.length) {
            NSString * hostUrl = Get_Common_Channel_Url;
            NSMutableDictionary * param = [NSMutableDictionary dictionary];
            [param setObject:token forKey:@"token"];
            [param setObject:@"deleteCustomChannel" forKey:@"m"];
            [param setObject:customChannel.customChannelId forKey:@"customChannelId"];
            [self AFGetDataWithHostUrl:hostUrl params:param callback:^(HMCustomChannelStatus status,id object) {
                if (status == HMCustomChannelSuccess) {
                    if ([object isKindOfClass:[NSDictionary class]]) {
                        int status = [[object objectForKey:@"status"] intValue];
                        if (status == 0) {
                            [customChannel deleteObject];
                            callback(HMCustomChannelSuccess);
                        }else if(status == 2) {
                            callback(HMCustomChannelTokenIsInvalid);
                        }else if(status == 3) {
                            callback(HMCustomChannelUnboundDevice);
                        }else {
                            callback(HMCustomChannelFail);
                        }
                    }else {
                        callback(HMCustomChannelDataFormatError);

                    }
                }else {
                    callback(status);
                }
                
            }];
        }else {
            callback(status);
        }
    }];
    
}

- (void)updateCustomChannel:(HMCustomChannel *)customChannel
                channelName:(NSString *)channelName
                 channelNum:(int)channelNum
                   callback:(void(^)(HMCustomChannelStatus status,HMCustomChannel * customChannel))callback {
            [self getCommonChannekToken:^(HMCustomChannelStatus status, NSString *token) {
                if (token.length) {
                    NSString * hostUrl = Get_Common_Channel_Url;
                    NSMutableDictionary * param = [NSMutableDictionary dictionary];
                    [param setObject:token forKey:@"token"];
                    [param setObject:@"updateCustomChannel" forKey:@"m"];
                    [param setObject:customChannel.customChannelId forKey:@"customChannelId"];
                    [param setObject:channelName forKey:@"channelName"];
                    [param setObject:@(channelNum) forKey:@"channel"];
                    
                    [self AFGetDataWithHostUrl:hostUrl params:param callback:^(HMCustomChannelStatus status,id object) {
                        if (status == HMCustomChannelSuccess) {
                            if ([object isKindOfClass:[NSDictionary class]]) {
                                int status = [[object objectForKey:@"status"] intValue];
                                if (status == 0) {
                                    NSDictionary * data = [object objectForKey:@"data"];
                                    HMCustomChannel * customChannel = [[HMCustomChannel alloc] init];
                                    customChannel.channel = [[data objectForKey:@"channel"] intValue];
                                    customChannel.customChannelId = [data objectForKey:@"customChannelId"];
                                    customChannel.deviceId = [data objectForKey:@"deviceId"];
                                    customChannel.channelName = [data objectForKey:@"channelName"];
                                    [customChannel insertObject];
                                    callback(HMCustomChannelSuccess, customChannel);
                                    
                                }else if(status == 2) {
                                    callback(HMCustomChannelTokenIsInvalid,nil);
                                }else if(status == 3) {
                                    callback(HMCustomChannelUnboundDevice,nil);
                                }else {
                                    callback(HMCustomChannelFail,nil);
                                }
                            }else {
                                callback(HMCustomChannelDataFormatError,nil);
                            }
                        }else {
                            callback(status,nil);
                        }
                        
                    }];
                }else {
                    callback(status,nil);
                }
            }];
}


- (void)addChannel:(HMDevice *)device
       channelName:(NSString *)channelName
        channelNum:(int)channelNum
          callback:(void(^)(HMCustomChannelStatus status,HMCustomChannel * customChannel))callback {
    
    [self getCommonChannekToken:^(HMCustomChannelStatus status, NSString *token) {
        if (token.length) {
            NSString * hostUrl = Get_Common_Channel_Url;
            NSMutableDictionary * param = [NSMutableDictionary dictionary];
            [param setObject:token forKey:@"token"];
            [param setObject:@"addCustomChannel" forKey:@"m"];
            [param setObject:device.deviceId forKey:@"deviceId"];
            [param setObject:channelName forKey:@"channelName"];
            [param setObject:@(channelNum) forKey:@"channel"];
            
            [self AFGetDataWithHostUrl:hostUrl params:param callback:^(HMCustomChannelStatus status,id object) {
                if (status == HMCustomChannelSuccess) {
                    if ([object isKindOfClass:[NSDictionary class]]) {
                        int status = [[object objectForKey:@"status"] intValue];
                        if (status == 0) {
                            NSDictionary * data = [object objectForKey:@"data"];
                            HMCustomChannel * customChannel = [[HMCustomChannel alloc] init];
                            customChannel.channel = [[data objectForKey:@"channel"] intValue];
                            customChannel.customChannelId = [data objectForKey:@"customChannelId"];
                            customChannel.deviceId = [data objectForKey:@"deviceId"];
                            customChannel.channelName = [data objectForKey:@"channelName"];
                            [customChannel insertObject];
                            callback(HMCustomChannelSuccess, customChannel);
                            
                        }else if(status == 2) {
                            callback(HMCustomChannelTokenIsInvalid,nil);
                        }else if(status == 3) {
                            callback(HMCustomChannelUnboundDevice,nil);
                        }else {
                            callback(HMCustomChannelFail,nil);
                        }
                    }else {
                        callback(HMCustomChannelDataFormatError,nil);
                    }
                }else {
                    callback(status,nil);
                }
            }];
        }else {
            callback(status,nil);
        }
    }];
    
}
- (void)getChannelList:(void(^)(HMCustomChannelStatus status,NSMutableArray * channelList))callback {
    
    [self getCommonChannekToken:^(HMCustomChannelStatus status, NSString *token) {
        if (token.length) {
            NSString * hostUrl = Get_Common_Channel_Url;
            NSMutableDictionary * param = [NSMutableDictionary dictionary];
            [param setObject:token forKey:@"token"];
            [param setObject:@"queryChannelByProvinceCity" forKey:@"m"];
            
            NSDictionary *dic = [HMUserDefaults objectForKey:kLocationDictionaryKey];
            if (dic) {
                NSString * state =  dic[@"state"];
                if (state.length) {
                    state = [state stringByReplacingOccurrencesOfString:@"省" withString:@""];
                    [param setObject:state forKey:@"province"];
                }
                NSString * city =  dic[@"city"];
                if (city.length) {
                    city = [city stringByReplacingOccurrencesOfString:@"市" withString:@""];
                    [param setObject:city forKey:@"city"];
                }

            }else {
                [param setObject:@"广东" forKey:@"province"];
                [param setObject:@"深圳" forKey:@"city"];
            }
            [param setObject:@(-1) forKey:@"support"];

            [self AFGetDataWithHostUrl:hostUrl params:param callback:^(HMCustomChannelStatus status,id object) {
                if (status == HMCustomChannelSuccess) {
                    if ([object isKindOfClass:[NSDictionary class]]) {
                        int status = [[object objectForKey:@"status"] intValue];
                        if (status == 0) {
                            NSArray * data = [object objectForKey:@"data"];
                            NSMutableArray * array = [NSMutableArray array];
                            int i = 0;
                            for (NSDictionary * dic in data) {
                                HMChannel * channel = [[HMChannel alloc] init];
                                channel.type = [[dic objectForKey:@"type"] intValue];
                                channel.channelName = [dic objectForKey:@"channelName"];
                                channel.channelNamePinYin = @"";
                                channel.sequence = i;
                                [array addObject:channel];
                                i ++;
                            }
                            if(array.count) {
                                [HMChannel deleteAllChannel];
                            }
                            [[HMDatabaseManager shareDatabase] inTransaction:^(FMDatabase *db, BOOL *rollback) {
                                DLog(@"-----开始频道表信息写入数据库");
                                [array setValue:db forKey:@"insertWithDb"];
                                DLog(@"-----开始频道表信息写入数据库完成");
                            }];
                            callback(HMCustomChannelSuccess, array);
                        }else {
                            callback(HMCustomChannelFail,nil);
                        }
                    }else {
                        callback(HMCustomChannelDataFormatError,nil);
                    }
                }else {
                    callback(status,nil);
                }
                
            }];
        }else {
            callback(status,nil);
        }
    }];
}

- (void)getPublicCannelList:(HMDevice *)device
                   callback:(void(^)(HMCustomChannelStatus status,NSMutableArray * customChannelList))callback {
    [self getCommonChannekToken:^(HMCustomChannelStatus status, NSString *token) {
        if (status == HMCustomChannelSuccess) {
            if (token.length) {
                NSString * hostUrl = Get_Common_Channel_Url;
                NSMutableDictionary * param = [NSMutableDictionary dictionary];
                [param setObject:token forKey:@"token"];
                [param setObject:@"queryChannelNumberPublic" forKey:@"m"];
                if(device.company.length) {
                    NSArray *companyArray = [device.company componentsSeparatedByString:@","];
                    if (companyArray.count >= 5) {
                        NSString * spId = [companyArray objectAtIndex:1];
                        NSString * areaId = [companyArray objectAtIndex:2];
                        NSString * brandId = [companyArray objectAtIndex:3];
                        [param setObject:spId forKey:@"spId"];
                        [param setObject:areaId forKey:@"areaId"];
                        [param setObject:brandId forKey:@"brandId"];
                    }
                }
                [param setObject:device.deviceId forKey:@"deviceId"];
                [self AFGetDataWithHostUrl:hostUrl params:param callback:^(HMCustomChannelStatus status,id object) {
                    if ([object isKindOfClass:[NSDictionary class]]) {
                        int status = [[object objectForKey:@"status"] intValue];
                        if (status == 0) {
                            NSArray * data = [object objectForKey:@"data"];
                            NSMutableArray * array = [NSMutableArray array];
                            for (NSDictionary * dic in data) {
                                HMCustomChannel * customChannel = [[HMCustomChannel alloc] init];
                                customChannel.channel = [[dic objectForKey:@"channel"] intValue];
                                customChannel.customChannelId = (NSString *)[NSNull null];//这里是因为之前代码使用该字段是否为null判断是否为公共频道，4.2.1服务器不返回会该字段，为了不改之前的逻辑，这里手动赋值一下
                                customChannel.stbChannelId = [dic objectForKey:@"stbChannelId"];
                                customChannel.deviceId = device.deviceId;
                                customChannel.channelName = [dic objectForKey:@"channelName"];
                                [array addObject:customChannel];
                            }
                            [HMCustomChannel deletePublicObjectWithDevice:device];
                            [[HMDatabaseManager shareDatabase] inTransaction:^(FMDatabase *db, BOOL *rollback) {
                                DLog(@"-----开始公共频道表信息写入数据库");
                                [array setValue:db forKey:@"insertWithDb"];
                                DLog(@"-----开始公共频道表信息写入数据库完成");
                            }];
                            callback(HMCustomChannelSuccess, array);
                        }else if(status == 2) {
                            callback(HMCustomChannelTokenIsInvalid,nil);
                        }else if(status == 3) {
                            callback(HMCustomChannelUnboundDevice,nil);
                        }else {
                            callback(HMCustomChannelFail,nil);
                        }
                    }else {
                        callback(HMCustomChannelDataFormatError,nil);
                    }
                }];
            }else {
                callback(status,nil);
            }
        }else {
            callback(status,nil);
        }
        
    }];
}


- (void)getCommonCannelList:(HMDevice *)device callback:(void(^)(HMCustomChannelStatus status,NSMutableArray * customChannelList))callback {
    
    [self getCommonChannekToken:^(HMCustomChannelStatus status, NSString *token) {
        if (token.length) {
            NSString * hostUrl = Get_Common_Channel_Url;
            NSMutableDictionary * param = [NSMutableDictionary dictionary];
            [param setObject:token forKey:@"token"];
            [param setObject:@"queryCustomChannel" forKey:@"m"];
            [param setObject:device.deviceId forKey:@"deviceId"];            
            [self AFGetDataWithHostUrl:hostUrl params:param callback:^(HMCustomChannelStatus status,id object) {
                
                if (status == HMCustomChannelSuccess) {
                    if ([object isKindOfClass:[NSDictionary class]]) {
                        int status = [[object objectForKey:@"status"] intValue];
                        if (status == 0) {
                            NSArray * data = [object objectForKey:@"data"];
                            NSMutableArray * array = [NSMutableArray array];
                            for (NSDictionary * dic in data) {
                                HMCustomChannel * customChannel = [[HMCustomChannel alloc] init];
                                customChannel.channel = [[dic objectForKey:@"channel"] intValue];
                                customChannel.customChannelId = [dic objectForKey:@"customChannelId"];
                                customChannel.deviceId = [dic objectForKey:@"deviceId"];
                                customChannel.channelName = [dic objectForKey:@"channelName"];
                                [array addObject:customChannel];
                            }
                            [HMCustomChannel deleteCustomChannelWithDevice:device];
                            [[HMDatabaseManager shareDatabase] inTransaction:^(FMDatabase *db, BOOL *rollback) {
                                DLog(@"-----开始自定义频道表信息写入数据库");
                                [array setValue:db forKey:@"insertWithDb"];
                                DLog(@"-----开始自定义频道表信息写入数据库完成");
                            }];
                            callback(HMCustomChannelSuccess, array);
                        }else if(status == 2) {
                            callback(HMCustomChannelTokenIsInvalid,nil);
                        }else if(status == 3) {
                            callback(HMCustomChannelUnboundDevice,nil);
                        }else {
                            callback(HMCustomChannelFail,nil);
                        }
                    }else {
                        callback(HMCustomChannelDataFormatError,nil);
                    }
                }else {
                    callback(status,nil);
                }
            }];
        }else {
            callback(status,nil);
        }
    }];
}




- (void)getCommonChannekToken:(void(^)(HMCustomChannelStatus status, NSString *token))callback {
    
    NSString *session= [RemoteGateway shareInstance].session;
    if(session.length == 0) {
        callback(HMCustomChannelSessionError,nil);
        DLog(@"远程socket链接 session 为空");
        return;
    }
    
    NSString * sessionKey = [NSString stringWithFormat:@"sessionKey_%@",session];
    
    NSString * token = [[NSUserDefaults standardUserDefaults] objectForKey:sessionKey];
    if (token) {
        callback(HMCustomChannelSuccess,token);
    }else {
        if (session) {
            NSString * hostUrl = Get_Channel_token_Url;
            hostUrl = dynamicDomainURL(hostUrl);
            NSMutableDictionary * param = [NSMutableDictionary dictionary];
            [param setObject:session forKey:@"sessionId"];
            [self AFGetDataWithHostUrl:hostUrl params:param callback:^(HMCustomChannelStatus status,id object) {
                if (status == HMCustomChannelSuccess) {
                    if ([object isKindOfClass:[NSDictionary class]]) {
                        int status = [[object objectForKey:@"status"] intValue];
                        if (status == 0) {
                            self.getTokenTimes = 0;
                            NSDictionary * data = [object objectForKey:@"data"];
                            NSString * access_token = [data objectForKey:@"access_token"];
                            callback(HMCustomChannelSuccess,access_token);
                            
                            NSDictionary *dictionary = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
                            
                            for(NSString *key in [dictionary allKeys]){

                                if([key containsString:@"sessionKey"]){
                                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
                                    break;
                                }
                            }
                            
                            [[NSUserDefaults standardUserDefaults] setObject:access_token forKey:sessionKey];
                        }else {
                            if (self.getTokenTimes < MAXGETTOKEN) {
                                [self sendHeart:callback];
                            }else {
                                callback(HMCustomChannelFail,nil);
                            }
                        }
                    }else {
                        callback(HMCustomChannelDataFormatError,nil);
                    }
                }else {
                    callback(status,nil);
                }
                
            }];
        }else {
            callback(HMCustomChannelFail,nil);
        }
    }
}

- (void)sendHeart:(void(^)(HMCustomChannelStatus status, NSString *token))callback {
    self.getTokenTimes ++;
    HeartbeatCmd * hbReq = [HeartbeatCmd object];
    hbReq.sendToServer = YES;
    sendCmd(hbReq, ^(KReturnValue returnValue, NSDictionary *returnDic) {
        
        BOOL success = (returnValue == KReturnValueSuccess);
        if (success) {
            [self getCommonChannekToken:callback];
        }else {
            self.getTokenTimes = 0;
            callback(HMCustomChannelFail,nil);
        }
    });
}

- (void)AFGetDataWithHostUrl:(NSString *)string params:(NSDictionary *)params callback:(void(^)(HMCustomChannelStatus status,id object))callback {
    
    DLog(@"常用频道请求数据url = %@ 参数 = %@",string,params);
    
    if (!isNetworkAvailable()) {//当前网络不可用
        callback(HMCustomChannelHttpNoNet,nil);
        return;
    }
    
    NSMutableArray * paramArray = [NSMutableArray array];
    
    for (NSString * key in [params allKeys]) {
        NSString * string = [NSString stringWithFormat:@"%@=%@",key,params[key]];
        [paramArray addObject:string];
    }
    
    NSString * urlString = [NSString stringWithFormat:@"%@?%@",string,[paramArray componentsJoinedByString:@"&"]];
    
    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    requestURL(urlString, 5, ^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (!error && data) {
            
            NSError *jsonError = nil;
            id responseObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
        
            if (!jsonError && responseObject) {
                 callback(HMCustomChannelSuccess, responseObject);
                 DLog(@"常用频道请求数据成功 operation %@ 返回 %@",response,responseObject);
            }else{
                callback(HMCustomChannelFail, responseObject);
            }
        }else {
            if (error.code == -1009) {
                callback(HMCustomChannelHttpNoNet,nil);
            }else {
                callback(HMCustomChannelHttpError,nil);
            }
        }
        
    });
    
//    [_manager GET:string parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        DLog(@"常用频道请求数据成功 operation %@ 返回 %@",operation,responseObject);
//        callback(HMCustomChannelSuccess, responseObject);
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        DLog(@"常用频道请求数据失败 operation %@ 返回 %i",operation,error.code);
//        if (error.code == -1009) {
//            callback(HMCustomChannelHttpNoNet,nil);
//        }else {
//            callback(HMCustomChannelHttpError,nil);
//        }
//    }];
//
//
//    [_manager GET:@"http://homemate.orvibo.com/getCurrentIDC" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        DLog(@"获取IDC = %@",responseObject);
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        DLog(@"获取IDC 失败 %@",error.description);
//    }];
    
   
}


- (void)uploadCountryId:(NSString *)countryId countryName:(NSString *)countryName  device:(HMDevice *)device callback:(commonBlock)callback {
    
    ModifyHomeNameCmd * cmd = [ModifyHomeNameCmd object];
    cmd.country = countryName;
    cmd.uid = device.uid;
    cmd.countryCode = countryId;
    cmd.sendToServer = YES;
    sendCmd(cmd, ^(KReturnValue returnValue, NSDictionary *returnDic) {
        if (returnValue == KReturnValueSuccess) {
            HMGateway * gateWay = [HMGateway objectWithUid:device.uid];
            gateWay.country = countryName;
            gateWay.countryCode = countryId;
            [gateWay updateObject];
        }
        callback(returnValue);
    });
}

- (NSString *)getCountyId:(HMDevice *)device {
    
    NSString * countryId = @"";
    HMGateway * gateWay = [HMGateway objectWithUid:device.uid];
    if (gateWay && gateWay.countryCode.length) {
        countryId = gateWay.countryCode;
    }else {
        NSString *userId = userAccout().userId;
        NSDictionary *dic = [HMUserDefaults objectForKey:userId];;
        if ([dic isKindOfClass:[NSDictionary class]]) {
            countryId = [dic objectForKey:@"countryId"];
            NSString * countryName = [dic objectForKey:@"name"];
            if (countryId.length && device) {
                [self uploadCountryId:countryId countryName:countryName device:device callback:^(KReturnValue value) {
                    
                }];
            }
        }
    }
    if([countryId isEqualToString:@"中国"]) {
        countryId  = @"CN";
    }
    return countryId;

}

- (NSString *)getCountyName:(HMDevice *)device {
    NSString * countryName = @"";
    HMGateway * gateWay = [HMGateway objectWithUid:device.uid];
    if (gateWay && gateWay.country.length) {
        countryName = gateWay.country;
    }else {
        NSString *userId = userAccout().userId;
        NSDictionary *dic = [HMUserDefaults objectForKey:userId];
        if ([dic isKindOfClass:[NSDictionary class]]) {
            countryName = [dic objectForKey:@"name"];
            NSString * countryId = [dic objectForKey:@"countryId"];
            if (countryId.length && device) {
                [self uploadCountryId:countryId countryName:countryName device:device callback:^(KReturnValue value) {
                    
                }];
            }
        }
    }
    
    return countryName;
}

- (void)showErrorTip:(HMCustomChannelStatus)status device:(HMDevice *)device {

    
}

- (NSString *)transform:(NSString *)chinese
{
    NSMutableString *pinyin = [chinese mutableCopy];
    CFStringTransform((__bridge CFMutableStringRef)pinyin, NULL, kCFStringTransformMandarinLatin, NO);
    CFStringTransform((__bridge CFMutableStringRef)pinyin, NULL, kCFStringTransformStripCombiningMarks, NO);
    pinyin = [[pinyin stringByReplacingOccurrencesOfString:@" " withString:@""] mutableCopy];
    return [pinyin uppercaseString];
}

@end
