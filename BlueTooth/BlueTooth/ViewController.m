//
//  ViewController.m
//  BlueTooth
//
//  Created by caiyue on 15/11/9.
//  Copyright © 2015年 soufun. All rights reserved.
//

#import "ViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "DeviceDetailViewController.h"
#import "BlueToothManager.h"
#import "PhotoIntervalSettingViewController.h"


@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>
- (IBAction)startSearchDevice:(UIBarButtonItem *)sender;

- (IBAction)stopSearchDevice:(UIBarButtonItem *)sender;

@property   (strong, nonatomic) IBOutlet UITableView *tableView;
@property   (nonatomic,strong)  NSMutableArray  *deviceArray;




@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
    
    
    self.deviceArray = [NSMutableArray array];
//    [self.deviceArray addObject:[CBPeripheral new]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(findDevice:) name:kFindNewBlueToothDevice object:nil];
}

- (void)findDevice:(NSNotification *) noti
{
    [self.deviceArray addObject:noti.object];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//开始搜索设备
- (IBAction)startSearchDevice:(UIBarButtonItem *)sender {
    
    [[BlueToothManager shareInstance] startScan];
}

- (IBAction)stopSearchDevice:(UIButton *)sender {
    
    [[BlueToothManager shareInstance] stopScan];
}


////开始查看服务，蓝牙开启
//-(void)centralManagerDidUpdateState:(CBCentralManager *)central
//{
//    switch (central.state) {
//        case CBCentralManagerStatePoweredOn:
//        {
//            [self updateLog:@"蓝牙已打开,请扫描外设"];
//            [manager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:kServiceUUID]]  options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
//        }
//            break;
//        case CBCentralManagerStatePoweredOff:
//            [self updateLog:@"蓝牙没有打开,请先打开蓝牙"];
//            break;
//            
//            case CBCentralManagerStateUnsupported:
//            [self updateLog:@"设备不支持BLE"];
//            break;
//        default:
//            break;
//    }
//}

////查到外设后，停止扫描，连接设备
//-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
//{
////    [self updateLog:[NSString stringWithFormat:@"已发现 peripheral: %@ rssi: %@, UUID: %@ advertisementData: %@ ", peripheral, RSSI, peripheral.identifier, advertisementData]];
////
////    _peripheral = peripheral;
////    [_manager connectPeripheral:_peripheral options:nil];
////
//    
////    if ([self.deviceArray containsObject:peripheral] || ) {
////        <#statements#>
////    }
//    
//    [self.deviceArray addObject:peripheral];
//    
//    [self.tableView reloadData];
//    
//    [manager stopScan];
//}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    
    CBPeripheral    *device = [self.deviceArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"name:%@,rssi:%@,state:%ld,deviceId:%@,deviceServices:%@",device.name,[device.RSSI stringValue],(long)device.state,[device.identifier UUIDString],device.services];
    
    return cell;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.deviceArray.count;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    
//    PhotoIntervalSettingViewController *s =  [[UIStoryboard  storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"timeIntervalSetting"];
//    
//    [self.navigationController pushViewController:s animated:YES];
    
    
//    timeIntervalSetting
//    [self  performSegueWithIdentifier:@"timeIntervalSetting" sender:nil];
    
    [self performSegueWithIdentifier:@"pushDetailDevice" sender:[self.deviceArray  objectAtIndex:indexPath.row]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    

    CBPeripheral    *device  = sender;
    DeviceDetailViewController  *detailVC = segue.destinationViewController;
    detailVC.title = device.name;
    detailVC.device = device;
}


@end
