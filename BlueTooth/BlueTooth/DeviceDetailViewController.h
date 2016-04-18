//
//  DeviceDetailViewController.h
//  BlueTooth
//
//  Created by caiyue on 15/11/14.
//  Copyright © 2015年 soufun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface DeviceDetailViewController : UIViewController

@property   (nonatomic,strong)  CBPeripheral    *device;
@end
