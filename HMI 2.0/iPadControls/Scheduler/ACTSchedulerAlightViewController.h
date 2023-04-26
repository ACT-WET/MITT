//
//  ACTSchedulerAlightViewController.h
//  iPadControls
//
//  Created by Rakesh Raveendra on 1/9/23.
//  Copyright © 2023 WET. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ACTUISafeNavigationController.h"

@interface ACTSchedulerAlightViewController : UIViewController <UIScrollViewDelegate, UIPopoverControllerDelegate, UIAlertViewDelegate, ACTUISafeNavigationDelegate>
@property (weak, nonatomic) IBOutlet UIView *pinchZoomView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *timeScrollView;
@property (weak, nonatomic) NSFileManager *manager;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIButton *regSched;
@property (weak, nonatomic) IBOutlet UIButton *sp1Sched;
@property (weak, nonatomic) IBOutlet UIButton *sp2Sched;
@property (weak, nonatomic) IBOutlet UIButton *sp3Sched;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIView *noConnection;
@property (weak, nonatomic) IBOutlet UIButton *clearWeek;
@property (weak, nonatomic) IBOutlet UILabel *noConnectionLabel;
@property (weak, nonatomic) IBOutlet UIButton *scheduleList;

@end
