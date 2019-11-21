//
//  diyCell.h
//  demo_blueTooth
//
//  Created by LZP on 2017/7/21.
//  Copyright © 2017年 LZP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface diyCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UILabel *UUIDLabel;

@property (weak, nonatomic) IBOutlet UILabel *RSSILabel;

@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;

@end
