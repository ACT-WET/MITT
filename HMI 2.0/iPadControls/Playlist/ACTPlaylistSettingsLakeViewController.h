//
//  ACTPlaylistSettingsLakeViewController.h
//  iPadControls
//
//  Created by Rakesh Raveendra on 1/6/23.
//  Copyright © 2023 WET. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ACTPlaylistSettingsLakeViewController : UIViewController  <UIPopoverControllerDelegate>
@property (weak, nonatomic) NSFileManager *manager;
@property (weak, nonatomic) IBOutlet UITextField *screenName;
@property (weak, nonatomic) IBOutlet UITextField *textField1; // IP Address
@property (weak, nonatomic) IBOutlet UITextField *textField2; // autoMan
@property (weak, nonatomic) IBOutlet UITextField *textField3; // manPlay
@property (weak, nonatomic) IBOutlet UITextField *textField5; // PLC IP
@property (weak, nonatomic) IBOutlet UITextField *outOfRangeMessage;
@property (weak, nonatomic) IBOutlet UITextField *scanUpTo;
@end
