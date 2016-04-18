//
//  BlueToothManager.h
//  BlueTooth
//
//  Created by caiyue on 15/11/14.
//  Copyright © 2015年 soufun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

extern NSString    *kWriteToDeviceSuccessfulNotification ;

#define kPeripheralName     @"360qws Electric Bike Service" //外围设备名称
#define kServiceUUID        @"FFF0" //服务的UUID
#define kCharacteristicUUID @"FFF1" //特征的UUID
#define kCharacteristicUUID_KEYBOARD @"FFF2" //特征的UUID，键盘状态，6个键盘


#define kFindNewBlueToothDevice @"FindNewBlueToothDevice"
#define kConnectedBlueToothDevice   @"ConnectedBlueToothDevice"
#define kDisconnectBlueToothDevice  @"DisconnectBlueToothDevice"


#define kLIGHT_NUMBER   @"lightNumber"
#define kLIGHT_VALUE    @"lightValue"


#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

#define TB_WIDTH    100
#define TB_HEIGHT   [UIScreen mainScreen].bounds.size.width

#define TB_Y_OFFSET 50

@interface BlueToothManager : NSObject

@property   (nonatomic,strong)  CBCentralManager    *manager;
+ (instancetype)shareInstance;
- (void)startScan;
- (void)stopScan;

- (void)connectDevice:(CBPeripheral   *)device;
- (void)disconnectDevice:(CBPeripheral *)device;

- (CBCharacteristic *)characterForUUID:(NSString *)UUID;
- (void)writeValue:(NSData *)data forCBCharacteristic:(CBCharacteristic *)character ToPeripheral:(CBPeripheral *)peripheral;
- (NSData *)readValueForCBCharacteristic:(CBCharacteristic *)character ToPeripheral:(CBPeripheral *)peripheral;
- (NSUInteger)MaxdataLengthDataToPeripheral:(CBPeripheral *)peripheral withType:(CBCharacteristicWriteType)type;
@end
