//
//  BLUtility.m
//  Vihome
//
//  Created by Ned on 1/19/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "BLUtility.h"
#import <arpa/inet.h>
#import <zlib.h>
#import "NSData+CRC32.h"
#import <ifaddrs.h>
#import "HMAirConditionUtil.h"
#import "HMVRVAirConditionUtil.h"
#import "HMConstant.h"
#import <objc/runtime.h>


@implementation BLUtility

+ (int)getTimestamp
{
    NSTimeInterval ti = [[NSDate date] timeIntervalSince1970] * 1000 * 1000; // 精确到微秒
    
    int realStamp = (unsigned long long)ti % (1000* 1000 * 1000); // 截取后面有效位
    
    return realStamp;
}

+  (NSString *)timeformatFromSeconds:(NSInteger)seconds
{
    NSString *str_minute = [NSString stringWithFormat:@"%02d",((int)seconds)/60];
    NSString *str_second = [NSString stringWithFormat:@"%02d",(int)seconds%60];
    NSString *format_time = [NSString stringWithFormat:@"%@:%@",str_minute,str_second];
    return format_time;
}

+ (double)getUnixTimestamp
{
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970] * 1000;
    return timeStamp;
}



+ (NSString *)getIPAddressByData:(NSData *)data
{
    struct sockaddr_in *addr = (struct sockaddr_in *)[data bytes];
    NSString * IP = [NSString stringWithCString:inet_ntoa(addr->sin_addr) encoding:NSASCIIStringEncoding];
    return IP;
}

+ (NSMutableData *)stringToNSData:(NSString*)str len:(int)len;
{
    
    return stringToData(str, len);
}

