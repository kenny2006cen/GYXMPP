//
//  Constant.m
//  ABB
//
//  Created by orvibo on 14-3-8.
//  Copyright (c) 2014年 orvibo. All rights reserved.
//

#import "HMConstant.h"
#include <stdio.h>
#import "HMNetworkMonitor.h"
#import "CommonCrypto/CommonDigest.h"
#import "SocketSend.h"
#import "SearchMdns.h"
#import "NSData+AES.h"
#import "Gateway+Foreground.h"
#import "Gateway+RT.h"
#import <sys/types.h>
#import <sys/sysctl.h>
#import "RemoteGateway.h"
#import "sys/utsname.h"
#import <dlfcn.h>
#import "BCCKeychain.h"
#import "HMStorage.h"


// 是否wifi
BOOL isEnableWIFI(void)
{
    if ([HMNetworkMonitor shareInstance].networkStatus == ReachableViaWiFi) {
        return YES;
    }
    @autoreleasepool {
        
        if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == ReachableViaWiFi) {
            return YES;
        }
        return [[Reachability reachabilityForLocalWiFi]isReachableViaWiFi];
    }
}
// 是否3G
BOOL isEnable3G(void)
{
    if ([HMNetworkMonitor shareInstance].networkStatus == ReachableViaWWAN) {
        return YES;
    }
    @autoreleasepool {
        if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == ReachableViaWWAN) {
            return YES;
        }
        return [[Reachability reachabilityForInternetConnection] isReachableViaWWAN];
    }
}
// 网络是否可用
BOOL isNetworkAvailable(void)
{
    if (isEnable3G()){
        return YES;
        
    }else{
        return [[Reachability reachabilityWithHostname:TEST_HOST_NAME]isReachable];
    }
}


#pragma mark - 按指定格式获取当前时间
NSString *getCurrentTime(NSString *dateFormat)
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [formatter setDateFormat: dateFormat];
    NSString *dateStr = [formatter stringFromDate:[NSDate date]];
    return dateStr;
}

#pragma mark - 获取系统当前时间
NSString *currentTime(void)
{
    return getCurrentTime(@"yyyy-MM-dd HH:mm:ss");
}

#pragma mark - 获取当前日期
NSString *currentDay(void)
{
    return getCurrentTime(@"yyyyMMdd");
}

NSString* md5WithStr(NSString *input)
{
    if (input.length) {
        
        const char *cStr = [input UTF8String];
        unsigned char result[CC_MD5_DIGEST_LENGTH];
        CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
        
        return [[NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X"
                 "%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                 result[0], result[1], result[2], result[3],
                 result[4], result[5], result[6], result[7],
                 result[8], result[9], result[10], result[11],
                 result[12], result[13], result[14], result[15]
                 ] uppercaseString];
    }
    
    return nil;
}

#pragma mark - 把字符串中的字符为对应的 asii码 data
NSData *stringAsciiData(NSString*hexString,int length)
{
    int j=0;
    Byte bytes[length]; ///3ds key的Byte 数组， 128位
    for (int i = 0; i < [hexString length]; i++){
        int int_ch; /// 两位16进制数转化后的10进制数
        unichar hex_char1 = [hexString characterAtIndex:i]; ////两位16进制数中的第一位(高位*16)
        int int_ch1;
        if (hex_char1 >= '0' && hex_char1 <='9')
            //int_ch1 = (hex_char1-48)*16; //// 0 的Ascll - 48
            int_ch1 = (hex_char1 - 48 + 0x00) << 4;
        else if (hex_char1 >= 'A' && hex_char1 <='F')
            //int_ch1 = (hex_char1-65)*16; //// A 的Ascll - 65
            int_ch1 = (hex_char1 - 65 + 0x0A) << 4;
        else
            //int_ch1 = (hex_char1-97)*16; //// a 的Ascll - 97
            int_ch1 = (hex_char1 - 97 + 0x0A) << 4;
        i++;
        unichar hex_char2 = [hexString characterAtIndex:i]; ///两位16进制数中的第二位(低位)
        int int_ch2;
        if (hex_char2 >= '0' && hex_char2 <='9')
            //int_ch2 = (hex_char2-48); //// 0 的Ascll - 48
            int_ch2 = hex_char2 - 48 + 0x00;
        else if (hex_char2 >= 'A' && hex_char2 <='F')
            //int_ch2 = hex_char2-65; //// A 的Ascll - 65
            int_ch2 = hex_char2 - 65 + 0x0A;
        else
            //int_ch2 = hex_char2-97; //// a 的Ascll - 97
            int_ch2 = hex_char2 - 97 + 0x0A;
        
        //        int_ch = int_ch1+int_ch2;
        int_ch = int_ch1 | int_ch2;
        
        //DLog(@"int_ch=%d",int_ch);
        bytes[j] = int_ch; ///将转化后的数放入Byte数组里
        j++;
    }
    
    return [[NSData alloc] initWithBytes:bytes length:length];
    
}

NSMutableData *stringToData(NSString*str ,int len)
{
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    
    NSMutableData *data = [NSMutableData data];
    if(str !=nil)
    {
        NSData *stringData = [str dataUsingEncoding:enc];
        
        if(len < stringData.length) { // 目标长度 len 小于字符串的实际长度，则只截取len长度的字符串
            
            [data setData:[stringData subdataWithRange:NSMakeRange(0, len)]];
        }else{
            [data setData: stringData];
        }
    }
    
    if(len > data.length) // 字符串实际长度不够目标长度，则后面的字节补0，凑够len长度
    {
        NSString *value = @"20202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020";
        NSData *mData = stringAsciiData(value, 112);
        [data appendData:[mData subdataWithRange:NSMakeRange(0, len - data.length)]];
    }
    
    return data;
    
}

NSString *asiiStringWithData(NSData *data)
{
    if (data) {
        NSStringEncoding enc = NSASCIIStringEncoding;
        NSString *str =[[NSString alloc] initWithData:data encoding:enc];
        return str;
    }
    return nil;
}

BOOL isValidString(NSString *string,NSString *regex)
{
    // 6 - 20 位字母数字
    //NSString *regex =@"^[A-Za-z0-9]{6,20}$";
    //@"^[A-Za-z0-9]{6,20}$
    //"@"^[A-Za-z0-9]+$"
    
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    BOOL valid = [pre evaluateWithObject:string];
    return valid;
}

#if HOMEMATE_RELEASE
#else

void sendCmd(BaseCmd *cmd,SocketCompletionBlock completion)
{
    [[SocketSend shareInstance]sendCmd:cmd completion:completion];
}
void sendLCmd(BaseCmd *cmd,BOOL loading,SocketCompletionBlock completion)
{
    [[SocketSend shareInstance]sendCmd:cmd loading:loading alertTimeout:NO completion:completion];
}

#endif

void hm_printCmd(char *func,char *sendFunc,int line,char *file,BaseCmd *cmd)
{
#ifdef __SHOW__LOG__
    NSString *fileName = [[NSString stringWithUTF8String:file]lastPathComponent];
    NSString *funcName = [NSString stringWithUTF8String:func];
    if ([funcName hasPrefix:@"-["] || [funcName hasPrefix:@"+["]) {
        NSRange start = [funcName rangeOfString:@" "];
        NSRange end = [funcName rangeOfString:@"]"];
        NSRange range = NSMakeRange(start.location + start.length, end.location - start.location - start.length);
        funcName = [funcName substringWithRange:range];
    }
    NSString *debugString = [NSString stringWithFormat:@"\n[%@][%@-->%d行][%@-->%s]发送指令: %@\n",getCurrentTime(@"yyyy/MM/dd HH:mm:ss:SSS"),fileName,line,funcName,sendFunc,cmd];
    printf("%s\n",[debugString UTF8String]);
#endif

}

// 下面的接口发送失败后会自动重新登录gateway（本地和远程都会尝试）
void hm_sendCmd(char *func,int line,char *file,BaseCmd *cmd,SocketCompletionBlock completion)
{
    hm_printCmd(func,(char *)__FUNCTION__,line, file, cmd);
    [[SocketSend shareInstance]sendCmd:cmd completion:completion];
}
void hm_sendLCmd(char *func,int line,char *file,BaseCmd *cmd,BOOL loading,SocketCompletionBlock completion)
{
    hm_printCmd(func,(char *)__FUNCTION__,line, file, cmd);
    [[SocketSend shareInstance]sendCmd:cmd loading:loading alertTimeout:NO completion:completion];
}

BOOL isValidUID(NSString *uid) // 是否是合法的网关UID
{
    if ([uid isKindOfClass:[NSString class]] && [uid hasPrefix:@"HOPE"]) {
        return YES;
    }
    //必须是十六进制的字符
    BOOL valid = isValidString(uid, @"^[A-Fa-f0-9]+$");
    return valid;
}

#pragma mark - 根据网关UID获取网关信息
Gateway *getGateway(NSString *uid)
{
    if (uid && isValidUID(uid)) {
        
        NSMutableDictionary *dic = userAccout().gatewayDicList;

        Gateway *gateway = [dic objectForKey:uid];
        
        if (!gateway) {
            
            gateway = [Gateway newGateway];
            gateway.uid = uid;
            
            [dic setObject:gateway forKey:uid];
        }
        return gateway;
    }
    return [RemoteGateway shareInstance];
}


// 移除设备
void removeDevice(NSString *uid)
{
    DLog(@"removeDevice uid == %@",uid);
    
    if (uid && isValidUID(uid)) {
        
        NSMutableDictionary *dic = userAccout().gatewayDicList;
        Gateway *gateway = dic[uid];
        if (gateway) {
            
            [gateway hm_removeAllObserver];
            gateway.isLoginSuccessful = NO;
            [dic removeObjectForKey:uid];
        }
    }
}



AccountSingleton *userAccout(void)
{
    return [AccountSingleton shareInstance];
}

// 通过mdns 查找网关
void searchGatewaysAndPostResult(void)
{
    [[SearchMdns shareInstance]searchGatewaysAndPostResult];
}
void searchGatewaysWtihCompletion(SearhMdnsBlock completion)
{
    [[SearchMdns shareInstance]searchGatewaysWtihCompletion:completion];
}

