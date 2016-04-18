//
//  DeviceDetailViewController.m
//  BlueTooth
//
//  Created by caiyue on 15/11/14.
//  Copyright © 2015年 soufun. All rights reserved.
//

#import "DeviceDetailViewController.h"
#import "BlueToothManager.h"
#import "TakePhotosViewController.h"
#import "AlertMessage.h"


extern char *global_light_data;

@interface DeviceDetailViewController ()
- (IBAction)disconnectDevice:(UIBarButtonItem *)sender;
- (IBAction)connectDevice:(UIBarButtonItem *)sender;
- (IBAction)writeData:(UIButton *)sender;
- (IBAction)readData:(UIButton *)sender;

//光源控制
- (IBAction)light1:(UISlider *)sender;
- (IBAction)light2:(UISlider *)sender;
- (IBAction)light3:(UISlider *)sender;
- (IBAction)light4:(UISlider *)sender;
- (IBAction)light5:(UISlider *)sender;
- (IBAction)light6:(UISlider *)sender;

- (IBAction)playSound:(UIButton *)sender;
- (IBAction)closeSound:(UIButton *)sender;
- (IBAction)reset:(UIButton *)sender;
- (IBAction)takePhotos:(UIButton *)sender;

@property (strong, nonatomic) IBOutlet UITextField *textField;
@property   (nonatomic,strong)  UIBarButtonItem *leftButtonItem;
@property   (nonatomic,strong)  UIBarButtonItem *rightButtonItem;
@property   (nonatomic,strong)  BlueToothManager    *blueToothManager;

@property   (nonatomic,strong)  NSMutableDictionary *valueDict;


@property (strong, nonatomic) IBOutlet UILabel *light_1_label;

@property (strong, nonatomic) IBOutlet UILabel *light_2_label;

@property (strong, nonatomic) IBOutlet UILabel *light_3_label;

@property (strong, nonatomic) IBOutlet UILabel *light_4_label;

@property (strong, nonatomic) IBOutlet UILabel *light_5_label;

@property (strong, nonatomic) IBOutlet UILabel *light_6_label;




@end

@implementation DeviceDetailViewController{
    
    int lastValue;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectDeviceNoti:) name:kConnectedBlueToothDevice object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disconnectDeviceNoti:) name:kDisconnectBlueToothDevice object:nil];
    
    
    self.leftButtonItem = self.navigationItem.leftBarButtonItem;
    self.rightButtonItem = self.navigationItem.rightBarButtonItem;
    
    self.valueDict = [NSMutableDictionary dictionary];
    self.blueToothManager = [BlueToothManager shareInstance];
    lastValue = 0;
    
    
    UITapGestureRecognizer  *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickView)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:tap];
    
}

