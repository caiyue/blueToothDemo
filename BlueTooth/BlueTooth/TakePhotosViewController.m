//
//  TakePhotosViewController.m
//  BlueTooth
//
//  Created by caiyue on 15/11/29.
//  Copyright © 2015年 soufun. All rights reserved.
//

#import "TakePhotosViewController.h"
#import "BlueToothManager.h"
#import "AlertMessage.h"
#import "PhotosTableViewCell.h"
#import "PhotoDetailViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>


extern NSString    *settingInfoKey;
extern NSString    *timeIntervalStep1;
extern NSString    *timeIntervalStep2;
extern NSString    *timeIntervalStep3;
extern NSString    *timeIntervalStep4;
extern NSString    *timeIntervalStep5;
extern NSString    *timeIntervalStep6;


@interface TakePhotosViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIAlertViewDelegate,UITableViewDataSource,UITableViewDelegate>


@property   (nonatomic,strong)  NSMutableArray  *dataArray;
@property   (nonatomic,strong)  UITableView     *tableView;
@property   (nonatomic,strong)  NSDictionary    *settingDict;
@end

extern  char *global_light_data;

@implementation TakePhotosViewController
{
     UIImagePickerController *imagePickerController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataArray = [NSMutableArray array];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(writeSuccess:) name:kWriteToDeviceSuccessfulNotification object:nil];
}

- (void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    NSUserDefaults  *ud = [NSUserDefaults standardUserDefaults];
    self.settingDict = [ud objectForKey:settingInfoKey];
}

- (void)back{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)takePhotos:(UIBarButtonItem *)sender {
    
    
    [self openCamera];
    
    UITapGestureRecognizer  *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(back)];
    
    tap.numberOfTapsRequired = 2;
    tap.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:tap];
    

    
    for (NSString *key  in self.settingDict) {
        
        NSString    *value = self.settingDict[key];
        if ([value floatValue] == 0 || value.length == 0) {
            
            [AlertMessage alert:@"拍照时间间隔未设置"];
            
            [self performSelector:@selector(back) withObject:nil afterDelay:2.0];
            
            return;
        }
    }
    
    
    
//    异步执行
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_group_async(group, queue, ^{
        [self setLight];
    });
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        
        [AlertMessage alert:@"执行完毕"];
    });
}

- (void)setLight{
    
    //    关闭p0.2 ,点亮p0.3
    usleep(3000000);//等待相机准备好
    [self performSelector:@selector(writeSomeLight:) withObject:@[@{kLIGHT_NUMBER:@"6",kLIGHT_VALUE:@"0"},@{kLIGHT_NUMBER:@"5",kLIGHT_VALUE:@"100"},@{kLIGHT_NUMBER:@"8",kLIGHT_VALUE:@"100"}]];
    [self writeToDevice];
//     [[NSNotificationCenter defaultCenter] postNotificationName:@"takePhotos" object:nil];
    
    
    //    1秒后关闭p0.3,点亮p0.4 6.5秒
    usleep(1000000 * [[self.settingDict objectForKey:timeIntervalStep1] floatValue]);
    [self performSelector:@selector(writeSomeLight:) withObject:@[@{kLIGHT_NUMBER:@"5",kLIGHT_VALUE:@"0"},@{kLIGHT_NUMBER:@"4",kLIGHT_VALUE:@"100"},@{kLIGHT_NUMBER:@"8",kLIGHT_VALUE:@"100"}]];
    [self writeToDevice];
//      [[NSNotificationCenter defaultCenter] postNotificationName:@"takePhotos" object:nil];
    
    
    //    6.5秒后 关闭P0.4,点亮P0.5
    usleep(1000000 * [[self.settingDict objectForKey:timeIntervalStep2] floatValue]);
    [self performSelector:@selector(writeSomeLight:) withObject:@[@{kLIGHT_NUMBER:@"4",kLIGHT_VALUE:@"0"},@{kLIGHT_NUMBER:@"3",kLIGHT_VALUE:@"100"},@{kLIGHT_NUMBER:@"8",kLIGHT_VALUE:@"100"} ]];
    [self writeToDevice];
//      [[NSNotificationCenter defaultCenter] postNotificationName:@"takePhotos" object:nil];
    
    
    //    5.5秒后关闭p0.5 点亮 p0.2 P0.6 微亮 P0.7全亮
    usleep(1000000 * [[self.settingDict objectForKey:timeIntervalStep3] floatValue]);
    [self performSelector:@selector(writeSomeLight:) withObject:@[@{kLIGHT_NUMBER:@"3",kLIGHT_VALUE:@"0"},@{kLIGHT_NUMBER:@"6",kLIGHT_VALUE:@"50"},@{kLIGHT_NUMBER:@"2",kLIGHT_VALUE:@"50"},@{kLIGHT_NUMBER:@"1",kLIGHT_VALUE:@"100"},@{kLIGHT_NUMBER:@"8",kLIGHT_VALUE:@"100"} ]];
    [self writeToDevice];
//      [[NSNotificationCenter defaultCenter] postNotificationName:@"takePhotos" object:nil];
    
    //    6.5秒后关闭，同时点亮P0.2 p0.7微亮，P0.6全亮
    usleep(1000000 * [[self.settingDict objectForKey:timeIntervalStep4] floatValue]);
    [self performSelector:@selector(writeSomeLight:) withObject:@[@{kLIGHT_NUMBER:@"6",kLIGHT_VALUE:@"50"},@{kLIGHT_NUMBER:@"1",kLIGHT_VALUE:@"50"},@{kLIGHT_NUMBER:@"2",kLIGHT_VALUE:@"100"},@{kLIGHT_NUMBER:@"8",kLIGHT_VALUE:@"100"}]];
    [self writeToDevice];
//      [[NSNotificationCenter defaultCenter] postNotificationName:@"takePhotos" object:nil];
    
    
    //    5.5秒后 关闭 P0.2 P0.7 P0.6全亮
    usleep(1000000 * [[self.settingDict objectForKey:timeIntervalStep5] floatValue]);
    [self performSelector:@selector(writeSomeLight:) withObject:@[@{kLIGHT_NUMBER:@"6",kLIGHT_VALUE:@"0"},@{kLIGHT_NUMBER:@"1",kLIGHT_VALUE:@"0"},@{kLIGHT_NUMBER:@"2",kLIGHT_VALUE:@"100"},@{kLIGHT_NUMBER:@"8",kLIGHT_VALUE:@"100"} ]];
    [self writeToDevice];
//      [[NSNotificationCenter defaultCenter] postNotificationName:@"takePhotos" object:nil];
    
    
    //    1秒后关闭p0.6,点亮P0.2
    usleep(1000000 * [[self.settingDict objectForKey:timeIntervalStep6] floatValue]);
    [self performSelector:@selector(writeSomeLight:) withObject:@[@{kLIGHT_NUMBER:@"2",kLIGHT_VALUE:@"0"},@{kLIGHT_NUMBER:@"6",kLIGHT_VALUE:@"100"},@{kLIGHT_NUMBER:@"8",kLIGHT_VALUE:@"100"}]];
    [self writeToDevice];
//      [[NSNotificationCenter defaultCenter] postNotificationName:@"takePhotos" object:nil];
    
    
    
    usleep(1000000);
    memset(global_light_data, 0, 8);//清空数据，防止影响其他功能。
    [self writeToDevice];
    
}

