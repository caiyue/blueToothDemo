//
//  PhotoIntervalSetting.m
//  BlueTooth
//
//  Created by caiyue on 15/12/5.
//  Copyright © 2015年 soufun. All rights reserved.
//

#import "PhotoIntervalSettingViewController.h"
#import "AlertMessage.h"


NSString    *settingInfoKey = @"settingInfoKey";
NSString    *timeIntervalStep1 = @"timeIntervalStep1";
NSString    *timeIntervalStep2 = @"timeIntervalStep2";
NSString    *timeIntervalStep3 = @"timeIntervalStep3";
NSString    *timeIntervalStep4 = @"timeIntervalStep4";
NSString    *timeIntervalStep5 = @"timeIntervalStep5";
NSString    *timeIntervalStep6 = @"timeIntervalStep6";


@interface PhotoIntervalSettingViewController ()

@property (strong, nonatomic) IBOutlet UITextField *timeIntervalStep1;
@property (strong, nonatomic) IBOutlet UITextField *timeIntervalStep2;
@property (strong, nonatomic) IBOutlet UITextField *timeIntervalStep3;
@property (strong, nonatomic) IBOutlet UITextField *timeIntervalStep4;
@property (strong, nonatomic) IBOutlet UITextField *timeIntervalStep5;
@property (strong, nonatomic) IBOutlet UITextField *timeIntervalStep6;



- (IBAction)intervalStep1_add:(UIButton *)sender;
- (IBAction)intervalStep1_plus:(UIButton *)sender;

- (IBAction)intervalStep2_add:(UIButton *)sender;
- (IBAction)intervalStep2_plus:(UIButton *)sender;

- (IBAction)intervalStep3_add:(UIButton *)sender;
- (IBAction)intervalStep3_plus:(UIButton *)sender;

- (IBAction)intervalStep4_add:(UIButton *)sender;
- (IBAction)intervalStep4_plus:(UIButton *)sender;

- (IBAction)intervalStep5_add:(UIButton *)sender;
- (IBAction)intervalStep5_plus:(UIButton *)sender;

- (IBAction)intervalStep6_add:(UIButton *)sender;
- (IBAction)intervalStep6_plus:(UIButton *)sender;


@end


@implementation PhotoIntervalSettingViewController


- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    NSDictionary    *dict = [[NSUserDefaults standardUserDefaults] objectForKey:settingInfoKey];
    
     self.timeIntervalStep1.text = [dict objectForKey:timeIntervalStep1];
     self.timeIntervalStep2.text = [dict objectForKey:timeIntervalStep2];
     self.timeIntervalStep3.text = [dict objectForKey:timeIntervalStep3];
     self.timeIntervalStep4.text = [dict objectForKey:timeIntervalStep4];
     self.timeIntervalStep5.text = [dict objectForKey:timeIntervalStep5];
     self.timeIntervalStep6.text = [dict objectForKey:timeIntervalStep6];

    
}

- (IBAction)saveInfo:(id)sender {
    
    
    if (self.timeIntervalStep1.text.length == 0 ||
        self.timeIntervalStep2.text.length == 0 ||
        self.timeIntervalStep3.text.length == 0 ||
        self.timeIntervalStep4.text.length == 0 ||
        self.timeIntervalStep5.text.length == 0 ||
        self.timeIntervalStep6.text.length == 0) {
        
        [AlertMessage alert:@"时间设置不正确"];
        return;
    }
    
    
    NSDictionary    *dict = [NSDictionary dictionaryWithObjectsAndKeys:self.timeIntervalStep1.text,timeIntervalStep1,self.timeIntervalStep2.text,timeIntervalStep2,self.timeIntervalStep3.text,timeIntervalStep3,self.timeIntervalStep4.text,timeIntervalStep4,self.timeIntervalStep5.text,timeIntervalStep5,self.timeIntervalStep6.text,timeIntervalStep6, nil];
    
    NSUserDefaults  *d = [NSUserDefaults standardUserDefaults];
    [d setValue:dict forKey:settingInfoKey];
    [d synchronize];
    
    
    [self.navigationController popViewControllerAnimated:YES];
    
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://123.56.157.109/user/uploadImg"]];
//    
//    UIImage *image = [UIImage imageNamed:@"11.jpg"];
//    NSData*data = UIImageJPEGRepresentation(image, 1.0);
//    [request setHTTPBody:data];
//    [request setHTTPMethod:@"POST"];
//    [request setValue:@"aaaa" forHTTPHeaderField:@"photoName"];
//    [request setValue:@"10000" forHTTPHeaderField:@"photoSize"];
//    
//    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
//       
//        
//        NSLog(@"post :%@,%@,%@",response,d,connectionError);
//    }];

    
}

