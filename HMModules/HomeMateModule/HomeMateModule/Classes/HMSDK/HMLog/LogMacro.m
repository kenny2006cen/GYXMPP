//
//  LogMacro.c
//
//  Created by Alic on 14-6-24.
//  Copyright (c) 2014年 Alic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HMTypes.h"
#import "HMConstant.h"
#import "HMStorage.h"

@interface HMLog : NSObject

@property (retain, nonatomic) NSString *path;
@property (assign, nonatomic) NSUInteger loglines;
@property (assign, nonatomic) HMEnvironmentOptions environment;

+(void)printLog:(NSString *)string;

@end

@implementation HMLog

#pragma mark - 模板，需要子类自己实现
+ (id)shareInstance
{
    static HMLog *__singletion__;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        __singletion__ = [[[self class]alloc]init];
        
        HMEnvironmentOptions logEnv = [HMSDK SDKEnvironment];
        [__singletion__ setEnvironment:logEnv];
        if (![HMLog isDebug:logEnv]){
            [__singletion__ resetPath];
        }
        
    });
    
    return __singletion__;
}

-(void)resetPath
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
    NSString *logFileName = [formatter stringFromDate:[NSDate date]];
    
    NSString *directory= [NSHomeDirectory() stringByAppendingString:@"/Documents"];
    self.path = [NSString stringWithFormat:@"%@/%@.txt",directory,logFileName];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:self.path]) {
        [fm createFileAtPath:self.path contents:nil attributes:nil];
    }
    freopen([self.path cStringUsingEncoding:NSASCIIStringEncoding], "a+", stdout);
}

+(BOOL)isDebug:(HMEnvironmentOptions)logEnv{
    return ((logEnv == HMEnvironmentDebug) || (logEnv == HMEnvironmentDebug2) || (logEnv == HMEnvironmentDebug3));
}
+(void)printLog:(NSString *)logString
{
    HMLog *log =[HMLog shareInstance];
    
    // Debug状态时，日志打印到控制台，其他情况下，日志都打印到日志文件
    if ([HMLog isDebug:log.environment]) {
        printf("%s\n",[logString UTF8String]);
        //CFShow(debug0);
    }else{
 
        // 一个log文件打印50000行log
        if (++log.loglines % 50000 == 0) {
            [log resetPath];
        }
        
        // Adhoc状态时打印明文，其他状态都打印密文
        BOOL isAdhocEnv  = (log.environment == HMEnvironmentAdhoc);
        NSString *newOutstring = isAdhocEnv?logString:encryptTheString(logString);
        printf("%s\n",[newOutstring UTF8String]);
        freopen([log.path cStringUsingEncoding:NSASCIIStringEncoding], "a+", stdout);
    }
}

@end



void myLevelLog(int line,char *functname,char *file,LOG_LEVEL level, id formatstring,...)
{
    if (![HMStorage shareInstance].enableLog) {
        return;
    }
    if (level >= LEVEL_ALL) {
        
        if (!formatstring) return;
        
        @autoreleasepool {
            
            va_list arglist;
            va_start(arglist, formatstring);
            id outstring = [[NSString alloc]initWithFormat:formatstring arguments:arglist];
            va_end(arglist);
            
            NSString *fileName = [[NSString stringWithUTF8String:file]lastPathComponent];
            NSString *logString = [NSString stringWithFormat:@"[%@][%@-->%d行]:%@",getCurrentTime(@"yyyy/MM/dd HH:mm:ss:SSS"),fileName,line,outstring];
            [HMLog printLog:logString];
        }
    }
}


