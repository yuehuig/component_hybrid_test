//
//  SQViewController.m
//  SQHYBRID
//
//  Created by 475993847@qq.com on 04/19/2021.
//  Copyright (c) 2021 475993847@qq.com. All rights reserved.
//

#import "SQViewController.h"
#import <SQWeChat/SQWeChat.h>
@import SQHYBRID;
//#import "SQHYBRID-Swift.h"

@interface SQViewController ()

@end

@implementation SQViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [SQWeChat isWXAppInstalled];
    Person *p = [[Person alloc] init];
    p.name = @"xx";
    NSLog(@"%@---%@",p.name, p.age);
    
    People *pp = [[People alloc] init];
    pp.nickName = @"小明";
    [pp run];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