BOOL isVirtualDevice(HMDevice *deviceVo)
{
    // 如果是类型为 5,6,7,32,33 的虚拟红外设备，就查询对应的红外转发器（zigbee）状态，而不是它自己的状态
    KDeviceType type = deviceVo.deviceType;
    if (type == KDeviceTypeAirconditioner
        || type == KDeviceTypeTV
        || type == KDeviceTypeSound
        || type == KDeviceTypeSTB
        || type == KDeviceTypeCustomerInfrared) {
        return YES;
    }
    return NO;
}
#pragma mark - 获取设备状态
HMDeviceStatus *realStatusOfDevice(HMDevice *deviceVo)
{
    HMDeviceStatus *object = [[HMDeviceStatus alloc] init];
    if (!deviceVo) {
        return object;
    }
    if (deviceVo.deviceType == KDeviceTypeDeviceGroup
        && deviceVo.subDeviceType == HMGrpupTypeColorTemperatureLight) {
        return [HMGroupStatus groupStatusForGroupDevice:deviceVo];
    }
    
    if (deviceVo.deviceType == KDeviceTypeCamera
        ||deviceVo.deviceType ==  kDeviceTypeViHCenter300 // 主机离线在线判断
        ||deviceVo.deviceType ==  kDeviceTypeMiniHub){
        
        object.online = YES;
        object.uid = deviceVo.uid;
        object.deviceId = deviceVo.deviceId;
        return object;
        
    }else if ([deviceVo.model isEqualToString:kSkyworthModelID]){
        
        // WIFI 空调查找状态时要特殊处理
        object = [HMDeviceStatus objectWithDeviceId:deviceVo.deviceId uid:deviceVo.uid];
        return object;
    }
    
    NSMutableString *sql = [NSMutableString string];
    
    // Zigbee红外转发器创建的虚拟设备，zigbee主机没有给子设备生成对应的状态数据，所以查询状态时需要特殊处理
    // 小方和RF主机也有虚拟红外设备，它们是WiFi设备，服务器给它们的子设备有生成对应的状态，可以直接查询
    if (isVirtualDevice(deviceVo) && (!deviceVo.isWifiDevice)){
        
        // 如果是类型为 5,6,7,32,33 的虚拟红外设备，就查询对应的红外转发器（zigbee）状态，而不是它自己的状态
        [sql appendFormat:@"select * from deviceStatus where uid = '%@' and deviceId = "
         "(select deviceId from device where deviceType not in (5,6,7,32,33) and endpoint = %d "
         "and extAddr = '%@' and uid = '%@' and delFlag = 0)",deviceVo.uid,deviceVo.endpoint,deviceVo.extAddr,deviceVo.uid];
    }
    else{
        [sql appendFormat:@"select * from deviceStatus where uid = '%@' and deviceId = '%@'",deviceVo.uid,deviceVo.deviceId];
    }
    
    
    FMResultSet * rs = [[HMDatabaseManager shareDatabase] executeQuery:sql];
    
    if([rs next]){
        
        object.statusId = [rs stringForColumn:@"statusId"];
        object.uid = [rs stringForColumn:@"uid"];
        object.deviceId = [rs stringForColumn:@"deviceId"];
        object.value1 = [rs intForColumn:@"value1"];
        object.value2 = [rs intForColumn:@"value2"];
        object.value3 = [rs intForColumn:@"value3"];
        object.value4 = [rs intForColumn:@"value4"];
        object.online = [rs intForColumn:@"online"];
        
        if ([object respondsToSelector:@selector(alarmType)]) {
            object.alarmType = [rs intForColumn:@"alarmType"];
        }
        object.updateTime = [rs stringForColumn:@"updateTime"];
        object.updateTimeSec = [rs intForColumn:@"updateTimeSec"];
        object.delFlag = [rs intForColumn:@"delFlag"];
    }else{
        object.uid = deviceVo.uid;
        object.deviceId = deviceVo.deviceId;
        object.delFlag = 1;
        object.online = 1; // 数据库中没有查询到当前设备状态时，给一个默认状态
        DLog(@"本地数据库中没有查询到当前设备的状态：%@",deviceVo);
    }
    [rs close];
    
    if (deviceVo.deviceType == KDeviceTypeOrviboLock && deviceVo.isC1Lock) {
        if (object.updateTimeSec > 0) {
            object.online = [[NSDate date] timeIntervalSince1970] - object.updateTimeSec <= 12 * 60 * 60;//门锁离线是否 按状态表的更新时间跟当前时间 查 是否是 12小时
        }else {
            object.online = [[NSDate date] timeIntervalSince1970] - [dateWithString(object.updateTime) timeIntervalSince1970] <= 12 * 60 * 60;//门锁离线是否 按状态表的更新时间跟当前时间 查 是否是 12小时
        }
    }
    
    return object;
}
BOOL isOppleScene(HMDevice * device) {
    BOOL isRet = NO;
    
    if (device.deviceType == kDeviceType1KeySceneBorad) {
        isRet = YES;
    }else if (device.deviceType == kDeviceType2KeySceneBorad) {
        isRet = YES;
        
    }else if (device.deviceType == kDeviceType4KeySceneBorad) {
//        isRet = YES;
        
    }else if (device.deviceType == kDeviceType5KeySceneBorad) {
        if ([device.model isEqualToString:KOPPLE5KeySceneBoardModelID]) {
            isRet = YES;
        }
    }
    
    return isRet;
}

HMDeviceStatus *statusOfDevice(HMDevice *deviceVo)
{
    HMDeviceStatus *object = realStatusOfDevice(deviceVo);
    if (!deviceVo) {
        return object;
    }
#if defined(__NVCLighting__) // 雷士项目需要显示真实状态
    return object;
#endif
    // 所有的zigbee设备，都取消离线状态的显示
    if (!deviceVo.isWifiDevice){
        
        // 可以休眠的设备（zigbee遥控器，随意贴）直接返回真实状态
        if (deviceVo.deviceType == KDeviceTypeRemote || isOppleScene(deviceVo)) {
            return object;
        }

        // Ember主机下的所有设备都返回真实的设备状态
        if (isEmberHub(deviceVo.uid)) {
            return object;
        }
        
        // NXP主机下的设备online字段不够准确，所以不显示离线
        object.online = YES;
    }
    return object;
}

#pragma mark - 删除本地数据库中的数据

void cleanDeviceData(NSString *uid)
{
    DLog(@"cleanDeviceData uid == %@",uid);
    
    if (!uid) return;
    
    [[HMDatabaseManager shareDatabase]deleteAllWithUid:uid];
    
    
    // 通知各个页面刷新页面显示
    [HMBaseAPI postNotification:KNOTIFICATION_SYNC_TABLE_DATA_FINISH object:nil];
    // 发出更新设备-widget数据的通知
    [HMBaseAPI postNotification:kNOTIFICATION_NEED_UPDATE_DEVICE_WIDGET_INFO object:nil];
    
    DLog(@"确认清除gateway数据 uid == %@",uid);
}

void cleanDeviceDataWithDevice(HMDevice * device) {
    
    cleanDeviceData(device.extAddr);
    if (device.deviceType == KDeviceTypeOrviboLock) {//如果是t1门锁，还要删除dooruserbind表数据
        [HMDoorUserBind deleteAllObjectWithExtAddr:device.extAddr];
        HMGateway * blueGateWay = [HMGateway bluetoothLockGateWayWithbleMac:device.blueExtAddr];
        [blueGateWay deleteObject];
        HMGateway * zigbeeGateWay = [HMGateway bluetoothLockGateWayWithbleMac:device.extAddr];
        [zigbeeGateWay deleteObject];
        HMUserGatewayBind * blueUserGateWay = [HMUserGatewayBind bindWithUid:device.blueExtAddr];
        [blueUserGateWay deleteObject];
        HMUserGatewayBind * zigbeeUserGateWay = [HMUserGatewayBind bindWithUid:device.extAddr];
        [zigbeeUserGateWay deleteObject];
        [HMAuthorizedUnlockModel deleteUnlockModelDevice:device];
        DLog(@"删除T1门锁，清除门锁的相关信息");
    }
    
}

/**
 *  新增coco等设备时，添加一份本地的绑定关系，作为数据同步的依据
 *
 *  @param uid
 *  @param model
 */

void addDeviceBind(NSString *uid,NSString *model)
{
    // 发出更新设备-widget数据的通知
    [HMBaseAPI postNotification:kNOTIFICATION_NEED_UPDATE_DEVICE_WIDGET_INFO object:nil];
}

NSDate *dateWithString(NSString *string)
{
    NSString *dateFormat = @"yyyy-MM-dd HH:mm:ss";
    // 兼容主机错误的数据格式
    if ([string isKindOfClass:[NSArray class]]) {
        
        NSArray *array = (NSArray *)string;
        string = array.lastObject;
    }
    
    if (![string isKindOfClass:[NSString class]]) {
        string = @"2015-12-30 00:00:00";
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: dateFormat];
    //[formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    NSDate *date = [formatter dateFromString:string];
    if (!date && string) {
        DLog(@"时间字符串有值，转换成date出错");
    }
    return date;
}

int secondWithString(NSString *string)
{
    // 如果传入的updatetime字符串为空，直接返回 0，不能返回默认的 2015-12-30 00:00:00，若传入此默认值，会导致读取的数据变多，速度变慢
    if (!string) {
        
        return 0;
    }
    
    if ([string isKindOfClass:[NSNumber class]]) {
        
        NSNumber *sec = (NSNumber *)string;
        DLog(@"上次更新时间：%@ lastUpdateTime： %@ ",dateStringWithSec(string),sec);
        return sec.intValue;
        
    }else{
        NSTimeInterval interval = [dateWithString(string) timeIntervalSince1970];
        int sec = interval;
        DLog(@"上次更新时间：%@ lastUpdateTime： %d",string,sec);
        return sec;
    }
}

unsigned int getCrcValue(NSData *data)
{
    NSUInteger len = [data length];
    
    Byte *buff = (Byte *)malloc(len);
    memcpy(buff, [data bytes], len);
    
    unsigned int value = buff[3]| (buff[2] << 8) | (buff[1] << 16) | (buff[0] << 24);
    
    free(buff);
    return value;
}


/**
 *  根据uid读取指定的表数据，可能是远程也可能是本地
 *
 *  @param tableName  表名
 *  @param uid
 *  @param completion
 */
void readTable(NSString *tableName,NSString *uid,commonBlock completion)
{
    [getGateway(uid) readTable:tableName uid:uid completion:completion];
}

