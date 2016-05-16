//
//  PhotoDetailViewController.m
//  blueToothCamera
//
//  Created by caiyue on 15/12/1.
//  Copyright © 2015年 soufun. All rights reserved.
//

#import "PhotoDetailViewController.h"
#import "BlueToothManager.h"

@implementation PhotoDetailViewController

- (instancetype)init
{
    if (self = [super init]) {
        
        return self;
    }
    
    return nil;
}


- (void)loadView
{
    
    UIScrollView    *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    scrollView.contentSize = CGSizeMake(SCREEN_WIDTH * self.imageArray.count, SCREEN_HEIGHT);
    scrollView.pagingEnabled = YES;
    self.view = scrollView;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithTitle:@"退出" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = left;
    
    for (int i = 0; i < self.imageArray.count && self.imageArray.count > 0; i++) {
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:self.imageArray[i]];
        imageView.userInteractionEnabled = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.frame = CGRectMake(i * SCREEN_WIDTH, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        [self.view addSubview:imageView];
    }
}


- (void)back{
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    
    static  BOOL    hidden = NO;
    UITouch *touch   = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];
    
    
    if (point.y > 64 ) {
        
        [self.navigationController.navigationBar setHidden:!hidden];
    }
}

@end
