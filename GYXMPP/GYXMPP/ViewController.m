//
//  ViewController.m
//  GYXMPP
//
//  Created by jianglincen on 16/6/4.
//  Copyright © 2016年 jianglincen. All rights reserved.
//

#import "ViewController.h"
#import "GYXMPP.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.title = @"登录";
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    
    [button setFrame:CGRectMake(100, 200, 100, 100)];
    
    [button setTitle:@"登录" forState:UIControlStateNormal];
    
    [button addTarget:self action:@selector(loginAction) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:button];
}

-(void)loginAction{

    [[GYXMPP sharedInstance]xmppUserLogin:^(XMPPResultType type) {
        
        if (type==XMPPResultTypeLoginSuccess) {
            
            NSLog(@"登陆成功");
            
            
        }
        
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