+ (NSData *)getData:(NSString*)str length:(int)length
{
    NSString *hexString = str;
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

+ (NSData *)dataFromHexString:(NSString *)hexString
{
    NSString * command = [hexString stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSMutableData *commandToSend= [[NSMutableData alloc] init];
    unsigned char whole_byte;
    char byte_chars[3] = {'\0','\0','\0'};
    int i;
    for (i=0; i < [command length]/2; i++) {
        byte_chars[0] = [command characterAtIndex:i*2];
        byte_chars[1] = [command characterAtIndex:i*2+1];
        whole_byte = strtol(byte_chars, NULL, 16);
        [commandToSend appendBytes:&whole_byte length:1];
    }
    return commandToSend;
}

+ (NSString *)dataToHexString:(NSData *)data
{
    /*
     NSString * string = [data description];
     string = [string stringByReplacingOccurrencesOfString:@"<" withString:@""];
     string = [string stringByReplacingOccurrencesOfString:@">" withString:@""];
     string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
     return string;
     //http://stackoverflow.com/questions/7520615/how-to-convert-an-nsdata-into-an-nsstring-hex-string
     */
    
    
    @autoreleasepool {
        Byte * bytept = (Byte *)[data bytes];
        NSMutableString * mutableString = [[NSMutableString alloc] init];
        for (int i = 0; i < [data length]; i++) {
            NSString *newHexStr = [[NSString alloc] initWithFormat:@"%x",bytept[i]&0xff];
            if ([newHexStr length]==1)
            {
                [mutableString appendFormat:@"0%@",newHexStr];
            }
            else
            {
                [mutableString appendFormat:@"%@",newHexStr];
            }
        }
        return mutableString;
    }
}


+ (NSData *)CRCDataWithEncryptedString:(NSString *)encryptedString
{
    encryptedString = encryptedString.uppercaseString;
    unsigned long CRC = crc32(0, (Bytef *)encryptedString.UTF8String, (uInt)encryptedString.length);
    NSMutableData * CRCData = [[NSMutableData alloc] initWithCapacity:0];
    
    Byte * CRCByte = (Byte*)malloc(4);
    CRCByte[0] = CRC >> 24;
    CRCByte[1] = CRC >> 16;
    CRCByte[2] = CRC >> 8;
    CRCByte[3] = CRC;
    
    [CRCData appendBytes:CRCByte length:4];
    free(CRCByte);
    
    /*
     NSString * crcString = [KeplerUtility dataToHexString:CRCData];
     DLog(@"%@", encryptedString.uppercaseString);
     DLog(@"%@", crcString.uppercaseString);
     */
    
    return CRCData;
}

+ (NSData *)CRCDataWithEncryptedDataToHexData:(NSData *)encryptedPayLoadData
{
    unsigned long CRC = [encryptedPayLoadData hm_crc32];
    NSMutableData * CRCData = [[NSMutableData alloc] initWithCapacity:0];
    
    Byte * CRCByte = (Byte*)malloc(4);
    CRCByte[0] = CRC >> 24;
    CRCByte[1] = CRC >> 16;
    CRCByte[2] = CRC >> 8;
    CRCByte[3] = CRC;
    
    [CRCData appendBytes:CRCByte length:4];
    free(CRCByte);
    
    /*
     NSString * crcDataString = [KeplerUtility dataToHexString:encryptedPayLoadData];
     NSString * crcString = [KeplerUtility dataToHexString:CRCData];
     DLog(@"%@", crcDataString.uppercaseString);
     DLog(@"%@", crcString.uppercaseString);
     */
    
    return CRCData;
}

+ (int)getRandomNumber:(int)from to:(int)to
{
    return (int)(from + (arc4random() % (to - from + 1))); //+1,result is [from to];
    
}


//将十进制转化为二进制,设置返回NSString 长度
+ (NSString *)decimalTOBinary:(uint16_t)tmpid backLength:(int)length
{
    NSString *a = @"";
    while (tmpid)
    {
        a = [[NSString stringWithFormat:@"%d",tmpid%2] stringByAppendingString:a];
        if (tmpid/2 < 1)
        {
            break;
        }
        tmpid = tmpid/2 ;
    }
    
    if (a.length <= length)
    {
        NSMutableString *b = [[NSMutableString alloc]init];;
        for (int i = 0; i < length - a.length; i++)
        {
            [b appendString:@"0"];
        }
        
        a = [b stringByAppendingString:a];
    }
    
    return a;
    
}

//将十进制转化为十六进制
+ (NSString *)ToHex:(uint16_t)tmpid
{
    NSString *nLetterValue;
    NSString *str =@"";
    uint16_t ttmpig;
    for (int i = 0; i<9; i++) {
        ttmpig=tmpid%16;
        tmpid=tmpid/16;
        switch (ttmpig)
        {
            case 10:
                nLetterValue =@"A";break;
            case 11:
                nLetterValue =@"B";break;
            case 12:
                nLetterValue =@"C";break;
            case 13:
                nLetterValue =@"D";break;
            case 14:
                nLetterValue =@"E";break;
            case 15:
                nLetterValue =@"F";break;
            default:
                nLetterValue = [NSString stringWithFormat:@"%u",ttmpig];
                
        }
        str = [nLetterValue stringByAppendingString:str];
        if (tmpid == 0) {
            break;
        }
        
    }
    return str;
}

//将16进制转化为二进制
+ (NSString *)getBinaryByhex:(NSString *)hex
{
    NSMutableDictionary  *hexDic = [[NSMutableDictionary alloc] initWithCapacity:16];
    
    [hexDic setObject:@"0000" forKey:@"0"];
    
    [hexDic setObject:@"0001" forKey:@"1"];
    
    [hexDic setObject:@"0010" forKey:@"2"];
    
    [hexDic setObject:@"0011" forKey:@"3"];
    
    [hexDic setObject:@"0100" forKey:@"4"];
    
    [hexDic setObject:@"0101" forKey:@"5"];
    
    [hexDic setObject:@"0110" forKey:@"6"];
    
    [hexDic setObject:@"0111" forKey:@"7"];
    
    [hexDic setObject:@"1000" forKey:@"8"];
    
    [hexDic setObject:@"1001" forKey:@"9"];
    
    [hexDic setObject:@"1010" forKey:@"A"];
    
    [hexDic setObject:@"1011" forKey:@"B"];
    
    [hexDic setObject:@"1100" forKey:@"C"];
    
    [hexDic setObject:@"1101" forKey:@"D"];
    
    [hexDic setObject:@"1110" forKey:@"E"];
    
    [hexDic setObject:@"1111" forKey:@"F"];
    
    NSMutableString *binaryString=[[NSMutableString alloc] init];
    
    for (int i=0; i<[hex length]; i++) {
        
        NSRange rage;
        
        rage.length = 1;
        
        rage.location = i;
        
        NSString *key = [hex substringWithRange:rage];
        
        //DLog(@"%@",[NSString stringWithFormat:@"%@",[hexDic objectForKey:key]]);
        
        [binaryString setString:[NSString stringWithFormat:@"%@%@",binaryString,[NSString stringWithFormat:@"%@",[hexDic objectForKey:key]]]];
        
    }
    
    //DLog(@"转化后的二进制为:%@",binaryString);
    
    return binaryString;
    
}


+ (int)data2Int:(NSData *)data start:(int)startIndex
{
    int temp;
    Byte *b=(Byte *)[data bytes];
    temp = (b[startIndex] & 0xff)| (b[startIndex+1] & 0xff) << 8 | (b[startIndex+2] & 0xff) << 16 | (b[startIndex+3] & 0xff) << 24;
    return temp;
}

+ (NSString *)getIPAddress
{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}

+ (NSString*)DataTOjsonString:(id)object
{
    NSString *jsonString = nil;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    if (! jsonData) {
        DLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}

+ (NSDictionary *)periodIntValueToDic:(int)value
{
    if (value == 0) {
        NSMutableDictionary * selectedDic = [[NSMutableDictionary alloc] initWithCapacity:0];
        for (int i = 0; i < 7; i++) {
            [selectedDic setObject:[NSNumber numberWithBool:NO] forKey:[NSString stringWithFormat:@"%d",i]];
        }
        return selectedDic;
    }
    
    int Monday = value & 0x00000001;
    int TuesDay = value >>1 & 0x00000001;
    int WednesDay = value >>2 & 0x00000001;
    int Thursday = value >>3 & 0x00000001;
    int Friday = value >>4 & 0x00000001;
    int Saturday = value >>5 & 0x00000001;
    int Sunday = value >>6 & 0x00000001;
    
    NSMutableDictionary * selectedDic = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    if (Monday == 1) {
        [selectedDic setObject:[NSNumber numberWithBool:YES] forKey:[NSString stringWithFormat:@"%d" ,1]];
    }else{
        [selectedDic setObject:[NSNumber numberWithBool:NO] forKey:[NSString stringWithFormat:@"%d",1]];
    }
    
    if (TuesDay == 1) {
        [selectedDic setObject:[NSNumber numberWithBool:YES] forKey:[NSString stringWithFormat:@"%d",2]];
    }else{
        [selectedDic setObject:[NSNumber numberWithBool:NO] forKey:[NSString stringWithFormat:@"%d",2]];
    }
    
    if (WednesDay == 1) {
        [selectedDic setObject:[NSNumber numberWithBool:YES] forKey:[NSString stringWithFormat:@"%d",3]];
    }else{
        [selectedDic setObject:[NSNumber numberWithBool:NO] forKey:[NSString stringWithFormat:@"%d",3]];
    }
    
    if (Thursday == 1) {
        [selectedDic setObject:[NSNumber numberWithBool:YES] forKey:[NSString stringWithFormat:@"%d",4]];
    }else{
        [selectedDic setObject:[NSNumber numberWithBool:NO] forKey:[NSString stringWithFormat:@"%d",4]];
    }
    
    if (Friday == 1) {
        [selectedDic setObject:[NSNumber numberWithBool:YES] forKey:[NSString stringWithFormat:@"%d", 5]];
    }else{
        [selectedDic setObject:[NSNumber numberWithBool:NO] forKey:[NSString stringWithFormat:@"%d", 5]];
    }
    
    if (Saturday == 1) {
        [selectedDic setObject:[NSNumber numberWithBool:YES] forKey:[NSString stringWithFormat:@"%d", 6]];
    }else{
        [selectedDic setObject:[NSNumber numberWithBool:NO] forKey:[NSString stringWithFormat:@"%d", 6]];
    }
    
    if (Sunday == 1) {
        [selectedDic setObject:[NSNumber numberWithBool:YES] forKey:[NSString stringWithFormat:@"%d", 0]];
    }else{
        [selectedDic setObject:[NSNumber numberWithBool:NO] forKey:[NSString stringWithFormat:@"%d", 0]];
    }
    
    return selectedDic;
}

+ (int)periodDicToIntValue:(NSDictionary *)valueDic
{
    int value = 128;
    
    /**
     *
     一个字节有8位，
     最高位为0的时候表示执行周期为单次；
     最高位为1的时候，
     从低位到高位的前7位分别表示星期一到星期天的有效位。
     1表示有效、0表示无效
     */
    for (int i = 0; i < 7; i++) {
        NSNumber * boolNumber = [valueDic objectForKey:[NSString stringWithFormat:@"%d", i]];
        if ([boolNumber boolValue]) {
            switch (i) {
                case 0:
                {
                    value += 64;
                    break;
                }
                case 1:
                {
                    value += 1;
                    break;
                }
                case 2:
                {
                    value += 2;
                    break;
                }
                case 3:
                {
                    value += 4;
                    break;
                }
                case 4:
                {
                    value += 8;
                    break;
                }
                case 5:
                {
                    value += 16;
                    break;
                }
                case 6:
                {
                    value += 32;
                    break;
                }
                    
                default:
                    break;
            }
        }
    }
    if (value == 128) {
        return 0;
    }
    return value;
    
}

+ (int)stringByteLength:(NSString*)strtemp
{
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSData* da = [strtemp dataUsingEncoding:enc];
    return (int)[da length];
}

+ (NSString *)getStringByLimitByte:(int)byteLen string:(NSString *)string
{
    NSMutableString *result = [NSMutableString stringWithCapacity:0];
    int len = 0;
    for (int i = 0; i < [string length]; i++) {
        unichar c = [string characterAtIndex:i];
        
        if (0x4e00 < c  && c < 0x9fff) {
            len += 3;
            DLog(@"%d",len);
            if (len > byteLen) {
                return result;
            }
            [result appendFormat:@"%C", c];
            
        }else{
            len++;
            DLog(@"%d",len);
            if (len > byteLen) {
                return result;
            }
            [result appendFormat:@"%C", c];
            
        }
    }
    return result;
}

+(BOOL)isIncludeSpecialCharact: (NSString *)str
{
    //去掉表情符号
    const char *name = [str UTF8String];
    //    DLog(@"0 = %c\n1 = %c\n2 = %c\n3 = %c\n",name[0],name[1],name[2],name[3]);
    
    /**
     strstr() 函数搜索一个字符串在另一个字符串中的第一次出现。
     找到所搜索的字符串，则该函数返回第一次匹配的字符串的地址；
     如果未找到所搜索的字符串，则返回NULL。
     */
    if (strstr(name, "\xf0") != NULL ) {
        return YES;
    }
    //需要过滤的特殊字符
    
    return NO;
#if 0
    NSRange urgentRange = [str rangeOfCharacterFromSet: [NSCharacterSet characterSetWithCharactersInString: @" ~￥#&*<>《》\()[]{}【】^@/￡¤￥|§¨「」『』￠￢￣~@#￥&*（）—+|《》$€,.?？·`!:：、，-;；—。%+'‘’“/”\"Ω≈ç√∫µ≤=≥÷æ…¬˚∆˙©ƒ∂ßåœ∑®†¥øπ“‘«≠–ºª•¶§∞¢£™¡🈳"]];
    /**
     *  下划线不算特殊字符
     *
     
     NSRange urgentRange = [str rangeOfCharacterFromSet: [NSCharacterSet characterSetWithCharactersInString: @" ~￥#&*<>《》\()[]{}【】^@/￡¤￥|§¨「」『』￠￢￣~@#￥&*（）—+|《》$_€,.?？·`!:：、，-;；—。%+'‘’“/”\"Ω≈ç√∫µ≤=≥÷æ…¬˚∆˙©ƒ∂ßåœ∑®†¥øπ“‘«≠–ºª•¶§∞¢£™¡🈳"]];
     */
    if (urgentRange.location == NSNotFound)
    {
        return NO;
    }
    else {
        return YES;
    }
#endif
}

+ (BOOL)isSwitchType:(KDeviceType)type
{
    if (type == KDeviceTypeDimmerLight || type== KDeviceTypeOrdinaryLight || type== KDeviceTypeSocket || type== KDeviceTypeDimmerLight || type== KDeviceTypeSwitchedElectricRelay || type == KDeviceTypeSingleFireSwitch) {
        return YES;
    }
    return NO;
}

+ (BOOL)isInfraredDevice:(KDeviceType)type
{
    if (type == KDeviceTypeTV || type== KDeviceTypeAirconditioner || type== KDeviceTypeSTB || type== KDeviceTypeCustomerInfrared) {
        return YES;
    }
    return NO;
}

+ (BOOL)isOldControlboxDevice:(KDeviceType)type
{
    if (type == KDeviceTypeScreen || type== KDeviceTypeCurtain || type== KDeviceTypeBlinds) {
        return YES;
    }
    return NO;
}

+ (BOOL)isNewControlboxDevice:(KDeviceType)type
{
    if (type == KDeviceTypeCasement || type== KDeviceTypeRoller  || type== KDeviceTypeAwningWindow) {
        return YES;
    }
    return NO;
}

/**
 判断是否为 红外设备
 */
+ (BOOL)isRFDevice:(id <SceneEditProtocol>)sbind {
    
    HMDevice * device = [HMDevice objectWithDeviceId:sbind.deviceId uid:nil];
    if (!AlloneProModelId(device.model) && !Allone2ModelId(device.model)) {
        return NO;
    } else {
        if (sbind.deviceType == KDeviceTypeAirconditioner ||
            sbind.deviceType == KDeviceTypeTV ||
            sbind.deviceType == KDeviceTypeSound ||
            sbind.deviceType == KDeviceTypeSTB ||
            sbind.deviceType == KDeviceTypeCustomerInfrared ||
            sbind.deviceType == KDeviceTypeFan ||
            sbind.deviceType == KDeviceTypeTVBox ||
            sbind.deviceType == KDeviceTypeProjector ||
            sbind.deviceType == KDeviceTypeRemoteLight) {
            return YES;
        } else {
            return NO;
        }
    }
}

/**
 根据宽度，截取
 */
+ (NSString *)cutMusicsArrayString:(NSString *)musicString plusData:(NSString *)pluseData withWidth:(CGFloat)width {

    if (!musicString || !musicString.length || !pluseData || !pluseData.length) {
        return @"";
    }
    NSString *numString = @"";
    NSArray *array = @[];
    
    NSDictionary *plusDic = [NSJSONSerialization JSONObjectWithData:[pluseData dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    DLog(@"HMSceneChoiceMusicViewController -- %@",plusDic);
    
    if ([plusDic isKindOfClass:[NSDictionary class]] && plusDic[@"playList"]) { // 新app数据有playList
        if ([plusDic[@"playList"] respondsToSelector:@selector(dataUsingEncoding:)]) {
            array = [NSJSONSerialization JSONObjectWithData:[plusDic[@"playList"] dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];

        }else {
            array = plusDic[@"playList"];
        }
    }else if ([plusDic isKindOfClass:[NSArray class]]) {
        
        DLog(@"是数组");
        array = (NSArray *)plusDic;
        
    }else {
        // 表示旧数据
        array = [NSJSONSerialization JSONObjectWithData:[pluseData dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    }
    
    if (array.count > 1) {
        numString = [NSString stringWithFormat:@"(%ld)", (unsigned long)array.count];
        CGSize numStringSize = [numString sizeWithAttributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:14] }];
        width = width - numStringSize.width;
    }

    CGSize musicStringSize = [musicString sizeWithAttributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:14] }];

    if (musicStringSize.width > width) {    // 如果
        [musicString drawInRect:CGRectMake(0, 0, width, musicStringSize.height) withAttributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:14] }];
    }
    BOOL isCuted = NO;
    while (musicStringSize.width > width) {
        isCuted = YES;
        musicString = [musicString substringToIndex:musicString.length - 2];
        musicStringSize = [musicString sizeWithAttributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:14] }];
    }

    if (isCuted) {
        musicString = [NSString stringWithFormat:@"%@...%@",musicString, numString];
    } else if (numString.length > 0) {
        musicString = [NSString stringWithFormat:@"%@ %@",musicString, numString];
    }

    DLog(@"处理后的musicString： %@", musicString);
    return musicString;
}