NSString *devicePlatform(void)
{
    /** 参考网址 http://blog.csdn.net/liqinghai2015/article/details/49685525 */
    /** 参考网址 https://www.theiphonewiki.com/wiki/Models */
    
    int mib[2];
    size_t len;
    char *machine;
    
    mib[0] = CTL_HW;
    mib[1] = HW_MACHINE;
    sysctl(mib, 2, NULL, &len, NULL, 0);
    machine = malloc(len);
    sysctl(mib, 2, machine, &len, NULL, 0);
    
    NSString *platform = [NSString stringWithCString:machine encoding:NSASCIIStringEncoding];
    free(machine);
    return platform;
}

//获得设备型号
NSString *getCurrentDeviceModel(void)
{
    
    NSString *platform = devicePlatform();
    
    /* iPhone */
    if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone 2G";
    if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"]) return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,2"]) return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"]) return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"]) return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"]) return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,2"]) return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,3"]) return @"iPhone 5c";
    if ([platform isEqualToString:@"iPhone5,4"]) return @"iPhone 5c";
    if ([platform isEqualToString:@"iPhone6,1"]) return @"iPhone 5s";
    if ([platform isEqualToString:@"iPhone6,2"]) return @"iPhone 5s";
    if ([platform isEqualToString:@"iPhone7,1"]) return @"iPhone 6 Plus";
    if ([platform isEqualToString:@"iPhone7,2"]) return @"iPhone 6";
    if ([platform isEqualToString:@"iPhone8,1"]) return @"iPhone 6s";
    if ([platform isEqualToString:@"iPhone8,2"]) return @"iPhone 6s Plus";
    if ([platform isEqualToString:@"iPhone8,4"]) return @"iPhone SE";
    if ([platform isEqualToString:@"iPhone9,1"]) return @"iPhone 7";
    if ([platform isEqualToString:@"iPhone9,3"]) return @"iPhone 7";
    if ([platform isEqualToString:@"iPhone9,2"]) return @"iPhone 7 Plus";
    if ([platform isEqualToString:@"iPhone9,4"]) return @"iPhone 7 Plus";
    
    if ([platform isEqualToString:@"iPhone10,1"]) return @"iPhone 8";
    if ([platform isEqualToString:@"iPhone10,4"]) return @"iPhone 8";
    if ([platform isEqualToString:@"iPhone10,2"]) return @"iPhone 8 Plus";
    if ([platform isEqualToString:@"iPhone10,5"]) return @"iPhone 8 Plus";
    if ([platform isEqualToString:@"iPhone10,3"]) return @"iPhone X";
    if ([platform isEqualToString:@"iPhone10,6"]) return @"iPhone X";
    if ([platform isEqualToString:@"iPhone11,8"]) return @"iPhone XR";
    if ([platform isEqualToString:@"iPhone11,2"]) return @"iPhone XS";
    if ([platform isEqualToString:@"iPhone11,6"]) return @"iPhone XS Max";
    /* iPad */
    if ([platform isEqualToString:@"iPad1,1"])   return @"iPad 1G";
    if ([platform isEqualToString:@"iPad2,1"])   return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,2"])   return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,3"])   return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,4"])   return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,5"])   return @"iPad Mini 1G";
    if ([platform isEqualToString:@"iPad2,6"])   return @"iPad Mini 1G";
    if ([platform isEqualToString:@"iPad2,7"])   return @"iPad Mini 1G";
    
    if ([platform isEqualToString:@"iPad3,1"])   return @"iPad 3";
    if ([platform isEqualToString:@"iPad3,2"])   return @"iPad 3";
    if ([platform isEqualToString:@"iPad3,3"])   return @"iPad 3";
    if ([platform isEqualToString:@"iPad3,4"])   return @"iPad 4";
    if ([platform isEqualToString:@"iPad3,5"])   return @"iPad 4";
    if ([platform isEqualToString:@"iPad3,6"])   return @"iPad 4";
    
    if ([platform isEqualToString:@"iPad4,1"])   return @"iPad Air";
    if ([platform isEqualToString:@"iPad4,2"])   return @"iPad Air";
    if ([platform isEqualToString:@"iPad4,3"])   return @"iPad Air";
    if ([platform isEqualToString:@"iPad4,4"])   return @"iPad Mini 2G";
    if ([platform isEqualToString:@"iPad4,5"])   return @"iPad Mini 2G";
    if ([platform isEqualToString:@"iPad4,6"])   return @"iPad Mini 2G";
    if ([platform isEqualToString:@"iPad4,7"])   return @"iPad Mini 3";
    if ([platform isEqualToString:@"iPad4,8"])   return @"iPad Mini 3";
    if ([platform isEqualToString:@"iPad4,9"])   return @"iPad Mini 3";
    
    if ([platform isEqualToString:@"iPad5,1"])   return @"iPad Mini 4";
    if ([platform isEqualToString:@"iPad5,2"])   return @"iPad Mini 4";
    if ([platform isEqualToString:@"iPad5,3"])   return @"iPad Air 2";
    if ([platform isEqualToString:@"iPad5,4"])   return @"iPad Air 2";
    if ([platform isEqualToString:@"iPad6,7"])   return @"iPad Air 2";
    
    if ([platform isEqualToString:@"iPad6,3"])   return @"iPad Pro 12.9";
    if ([platform isEqualToString:@"iPad6,8"])   return @"iPad Pro 12.9";
    if ([platform isEqualToString:@"iPad6,4"])   return @"iPad Pro 9.7";
    
    /* iPod */
    if ([platform isEqualToString:@"iPod1,1"])   return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])   return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])   return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])   return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPod5,1"])   return @"iPod Touch 5G";
    if ([platform isEqualToString:@"iPod7,1"])   return @"iPod Touch 6";
    
    if ([platform isEqualToString:@"i386"])      return @"iPhone Simulator";
    if ([platform isEqualToString:@"x86_64"])    return @"iPhone Simulator";
    
    return platform;
    
}


/**
 获得当前uid上次更新的时间
 */
NSString *lastUpdateTimeKey(NSString *uid)
{
    NSString *lastTimeKey = [NSString stringWithFormat:@"UpdateTimeKey_%@_%@_%@",userAccout().familyId,uid,kDbVersion];
    DLog(@"%@",lastTimeKey);
    return lastTimeKey;
}
NSString *lastUpdateTimeSecKey(NSString *uid)
{
    NSString *lastUpdateTimeSecKey = [NSString stringWithFormat:@"UpdateTimeSecKey_%@_%@_%@",userAccout().familyId,uid,kDbVersion];
    DLog(@"%@",lastUpdateTimeSecKey);
    return lastUpdateTimeSecKey;
}


/**
 判断是不是手机号
 */
BOOL isPhoneNumber(NSString *phoneNum)
{
    return isValidString(phoneNum, @"^1[3-9]\\d{9}$");
}


#pragma mark - 上传token
void postToken(void)
{
    DLog(@"postToken()");

    if (![TokenReportCmd toKenIsNull]) {
        TokenReportCmd *trCmd = [TokenReportCmd object];
        trCmd.sendToServer = YES;
        sendCmd(trCmd, ^(KReturnValue returnValue, NSDictionary *returnDic) {
            
            BOOL success = (returnValue == KReturnValueSuccess);
            DLog(@"上传token状态码:%@", success ? @"成功": @"失败");
            
        });
    }
}

/**
 *  设备顺序
 *
 *  @return 顺序数组
 */
NSArray *orderOfDeviceType(void)
{
    return @[
             @(KDeviceTypeOrdinaryLight)           // 普通一路，二路，三路开关
             ,@(KDeviceTypeSingleFireSwitch)             // 单火控制开关
             ,@(KDeviceTypeDimmerLight)             // 调光灯
             ,@(KDeviceTypeColorTemperatureBubls)   // 色温灯
             ,@(KDeviceTypeRGBLight)                // RGB灯
             
             ,@(kDeviceTypeCoco)                    // CoCo
             ,@(KDeviceTypeSocket)                  // KDeviceTypeSocket
             
             ,@(KDeviceTypeInfraredSensor)          // 红外人体传感器
             ,@(KDeviceTypeMagneticDoor)            // 门磁
             ,@(KDeviceTypeMagneticWindow)          // 窗磁
             ,@(KDeviceTypeMagneticDrawer)          // 抽屉磁
             ,@(KDeviceTypeMagneticOther)           // 其他类型的门窗磁
             
             // 每一个红外转发器都自带一个分组，包含由它创建的虚拟设备
             ,@(KDeviceTypeAirconditioner)          // 空调
             ,@(KDeviceTypeTV)                      // 电视
             ,@(KDeviceTypeSTB)                     // 机顶盒
             ,@(KDeviceTypeCustomerInfrared)        // 自定义红外
             ,@(KDeviceTypeInfraredRelay)           // 红外转发器
             
             ,@(KDeviceTypeLock)                    // 门锁
             ,@(KDeviceTypeCamera)                  // 摄像头
             
             // 窗帘分组
             // 3,8,37,39,42 非百分比（类型可互相切换）
             ,@(KDeviceTypeScreen)                  // 幕布
             ,@(KDeviceTypeCurtain)                 // 对开窗帘
             ,@(KDeviceTypeAwningWindow)            // 推窗器
             ,@(KDeviceTypeRollupDoor)              // 卷匣门
             ,@(KDeviceTypeRoller2)                 // 卷帘
             ,@(KDeviceTypeCasement)                // 对开（百分比）
             ,@(KDeviceTypeRoller)                  // 卷帘（百分比）
             ,@(KDeviceTypeBlinds)                  // 百叶窗
             
             
             ,@(KDeviceTypeSwitchedElectricRelay)      // 继电器
             
             ,@(KDeviceTypeRemote)                  // Zigbee 智能遥控器
             
             ,@(KDeviceTypeSceneBorad)              // 情景面板 3键
             ,@(kDeviceType5KeySceneBorad)          // 情景面板 5键
             ,@(kDeviceType6KeySceneBorad)          // 情景面板 6键
             ,@(kDeviceType7KeySceneBorad)          // 情景面板 7键
             ,@(kDeviceType1KeySceneBorad)          // 情景面板 1键
             ,@(kDeviceType2KeySceneBorad)          // 情景面板 2键
             ,@(kDeviceType4KeySceneBorad)          // 情景面板 4键
             
             
             ,@(kDeviceTypeViHCenter300)            // Vi-Center300 大主机
             ,@(kDeviceTypeMiniHub)                 // Vi-Center300 小主机
             ];
}

BOOL isRemoteMode(NSString *uid)
{
    return (!isEnableWIFI() || (getGateway(uid).loginType != LOCAL_LOGIN));
}

