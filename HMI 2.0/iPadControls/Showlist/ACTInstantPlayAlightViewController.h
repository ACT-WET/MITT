//
//  ACTInstantPlayAlightViewController.h
//  iPadControls
//
//  Created by Rakesh Raveendra on 1/5/23.
//  Copyright © 2023 WET. All rights reserved.
//

#import <UIKit/UIKit.h>

#define TAG_TEXT_FIELD 10000
#define CELL_REUSE_IDENTIFIER @"EditableTextCell"

@interface ACTInstantPlayAlightViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) NSFileManager *manager;

@property (weak, nonatomic) IBOutlet UIImageView *handMode;
@property (weak, nonatomic) IBOutlet UIImageView *autoMode;
@property (weak, nonatomic) IBOutlet UIButton *autoHandToggle;
@property (weak, nonatomic) IBOutlet UILabel *noConnectionLabel;
@property (weak, nonatomic) IBOutlet UIView *noConnectionView;


@end