+ (UIColor *)colorWithHexString:(NSString *)color alpha:(CGFloat)alpha
{
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) {
        return [UIColor clearColor];
    }
    
    // 判断前缀并剪切掉
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return [UIColor clearColor];
    
    // 从六位数值中找到RGB对应的位数并转换
    NSRange range;
    range.location = 0;
    range.length = 2;
    
    //R、G、B
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:alpha];
}

/**
 十进制转换为二进制
 
 @param decimal 十进制数
 @return 二进制数
 */
+ (NSString *)getSixteenBitBinaryByDecimal:(NSInteger)decimal {
    
    return [self getBinaryOfAnyBit:16 byDecimal:decimal];
}

+ (NSString *)getBinaryOfAnyBit:(NSUInteger)numberBit byDecimal:(NSInteger)decimal {
    NSString *binary = @"";
    while (decimal) {
        
        binary = [[NSString stringWithFormat:@"%ld", (long)decimal % 2] stringByAppendingString:binary];
        if (decimal / 2 < 1) {
            
            break;
        }
        decimal = decimal / 2 ;
    }
    if (binary.length % 4 != 0) {
        
        NSMutableString *mStr = [[NSMutableString alloc]init];;
        for (int i = 0; i < 4 - binary.length % 4; i++) {
            
            [mStr appendString:@"0"];
        }
        binary = [mStr stringByAppendingString:binary];
    }
    
    // 不足，前面补0
    if (binary.length < numberBit) {
        NSMutableString *mStr = [[NSMutableString alloc]init];;
        for (int i = 0; i < numberBit - binary.length; i++) {
            
            [mStr appendString:@"0"];
        }
        binary = [mStr stringByAppendingString:binary];
    }
    return binary;
    
}

