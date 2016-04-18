//
//  AlertMessage.m
//  BlueTooth
//
//  Created by caiyue on 15/11/29.
//  Copyright © 2015年 soufun. All rights reserved.
//

#import "AlertMessage.h"
#import <UIKit/UIKit.h>

@implementation AlertMessage

+ (void)alert:(NSString *)string{
    
    UIAlertView *alertView = [[UIAlertView alloc]  initWithTitle:@"通知" message:string delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    
    [alertView show];
}

@end