- (void)clickView{
    
    [self.view endEditing:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if ([self connected]) {
        
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = self.rightButtonItem;
    }else{
        
        self.navigationItem.leftBarButtonItem = self.leftButtonItem;
        self.navigationItem.rightBarButtonItem = nil;
    } 
//    self.navigationItem.rightBarButtonItem = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)disconnectDevice:(UIBarButtonItem *)sender {
    
    [self playSound:nil];
    [[BlueToothManager shareInstance] disconnectDevice:self.device];
}

- (IBAction)connectDevice:(UIBarButtonItem *)sender {
    
    [[BlueToothManager shareInstance] connectDevice:self.device];
}


- (void)connectDeviceNoti:(NSNotification *)noti{
    
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = self.rightButtonItem;
}

- (void)disconnectDeviceNoti:(NSNotification *)noti{
    
    self.navigationItem.leftBarButtonItem = self.leftButtonItem;
    self.navigationItem.rightBarButtonItem = nil;
    
}

- (IBAction)writeData:(UIButton *)sender {
    
    if (self.device.state != CBPeripheralStateConnected) {
        
        [AlertMessage alert:@"设备还未连接"];
        return;
    }

    
    
    if (self.textField.text.length == 0) {
        
        [AlertMessage alert:@"输入不能为空"];
        return;
    }
    
    NSString    * value = [self getAbsoulteString:self.textField.text];
    
    //    NSString    *reversedString = [self reverseStringFromString:value];
    
    UInt64 result =  [self computeCharFromString:value];
//    NSLog(@"orgin hex = %x",result);
//    字节倒叙
    [self reverseCharFromUint64:&result saveTo:global_light_data];
//    memcpy(global_light_data, &result, 8);
    NSData  *data = [NSData dataWithBytes:global_light_data length:8];
    NSUInteger  length = [self.blueToothManager MaxdataLengthDataToPeripheral:self.device withType:CBCharacteristicWriteWithResponse];
    
    if (data.length > length) {
        
        NSLog(@"data formate is error");
        return;
    }
    
    [self.blueToothManager writeValue:data forCBCharacteristic:[self.blueToothManager characterForUUID:kCharacteristicUUID] ToPeripheral:self.device];
}

- (IBAction)readData:(UIButton *)sender {
    
    if (self.device.state != CBPeripheralStateConnected) {
        
        [AlertMessage alert:@"设备还未连接"];
        return;
    }

    self.textField.text = [self readString];
//
}

- (IBAction)light1:(UISlider *)sender {
    
    if (![self connected]){
        
        sender.value = 0.0;
        return;
    }
//    char value = (char)sender.value;
    int offset = sender.value;
    lastValue = [[self.valueDict objectForKey:@"1"] intValue];
    if (lastValue > 100 || lastValue < 0) {
        
        lastValue = (int)sender.value;
    }
    
    if (abs((int)offset - lastValue)  <  5) {
        
        return;
    }else{
        [self.valueDict setObject:@(sender.value) forKey:@"1"];
    }
   
    self.light_1_label.text = @(sender.value).description;
   
    
//    if (global_light_data == 0) {
//        
//        global_light_data = global_light_data | offset << 56;
//    }else
//        global_light_data = global_light_data & (0x0011111111111111 | offset << 56);
    
//    global_light_data[0] = (char)offset;
    memset(global_light_data + 7, offset, 1);
//    [self print:global_light_data];
//    NSLog(@"write value %lld",value);
//     NSLog(@"write light1 offset:%lld value:%lld",offset,global_light_data);
//    NSData  *data = [NSData dataWithBytes:global_light_data length:8];    
//    [self.manager writeValue:data forCBCharacteristic:[self.manager characterForUUID:kCharacteristicUUID] ToPeripheral:self.device];

    [self writeToDevice];
}

- (IBAction)light2:(UISlider *)sender {
    
    if (![self connected]){
        
        sender.value = 0.0;
        return;
    }
    
    
    char offset = sender.value;
    lastValue = [[self.valueDict objectForKey:@"2"] intValue];
    if (lastValue > 100 || lastValue < 0) {
        
        lastValue = (int)sender.value;
    }
    
    if (abs((int)offset - lastValue)  <  5) {
        
        return;
    }else{
        [self.valueDict setObject:@(sender.value) forKey:@"2"];
    }
    

     self.light_2_label.text = @(sender.value).description;
    
    memset(global_light_data + 6, offset, 1);

    [self writeToDevice];
}

- (IBAction)light3:(UISlider *)sender {
    
    if (![self connected]){
        
        sender.value = 0.0;
        return;
    }
    
    char offset = sender.value;
    lastValue = [[self.valueDict objectForKey:@"3"] intValue];
    if (lastValue > 100 || lastValue < 0) {
        
        lastValue = (int)sender.value;
    }
    
    if (abs((int)offset - lastValue)  <  5) {
        
        return;
    }else{
        [self.valueDict setObject:@(sender.value) forKey:@"3"];
    }

     self.light_3_label.text = @(sender.value).description;
    
    memset(global_light_data + 5, offset, 1);

    
    [self writeToDevice];
}

- (IBAction)light4:(UISlider *)sender {
    
    if (![self connected]){
        
        sender.value = 0.0;
        return;
    }
    
    char offset = sender.value;
    lastValue = [[self.valueDict objectForKey:@"4"] intValue];
    if (lastValue > 100 || lastValue < 0) {
        
        lastValue = (int)sender.value;
    }
    
    if (abs((int)offset - lastValue)  <  5) {
        
        return;
    }else{
        [self.valueDict setObject:@(sender.value) forKey:@"4"];
    }
    
    
     self.light_4_label.text = @(sender.value).description;

    memset(global_light_data + 4, offset, 1);

    [self writeToDevice];
}

- (IBAction)light5:(UISlider *)sender {
    
    if (![self connected]){
        
        sender.value = 0.0;
        return;
    }
    
    char offset = sender.value;
    lastValue = [[self.valueDict objectForKey:@"5"] intValue];
    if (lastValue > 100 || lastValue < 0) {
        
        lastValue = (int)sender.value;
    }
    
    if (abs((int)offset - lastValue)  <  5) {
        
        return;
    }else{
        [self.valueDict setObject:@(sender.value) forKey:@"5"];
    }

 
     self.light_5_label.text = @(sender.value).description;

    memset(global_light_data + 3, offset, 1);

    [self writeToDevice];
}

- (IBAction)light6:(UISlider *)sender {
    
    if (![self connected]){
        
        sender.value = 0.0;
        return;
    }
    
    char offset = sender.value;
    lastValue = [[self.valueDict objectForKey:@"6"] intValue];
    if (lastValue > 100 || lastValue < 0) {
        
        lastValue = (int)sender.value;
    }
    
    if (abs((int)offset - lastValue)  <  5) {
        
        return;
    }else{
        [self.valueDict setObject:@(sender.value) forKey:@"6"];
    }
    
    
     self.light_6_label.text = @(sender.value).description;

    memset(global_light_data + 2, offset, 1);
 
    [self writeToDevice];
    
}

- (IBAction)playSound:(UIButton *)sender {
    
    if (![self connected]){
        
        
        return;
    }
    

    memset(global_light_data, 100, 1);

    [self writeToDevice];
}

- (IBAction)closeSound:(UIButton *)sender {
    
    if (![self connected]){
        
        
        return;
    }
    

    memset(global_light_data, 0, 1);

    [self writeToDevice];
}

- (IBAction)reset:(UIButton *)sender {

    if (![self connected]) {
        
        return;
    }

    memset(global_light_data, 0, 8);
    
    self.light_1_label.text = @"0";
    self.light_2_label.text = @"0";
    self.light_3_label.text = @"0";
    self.light_4_label.text = @"0";
    self.light_5_label.text = @"0";
    self.light_6_label.text = @"0";

    [self writeToDevice];
}

- (IBAction)takePhotos:(UIButton *)sender {
    
    if (![self connected]) {
        

        return;
    }
    
    
    [self performSegueWithIdentifier:@"takePhotos" sender:self.device];
//    [self beginTakePhotos];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    
    CBPeripheral    *device  = sender;
    TakePhotosViewController  *photoVC = segue.destinationViewController;
    photoVC.device = device;
}

- (void)beginTakePhotos{
    
    //    关闭p0.2 ,点亮p0.3
    usleep(0);
    [self performSelector:@selector(writeSomeLight:) withObject:@[@{@"lightNum":@"6",@"lightValue":@"0"},@{@"lightNum":@"5",@"lightValue":@"100"},@{@"lightNum":@"8",@"lightValue":@"100"}]];
    [self writeToDevice];
    
    //    1秒后关闭p0.3,点亮p0.4 6.5秒
    usleep(1000000);
    [self performSelector:@selector(writeSomeLight:) withObject:@[@{@"lightNum":@"5",@"lightValue":@"0"},@{@"lightNum":@"4",@"lightValue":@"100"},@{@"lightNum":@"8",@"lightValue":@"100"}]];
    [self writeToDevice];
    
    
    //    6.5秒后 关闭P0.4,点亮P0.5
    usleep(6500000);
    [self performSelector:@selector(writeSomeLight:) withObject:@[@{@"lightNum":@"4",@"lightValue":@"0"},@{@"lightNum":@"3",@"lightValue":@"100"},@{@"lightNum":@"8",@"lightValue":@"100"} ]];
    [self writeToDevice];
    
    
    //    5.5秒后关闭p0.5 点亮 p0.2 P0.6 微亮 P0.7全亮
    usleep(5500000);
    [self performSelector:@selector(writeSomeLight:) withObject:@[@{@"lightNum":@"3",@"lightValue":@"0"},@{@"lightNum":@"6",@"lightValue":@"50"},@{@"lightNum":@"2",@"lightValue":@"50"},@{@"lightNum":@"1",@"lightValue":@"100"},@{@"lightNum":@"8",@"lightValue":@"100"} ]];
    [self writeToDevice];
    
    //    6.5秒后关闭，同时点亮P0.2 p0.7微亮，P0.6全亮
    usleep(6500000);
    [self performSelector:@selector(writeSomeLight:) withObject:@[@{@"lightNum":@"6",@"lightValue":@"50"},@{@"lightNum":@"1",@"lightValue":@"50"},@{@"lightNum":@"2",@"lightValue":@"100"},@{@"lightNum":@"8",@"lightValue":@"100"}]];
    [self writeToDevice];
    
    
    //    5.5秒后 关闭 P0.2 P0.7 P0.6全亮
    usleep(5500000);
    [self performSelector:@selector(writeSomeLight:) withObject:@[@{@"lightNum":@"6",@"lightValue":@"0"},@{@"lightNum":@"1",@"lightValue":@"0"},@{@"lightNum":@"2",@"lightValue":@"100"},@{@"lightNum":@"8",@"lightValue":@"100"} ]];
    [self writeToDevice];
    
    //    1秒后关闭p0.6,点亮P0.2
    usleep(1000000);
    [self performSelector:@selector(writeSomeLight:) withObject:@[@{@"lightNum":@"2",@"lightValue":@"0"},@{@"lightNum":@"6",@"lightValue":@"100"},@{@"lightNum":@"8",@"lightValue":@"100"}]];
    [self writeToDevice];
    
    
    usleep(1000000);
    memset(global_light_data, 0, 8);//清空数据，防止影响其他功能。
    [self writeToDevice];
    [AlertMessage alert:@"执行完毕"];

}


- (void)writeLightWithInfo:(NSDictionary *)dict{
    
    NSInteger lightNum = [[dict objectForKey:@"lightNum"] integerValue];
    int value  = [[dict objectForKey:@"lightValue"] intValue];
    
    [self writeLight:lightNum withValue:value];
}

- (void)writeLight:(NSInteger)lightNum withValue:(int)value{
    
    if (![self connected]){
        
        return;
    }
    
    memset(global_light_data + 8 - lightNum, value, 1);

}

- (void)writeToDevice{
    
    NSData  *data = [NSData dataWithBytes:global_light_data length:8];
    [self.blueToothManager writeValue:data forCBCharacteristic:[self.blueToothManager characterForUUID:kCharacteristicUUID] ToPeripheral:self.device];
}

//同时点亮多个光源
- (void)writeSomeLight:(NSArray *)array{
    
    for (NSDictionary *dict in array) {
        
        NSInteger lightNum = [[dict objectForKey:@"lightNum"] integerValue];
        int         value = [[dict objectForKey:@"lightValue"] intValue];
        
        
        [self writeLight:lightNum withValue:value];
    }
    
}




- (void)writeValue:(NSData *)data forCBCharacteristic:(CBCharacteristic *)character {
    
    [self.device writeValue:data forCharacteristic:character type:CBCharacteristicWriteWithoutResponse];
}



- (BOOL)connected{
    
        if (self.device.state == CBPeripheralStateConnected) {
    
            return YES;
        }
        else{
            
            [AlertMessage alert:@"设备还未连接"];
            return NO;
        }
    
    return NO;
}

- (void)dealloc{
    
    [[NSNotificationCenter defaultCenter ] removeObserver:self];;
}

- (void)print:(char*)str
{
    NSLog(@"output data =====");
    int i = 0;
    char *p = str;
    while (i < 8) {
        printf("%d  ",*p);
        i++;
        p++;
    }
}

- (char )covertToCharFromString:(char *)string{

    if (string) {
        
        if (*string <= '9' && *string >= '0') {
            
            return *string - 48;
        }
        
        else if (*string == 'a' || *string == 'A') {
            
            return 10;
        }
        else if (*string == 'b' || *string == 'B') {
            
            return 11;
        }
        else if (*string == 'c' || *string == 'C') {
            
            return 12;
        }else if (*string == 'd' || *string == 'D') {
            
            return 13;
        }else if (*string == 'e' || *string == 'E') {
            
            return 14;
        }else if (*string == 'f' || *string == 'F') {
            
            return 15;
        }
        
        else
            return 0;
    }
    
    return 0;
}

////剔除掉0x 0X计算
- (UInt64)computeCharFromString:(NSString *)string{
    
    char *str = string.cString;
    NSUInteger len = string.length;
    char  *p = str;
    UInt64 sum = 0;
    while (*p != '\0') {
        
        sum += ([self covertToCharFromString:p] * pow(16, (str + len - p - 1)));
        p++;
    }

    
    return sum;
}

- (void)reverseCharFromUint64:(UInt64 *)s saveTo:(char *)d{
    
    
    int len = sizeof(UInt64);
    char *src = (char *)s;
    char *dest = (char *)d + len - 1;
    while (len > 0) {
        
        memcpy(dest, src, 1);
        src++;
        dest--;
        len--;
    }
    
}

- (NSString *)readString{
    
    int len = sizeof(UInt64) + 1;
    char *tem = (char *)malloc(sizeof(char) * len);
    memset(tem, 0, len);
    char *src = (char *)global_light_data;
    char *dest = tem + len  - 2;
    while (len > 1) {
        
        memcpy(dest, src, 1);
        src++;
        dest--;
        len--;
    }
    
    
    
   return [NSString stringWithCString:tem encoding:NSUTF8StringEncoding];
}



//
//- (NSString *)reverseStringFromString:(NSString *)string{
//    
//    NSMutableString *newString = [[NSMutableString alloc] initWithCapacity:string.length];
//    for (int i = string.length - 1; i >=0 ; i --) {
//        unichar ch = [string characterAtIndex:i];
//        [newString appendFormat:@"%c",ch];
//    }
//
//    return newString;
//}
//
//- (void)setValueFromUint64:(UInt64)value{
//    
////    global_light_data = & value;
//    memcpy(&value, global_light_data, 8);
//    
//    NSData  *data = [NSData dataWithBytes:global_light_data length:8];
//    [self.manager writeValue:data forCBCharacteristic:[self.manager characterForUUID:kCharacteristicUUID] ToPeripheral:self.device];
//
//    
//}
//
//get absoulte string
- (NSString*)getAbsoulteString:(NSString *)string{
    
    NSString *newString = nil;
    newString = [string stringByReplacingOccurrencesOfString:@"0x" withString:@""];
    newString = [string stringByReplacingOccurrencesOfString:@"0X" withString:@""];
    
    return newString;
}





@end
