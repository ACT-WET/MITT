//
//  ACTCalendarScheduleLakeViewController.h
//  iPadControls
//
//  Created by Rakesh Raveendra on 1/9/23.
//  Copyright © 2023 WET. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RDVCalendarViewController.h"

@interface ACTCalendarScheduleLakeViewController : UIViewController <RDVCalendarViewDelegate>
@property (weak, nonatomic) NSFileManager *manager;
@end