#pragma mark - 根据model判断类型
/**
 *  vicenter - 300 大主机的modelID数组
 *
 *  @return 数组
 */
NSSet *VIHModelIDArray(void)
{
    static NSMutableSet *VIHModelSet;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSArray *array = @[@"91523b91a32a4a8b902bb1bf2ee7d821" // 链融
                           ,@"e507adfd602d403cb42a916ac079e33c" // ORVIBO
                           ,@"4cc2098e7c2a471eb47daa191c973fa1" // 铂顿
                           ,@"e019ff119e5f4567a0c3f5868b566253" //
                           ];
        
        VIHModelSet = [[NSMutableSet alloc]initWithArray:array];// 已知的确定类型的大主机 model
        
        FMResultSet *set = [[HMDatabaseManager shareDatabase]executeQuery:@"select model from deviceDesc where wifiFlag = 2"];
        while([set next]) {
            NSString *model = [set stringForColumn:@"model"];
            if (model) {
                [VIHModelSet addObject:model];
            }
        }
        [set close];
    });
    return VIHModelSet;
}

/**
 *  小主机的modelID数组
 *
 *  @return 数组
 */
NSSet *HubModelIDArray(void)
{
    static NSMutableSet *hubModelSet;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSArray *array = @[@"430da7aaf95b496c934d8721d8cea8c9",  // ORVIBO
                           @"9f99fd207d4448838bd12d4683d536e1"];  // 小主机(中性)
        hubModelSet = [[NSMutableSet alloc]initWithArray:array];// 已知的确定类型的小主机 model
        
        FMResultSet *set = [[HMDatabaseManager shareDatabase]executeQuery:@"select model from deviceDesc where wifiFlag = 3"];
        while([set next]) {
            
            NSString *model = [set stringForColumn:@"model"];
            if (model) {
                [hubModelSet addObject:model];
            }
        }
        [set close];
    });
    return hubModelSet;
}

/**
 *  MixPad的modelID数组
 *
 *  @return 数组
 */
NSSet *MixPadModelIDArray(void)
{
    static NSMutableSet *hubModelSet;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSArray *array = @[@"MixpadHost001"]; // Mixpad
        
        hubModelSet = [[NSMutableSet alloc]initWithArray:array];// 已知的确定类型的 Mixpad model
        
        FMResultSet *set = [[HMDatabaseManager shareDatabase]executeQuery:@"select model from deviceDesc where wifiFlag = 4"];
        while([set next]) {
            
            NSString *model = [set stringForColumn:@"model"];
            if (model) {
                [hubModelSet addObject:model];
            }
        }
        [set close];
    });
    return hubModelSet;
}

/**
 *  AlarmHost的modelID数组
 *
 *  @return 数组
 */
NSSet *AlarmHostModelIDArray(void)
{
    static NSMutableSet *hubModelSet;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSArray *array = @[@"AlarmHost001",
                           @"AlarmHost002",
                           @"7c4dd9b573504d7d96f333eb76de588d", // 智能网关 (浙江电信)
                           @"92a9b74644ce40728b82ac8d6b56dd9c"];
        
        hubModelSet = [[NSMutableSet alloc]initWithArray:array];// 已知的确定AlarmHost model
        
        //endpointSet: 0,0,113@ 113表示此设备的类型（报警主机）
        FMResultSet *set = [[HMDatabaseManager shareDatabase]executeQuery:@"select model from deviceDesc where endpointSet like '%%113@%%' and delFlag = 0"];
        while([set next]) {
            
            NSString *model = [set stringForColumn:@"model"];
            if (model) {
                [hubModelSet addObject:model];
            }
        }
        [set close];
    });
    return hubModelSet;
}

/**
 *  晾衣架的modelID
 *
 *  @return
 */
NSArray *CLHModelIDArray(void)
{
    return @[kZiChengCLHModel    // 紫程晾衣架
             ,kAoKeCLHModel   // 奥科晾衣架
             ,kLiangBaCLHModel   // 晾霸晾衣架
             ,kYuShunCLHModel   // 禹顺晾衣架
             ,kORVIBOCLHModel   //  欧瑞博晾衣架（豪华版）
             ,kORVIBOCLHModel_20w   //  欧瑞博晾衣架（时尚版）
             ,kORVIBOCLHModel_30w   //  欧瑞博晾衣架（旗舰版）
             ,kMaiRunCLHModel   // 麦润晾衣架
             ,kBangHeCLHModel   // 邦禾云晾衣架
             ];
}


/// 萤石摄像机modelID
NSArray * YSCamaraModleIDArray(void) {
    return @[@"d3bf4822f3ed41d7a8b7e154ddc46ffa",
             @"46a2523b3a0d472ba73bad0e868f6531"];
}

/**
 *  coco的modelID
 *
 *  @return
 */
NSArray *COCOModelIDArray(void)
{
    return @[@"7f831d28984a456698dce9372964caf3"    // 汉枫版本
             ,@"2a9131f335684966a86c54ca784520d7"   // 乐鑫版本
             ,@"22a70be5d60944f7b50d26b78eeebf01"   // 飞雕COCO插线板
             ];
}

/**
 *  S20c 的modelID
 *
 *  @return
 */
NSArray *S20cModelIDArray(void)
{
    /*
     欧瑞博S20c：56d124ba95474fc98aafdb830e933789  kS20cModelId
     海外版S20c 即S25：f8b11bed724647e98bd07a66dca6d5b6  kS20cFriModelId
     四川电信版S20c：a0ccd0836fed46978c1d933013c86412
     浙江电信版S20c：f758334cd00049c8987f9ae924d73842
     */
    return @[@"9cddfe4851ee47348e6e2df06fb9e945"    // 一栋
             ,kS20cModelId                          // S20c
             ,kS20cFriModelId                       // S20c海外版
             ,@"a0ccd0836fed46978c1d933013c86412"   // S20c电信版
             ,@"22a70be5d60944f7b50d26b78eeebf01"   // 飞雕
             ,kHuaDingStrip                         // 华顶排插
             ,kHuaDingSocket                        // 华顶插座
             ,kS20Model                             // 一栋model SOC002
             ,@"f758334cd00049c8987f9ae924d73842"   // 浙江电信S20c
             ];
}
/**
 *  Allone2 的modelID
 *
 *  @return
 */
NSArray *Allone2ModelIDArray(void)
{
    /*
     Allone2即小方
     欧瑞博小方 model：ffd65d82eae248a8a8bc08a2cb688a2b   kAllone2ModelID
     电信版小方 model：6aed061587f04620a17e057eeeb3c695
     */
    
    NSString * keyString = [NSString stringWithFormat:@"%@Allone2ModelIDArray",userAccout().familyId];

    NSArray * allone2Array = [HMCache objectForKey:keyString];
    if ([allone2Array isKindOfClass:[NSArray class]]) {
//        DLog(@"当前缓存allone2Array model id 为 %@",allone2Array);

        return allone2Array;
    }
    
    NSArray *existModels = @[kAllone2ModelID                       // allone2
                             ,@"d9e0292225204596aa57cd216a16af04"  // 南京电信版小方
                             ,@"6aed061587f04620a17e057eeeb3c695"  // 四川电信版小方
                             ,@"857b4d4870414bc4a015241e0b8c2865"  // 浙江电信版小方
                             ,@"f4b5e79d9219447ebf610d7c3067ae57"  // 欧瑞博小圆
                             ,@"d7d0cc45682b4f8797f8af13932b75ba"  // 四川电信小圆
                             ];
    
    NSMutableSet * allSet = [[NSMutableSet alloc] initWithArray:existModels];
    
    NSString *sql = [NSString stringWithFormat:@"select distinct model from device where deviceType = %d and delFlag = 0",KDeviceTypeAllone];
    
    FMResultSet *set = [[HMDatabaseManager shareDatabase] executeQuery:sql];
    
    while ([set next]){
        NSString * model = [set stringForColumn:@"model"];
        if (model) {
            [allSet addObject:model];
        }
    }
    [set close];
    NSArray * array = [allSet allObjects];
    [HMCache cacheObject:array forKey:keyString];
    
//    DLog(@"当前查询allone2Array model id 为 %@",array);

    return array;
}

/**
 *  AllonePro的modelID
 *
 *  @return
 */
NSArray *AlloneProModelIDArray(void)
{
    /*
     AllonePro即RF主机
     欧瑞博RF主机 model：32bede904a0f4b7a90f3d034e26fefb3  KRFModelID
     电信RF主机 model：80b2398a17154ceba704765c75d1295d
     */
    NSString * keyString = [NSString stringWithFormat:@"%@AlloneProModelIDArray",userAccout().familyId];
    NSArray * alloneProArray = [HMCache objectForKey:keyString];
    if ([alloneProArray isKindOfClass:[NSArray class]]) {
        
//        DLog(@"当前缓存alloneProArray model id 为 %@",alloneProArray);
        
        return alloneProArray;
    }
    
    NSArray *existModels = @[KRFModelID                       // AllonePro主机
                             ,@"80b2398a17154ceba704765c75d1295d"  // 四川电信版AllonePro
                             ,@"7efc89ce787546ec9f8a18ee3a2664ba"  // 浙江电信版AllonePro
                             ];
    
    NSMutableSet * allSet = [[NSMutableSet alloc] initWithArray:existModels];
    
    NSString *sql = [NSString stringWithFormat:@"select distinct model from device where deviceType = %d and delFlag = 0",kDeviceTypeRF];
    
    FMResultSet *set = [[HMDatabaseManager shareDatabase] executeQuery:sql];
    
    while ([set next]){
        
        NSString * model = [set stringForColumn:@"model"];
        if (model) {
            [allSet addObject:model];
        }
    }
    [set close];
    NSArray * array = [allSet allObjects];
    [HMCache cacheObject:array forKey:keyString];

    
//    DLog(@"当前查询alloneProArray model id 为 %@",array);

    return array;
}
/**
 *  vicenter - 300 大，小主机的modelID总数组
 *
 *  @return 数组
 */
NSSet *AllZigbeeHostModel(void)
{
    static NSMutableSet *allHostSet;
    static dispatch_once_t token;
    dispatch_once(&token , ^{
        allHostSet = [[NSMutableSet alloc]initWithSet:VIHModelIDArray()];   // 大主机
        [allHostSet unionSet:HubModelIDArray()];                            // 小主机
        [allHostSet unionSet:MixPadModelIDArray()];                         // MixPad
        [allHostSet unionSet:AlarmHostModelIDArray()];                      // 报警主机
    });
    
    return allHostSet;
}


