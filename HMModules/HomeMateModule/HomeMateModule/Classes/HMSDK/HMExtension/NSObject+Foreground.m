//
//  NSObject+Foreground.m
//  Vihome
//
//  Created by Air on 15/5/19.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "NSObject+Foreground.h"

@implementation NSObject (Foreground)

-(void)hm_startNotifierForeground:(SEL)foreground
{
    [self hm_startNotifierForeground:foreground background:NULL];
}
-(void)hm_startNotifierBackground:(SEL)background
{
    [self hm_startNotifierForeground:NULL background:background];
}
-(void)hm_startNotifierForeground:(SEL)foreground background:(SEL)background
{
    // 为防止监听多次，要先取消监听再添加
    [self hm_stopForegroundBackgroundNotifier];
    
    if (foreground) {
        
        [[NSNotificationCenter defaultCenter]addObserver:self
                                                selector:foreground
                                                    name:UIApplicationWillEnterForegroundNotification//UIApplicationDidBecomeActiveNotification
                                                  object:nil];
    }
    
    if (background) {
        
        [[NSNotificationCenter defaultCenter]addObserver:self
                                                selector:background
                                                    name:UIApplicationDidEnterBackgroundNotification//UIApplicationWillResignActiveNotification
                                                  object:nil];
    }
    
}

-(void)hm_stopForegroundNotifier
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
}
-(void)hm_stopBackgroundNotifier
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillResignActiveNotification
                                                  object:nil];
}
-(void)hm_stopForegroundBackgroundNotifier
{
    [self hm_stopForegroundNotifier];
    [self hm_stopBackgroundNotifier];
}

@end
