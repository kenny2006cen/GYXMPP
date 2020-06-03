//
//  Gateway+Foreground.m
//  Vihome
//
//  Created by Air on 15-1-27.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "Gateway+Foreground.h"
#import "Gateway+RT.h"
#import "Gateway+Send.h"
#import "SearchMdns.h"
#import "HMConstant.h"

@implementation Gateway (Foreground)
#pragma mark - mdns 服务发现网关之后返回的结果

- (void)searchMdnsResult:(NSNotification *)notif
{
    NSArray *gateways = notif.object;
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"self.uid = %@",self.uid];
    NSArray *array = [gateways filteredArrayUsingPredicate:pred];
    
    BOOL isRemote = !(array.count > 0);
    
    if (!isRemote) { //说明当前网关在内网
        
        DLog(@"uid -- %@ 切换到本地登录类型",self.uid);
        self.loginType = LOCAL_LOGIN; // 更改登录类型进行登录

    }else {//说明当前网关不在内网
        DLog(@"uid -- %@ 切换到远程登录类型",self.uid);
        self.loginType = REMOTE_LOGIN; // 更改登录类型进行登录
    }
    
    // 当前网关已经登录成功
    if (self.isLoginSuccessful && (isEnableWIFI() || isNetworkAvailable())) {
        
        [self readZigbeeHostData];
    }
}

-(void)readZigbeeHostData
{
    BOOL isRemote = (self.loginType == REMOTE_LOGIN);
    [self readTableWithUid:self.uid remote:isRemote completion:^(KReturnValue value) {
        
        DLog(@"Zigbee主机uid=%@：数据同步%@",self.uid,(value == KReturnValueSuccess) ? @"成功" : @"失败");
        // 发出通知消息，数据表更新完毕
        [HMBaseAPI postNotification:KNOTIFICATION_SYNC_TABLE_DATA_FINISH object:nil];

    }];
}

#pragma mark - 只读状态表
-(void)readStatus
{
    readTable(@"deviceStatus", self.uid, ^(KReturnValue value) {
        
        if (value == KReturnValueSuccess) {
            
            // 发出通知消息，设备状态表更新完毕
            [HMBaseAPI postNotification:KNOTIFICATION_SYNC_TABLE_DATA_FINISH object:nil];
            DLog(@"状态表同步成功");
        }else {
            DLog(@"状态表同步失败,状态码：%d",value);
        }
        
    });
}
//#error 后台进前台的时候网关的uid会被赋值为userId

-(void)readTable:(NSString *)tableName uid:(NSString *)uid completion:(commonBlock)completion
{
    __block Gateway *weakSelf = self;
    
    BOOL isRemote = (weakSelf.loginType == REMOTE_LOGIN);
    // 查询更新统计
    QueryStatisticsCmd *qsCmd = [QueryStatisticsCmd object];
    qsCmd.userName = userAccout().userName;
    qsCmd.uid = uid;
    qsCmd.LastUpdateTime = secondWithString([self tableUpdateTime:tableName]);
    qsCmd.sendToServer = isRemote;
    
    sendCmd(qsCmd, ^(KReturnValue returnValue, NSDictionary *returnDic) {
        
        if (returnValue == KReturnValueSuccess) {
            
            NSDictionary *dic = [returnDic objectForKey:tableName];
            
            if (dic) {
                
                // 读指定名称的表
                [weakSelf readTableWithName:tableName dic:dic uid:uid remote:isRemote specific:YES completion:completion];
  
            }
        }
    });
}
@end