//同时点亮多个光源
- (void)writeSomeLight:(NSArray *)array{
    
    for (NSDictionary *dict in array) {
        
        NSInteger lightNum = [[dict objectForKey:kLIGHT_NUMBER] integerValue];
        int         value = [[dict objectForKey:kLIGHT_VALUE] intValue];
        
        
        [self writeLight:lightNum withValue:value];
    }
    
}


- (void)writeLight:(NSInteger)lightNum withValue:(int)value{
    
    if (![self connected]){
        
        return;
    }
    
    memset(global_light_data + 8 - lightNum, value, 1);
    
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


- (void)writeToDevice{
    
    BlueToothManager    *manager = [BlueToothManager shareInstance];
    NSData  *data = [NSData dataWithBytes:global_light_data length:8];
    [manager writeValue:data forCBCharacteristic:[manager characterForUUID:kCharacteristicUUID] ToPeripheral:self.device];
}


- (void)alert:(NSString *)string{
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:string message:@"通知" delegate:self cancelButtonTitle:@"返回" otherButtonTitles:@"确定   ", nil];
    
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    //    [imagePickerController dismissViewControllerAnimated:YES completion:nil];
    
    if (buttonIndex == 0) {
        [imagePickerController dismissViewControllerAnimated:YES completion:nil];
    }
}


- (void)takePhoto{
    
    [imagePickerController takePicture];
}

- (void)writeSuccess:(NSNotification *)noti
{
    if ([noti.object integerValue] == 0) {
        
        return;
    }else
    {
        [self takePhoto];
    }
}


-(BOOL)boolForWethearCameraAuth
{
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        
        return  NO;
    }
    return YES;
}

- (void)openCamera{
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        if (!imagePickerController) {
            imagePickerController=[[UIImagePickerController alloc] init];
        }
        
        imagePickerController.sourceType=UIImagePickerControllerSourceTypeCamera;
        imagePickerController.showsCameraControls = NO;
        imagePickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        imagePickerController.delegate = self;
        imagePickerController.modalTransitionStyle=UIModalTransitionStyleCoverVertical;
        
        
        UITableView *tb = [self createTableView];
        tb.transform = CGAffineTransformRotate(tb.transform, -M_PI_2);//逆时针90度旋转
        tb.backgroundColor = [UIColor blackColor];
        imagePickerController.cameraOverlayView = tb;
        
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }

}

