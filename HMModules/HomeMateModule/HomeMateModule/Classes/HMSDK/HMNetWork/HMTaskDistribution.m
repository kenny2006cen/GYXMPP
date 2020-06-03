//
//  HMTaskDistribution.m
//
//  Created by Alic on 18/10/18.
//  Copyright © 2018 Alic. All rights reserved.
//


#import "HMTaskDistribution.h"
#import <objc/runtime.h>

@interface HMTaskDistribution ()

@property (nonatomic, strong) NSMutableArray *tasks;

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation HMTaskDistribution

- (void)removeAllTasks {
    [self.tasks removeAllObjects];
}

- (void)addTask:(HMTaskDistributionUnit)unit{
    [self.tasks addObject:unit];
    if (self.tasks.count > self.maximumQueueLength) {
        [self.tasks removeObjectAtIndex:0];
    }
}

- (void)_timerFiredMethod:(NSTimer *)timer {
    // We do nothing here
    // 空timer，每间隔0.1s唤醒一次runloop
}

- (instancetype)init
{
    if ((self = [super init])) {
        _maximumQueueLength = 300;
        _tasks = [NSMutableArray array];
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(_timerFiredMethod:) userInfo:nil repeats:YES];
    }
    return self;
    /*
    UITrackingRunLoopMode
    NSDefaultRunLoopMode
    NSRunLoopCommonModes
     */
}

+ (instancetype)sharedInstance {
    static HMTaskDistribution *singleton;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        singleton = [[HMTaskDistribution alloc] init];
        [self registerRunLoopWorkDistributionAsMainRunloopObserver:singleton];
    });
    return singleton;
}

+ (void)registerRunLoopWorkDistributionAsMainRunloopObserver:(HMTaskDistribution *)runLoopWorkDistribution {
    static CFRunLoopObserverRef defaultModeObserver;
    registerRunloopObserver(kCFRunLoopBeforeWaiting, defaultModeObserver, NSIntegerMax - 999, kCFRunLoopDefaultMode, (__bridge void *)runLoopWorkDistribution, &runLoopWorkDistributionCallback);
}

static void registerRunloopObserver(CFOptionFlags activities, CFRunLoopObserverRef observer, CFIndex order, CFStringRef mode, void *info, CFRunLoopObserverCallBack callback) {
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    CFRunLoopObserverContext context = {
        0,
        info,
        &CFRetain,
        &CFRelease,
        NULL
    };
    observer = CFRunLoopObserverCreate(     NULL,
                                            activities,
                                            YES,
                                            order,
                                            callback,
                                            &context);
    CFRunLoopAddObserver(runLoop, observer, mode);
    CFRelease(observer);
}

static void runLoopWorkDistributionCallback(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info)
{
    HMTaskDistribution *runLoopWorkDistribution = (__bridge HMTaskDistribution *)info;
    if (runLoopWorkDistribution.tasks.count == 0) {
        return;
    }
    BOOL result = NO;
    while (result == NO && runLoopWorkDistribution.tasks.count) {
        HMTaskDistributionUnit unit  = runLoopWorkDistribution.tasks.firstObject;
        result = unit();
        [runLoopWorkDistribution.tasks removeObjectAtIndex:0];
    }
}


@end

