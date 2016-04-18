//
//  PhotosTableViewCell.m
//  blueToothCamera
//
//  Created by caiyue on 15/12/1.
//  Copyright © 2015年 soufun. All rights reserved.
//

#import "PhotosTableViewCell.h"
#import "BlueToothManager.h"

@implementation PhotosTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        
        [self createView];
    }
    
    return self;
}


- (void)createView{
    
    
    UIImageView *imageView = [[ UIImageView alloc] initWithFrame:CGRectMake(0, 0, TB_WIDTH, TB_WIDTH)];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:imageView];
    self.headImageView = imageView;
}

@end
