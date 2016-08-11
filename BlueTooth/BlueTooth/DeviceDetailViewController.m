


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
//- (IBAction)light1:(UISlider *)sender;
//- (IBAction)light2:(UISlider *)sender;
//- (IBAction)light3:(UISlider *)sender;
//- (IBAction)light4:(UISlider *)sender;
//- (IBAction)light5:(UISlider *)sender;
//- (IBAction)light6:(UISlider *)sender;
- (IBAction)light1_add:(UIButton *)sender;
- (IBAction)light1_plus:(UIButton *)sender;

- (IBAction)light2_add:(UIButton *)sender;
- (IBAction)light2_plus:(UIButton *)sender;

- (IBAction)light3_add:(UIButton *)sender;
- (IBAction)light3_plus:(UIButton *)sender;


- (IBAction)light4_add:(UIButton *)sender;
- (IBAction)light4_plus:(UIButton *)sender;

- (IBAction)light5_add:(UIButton *)sender;
- (IBAction)light5_plus:(UIButton *)sender;

- (IBAction)light6_add:(UIButton *)sender;
- (IBAction)light6_plus:(UIButton *)sender;

- (IBAction)light7_add:(UIButton *)sender;
- (IBAction)light7_plus:(UIButton *)sender;



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

@property (strong,nonatomic)  IBOutlet UILabel *light_7_label;

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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
     [self reset:nil];
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
    
//    判断输入是否合法,合法返回有效数据字符串
    NSString    *string = [self legalString:self.textField.text];
    if (!string) {
        [AlertMessage alert:@"输入格式有误，请输入0x/0X开头的16位数字~~~"];
        return;
    }

//    倒序
//    string = [self reverseStringFromString:string];
    
//    转换成10进制数组输出
    char *array = [self getDecimalNumberArrayWithString:string];
    
    
//    拷贝所有数据
    memcpy(global_light_data, array, 8);
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
}

//- (IBAction)light1:(UISlider *)sender {
//    
//    if (![self connected]){
//        
//        sender.value = 0.0;
//        return;
//    }
////    char value = (char)sender.value;
//    int offset = sender.value;
//    lastValue = [[self.valueDict objectForKey:@"1"] intValue];
//    if (lastValue > 100 || lastValue < 0) {
//        
//        lastValue = (int)sender.value;
//    }
//    
//    if (abs((int)offset - lastValue)  <  5) {
//        
//        return;
//    }else{
//        [self.valueDict setObject:@(sender.value) forKey:@"1"];
//    }
//   
//    self.light_1_label.text = @(sender.value).description;
//   
//    
////    if (global_light_data == 0) {
////        
////        global_light_data = global_light_data | offset << 56;
////    }else
////        global_light_data = global_light_data & (0x0011111111111111 | offset << 56);
//    
////    global_light_data[0] = (char)offset;
//    memset(global_light_data + 7, offset, 1);
////    [self print:global_light_data];
////    NSLog(@"write value %lld",value);
////     NSLog(@"write light1 offset:%lld value:%lld",offset,global_light_data);
////    NSData  *data = [NSData dataWithBytes:global_light_data length:8];    
////    [self.manager writeValue:data forCBCharacteristic:[self.manager characterForUUID:kCharacteristicUUID] ToPeripheral:self.device];
//
//    [self writeToDevice];
//}
//
//- (IBAction)light2:(UISlider *)sender {
//    
//    if (![self connected]){
//        
//        sender.value = 0.0;
//        return;
//    }
//    
//    
//    char offset = sender.value;
//    lastValue = [[self.valueDict objectForKey:@"2"] intValue];
//    if (lastValue > 100 || lastValue < 0) {
//        
//        lastValue = (int)sender.value;
//    }
//    
//    if (abs((int)offset - lastValue)  <  5) {
//        
//        return;
//    }else{
//        [self.valueDict setObject:@(sender.value) forKey:@"2"];
//    }
//    
//
//     self.light_2_label.text = @(sender.value).description;
//    
//    memset(global_light_data + 6, offset, 1);
//
//    [self writeToDevice];
//}
//
//- (IBAction)light3:(UISlider *)sender {
//    
//    if (![self connected]){
//        
//        sender.value = 0.0;
//        return;
//    }
//    
//    char offset = sender.value;
//    lastValue = [[self.valueDict objectForKey:@"3"] intValue];
//    if (lastValue > 100 || lastValue < 0) {
//        
//        lastValue = (int)sender.value;
//    }
//    
//    if (abs((int)offset - lastValue)  <  5) {
//        
//        return;
//    }else{
//        [self.valueDict setObject:@(sender.value) forKey:@"3"];
//    }
//
//     self.light_3_label.text = @(sender.value).description;
//    
//    memset(global_light_data + 5, offset, 1);
//
//    
//    [self writeToDevice];
//}
//
//- (IBAction)light4:(UISlider *)sender {
//    
//    if (![self connected]){
//        
//        sender.value = 0.0;
//        return;
//    }
//    
//    char offset = sender.value;
//    lastValue = [[self.valueDict objectForKey:@"4"] intValue];
//    if (lastValue > 100 || lastValue < 0) {
//        
//        lastValue = (int)sender.value;
//    }
//    
//    if (abs((int)offset - lastValue)  <  5) {
//        
//        return;
//    }else{
//        [self.valueDict setObject:@(sender.value) forKey:@"4"];
//    }
//    
//    
//     self.light_4_label.text = @(sender.value).description;
//
//    memset(global_light_data + 4, offset, 1);
//
//    [self writeToDevice];
//}
//
//- (IBAction)light5:(UISlider *)sender {
//    
//    if (![self connected]){
//        
//        sender.value = 0.0;
//        return;
//    }
//    
//    char offset = sender.value;
//    lastValue = [[self.valueDict objectForKey:@"5"] intValue];
//    if (lastValue > 100 || lastValue < 0) {
//        
//        lastValue = (int)sender.value;
//    }
//    
//    if (abs((int)offset - lastValue)  <  5) {
//        
//        return;
//    }else{
//        [self.valueDict setObject:@(sender.value) forKey:@"5"];
//    }
//
// 
//     self.light_5_label.text = @(sender.value).description;
//
//    memset(global_light_data + 3, offset, 1);
//
//    [self writeToDevice];
//}
//
//- (IBAction)light6:(UISlider *)sender {
//    
//    if (![self connected]){
//        
//        sender.value = 0.0;
//        return;
//    }
//    
//    char offset = sender.value;
//    lastValue = [[self.valueDict objectForKey:@"6"] intValue];
//    if (lastValue > 100 || lastValue < 0) {
//        
//        lastValue = (int)sender.value;
//    }
//    
//    if (abs((int)offset - lastValue)  <  5) {
//        
//        return;
//    }else{
//        [self.valueDict setObject:@(sender.value) forKey:@"6"];
//    }
//    
//    
//     self.light_6_label.text = @(sender.value).description;
//
//    memset(global_light_data + 2, offset, 1);
// 
//    [self writeToDevice];
//    
//}


