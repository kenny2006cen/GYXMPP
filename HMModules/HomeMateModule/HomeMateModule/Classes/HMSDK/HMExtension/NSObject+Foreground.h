//
//  NSObject+Foreground.h
//  Vihome
//
//  Created by Air on 15/5/19.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSObject (Foreground)

-(void)hm_startNotifierForeground:(SEL)foreground;
-(void)hm_startNotifierBackground:(SEL)background;
-(void)hm_startNotifierForeground:(SEL)foreground background:(SEL)background;

-(void)hm_stopForegroundNotifier;
-(void)hm_stopBackgroundNotifier;
-(void)hm_stopForegroundBackgroundNotifier;

@end