/**
 *  判断model是不是主机
 *
 *  @param model 当前设备的model
 *
 *  @return
 */
BOOL isHostModel(NSString *model)
{
    if (!model) {
        return NO;
    }
    if (([model rangeOfString:kViHomeModel].location != NSNotFound)
        || ([model rangeOfString:kHubModel].location != NSNotFound)
        || ([model rangeOfString:@"MixpadHost"].location != NSNotFound)
        || ([model rangeOfString:@"AlarmHost"].location != NSNotFound)) {
        
        return YES;
    }else {
        return [AllZigbeeHostModel() containsObject:model];
    }
}

BOOL isHostDeviceType(KDeviceType deviceType)
{
    if (deviceType == KDeviceTypeAlarmHub
        || deviceType == kDeviceTypeViHCenter300
        || deviceType == kDeviceTypeMiniHub) {
        return YES;
    }
    return NO;
}

/**
 *  根据model 返回主机的类型，小主机 kDeviceTypeMiniHub 或大主机 kDeviceTypeViHCenter300
 *
 *  @param model
 *
 *  @return
 */
KDeviceType HostType(NSString *model)
{
    if ([AlarmHostModelIDArray() containsObject:model]) {
        return KDeviceTypeAlarmHub;
    }
    else if ([MixPadModelIDArray() containsObject:model]) {
        return KDeviceTypeMixPad;
    }
    else if ([model rangeOfString:kHubModel].location != NSNotFound) {
        
        return kDeviceTypeMiniHub;
        
    }else if ([model rangeOfString:kViHomeModel].location != NSNotFound) {
        
        return kDeviceTypeViHCenter300;
        
    }else if ([HubModelIDArray() containsObject:model]){
        
        return kDeviceTypeMiniHub;
        
    }else if ([VIHModelIDArray() containsObject:model]){
        
        return kDeviceTypeViHCenter300;
    }
    return kDeviceTypeMiniHub; // 默认小主机
}

KDeviceType deviceTypeWithModel(NSString *model)
{
    if (([model rangeOfString:kCLHModel].location != NSNotFound)
        || [CLHModelIDArray() containsObject:model]){ // 晾衣架
        
        return kDeviceTypeClothesHorse;
        
    }else if (([model rangeOfString:kCocoModel].location != NSNotFound)
              || [COCOModelIDArray() containsObject:model]){ // COCO插线板
        
        return kDeviceTypeCoco;
        
    }else if ([S20cModelIDArray() containsObject:model]){ // S20C
        
        return KDeviceTypeS20;
    }
    
    return HostType(model);
}

#pragma mark - 是否是wifi设备的uid
/**
 *  是否是wifi设备的uid
 *
 *  @param 设备的uid
 *
 *  @return
 */
BOOL isWifiDeviceUid(NSString *uid)
{
    return [HMUserGatewayBind isWifiDeviceWithUid:uid];
}

#pragma mark - 是否是wifi设备的model
/**
 *  是否是wifi设备的model
 *
 *  @param model
 *
 *  @return
 */
BOOL isWifiDeviceModel(NSString *model)
{
    if (!model) {
        return NO;
    }
    if (([model rangeOfString:kS20Model].location != NSNotFound)            // 一栋model SOC002
        || ([model rangeOfString:kCocoModel].location != NSNotFound)        // COCO 不带USB版本
        || ([model rangeOfString:kYSCameraModel].location != NSNotFound)    // 萤石摄像头
        || ([model rangeOfString:kS20cModel].location != NSNotFound)        // S20c 的model
        || ([model rangeOfString:kCLHModel].location != NSNotFound)         // 晾衣架
        || (Allone2ModelId(model))   //Allone2即小方
        || ([model rangeOfString:KCODetectorModelID].location != NSNotFound)//CO探测器
        || ([model rangeOfString:KHCHODetectorModelID].location != NSNotFound)//甲醛探测器
        || (AlloneProModelId(model))                                           //RF主机
        ) {
        
        return YES;
    }else{
        
        return [allWifiDeviceModel() containsObject:model];
    }
}

#pragma mark - 所有wifi设备的model
/**
 *  所有wifi设备的model
 *
 *  @param model
 *
 *  @return
 */
NSSet *allWifiDeviceModel(void)
{
    static NSMutableSet *wifiModelSet;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        wifiModelSet = [[NSMutableSet alloc]init];
        [wifiModelSet addObjectsFromArray:CLHModelIDArray()]  ;   // 晾衣架
        [wifiModelSet addObjectsFromArray:COCOModelIDArray()] ;   // coco
        [wifiModelSet addObjectsFromArray:S20cModelIDArray()] ;   // s20c
        [wifiModelSet addObjectsFromArray:YSCamaraModleIDArray()]; // 萤石
        [wifiModelSet addObjectsFromArray:Allone2ModelIDArray()];  // allone2
        
        FMResultSet *set = [[HMDatabaseManager shareDatabase]executeQuery:@"select model from deviceDesc where wifiFlag = 1"];
        while([set next]) {
            NSString *model = [set stringForColumn:@"model"];
            if (model) {
                [wifiModelSet addObject:model];
            }
        }
        [set close];
    });
    return wifiModelSet;
}
/**
 *  modelID 字符串，用来查询一个设备的model是否是WIFI设备的model
 *
 *  @return
 */
NSString *wifiDeviceModelIDs(void)
{
    static NSString *string;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        string = stringWithObjectArray([allWifiDeviceModel() allObjects]);
    });
    
    return string;
}
/**
 *  modelID 字符串，用来查询一个设备的model是否是主机的model
 *
 *  @return
 */
NSString *HostModelIDs(void)
{
    static NSString *string;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        string = stringWithObjectArray([AllZigbeeHostModel() allObjects]);
    });
    return string;
}

NSString *MiniHubModelIDs(void)
{
    static NSString *string;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        string = stringWithObjectArray([HubModelIDArray() allObjects]);
    });
    return string;
}

NSString *ViHomeModelIDs(void)
{
    static NSString *string;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        string = stringWithObjectArray([VIHModelIDArray() allObjects]);
    });
    return string;
}



DeleteDeviceCmd *deleteCmdWithDevice(HMDevice *device)
{
    DeleteDeviceCmd *deletecmd = [DeleteDeviceCmd object];
    
    BOOL isAlloneDevice = Allone2ModelId(device.model);
    BOOL isRFDevice = AlloneProModelId(device.model);
    
    if (isAlloneDevice || isRFDevice) {
        deletecmd.uid = device.uid;
        deletecmd.userName = userAccout().userName;
        deletecmd.deviceId = device.deviceId;
        deletecmd.extAddr = device.extAddr;
        deletecmd.sendToServer = YES;
        
    }else if (isWifiDeviceModel(device.model)) {
        deletecmd.uid = device.uid;
        deletecmd.userName = userAccout().userName;
        deletecmd.sendToServer = YES;
        
    }else {
        deletecmd.uid = device.uid;
        deletecmd.userName = userAccout().userName;
        deletecmd.deviceId = device.deviceId;
        if ([device.model isEqualToString:KVRVAirConditionPanelModelID] || [device.model isEqualToString:KVRVAirmasterProPanelModelID]) { // 删除zigbee子设备不带mac地址
            
        } else {
            deletecmd.extAddr = device.extAddr;
        }
//        deletecmd.isZigbeeDevice = YES; // 标记删除的是zigbee设备
        deletecmd.sendToServer = YES;

    }
    return deletecmd;
}


BOOL isBlankString(NSString * string)
{
    if (string == nil || string == NULL) {
        return YES;
    }
    
    if ([string isKindOfClass:[NSString class]]) {
        
        if ([string isEqualToString:@""]
            || [string isEqualToString:@"<null>"]
            || [string isEqualToString:@"null"]
            || [string isEqualToString:@"(null)"]
            || [string isEqualToString:@"Null"]) {
            return YES;
        }
        
        if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
            return YES;
        }
    }
    
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    
    return NO;
}


/**
 *  延时执行
 *
 *  @param delay 延时时间
 *  @param block 执行内容
 */
void executeAfterDelay(NSTimeInterval delay,VoidBlock block)
{
    NSString *identifier = [NSString stringWithFormat:@"hm_executeAfterDelay_%@"
                            ,[[NSProcessInfo processInfo]globallyUniqueString]];
    dispatch_queue_t queue = dispatch_queue_create(identifier.UTF8String, NULL);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), queue, ^{
        
        // 子线程计时，主线程执行
        if (block) {
            dispatch_async(dispatch_get_main_queue(),block);
        }
    });
}

/**
 *  全局队列异步执行
 *  @param block 执行内容
 */
void executeAsync(VoidBlock block)
{
    NSString *identifier = [NSString stringWithFormat:@"hm_executeAsync_%@"
                            ,[[NSProcessInfo processInfo]globallyUniqueString]];
    dispatch_queue_t queue = dispatch_queue_create(identifier.UTF8String, NULL);
    if (block) {
        dispatch_async(queue, block);
    }
}


/**
 *  通过gcd创建一个会重复执行的timer
 *
 *  @param interval    重复调用的间隔
 *  @param ^shouldStop 停止条件
 *
 *  @return
 */
dispatch_source_t gcdRepeatTimer(NSTimeInterval interval , BOOL(^shouldStop)(void) , VoidBlock block)
{
    NSString *identifier = [NSString stringWithFormat:@"hm_gcdRepeatTimer_%@"
                            ,[[NSProcessInfo processInfo]globallyUniqueString]];
    dispatch_queue_t queue = dispatch_queue_create(identifier.UTF8String, NULL);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),interval * NSEC_PER_SEC, 0); //每间隔 interval 执行一次
    dispatch_source_set_event_handler(_timer, ^{
        if(shouldStop()){ //倒计时结束，关闭
            dispatch_source_cancel(_timer);
        }else{
            if (block) {
                dispatch_async(dispatch_get_main_queue(),block);
            }
        }
    });
    dispatch_resume(_timer);
    return _timer;
}


/** 判断一个字符串中是否包含另一个字符串 */
BOOL stringContainString(NSString *source,NSString *target)
{
    if (source && target) {
        return [source rangeOfString:target].location != NSNotFound;
    }
    return NO;
};

/**
 *  返回当前是不是简体汉语环境
 *
 */
BOOL isZh_Hans(void)
{
    return [RunTimeLanguage isZh_Hans];
}
/**
 *  返回当前是不是繁体汉语环境
 *
 */