- (IBAction)light1_add:(UIButton *)sender {
    
    
    if (![self connected]){

        [AlertMessage alert:@"设备还未连接"];
        return;
        }
    
    int light = self.light_1_label.text.intValue;
    if (light >= 100) {
        
        [AlertMessage alert:@"不能大于 100"];
        return;
    }else{
        
        self.light_1_label.text = @(++light).description;
    }
    
    memset(global_light_data + 7, light, 1);
    
    [self writeToDevice];

}

- (IBAction)light1_plus:(UIButton *)sender {
    
    if (![self connected]){
        
        [AlertMessage alert:@"设备还未连接"];
        return;
    }
    
    int light = self.light_1_label.text.intValue;
    if (light <= 0) {
        
        [AlertMessage alert:@"不能小于 0"];
        return;
    }else{
        
        self.light_1_label.text = @(--light).description;
    }
    
    memset(global_light_data + 7, light, 1);
    
     [self writeToDevice];
}


- (IBAction)light2_add:(UIButton *)sender{
    
    if (![self connected]){
        
        [AlertMessage alert:@"设备还未连接"];
        return;
    }
    
    int light = self.light_2_label.text.intValue;
    if (light >= 100) {
        
        [AlertMessage alert:@"不能大于 100"];
        return;
    }else{
        
        self.light_2_label.text = @(++light).description;
    }
    
    memset(global_light_data + 6, light, 1);
     [self writeToDevice];
}
- (IBAction)light2_plus:(UIButton *)sender{
    
    if (![self connected]){
        
        [AlertMessage alert:@"设备还未连接"];
        return;
    }
    
    int light = self.light_2_label.text.intValue;
    if (light <= 0) {
        
        [AlertMessage alert:@"不能小于 0"];
        return;
    }else{
        
        self.light_2_label.text = @(--light).description;
    }
    
    memset(global_light_data + 6, light, 1);
     [self writeToDevice];
}




