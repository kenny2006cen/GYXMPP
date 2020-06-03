//
//  HMCountDownBusiness.m
//  HomeMateSDK
//
//  Created by liuzhicai on 2017/5/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMCountDownBusiness.h"

@implementation HMCountDownBusiness

+ (void)setCountDownWithDeviceId:(NSString *)deviceId uid:(NSString *)uid value1:(int)value1 time:(int)time completion:(commonBlockWithObject)completion {
   
    if (isBlankString(deviceId) || isBlankString(uid) || (value1 != 0 && value1 != 1) || time < 0) {
        if (completion) {
            DLog(@"参数错误");
            completion(KReturnValueParameterError,nil);
        }
        return;
    }
    int startTime = (int)[[NSDate date] timeIntervalSince1970];
    AddCountdownCmd *addCdCmd = [AddCountdownCmd object];
    addCdCmd.userName = userAccout().userName;
    addCdCmd.time = time;
    addCdCmd.startTime = startTime;
    addCdCmd.uid = uid;
    addCdCmd.deviceId = deviceId;
    addCdCmd.value1 = value1;
    addCdCmd.order = (value1 == 0) ? @"on" : @"off";
    sendLCmd(addCdCmd, NO, ^(KReturnValue returnValue, NSDictionary *returnDic) {
        
        if (returnValue == KReturnValueSuccess) {
            HMCountdownModel *cdModel = [HMCountdownModel objectFromDictionary:returnDic];
            cdModel.startTime = startTime;
            [cdModel updateObject];
            if (completion) {
                completion(returnValue,cdModel);
            }
        }
        else{
            if (completion) {
                completion(returnValue,nil);
            }
        }
    });
}

+ (void)modifyCountDownObj:(HMCountdownModel *)cdModel value1:(int)value1 time:(int)time completion:(commonBlockWithObject)completion{
    
    NSAssert(cdModel, @"倒计时对象不能为空");
    if (!cdModel || time < 0) {
        if (completion) {
            DLog(@"参数错误");
            completion(KReturnValueParameterError,nil);
        }
        return;
    }
    ModifyCountdownCmd *mdCdCmd = [ModifyCountdownCmd object];
    mdCdCmd.userName = userAccout().userName;
    mdCdCmd.time = time;
    mdCdCmd.startTime = (int)[[NSDate date] timeIntervalSince1970];
    mdCdCmd.uid = cdModel.uid;
    mdCdCmd.countdownId = cdModel.countdownId;
    mdCdCmd.value1 = value1;
    mdCdCmd.value3 = cdModel.value3;
    mdCdCmd.order = (value1 == 0) ? @"on" : @"off";
    mdCdCmd.value4 = cdModel.value4;
    sendLCmd(mdCdCmd, NO, ^(KReturnValue returnValue, NSDictionary *returnDic)  {
        DLog(@"修改倒计时状态码： %d",returnValue);
        if (returnValue == KReturnValueSuccess) {
            HMCountdownModel *cdModel = [HMCountdownModel objectFromDictionary:returnDic];
            cdModel.startTime = mdCdCmd.startTime;
            [cdModel updateObject];
            if (completion) {
                completion(returnValue,cdModel);
            }
        }else {
            if (completion) {
                completion(returnValue,nil);
            }
        }
    });
}

+ (void)deleteCountDownObj:(HMCountdownModel *)cdModel completion:(commonBlockWithObject)completion {
    NSAssert(cdModel, @"倒计时对象不能为空");
    if (!cdModel) {
        if (completion) {
            DLog(@"参数错误");
            completion(KReturnValueParameterError,nil);
        }
        return;
    }
    DeleteCountdownCmd *delCdCmd = [DeleteCountdownCmd object];
    delCdCmd.userName = userAccout().userName;
    delCdCmd.uid = cdModel.uid;
    delCdCmd.countdownId = cdModel.countdownId;
    sendLCmd(delCdCmd, NO, ^(KReturnValue returnValue, NSDictionary *returnDic) {
        if (returnValue == KReturnValueSuccess) {
            [cdModel deleteObject];
        }
        if (completion) {
            completion(returnValue,returnDic);
        }
    });
}


+ (void)activateCountDownObj:(HMCountdownModel *)cdModel isPause:(BOOL)isPause completion:(commonBlockWithObject)completion {
    NSAssert(cdModel, @"倒计时对象不能为空");
    if (!cdModel || (isPause !=0 && isPause!=1)) {
        if (completion) {
            DLog(@"参数错误");
            completion(KReturnValueParameterError,nil);
        }
        return;
    }
    ActivateCountdownCmd *activeCountdown = [ActivateCountdownCmd object];
    activeCountdown.uid = cdModel.uid;
    activeCountdown.countdownId = cdModel.countdownId;
    activeCountdown.isPause = isPause;
    activeCountdown.startTime = [[NSDate date] timeIntervalSince1970];
    activeCountdown.userName = userAccout().userName;
    activeCountdown.sendToServer = YES;
    sendLCmd(activeCountdown, NO, ^(KReturnValue returnValue, NSDictionary *returnDic) {
        if (returnValue == KReturnValueSuccess) {
            [HMCountdownModel updatePause:activeCountdown.isPause startTime:activeCountdown.startTime countdownId:activeCountdown.countdownId];
            cdModel.isPause = isPause;
            cdModel.startTime = activeCountdown.startTime;
            
            if (completion) {
                completion(returnValue,cdModel);
            }
        }else  {
            if (completion) {
                completion(returnValue,nil);
            }
        }
    });
}

@end
