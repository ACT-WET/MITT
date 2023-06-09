//
//  ACTSelectShowLakeViewController.h
//  iPadControls
//
//  Created by Rakesh Raveendra on 1/9/23.
//  Copyright © 2023 WET. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ACTPlaylistLakeViewController.h"

#define TAG_TEXT_FIELD 10000
#define CELL_REUSE_IDENTIFIER @"EditableTextCell"
@interface ACTSelectShowLakeViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIPopoverControllerDelegate, UIPickerViewDelegate>

@property (weak, nonatomic) NSFileManager *manager;
@property (nonatomic, copy) NSArray *contents;
@end