- (void)viewDidLoad{
    
    [super viewDidLoad];
    
    
}


- (IBAction)intervalStep1_add:(UIButton *)sender {
    
    int  v = self.timeIntervalStep1.text.intValue;
    self.timeIntervalStep1.text = @(++v).description;
    
}

- (IBAction)intervalStep1_plus:(UIButton *)sender{
    
    int  v = self.timeIntervalStep1.text.intValue;
    
    if (v <= 0) {
        
        [AlertMessage alert:@"时间间隔不能小于0"];
        return;
    }
    
    self.timeIntervalStep1.text = @(--v).description;
}

- (IBAction)intervalStep2_add:(UIButton *)sender{
    
    int  v = self.timeIntervalStep2.text.intValue;
    self.timeIntervalStep2.text = @(++v).description;
}
- (IBAction)intervalStep2_plus:(UIButton *)sender{
    
    int  v = self.timeIntervalStep2.text.intValue;
    if (v <= 0) {
        
        [AlertMessage alert:@"时间间隔不能小于0"];
        return;
    }
    self.timeIntervalStep2.text = @(--v).description;
}

- (IBAction)intervalStep3_add:(UIButton *)sender{
    
    int  v = self.timeIntervalStep3.text.intValue;
    self.timeIntervalStep3.text = @(++v).description;
}
- (IBAction)intervalStep3_plus:(UIButton *)sender{
    
    int  v = self.timeIntervalStep3.text.intValue;
    if (v <= 0) {
        
        [AlertMessage alert:@"时间间隔不能小于0"];
        return;
    }
    self.timeIntervalStep3.text = @(--v).description;
}

- (IBAction)intervalStep4_add:(UIButton *)sender{
    
    int  v = self.timeIntervalStep4.text.intValue;
    self.timeIntervalStep4.text = @(++v).description;
}
- (IBAction)intervalStep4_plus:(UIButton *)sender{
 
    int  v = self.timeIntervalStep4.text.intValue;
    if (v <= 0) {
        
        [AlertMessage alert:@"时间间隔不能小于0"];
        return;
    }
    self.timeIntervalStep4.text = @(--v).description;
}

- (IBAction)intervalStep5_add:(UIButton *)sender{
    
    int  v = self.timeIntervalStep5.text.intValue;
    self.timeIntervalStep5.text = @(++v).description;
}

- (IBAction)intervalStep5_plus:(UIButton *)sender{
    
    int  v = self.timeIntervalStep5.text.intValue;
    if (v <= 0) {
        
        [AlertMessage alert:@"时间间隔不能小于0"];
        return;
    }
    self.timeIntervalStep5.text = @(--v).description;
}


- (IBAction)intervalStep6_add:(UIButton *)sender{
    
    int  v = self.timeIntervalStep6.text.intValue;
    self.timeIntervalStep6.text = @(++v).description;
}
- (IBAction)intervalStep6_plus:(UIButton *)sender{
    
    int  v = self.timeIntervalStep6.text.intValue;
    if (v <= 0) {
        
        [AlertMessage alert:@"时间间隔不能小于0"];
        return;
    }
    self.timeIntervalStep6.text = @(--v).description;
}
@end