/**
 二进制转换为十进制
 
 @param binary 二进制数
 @return 十进制数
 */
+ (NSInteger)getDecimalByBinary:(NSString *)binary {
    
    NSInteger decimal = 0;
    for (int i=0; i<binary.length; i++) {
        
        NSString *number = [binary substringWithRange:NSMakeRange(binary.length - i - 1, 1)];
        if ([number isEqualToString:@"1"]) {
            
            decimal += pow(2, i);
        }
    }
    return decimal;
}

+ (NSDictionary*)getDicObjectData:(id)obj

{
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    unsigned int propsCount;
    
    objc_property_t *props = class_copyPropertyList([obj class], &propsCount);//获得属性列表
    
    for(int i = 0;i < propsCount; i++)
        
    {
        
        objc_property_t prop = props[i];
        
        
        
        NSString *propName = [NSString stringWithUTF8String:property_getName(prop)];//获得属性的名称
        
        id value = [obj valueForKey:propName];//kvc读值
        
        if(value == nil)
            
        {
            
            value = [NSNull null];
            
        }
        
        else
            
        {
            
            value = [self getObjectInternal:value];//自定义处理数组，字典，其他类
            
        }
        
        [dic setObject:value forKey:propName];
        
    }
    
    return dic;
    
}


+ (id)getObjectInternal:(id)obj