BOOL isZh_Hant(void)
{
    return [RunTimeLanguage isZh_Hant];
}

/**
 *  返回当前是不是韩语环境
 *
 */
BOOL isLan_Ko(void)
{
    return [RunTimeLanguage isLan_Ko];
}


/**
 *  返回当前是不是德语环境
 *
 */
BOOL isLan_De(void)
{
    return [RunTimeLanguage isLan_De];
}

/**
 *  返回当前是不是日语环境
 *
 */
BOOL isLan_Ja(void) {
    return [RunTimeLanguage isLan_Ja];
}


/**
 *  返回当前是不是法语环境
 *
 */
BOOL isLan_Fr(void) {
    return [RunTimeLanguage isLan_Fr];
}

/**
 *  返回当前是不是葡萄牙语环境
 *
 */
BOOL isLan_Pt(void) {
    return [RunTimeLanguage isLan_Pt];
}

/**
 *  返回当前是不是西班牙语环境
 *
 */
BOOL isLan_Es(void) {
    return [RunTimeLanguage isLan_Es];
}

/** 返回当前是不是英语语环境*/
BOOL isLan_En(void) {
    return [RunTimeLanguage isLan_En];

}

/**
 *  返回当前系统语言标识
 *  zh_TW,zh,en,de,fr,ru,ko,ja,pt,es
 */
NSString *language(void)
{
    return [RunTimeLanguage deviceLanguage];
}


NSString *dateStringWithSec(NSString *second)
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:second.intValue];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    if ([second isKindOfClass:[NSNumber class]]) {
        [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    }
    
    [formatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [formatter stringFromDate:date];
    DLog(@"second -- %@，dateString -- %@",second,dateString);
    return dateString;
}

BOOL isWhiteLightEndPoint(HMDevice *device)
{
    if ([device.model isEqualToString:kChuangWeiRGBWModel] && device.deviceType == KDeviceTypeDimmerLight) {
        return YES;
    }
    return NO;
}

BOOL isRGBLightEndPoint(HMDevice *device)
{
    if ([device.model isEqualToString:kChuangWeiRGBWModel] && device.deviceType == KDeviceTypeRGBLight) {
        return YES;
    }
    return NO;
}


void requestURL(NSString *URL,NSTimeInterval delayTime, HMRequestBlock completion){
    
    HMRequestBlock block = ^(NSData *data, NSURLResponse *response, NSError *error){
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            if (completion) {
                completion(data,response,error);
            }
        });
    };
    
    //默认会话配置
    NSURLSessionConfiguration *sessionConfig=[NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfig.timeoutIntervalForRequest= delayTime;//请求超时时间
    sessionConfig.allowsCellularAccess = YES;//是否允许蜂窝网络下载（2G/3G/4G）
    sessionConfig.requestCachePolicy = NSURLRequestReloadIgnoringCacheData; // 不使用缓存
    //创建会话，并指定配置和代理
    NSURLSession *session=[NSURLSession sessionWithConfiguration:sessionConfig];
    // 通过URL初始化task,在block内部可以直接对返回的数据进行处理
    NSURL *reqURL = [NSURL URLWithString:URL];
    NSURLSessionTask *task = [session dataTaskWithURL:reqURL completionHandler:block];
    
    // 启动任务
    [task resume];
}



// 根据uid/familyId获取 主机/家庭 数据的上次最大更新时间
NSNumber *getLastUpdateTime(NSString *key){
    
    if (![key isEqualToString:userAccout().familyId]) {
        
        // 只有发给主机的命令，lastUpdateTime才用此方法，发送到服务器的命令，使用到服务器的lastUpdateTime
        if (key && [HMUserGatewayBind isHostWithUid:key]) {
            
            NSNumber *lastUpdateTime = @(secondWithString(getGateway(key).lastUpdateTime));
            DLog(@"uid = %@ 主机的lastUpdateTime:%@",key,lastUpdateTime);
            return lastUpdateTime;
        }
    }
    
    // 返回家庭的 lastUpdateTime
    NSString * (^keyOfIdentifier)(NSString *) = ^(NSString *identifier){
        return [NSString stringWithFormat:@"%@_%@_%@_%@",identifier,userAccout().familyId,@"ReadAllWiFiData",kDbVersion];
    };
    
    NSString *lastTimeSecKey = keyOfIdentifier(@"UpdateTimeSecKey");
    NSString *lastTimeSec = [HMUserDefaults objectForKey:lastTimeSecKey]; // 实际上如果存在应该是nsnumber类型
    if (lastTimeSec) {
        NSNumber *lastUpdateTime = @(secondWithString(lastTimeSec));
        DLog(@"familyId = %@ 家庭的lastUpdateTime:%@",key,lastUpdateTime);
        return lastUpdateTime;
        
    }else{
        NSString *lastUpdateTimeKey = keyOfIdentifier(@"UpdateTimeKey");
        
        NSNumber *lastUpdateTime = @(secondWithString([HMUserDefaults objectForKey:lastUpdateTimeKey]));
        
        DLog(@"familyId = %@ 家庭的lastUpdateTime:%@",key,lastUpdateTime);
        return lastUpdateTime;
    }
    
}

BOOL hmSupportNewFunctionWithVersion(NSString *uid,NSString *supportVersion)
{

    NSString *key = [NSString stringWithFormat:@"%@_%@",uid,supportVersion];
    NSNumber *supportNum = hmCachedValue(key);
    if (supportNum) { // 已经缓存过，则直接返回结果
        return [supportNum boolValue];
    }
    
    BOOL isSupport = NO;
    // 只有Ember主机且版本号大于等于 2.4.0 才支持情景面板绑定安防&显示PanId&显示固件版本
    HMGateway *gateway = [HMGateway objectWithUid:uid];
    
    if (gateway) {
        
        // 如果开头为2.4.0的，则是支持2.4.0的，如果Model不是Hub1xx或VIH1xx的，都是NXP主机!!!!!!!!
        if (stringContainString(gateway.model, @"Hub1")
            || stringContainString(gateway.model, @"VIH1")
            || (HostType(gateway.model) == KDeviceTypeAlarmHub)
            || (HostType(gateway.model) == KDeviceTypeMixPad)) {
            
            NSString *softwareVersion = gateway.softwareVersion;
            
            NSComparisonResult result = [softwareVersion compare:supportVersion options:NSNumericSearch];
            // 当前版本号小于目标版本号
            if (result == NSOrderedAscending) {
                
                DLog(@"softwareVersion = %@ supportVersion = %@",softwareVersion,supportVersion);
                
            }else{
                // 当前版本号大于或等于目标版本号
                DLog(@"softwareVersion = %@ supportVersion = %@ 支持新功能",softwareVersion,supportVersion);
                
                isSupport = YES;
            }
        }
    }
    hmCache(key, @(isSupport)); // 缓存结果
    return isSupport;
}

/**
 判断当前设备是否是Ember方案的mini主机，Ember Hub 支持一些新功能，NXP 方案的Hub不支持
 */
BOOL isEmberHub(NSString *uid)
{
    if (!uid) return NO;

    static NSMutableDictionary *emberHubDic;
    if (!emberHubDic) {
        emberHubDic = [[NSMutableDictionary alloc]init];
    }
    NSNumber *isEmber = emberHubDic[uid];
    if (!isEmber) { // 未查询过此uid
        isEmber = @(hmSupportNewFunctionWithVersion(uid, @"2.4.0"));
        emberHubDic[uid] = isEmber; // 缓存起来
    }
    return [isEmber boolValue];
}

BOOL isSppportT1EmberHub(NSString *uid)
{
    return hmSupportNewFunctionWithVersion(uid, @"3.3.0");
}

BOOL isSppportControlBoxCustomType(NSString *uid)
{
    return hmSupportNewFunctionWithVersion(uid, @"3.5.0");
}

BOOL distBoxIsSupportLeakageDetect(HMDevice *device)
{
    // 先判断设备固件版本是否满足
    if (!isBlankString(device.version)) {
        
        NSComparisonResult result = [device.version compare:@"v1.0.5" options:NSNumericSearch];
        // 当前版本号小于目标版本号
        if (result == NSOrderedAscending) {
            
            return NO;
            
        }else{
            // 当前版本号大于或等于目标版本号
            // 再判断主机版本
            return hmSupportNewFunctionWithVersion(device.uid, @"3.5.0.101");

        }
    }
    return NO;
}

/**
 判断当前账号是否存在ember网关，Ember Hub 支持一些新功能，NXP 方案的Hub不支持
 */
BOOL hasEmberHub(void) {
    NSArray * allGateway = [HMGateway gatewayArr];
    if (allGateway.count) {
        for (HMGateway * gateway in allGateway) {
            BOOL emberGateway = isEmberHub(gateway.uid);
            if (emberGateway) {
                return YES;
            }
        }
    }
    return NO;
}



BOOL hasSuportT1LockEmber(void) {
    
    NSArray * allGateway = [HMGateway gatewayArr];
    if (allGateway.count) {
        for (HMGateway * gateway in allGateway) {
            BOOL emberGateway = isSppportT1EmberHub(gateway.uid);
            if (emberGateway) {
                return YES;
            }
        }
    }
    return NO;
}


// 3.2版本开始支持自动化，情景支持多个zigbee设备
BOOL hubVersionGreaterThanV32(NSString *uid)
{
    if (uid && [HMUserGatewayBind isHostWithUid:uid]) {
        
        HMGateway *gateway = [HMGateway objectWithUid:uid];
        if (gateway) {
            
            NSString *supportVersion = @"3.2.0";
            NSString *softwareVersion = gateway.softwareVersion;
            
            NSComparisonResult result = [softwareVersion compare:supportVersion options:NSNumericSearch];

            if (result == NSOrderedAscending) {}else{
                // 网关版本号大于或等于 3.2
                return YES;
            }
        }
    }
    
    return NO;
}

// 4.0版本主机支持联动二级条件
BOOL hubVersionGreaterThanV40(NSString *uid)
{
    if (uid && [HMUserGatewayBind isHostWithUid:uid]) {
        
        HMGateway *gateway = [HMGateway objectWithUid:uid];
        if (gateway) {
            
            NSString *supportVersion = @"4.0";
            NSString *softwareVersion = gateway.softwareVersion;
            
            NSComparisonResult result = [softwareVersion compare:supportVersion options:NSNumericSearch];
            
            if (result == NSOrderedAscending) {}else{
                // 网关版本号大于或等于 4.0
                return YES;
            }
        }
    }
    
    return NO;
}

