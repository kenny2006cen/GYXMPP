//
//  HMTaskDistribution.h
//
//  Created by Alic on 18/10/18.
//  Copyright © 2018 Alic. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef BOOL(^HMTaskDistributionUnit)(void);

@interface HMTaskDistribution : NSObject

@property (nonatomic, assign) NSUInteger maximumQueueLength;

+ (instancetype)sharedInstance;

- (void)addTask:(HMTaskDistributionUnit)unit;

- (void)removeAllTasks;

@end