{
    
    if([obj isKindOfClass:[NSString class]]
       
       || [obj isKindOfClass:[NSNumber class]]
       
       || [obj isKindOfClass:[NSNull class]])
        
    {
        
        return obj;
        
    }
    
    
    
    if([obj isKindOfClass:[NSArray class]])
        
    {
        
        NSArray *objarr = obj;
        
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:objarr.count];
        
        for(int i = 0;i < objarr.count; i++)
            
        {
            
            [arr setObject:[self getObjectInternal:[objarr objectAtIndex:i]] atIndexedSubscript:i];
            
        }
        
        return arr;
        
    }
    
    
    
    if([obj isKindOfClass:[NSDictionary class]])
        
    {
        
        NSDictionary *objdic = obj;
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:[objdic count]];
        
        for(NSString *key in objdic.allKeys)
            
        {
            
            [dic setObject:[self getObjectInternal:[objdic objectForKey:key]] forKey:key];
            
        }
        
        return dic;
        
    }
    
    return [self getDicObjectData:obj];
    
}

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        DLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}



+ (BOOL)isC1LockOnline:(HMDeviceStatus *)status {
    BOOL online = YES;
    if (status.updateTimeSec > 0) {
        online = [[NSDate date] timeIntervalSince1970] - status.updateTimeSec <= 12 * 60 * 60;//门锁离线是否 按状态表的更新时间跟当前时间 查 是否是 12小时
    }else {
        online = [[NSDate date] timeIntervalSince1970] - [dateWithString(status.updateTime) timeIntervalSince1970] <= 12 * 60 * 60;//门锁离线是否 按状态表的更新时间跟当前时间 查 是否是 12小时
    }
    
    return online;
    
}

@end