- (IBAction)light3_add:(UIButton *)sender{
    
    if (![self connected]){
        
        [AlertMessage alert:@"设备还未连接"];
        return;
    }
    
    int light = self.light_3_label.text.intValue;
    if (light >= 100) {
        
        [AlertMessage alert:@"不能大于 100"];
        return;
    }else{
        
        self.light_3_label.text = @(++light).description;
    }
    
    memset(global_light_data + 5, light, 1);
    
     [self writeToDevice];
}

- (IBAction)light3_plus:(UIButton *)sender{
 
    if (![self connected]){
        
        [AlertMessage alert:@"设备还未连接"];
        return;
    }
    
    int light = self.light_3_label.text.intValue;
    if (light <= 0) {
        
        [AlertMessage alert:@"不能小于 0"];
        return;
    }else{
        
        self.light_3_label.text = @(--light).description;
    }
    
    memset(global_light_data + 5, light, 1);
     [self writeToDevice];
}


- (IBAction)light4_add:(UIButton *)sender{
    
    if (![self connected]){
        
        [AlertMessage alert:@"设备还未连接"];
        return;
    }
    
    int light = self.light_4_label.text.intValue;
    if (light >= 100) {
        
        [AlertMessage alert:@"不能大于 100"];
        return;
    }else{
        
        self.light_4_label.text = @(++light).description;
    }
    
    memset(global_light_data + 4, light, 1);
    
     [self writeToDevice];
    
}
- (IBAction)light4_plus:(UIButton *)sender{
    
    if (![self connected]){
        
        [AlertMessage alert:@"设备还未连接"];
        return;
    }
    
    int light = self.light_4_label.text.intValue;
    if (light <= 0) {
        
        [AlertMessage alert:@"不能小于 0"];
        return;
    }else{
        
        self.light_4_label.text = @(--light).description;
    }
    
    memset(global_light_data + 4, light, 1);
    
     [self writeToDevice];
}

- (IBAction)light5_add:(UIButton *)sender{
    
    if (![self connected]){
        
        [AlertMessage alert:@"设备还未连接"];
        return;
    }
    
    int light = self.light_5_label.text.intValue;
    if (light >= 100) {
        
        [AlertMessage alert:@"不能大于 100"];
        return;
    }else{
        
        self.light_5_label.text = @(++light).description;
    }
    
    memset(global_light_data + 3, light, 1);
    
     [self writeToDevice];
    
}
- (IBAction)light5_plus:(UIButton *)sender{
    
    
    if (![self connected]){
        
        [AlertMessage alert:@"设备还未连接"];
        return;
    }
    
    int light = self.light_5_label.text.intValue;
    if (light <= 0) {
        
        [AlertMessage alert:@"不能小于 0"];
        return;
    }else{
        
        self.light_5_label.text = @(--light).description;
    }
    
    memset(global_light_data + 3, light, 1);
    
     [self writeToDevice];
}



- (IBAction)light6_add:(UIButton *)sender{
    
    
    if (![self connected]){
        
        [AlertMessage alert:@"设备还未连接"];
        return;
    }
    
    int light = self.light_6_label.text.intValue;
    if (light >= 100) {
        
        [AlertMessage alert:@"不能大于 100"];
        return;
    }else{
        
        self.light_6_label.text = @(++light).description;
    }
    
    memset(global_light_data + 2, light, 1);
    
     [self writeToDevice];
}
- (IBAction)light6_plus:(UIButton *)sender{
    
    if (![self connected]){
        
        [AlertMessage alert:@"设备还未连接"];
        return;
    }
    
    int light = self.light_6_label.text.intValue;
    if (light <= 0) {
        
        [AlertMessage alert:@"不能小于 0"];
        return;
    }else{
        
        self.light_6_label.text = @(--light).description;
    }
    
    memset(global_light_data + 2, light, 1);
    
     [self writeToDevice];
}

- (IBAction)light7_add:(UIButton *)sender{
    if (![self connected]){
        [AlertMessage alert:@"设备还未连接"];
        return;
    }
    
    int light = self.light_7_label.text.intValue;
    if (light >= 100) {
        
        [AlertMessage alert:@"不能大于 100"];
        return;
    }else{
        
        self.light_7_label.text = @(++light).description;
    }
    
    memset(global_light_data + 1, light, 1);
    
    [self writeToDevice];
}
- (IBAction)light7_plus:(UIButton *)sender{
    
    if (![self connected]){
        
        [AlertMessage alert:@"设备还未连接"];
        return;
    }
    
    int light = self.light_7_label.text.intValue;
    if (light <= 0) {
        
        [AlertMessage alert:@"不能小于 0"];
        return;
    }else{
        self.light_7_label.text = @(--light).description;
    }
    
    memset(global_light_data + 1, light, 1);
    
    [self writeToDevice];
}


