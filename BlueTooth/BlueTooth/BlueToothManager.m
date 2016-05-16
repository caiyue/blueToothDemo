//
//  BlueToothManager.m
//  BlueTooth
//
//  Created by caiyue on 15/11/14.
//  Copyright © 2015年 soufun. All rights reserved.
//

#import "BlueToothManager.h"


NSString    *kWriteToDeviceSuccessfulNotification   = @"kWriteToDeviceSuccessfulNotification";

@interface BlueToothManager()<CBCentralManagerDelegate,CBPeripheralDelegate>

@property   (nonatomic,strong)  NSMutableArray  *deviceArray;
@property   (nonatomic,strong)  NSMutableDictionary  *characterDict;
@end

@implementation BlueToothManager

char  *global_light_data;
static BlueToothManager  *singleton = nil;
+ (instancetype)shareInstance{
    
    static  dispatch_once_t once;
    
    dispatch_once(&once, ^{
        
        singleton = [[self alloc] init];
        __weak typeof(singleton)obj = singleton;
        singleton.manager = [[CBCentralManager   alloc] initWithDelegate:obj queue:nil];
        singleton.deviceArray = [NSMutableArray array];
        singleton.characterDict = [NSMutableDictionary dictionary];
       
        global_light_data = malloc(sizeof(char) * 8);
        memset(global_light_data, 0, 8);
    });
    
    return singleton;
}



//开始查看服务，蓝牙开启
-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
        {
            [self updateLog:@"蓝牙已打开,请扫描外设"];
            [self startScan];
        }
            break;
        case CBCentralManagerStatePoweredOff:
            [self updateLog:@"蓝牙没有打开,请先打开蓝牙"];
            break;
            
        case CBCentralManagerStateUnsupported:
            [self updateLog:@"设备不支持BLE"];
            break;
        default:
            break;
    }
}

- (void)startScan
{
    [self.manager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:kServiceUUID]]  options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
}

-(void)stopScan{
    
    [self.manager stopScan];
}


//查到外设后，停止扫描，连接设备
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    
    if ([self.deviceArray containsObject:peripheral]) {
        
        return;
    }else
    {
        [self updateLog:[NSString stringWithFormat:@"已发现 peripheral: %@ rssi: %@, UUID: %@ advertisementData: %@ ", peripheral, RSSI, peripheral.identifier, advertisementData]];
         [self.deviceArray addObject:peripheral];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kFindNewBlueToothDevice object:peripheral];
    }

}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
     [self updateLog:[NSString stringWithFormat:@"连接失败：name:%@,error:%@",peripheral.name,error]];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    [self updateLog:[NSString stringWithFormat:@"成功链接：name:%@",peripheral.name]];
    [[NSNotificationCenter defaultCenter] postNotificationName:kConnectedBlueToothDevice object:nil];
    
    peripheral.delegate = self;
    [peripheral discoverServices:@[[CBUUID UUIDWithString:kServiceUUID]]];
}



- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error{
    
     [self updateLog:[NSString stringWithFormat:@"成功断开链接：name:%@",peripheral.name]];
    [[NSNotificationCenter defaultCenter] postNotificationName:kDisconnectBlueToothDevice object:nil];
}


- (void)connectDevice:(CBPeripheral   *)device
{
    
    [self.manager connectPeripheral:device options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey]];
}

- (void)disconnectDevice:(CBPeripheral *)device{
    
    [self.manager cancelPeripheralConnection:device];
}



- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error) {
        NSLog(@"find services:%@",error);
        return;
    }
    else if (peripheral.services.count == 0) {
        NSLog(@"can not find  any services,error:%@",error);
        return;
    }
    
    
    for (CBService *service in peripheral.services) {
        
        if ([[service.UUID UUIDString] isEqualToString:kServiceUUID]) {
            
            NSLog(@"find service:%@",service);
            
            [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:kCharacteristicUUID],[CBUUID UUIDWithString:kCharacteristicUUID_KEYBOARD]] forService:service];
            
        }
    }

}


- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    
    if (error) {
        NSLog(@"can not find any charactor:%@",error);
        return;
    }else{
        
        
        for (CBCharacteristic *charchtor in service.characteristics) {

            if (charchtor.properties == CBCharacteristicPropertyNotify) {
                
                [peripheral setNotifyValue:YES forCharacteristic:charchtor];
                NSLog(@"监听 character :%@",charchtor);
            }
           
            
            NSString    *uuid = charchtor.UUID.UUIDString;
            if (![self.characterDict objectForKey:uuid]) {
                [self.characterDict setObject:charchtor forKey:uuid];
            }
            
        }
    }
}


- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    
    
    if (error) {
        
//        NSLog(@"can not update value for charactor:%@  error:%@",characteristic,error);
        return;
    }else{
        
        
//        NSLog(@"receive Data:%@",characteristic.value);
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    
    if (error) {
//        NSLog(@"can not update Notification for character:%@ error:%@",characteristic,error);
        return;
    }
    
}


- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    
    if (error) {
        
//        NSLog(@"can not write data to character:%@ error:%@",characteristic,error);
        return;
    }else
    {
        
//        NSLog(@"write data to character:%@ successfully",characteristic);
        
        int64_t value = *((int64_t *)global_light_data);
        
        if (value == 0) {
            
            NSLog(@"write 0,Do not take photo");
            return;
        }
        
        usleep(500000);
        [[NSNotificationCenter defaultCenter] postNotificationName:kWriteToDeviceSuccessfulNotification object:@(value).description];
        
    }
    
}


//- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request{
//    
//    NSLog(@"read Request:%@",request);
//}
//
//- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests{
//    
//    NSLog(@"write Request:%@",requests);
//}



- (void)writeValue:(NSData *)data forCBCharacteristic:(CBCharacteristic *)character ToPeripheral:(CBPeripheral *)peripheral{
    
    [peripheral writeValue:data forCharacteristic:character type:CBCharacteristicWriteWithResponse];
}

- (NSData *)readValueForCBCharacteristic:(CBCharacteristic *)character ToPeripheral:(CBPeripheral *)peripheral{
 
    [peripheral readValueForCharacteristic:character];
    return character.value;
}

- (CBCharacteristic *)characterForUUID:(NSString *)UUID{
    
    return [self.characterDict objectForKey:UUID];
}


//- (NSUInteger)MaxdataLengthDataToPeripheral:(CBPeripheral *)peripheral withType:(CBCharacteristicWriteType)type{
//    
//  return  [peripheral maximumWriteValueLengthForType:type];
//}

- (void)updateLog:(NSString *)string
{
    NSLog(@"%@",string);
}



- (void)dealloc
{
    [[NSNotificationCenter defaultCenter ] removeObserver:self];
}


@end
