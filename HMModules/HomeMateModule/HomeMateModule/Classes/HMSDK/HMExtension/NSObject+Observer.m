//
//  NSObject+Observer.m
//  Vihome
//
//  Created by Air on 15/7/21.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "NSObject+Observer.h"

@implementation NSObject (Observer)

-(void)hm_removeAllObserver
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
- (void)hm_removeNotification:(NSString *)aName object:(id)anObject
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:aName object:anObject];
}
- (void)hm_addNotification:(NSString *)aName selector:(SEL)aSelector object:(id)anObject
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:aName object:anObject];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:aSelector name:aName object:anObject];
}

@end