#pragma mark - 数据库版本号

/**
 当数据库表字段有更新（增删改）时，增加此version值
 此值改变时可以从server或者gateway中获取数据的表会重新建立，lastupdatetime key值也会跟着变化
 升级时，首次会把所有数据全部重读一遍，后面恢复正常
 */
NSString* hmDbVersion(void){
    
    return @"v63";
}

kClothesHorseType clothesType(HMDevice *device){
    
    if (device.deviceType != kDeviceTypeClothesHorse) {
        DLog(@"设备类型不是晾衣架");
        return kClothesHorseTypeUnknown;
    }
    if (AlloneProModelId(device.model)){
        return kClothesHorseTypeRF;
    }
    
    
    kClothesHorseType clothesType = kClothesHorseTypeZiCheng; // 默认紫程晾衣架
    
    HMDeviceDesc *descModel =  [HMDeviceDesc objectWithModel:device.model];
    // 如果设备描述表有值，则用描述表的: deviceFlag > 0 说明真的有值
    if (descModel && descModel.deviceFlag > 0) {
        DLog(@"设备描述表晾衣架类型 deviceFlag： %d",descModel.deviceFlag);
        switch (descModel.deviceFlag) {
            case 1:
                clothesType = kClothesHorseTypeAoKe;
                break;
            case 2:
            case 6: // 麦润是紫程晾衣架的OEM
            case 7: // 邦禾云是紫程晾衣架的OEM
                clothesType = kClothesHorseTypeZiCheng;
                break;
            case 3:
                clothesType = kClothesHorseTypeLiangBa;
                break;
            case 4:
                clothesType = kClothesHorseTypeYuShun;
                break;
            case 5:
                clothesType = kClothesHorseTypeORVIBO;
                break;
            case 8:
                clothesType = kClothesHorseTypeORVIBO_20w;
                break;
            case 9:
                clothesType = kClothesHorseTypeORVIBO_30w;
                break;
            default:
                break;
        }
        return clothesType;
    }
    
    DLog(@"设备表没值，用model来判断 : %@",device.model);
    if ([device.model isEqualToString:kLiangBaCLHModel]) {
        clothesType = kClothesHorseTypeLiangBa;
    }else if ([device.model isEqualToString:kYuShunCLHModel]) {
        clothesType = kClothesHorseTypeYuShun;
    }else if ([device.model isEqualToString:kAoKeCLHModel]) {
        clothesType = kClothesHorseTypeAoKe;
    }else if (AlloneProModelId(device.model)){
        clothesType = kClothesHorseTypeRF;
    }else if([device.model isEqualToString:kORVIBOCLHModel]) {
        clothesType = kClothesHorseTypeORVIBO;
    }else if([device.model isEqualToString:kORVIBOCLHModel_20w]) {
        clothesType = kClothesHorseTypeORVIBO_20w;
    }else if([device.model isEqualToString:kORVIBOCLHModel_30w]) {
        clothesType = kClothesHorseTypeORVIBO_30w;
    }else {
        clothesType = kClothesHorseTypeZiCheng;
    }
    return clothesType;
}

NSString *connectSSid(void)
{
    
#if defined(__Lenovo__)
    return LenovoAPSSID;
    
#endif
    return HomeMateAPSSID;
    
}

NSString *floorAndRoom(HMDevice *device)
{
    id <HMBusinessProtocol>delegate = [HMStorage shareInstance].delegate;
    if (delegate && [delegate respondsToSelector:@selector(floorAndRoom:)]) {
        
        return [delegate floorAndRoom:device];
    }
    return nil;
}

/**
 返回设备是否是汇泰龙智能门锁，这些设备功能相同，model不同
 */
BOOL isHTLDoorLock(HMDevice *device){
    
    return ([device.model isEqualToString:kHTLDoorModelID]
            || [device.model isEqualToString:kHTLSecondDoorModelID]
            || [device.model isEqualToString:kHTLThirdDoorModelID]
            || [device.model isEqualToString:kHTLFourthDoorModelID]);
}

/**
 返回设备是否是霸陵智能门锁，这些设备功能相同，model不同
 */
BOOL isBLDoorLock(HMDevice *device){
    
    return ([device.model isEqualToString:kBLDoorModelId]
            || [device.model isEqualToString:kBLSecondDoorModelId]
            || [device.model isEqualToString:kBLThirdDoorModelId]
            || [device.model isEqualToString:kBLFourthDoorModelId]);
}

BOOL isBaLingModel(NSString *model)
{
    if ([model isEqualToString:kBLDoorModelId]
        || [model isEqualToString:kBLSecondDoorModelId]//霸陵新加坡，限制局域网开锁
        || [model isEqualToString:kBLThirdDoorModelId]
        || [model isEqualToString:kBLFourthDoorModelId]
        || [model isEqualToString:k9113DoorModelId]) {
        return YES;
    }
    return NO;
}

/**
 返回设备是否是智能门锁，智能门锁采取授权开锁，非智能门锁App直接控制开锁
 */
BOOL isSmartDoorLock(HMDevice *device)
{
    return (device.deviceType == KDeviceTypeLockH1
            ||isHTLDoorLock(device)
            ||isBLDoorLock(device)
            ||[device.model isEqualToString:kOrviboDoorModelId]
            ||[device.model isEqualToString:k9113DoorModelId]
            ||[device.model isEqualToString:kAierFuDeDoorModelId]);
}
// WiFi设备AP配置之后，查询设备是否在线
void queryDeviceStatus(NSString *uid,NSTimeInterval delayTime,commonBlockWithObject block)
{
    if (!isValidUID(uid)) {
        DLog(@"uid 非法");
        if (block) {
            block(KReturnValueFail,@(NO));
        }
        return;
    }
    
    
    NSString *url = dynamicDomainURL([NSString stringWithFormat:kGet_OnlineStatus_URL,uid]);
    DLog(@"查询设备状态URL:%@",url);
    requestURL(url, delayTime, ^(NSData *data, NSURLResponse *response, NSError *error) {
        
        BOOL online = NO;
        if (!error && data) {
            
            NSError *jsonError = nil;
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
            
            DLog(@"查询设备状态的请求结果：%@",dic);
            
            if (!jsonError && [dic isKindOfClass:[NSDictionary class]]) {
                
                if (block) {
                    int online = [dic[@"online"]intValue];
                    block(KReturnValueSuccess,@(online));
                    return;
                }
                
            }else{
                
                DLog(@"error:%@",jsonError);
            }
        }else{
            
            if (error) {
                DLog(@"%@",error);
            }
            
            if (!data) {
                DLog(@"查询设备状态的请求结果为空，数据异常");
            }
        }
        
        DLog(@"查询uid:%@状态失败，返回设备不在线",uid);
        // 失败则认为不在线
        if (block) {
            block(KReturnValueFail,@(online));
        }
    });
}

NSString * stringWithObjectArray(NSArray *objectArray)
{
    NSMutableString *uidString = [NSMutableString string];
    for (NSString *uid in objectArray) {
        [uidString appendFormat:@"'%@',",uid];
    }
    // 删除最后一个 ',' 逗号
    if ([uidString hasSuffix:@","]) {
        NSString *result = [uidString substringToIndex:uidString.length - 1];
        [uidString setString:result];
    }
    return uidString;
}
void checkHubOnlineStatus(void) {
    
    // 查所有主机在线状态，不分 ember 或者 nxp
    // if(hasEmberHub() || hasSuportT1LockEmber()) {//有主机或者有支持T1门锁的主机时候，去查询主机的在线状态
    
    NSArray * allGateway = [HMGateway gatewayArr];
    if (allGateway.count){
        
        GetHubStatusCmd *hubStatusCmd = [GetHubStatusCmd object];
        hubStatusCmd.familyId = userAccout().familyId;
        hubStatusCmd.userId = userAccout().userId;
        sendCmd(hubStatusCmd, ^(KReturnValue returnValue, NSDictionary *returnDic) {
            if (returnValue == KReturnValueSuccess) {//查询是否有在线的主机成功
                NSArray *onlineStatusArr = returnDic[@"onlineStatus"];
                [HMDatabaseManager insertInTransactionWithHandler:^(NSMutableArray *objectArray) {
                    if ([onlineStatusArr isKindOfClass:[NSArray class]]){//查询是否有在线返回数据格式正确
                        DLog(@"查询是否有在线的主机，返回数据正确%@",returnDic);
                        for (NSDictionary *itemDic in onlineStatusArr){
                            
                            HMHubOnlineModel * hubOnlineModel = [[HMHubOnlineModel alloc] init];
                            hubOnlineModel.familyId = userAccout().familyId;
                            hubOnlineModel.uid = [itemDic objectForKey:@"uid"];
                            hubOnlineModel.online = [[itemDic objectForKey:@"online"] intValue];
                            [objectArray addObject:hubOnlineModel];
                        }
                    }else {//查询是否有在线返回数据格式错误
                        DLog(@"查询是否有在线的主机，返回数据格式不对%@",returnDic);
                    }
                } completion:^{
                    if (onlineStatusArr.count) {
                        [HMBaseAPI postNotification:kNOTIFICATION_CHECKHUBONLINE object:nil];
                    }
                }];
            }else {//查询是否有在线的主机失败
                DLog(@"查询是否有在线的主机，查询失败");
            }
        });
    }else{
        DLog(@"当前家庭下面无主机，familyId:%@",userAccout().familyId);
    }
    
    
    //}
}

// 判断设备是否是多功能控制盒
BOOL isControlBox(HMDevice *device){
    
    // 如果是RF设备直接返回NO，RF可选类型（KDeviceTypeCasement，KDeviceTypeRoller2）与zigbee多功能控制盒有重叠（KDeviceTypeRoller2）
    if (AlloneProModelId(device.model)) {
        return NO;
    }
    
    KDeviceType type = device.deviceType;
    if (type == KDeviceTypeCurtain // 对开
        || type == KDeviceTypeRoller2 // 卷帘
        || type == KDeviceTypeScreen // 幕布
        || type == KDeviceTypeRollupDoor // 卷闸门
        || type == KDeviceTypeAwningWindow) { // 推窗器
        
        return YES;
    }
    
    return NO;
}