- (IBAction)playSound:(UIButton *)sender {
    
    if (![self connected]){
        
        [AlertMessage alert:@"设备还未连接"];
        return;
    }

    memset(global_light_data, 100, 1);

    [self writeToDevice];
}


- (IBAction)closeSound:(UIButton *)sender {
    
    if (![self connected]){
        
        [AlertMessage alert:@"设备还未连接"];
        return;
    }
    

    memset(global_light_data, 0, 1);

    [self writeToDevice];
}

- (IBAction)reset:(UIButton *)sender {

    if (![self connected]) {
        
        [AlertMessage alert:@"设备还未连接"];
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
        
        [AlertMessage alert:@"设备还未连接"];
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



- (void)writeLight:(NSInteger)lightNum withValue:(int)value{
    
    if (![self connected]){
        
        [AlertMessage alert:@"设备还未连接"];
        return;
    }
    
    memset(global_light_data + 8 - lightNum, value, 1);

}

- (void)writeToDevice{
    
    NSData  *data = [NSData dataWithBytes:global_light_data length:8];
    [self.blueToothManager writeValue:data forCBCharacteristic:[self.blueToothManager characterForUUID:kCharacteristicUUID] ToPeripheral:self.device];
}




- (void)writeValue:(NSData *)data forCBCharacteristic:(CBCharacteristic *)character {
    
    [self.device writeValue:data forCharacteristic:character type:CBCharacteristicWriteWithoutResponse];
}



- (BOOL)connected{
    
        if (self.device.state == CBPeripheralStateConnected) {
    
            return YES;
        }
        else{

            return NO;
        }
    
    return NO;
}

- (void)dealloc{
    
    [[NSNotificationCenter defaultCenter ] removeObserver:self];;
}



-(NSString *)readString{
    
    char *array = global_light_data;
    NSMutableString *string = [NSMutableString string];
    for (int i = 0; i < 8; i++) {
        [string appendString:[NSString stringWithFormat:@"%d ",*(array++)]];
    }
    
    return  string;
}

//判断是否合法，如果合法返回小写的有效字符串，否则返回nil
-(NSString *)legalString:(NSString *)string{
    
    NSString * s = string.lowercaseString;
    if (![s hasPrefix:@"0x"]) {
        
        return nil;
    }else if(s.length != 18){
        
        return  nil;
    }
    
    return [s stringByReplacingOccurrencesOfString:@"0x" withString:@""];
}

//倒叙string，每个字节不变，也就是每2个字符顺序不变
-(NSString *) reverseStringFromString:(NSString *)string{
    
    NSMutableString *newString = [[NSMutableString alloc] initWithCapacity:string.length];
    NSString * subString = nil;
    for (int i = 8;i>=1;i--) {
        subString = [string substringWithRange:NSMakeRange(i * 2 -2, 2)];
        [newString appendString:subString];
    }
    return newString;
}

//将16进制字符串转化为10 进制字符串,自左到右
-(char *)getDecimalNumberArrayWithString:(NSString *)str{
    
    //     开辟空间存储转换来的数据
    char  *numberArray = (char *)malloc(sizeof(int) * (8));
    char *p = numberArray;
    
    NSString * subString = nil;
    char decimalValue = 0;
    for (int i = 0;i < 8;i++) {
        subString = [str substringWithRange:NSMakeRange(i * 2, 2)];
        decimalValue = [self convertToDecimalNumberWithTwoLetter:subString ];
        *(p++) = decimalValue;
    }
    
    return numberArray;
}


//核心转换，从字符串转换到10 进制数据
-(char)  convertToDecimalNumberWithTwoLetter:(NSString *)letters{
    
    NSString    *firstString = [letters substringWithRange:NSMakeRange(0, 1)];
    NSString    *secondString = [letters substringWithRange:NSMakeRange(1, 1)];
    
    int  firstChar =  [self covertToNumberFromChar:[firstString cStringUsingEncoding:NSUTF8StringEncoding]];
    int secondChar = [self  covertToNumberFromChar:[secondString cStringUsingEncoding:NSUTF8StringEncoding]];
    
    return firstChar * 16 + secondChar;
}

//字符转为数字
-(char) covertToNumberFromChar:(const char *)string{
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
@end