- (UITableView *)createTableView{
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2.0 - TB_WIDTH/2.0,  SCREEN_HEIGHT - TB_HEIGHT/2.0 - TB_Y_OFFSET * 2, TB_WIDTH, TB_HEIGHT)];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.showsHorizontalScrollIndicator = NO;
    tableView.showsVerticalScrollIndicator = NO;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView = tableView;
    
    return tableView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    PhotosTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"takePhotos"];
    
    if (!cell) {
        cell = [[PhotosTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"takePhotos"];
        cell.transform = CGAffineTransformRotate(cell.transform, M_PI_2); //顺时针 90度旋转
    }
    
    cell.headImageView.image = [self.dataArray objectAtIndex:indexPath.row];
    return cell;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return TB_WIDTH;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    [imagePickerController dismissViewControllerAnimated:NO completion:nil];
    
    
    PhotoDetailViewController *vc = [[PhotoDetailViewController alloc] init];
    vc.imageArray = [self.dataArray mutableCopy];
    
    //    [self presentViewController:vc animated:YES completion:nil];
    
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)clicked{
    
    NSLog(@"btn clicked");
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    UIImage * image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    //    NSLog(@"image size = %@",NSStringFromCGSize( image.size));
    [self.dataArray addObject:image];
    [self.tableView reloadData];
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [self downLoadCurrentImage:image];
    });
}

-(void)downLoadCurrentImage:(UIImage *)image
{
    ALAssetsLibrary * assetsLibrary = [[ALAssetsLibrary alloc]init];
    NSMutableArray * groups = [[NSMutableArray alloc]init];
    ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(ALAssetsGroup * group, BOOL * stop)
    {
        if(group)
        {
            [groups addObject:group];
        }
        else
        {
            BOOL haveHDRGroup = NO;
            for(ALAssetsGroup * gp in groups)
            {
                NSString * name = [gp valueForProperty:ALAssetsGroupPropertyName];
                if([name isEqualToString:@"美容院"])
                {
                    haveHDRGroup = YES;
                }
            }
            if(!haveHDRGroup)
            {
                [assetsLibrary addAssetsGroupAlbumWithName:@"美容院" resultBlock:^(ALAssetsGroup *group) {
                    
                    if (!group) {
                        //
                        //                        [UIToastView showToastViewWithContent:@"图片下载失败" andRect:CGRectMake(contrl.center.x - 100, contrl.center.y - 25, 200, 50) andTime:2.0 andObjectView:contrl];
                        return ;
                    }else
                        [groups addObject:group];
                } failureBlock:nil];
                //                haveHDRGroup = YES;
            }
        }
    };
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:listGroupBlock failureBlock:nil];
    
    [self saveToAlbumWithMetaData:nil imageData:UIImagePNGRepresentation(image) customAlbumName:@"美容院" completionBlock:^{
        //        [UIToastView showToastViewWithContent:@"图片下载成功" andRect:CGRectMake(contrl.center.x - 100, contrl.center.y - 25, 200, 50) andTime:2.0 andObjectView:contrl];
        
    } failureBlock:^(NSError *error) {
        //        [UIToastView showToastViewWithContent:@"图片下载失败" andRect:CGRectMake(contrl.center.x - 100, contrl.center.y - 25, 200, 50) andTime:2.0 andObjectView:contrl];
    }];
}

-(void)saveToAlbumWithMetaData:(NSDictionary *)metaData imageData:(NSData *)imageData customAlbumName:(NSString *)customAlbumName completionBlock:(void(^)(void))completionBlock failureBlock:(void (^) (NSError * error))failureBlock
{
    ALAssetsLibrary * assetsLibrary = [[ALAssetsLibrary alloc]init];
    void (^AddAsset)(ALAssetsLibrary *,NSURL *) = ^(ALAssetsLibrary * assetsLibray,NSURL * assetURL)
    {
        [assetsLibrary assetForURL:assetURL resultBlock:^(ALAsset *asset) {
            [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                if([[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:customAlbumName])
                {
                    [group addAsset:asset];
                    if(completionBlock)
                    {
                        completionBlock();
                    }
                }
            } failureBlock:^(NSError *error) {
                if(failureBlock)
                {
                    failureBlock(error);
                }
            }];
        } failureBlock:^(NSError *error) {
            if(failureBlock)
            {
                failureBlock(error);
            }
        }];
    };
    
    [assetsLibrary writeImageDataToSavedPhotosAlbum:imageData metadata:metaData completionBlock:^(NSURL *assetURL, NSError *error) {
        if(customAlbumName)
        {
            [assetsLibrary addAssetsGroupAlbumWithName:customAlbumName resultBlock:^(ALAssetsGroup *group) {
                if(group)
                {
                    [assetsLibrary assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                        [group addAsset:asset];
                        if(completionBlock)
                        {
                            completionBlock();
                        }
                    } failureBlock:^(NSError *error) {
                        if(failureBlock)
                        {
                            failureBlock(error);
                        }
                    }];
                }
                else
                {
                    AddAsset(assetsLibrary,assetURL);
                }
            } failureBlock:^(NSError *error) {
                AddAsset(assetsLibrary,assetURL);
            }];
        }
        else
        {
            if(completionBlock)
            {
                completionBlock();
            }
        }
    }];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