BOOL S30ModelId(NSString *model){
    
    if (!model) return NO;
    
    /*
     
     欧瑞博S30：62f1da0474434509923b2dc947a0f14c --> kS30ModelId 支持电量统计
     
     S30c与S30的功能一致，外观稍许改动，旧版本只有S30，新增三个版本的S30c
     S30c不支持电量统计
     新增欧瑞博S30c：98431e8c9e834776b414a40b2d8ddefb
     新增华为S30c：6e269db61b8345069a5dc8783c3b7093
     新增电信S30c：04aa419575be4714a853a82be3f22035
     */
    if ([model isEqualToString:kS30ModelId] // 旧版S30
        || [model isEqualToString:@"98431e8c9e834776b414a40b2d8ddefb"] //欧瑞博S30c
        || [model isEqualToString:@"6e269db61b8345069a5dc8783c3b7093"] //华为S30c
        || [model isEqualToString:@"04aa419575be4714a853a82be3f22035"] //四川电信S30c
        || [model isEqualToString:@"a832514f8adc45eb80a064ba6442aa7f"] //浙江电信S30c
        ){
        return YES;
    }
    
    return NO;
}

BOOL S20ModelId(NSString *model){
    
    if (!model) return NO;
    
    if ([S20cModelIDArray() containsObject:model]) {
        return YES;
    }
    return NO;

}

BOOL isSocketSpportPowerStatistics(NSString *model)
{
    if ([model isEqualToString:kS31ModelId]
        || [model isEqualToString:kS31YDModelId]
        || [model isEqualToString:kS30ModelId]
        || [model isEqualToString:KAmericanStandardSocketModelID]) {
        return YES;
    }
   return NO;
}
BOOL AlloneProModelId(NSString *model){
    
    if (!model) return NO;
    
    if ([AlloneProModelIDArray() containsObject:model]) {
        return YES;
    }
    
    
    KDeviceType deviceType = [HMDeviceDesc descTableDeviceTypeWithModel:model];
    
    if (deviceType == kDeviceTypeRF) {
        
        NSString * keyString = [NSString stringWithFormat:@"%@AlloneProModelIDArray",userAccout().familyId];
        NSArray * alloneProArray = [HMCache objectForKey:keyString];
        
        if (alloneProArray) {
            if ([alloneProArray isKindOfClass:[NSArray class]]) {
                if ([alloneProArray containsObject:model]) {
                    return YES;
                }else {
                    [[alloneProArray mutableCopy] addObject:model];
                }
            }else {
                alloneProArray = [NSArray arrayWithObjects:model, nil];
            }
        }else {
            alloneProArray = [NSArray arrayWithObjects:model, nil];
        }
        [HMCache cacheObject:alloneProArray forKey:keyString];
        return YES;
    }
    
    return NO;
    
}

BOOL Allone2ModelId(NSString *model){
    
    if (isBlankString(model)) return NO;
    
    if ([Allone2ModelIDArray() containsObject:model]) {
        return YES;
    }
    
    KDeviceType deviceType = [HMDeviceDesc descTableDeviceTypeWithModel:model];

    if (deviceType == KDeviceTypeAllone) {
        
        NSString * keyString = [NSString stringWithFormat:@"%@Allone2ModelIDArray",userAccout().familyId];
        NSArray * allone2Array = [HMCache objectForKey:keyString];
        
        if (allone2Array) {
            if ([allone2Array isKindOfClass:[NSArray class]]) {
                if ([allone2Array containsObject:model]) {
                    return YES;
                }else {
                    [[allone2Array mutableCopy] addObject:model];

                }
            }else {
                allone2Array = [NSArray arrayWithObjects:model, nil];
            }
        }else {
            allone2Array = [NSArray arrayWithObjects:model, nil];
        }
        [HMCache cacheObject:allone2Array forKey:keyString];
        return YES;
    }
    
    return NO;
    
}

BOOL deviceIsT1CLock(HMDevice * device) {
    if (!device.model.length) {
        return NO;
    }
    
    if ([device.model isEqualToString:kT1C1ModelId] ||
        [device.model isEqualToString:kT1C2ModelId]) {
        return YES;
    }else {
        return NO;
    }
}

NSString *phoneIdentifier(void)
{
    static NSString *identifier;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        identifier = [BCCKeychain UDID];
        DLog(@"=====手机序列号=====%@",identifier);
        
    });
    if(identifier == nil) {
       identifier = [BCCKeychain UDID];
    }
    return identifier;
}

//获取设备自定义的名字
NSString *terminalDeviceName(void) {
    
    NSString * name = [UIDevice currentDevice].name;
    
    if(name == nil) name = @"";
    
    DLog(@"=====终端名字=====%@",name);
    if(name.length > 30) {
        NSString * subString = [name substringToIndex:30];
        DLog(@"=====终端名字超过30个字，显示前30=====%@",subString);
        return subString;
    }
    return name;
    
}

// 判断是否是VRV空调控制器
BOOL isVRVAirConditionController(HMDevice * device)
{
    NSString *model = device.model;
    if ([model isEqualToString:KVRVAirConditionControlModelID]
        || [model isEqualToString:KVRVAirmasterProModelID]) {
        return YES;
    }
    return NO;
}


// Allone/小方支持的虚拟设备类型
NSArray *alloneVirtualDeviceType(void)
{
    return @[@(5),@(6),@(7),@(32),@(33),@(58),@(59),@(60),@(119)];
}

// Allone Pro/RF主机支持的虚拟设备类型
NSArray *alloneProVirtualDeviceType(void)
{
    return @[@(5),@(6),@(7),@(32),@(33),@(34),@(42),@(52),@(58),@(59),@(60),@(70),@(73),@(74),@(75),@(76),@(77),@(78),@(119),@(126),@(127)];
}

// Zigbee红外转发器支持的虚拟设备类型 5,6,7,32,33
NSArray *zigbeeIrVirtualDeviceType(void)
{
    return @[@(5),@(6),@(7),@(32),@(33)];
}

BOOL is_iPhoneX(void)
{
    static BOOL iPhoneXSeries = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (@available(iOS 11.0, *)) {
            UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
            if (mainWindow.safeAreaInsets.bottom > 0.0f) {
                iPhoneXSeries = YES;
            }
        }
    });
    return iPhoneXSeries;
}


NSString *getNumberFromStr(NSString *str)
{
    NSCharacterSet *nonDigitCharacterSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    return[[str componentsSeparatedByCharactersInSet:nonDigitCharacterSet] componentsJoinedByString:@""];
    
}


BOOL isSupportSiriShortcuts(void){
    
    if (@available(iOS 12.0, *)) {
        
        NSString *platform = devicePlatform();
        NSArray *array = [platform componentsSeparatedByString:@","];
        NSString *first = array.firstObject;
        if ([first isKindOfClass:[NSString class]]) {
            if (stringContainString(first, @"iPhone")) {
                int modelNumber = [getNumberFromStr(first) intValue];
                if (modelNumber > 6) {
                    return YES;
                }
            }else if (stringContainString(first, @"iPad")) {
                int modelNumber = [getNumberFromStr(first) intValue];
                if (modelNumber > 3) {
                    return YES;
                }
            }
        }
    }
    return NO;
}


BOOL isMixpadAppVersionHigherThanVersion(HMDevice *mixpad,NSString *supportVersion){
    
    if (mixpad.deviceType == KDeviceTypeMixPad){
        //MixPad App版本号 >= 传入的版本号, 以支持某个特定功能
        HMGateway *gateway = [HMGateway objectWithUid:mixpad.uid];
        NSArray *appVerArr = [gateway.softwareVersion componentsSeparatedByString:@"_"];
        NSString *appVer = @"";
        if (appVerArr.count > 1) {//主机有bug, 有时上报的版本号只有一段, 版本号未知, 所以做这个判断
            appVer = appVerArr.lastObject;
        }
        
        NSComparisonResult result = [supportVersion compare:appVer options:NSNumericSearch];
        if (result == NSOrderedAscending || result == NSOrderedSame){
            return YES;
        }
    }else {
        DLog(@"传入的设备类型：%d 不是MixPad，返回NO",mixpad.deviceType);
    }
    
    return NO;
}

NSString *AESEncryptKey(void){
    return @"AesEncryptLogKey";// 与安卓秘钥一致
}
NSString *decryptTheString(NSString *encryptedString){
    
    NSString *key = AESEncryptKey();
    NSData *data = [BLUtility dataFromHexString:encryptedString];
    NSData *decryptedData = [data hm_AES128DecryptWithKey:key iv:nil];
    NSString *decryptedString = [[NSString alloc]initWithData:decryptedData encoding:NSUTF8StringEncoding];
    
    return decryptedString;
}

NSString *encryptTheString(NSString *originSting){
    
    NSString *key = AESEncryptKey();
    NSData *stringData = [originSting dataUsingEncoding:NSUTF8StringEncoding];
    NSData * encryptedData = [stringData hm_AES128EncryptWithKey:key iv:nil];
    NSString *encryptedString = [BLUtility dataToHexString:encryptedData];
    
    return encryptedString;
}

BOOL appVersionLowerThanVersion(NSString * version) {
     NSBundle *bundle = [NSBundle mainBundle];
     NSString *appVersion = [bundle objectForInfoDictionaryKey:@"CFBundleVersion"];
    if ([appVersion compare:version] == NSOrderedAscending) {
        return YES;
    }
    
    return NO;
}


/**
 处理动态域名的URL
 */
NSString *dynamicDomainURL(NSString *url){
    NSString *newURL = [url copy];
    NSString *lowercaseURL = newURL.lowercaseString;
    
    // 之前的接口可能为http，需要更改为https
    if ([lowercaseURL hasPrefix:@"http://"]) {
        NSRange range = [lowercaseURL rangeOfString:@"http://"];
        newURL = [url stringByReplacingCharactersInRange:range withString:@"https://"];
    }
    
    NSString *host = [NSURL URLWithString:newURL].host;
    if ([host isEqualToString:@"app.homemate.orvibo.com"]) {
        NSString *recordUrl = [HMSDK memoryDict][@"recordUrl"];
        if (recordUrl) {
            newURL = [newURL stringByReplacingOccurrencesOfString:host withString:recordUrl];
        }
    }
    
    /*
        v4.5暂时屏蔽homemate.orvibo.com域名动态替换
        else if ([host isEqualToString:@"homemate.orvibo.com"]) {
        // 获取到新的ip，替换homemate.orvibo.com
            NSString *ip = [HMSDK memoryDict][@"ip"];
            if (ip) {
                newURL = [newURL stringByReplacingOccurrencesOfString:host withString:ip];
            }
        }
     */
    
    if (![url isEqualToString:newURL]) {
        DLog(@"url = %@\nnewURL = %@",url,newURL);
    }
    
    return newURL;
}
