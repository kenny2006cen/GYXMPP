//
//  HmTimeOutManager.m
//  HomeMate
//
//  Created by Orvibo on 15/8/19.
//  Copyright © 2017年 Orvibo. All rights reserved.
//

#import "HMDeviceConfigTimeOutManager.h"

static HMDeviceConfigTimeOutManager * manager = nil;

@interface HMDeviceConfigTimeOutManager ()
@property (nonatomic, strong) NSCondition* signal;
@property (nonatomic, strong) NSThread* monitorThread;
@property (nonatomic, strong) NSMutableArray* sipMsgList;
@end


@implementation HMDeviceConfigTimeOutManager
+ (HMDeviceConfigTimeOutManager *)getTimeOutManager {
    @synchronized(self)
    {
        if (manager == nil)
        {
            manager = [[self alloc] init];
            manager.sipMsgList = [NSMutableArray array];
        }
    }
    
    return manager;
}

+(id)allocWithZone:(NSZone *)zone
{
    @synchronized(self)
    {
        if (manager == nil)
        {
            manager = [super allocWithZone:zone];
            return manager;
        }
    }
    
    return nil;
}

- (void)addVhAPConfigMsg:(HMAPConfigMsg *)msg {
    [self makesureMonitorThreadRun];
    
    // 开始时间戳
    [msg startTimeout];//.startTimestamp = [NSDate date];
    
    // 新增监视点
    [self.signal lock];
    [self.sipMsgList addObject:msg];
    [self.signal signal];
    [self.signal unlock];
}


-(NSTimeInterval)removeMsg:(HMAPConfigMsg *)sipMsg
{
    // 移除该监视点 并计算响应时间
    NSTimeInterval responseTime = -1;
    [self.signal lock];
    if (sipMsg != NULL && [self.sipMsgList containsObject:sipMsg])
    {
        NSDate* now = [NSDate date];
        responseTime = [now timeIntervalSinceDate:[sipMsg getStartTime]];
        [self.sipMsgList removeObject:sipMsg];
    }
    [self.signal signal];
    [self.signal unlock];
    return responseTime;
}


-(void)makesureMonitorThreadRun
{
    if (self.monitorThread == nil)
    {
        // init
        _signal =  [[NSCondition alloc] init];
        _sipMsgList = [[NSMutableArray alloc] init];
        
        // thread
        _monitorThread = [[NSThread alloc] initWithTarget:self selector:@selector(monitorWithParam:) object:nil];
        [self.monitorThread start];
    }
    
    return;
}

// 处理监视任务的线程入口
-(void)monitorWithParam:(id)param
{
    do
    {
        @autoreleasepool
        {
            for (int i = 0; i < 3; i++)
            {
                NSArray* itemList = nil;
                
                [self.signal lock];
                if ([self.sipMsgList count] > 0)
                {
                    itemList = [NSArray arrayWithArray:self.sipMsgList];
                }
                [self.signal unlock];
                
                // 巡检
                if (itemList != nil
                    && [itemList count] > 0)
                {
                    [self monitorWithSipMsgList:itemList];
                }
                
                // sleep 5 secondes
                [NSThread sleepForTimeInterval:5];
            }
        }
        
    } while (YES);
    
    return;
}
-(void)monitorWithSipMsgList:(NSArray*)sipMsgList
{
    for (id msg in sipMsgList)
    {
        NSDate* now = [NSDate date];
        NSTimeInterval timeInterval = [now timeIntervalSinceDate:[msg getStartTime]];
        NSInteger timeoutTime = [msg getTimeoutTime];
        
        if (timeInterval > timeoutTime)
        {
            
            [self performSelectorOnMainThread:@selector(performTimeoutOnMainThreadWithSipMsg:) withObject:msg waitUntilDone:NO];
            
            [self  removeMsg:msg];
        }
    }
    
    return;
}

// 在主线程执行超时回调动作
-(void)performTimeoutOnMainThreadWithSipMsg:(HMAPConfigMsg *)msg
{

    [msg doTimeout];
    return;
}


-(void)removAllMsg
{
    [self.signal lock];
    [self.sipMsgList removeAllObjects];
    [self.signal signal];
    [self.signal unlock];
}
@end
