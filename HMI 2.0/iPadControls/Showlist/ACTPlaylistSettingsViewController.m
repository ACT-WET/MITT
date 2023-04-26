 //
//  ACTPlaylistSettingsViewController.m
//  iPadControls
//
//  Created by Ryan Manalo on 3/18/14.
//  Copyright (c) 2014 WET. All rights reserved.
//

#import "ACTPlaylistSettingsViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "ACTDesignateTestShowViewController.h"
#import "iPadControls-Swift.h"

@interface ACTPlaylistSettingsViewController ()
@property (weak, nonatomic) NSArray *paths;
@property (weak, nonatomic) NSObject *scanStateObj;
@property (weak, nonatomic) NSString *docDir;
@property (weak, nonatomic) NSString *filePath;
@property (nonatomic) NSString *data;
@property (nonatomic) int selectedShow;
@property (nonatomic) int loopCount;
@property (nonatomic) int dismiss;
@property (nonatomic) int currentScanShow;
@property (nonatomic) int totalNumShows;
@property (nonatomic) int currentScanTestShow;
@property (nonatomic) int totalNumTestShows;
@property (nonatomic) int scanState;
@property (nonatomic) NSMutableDictionary *masterSettings;
@property (weak, nonatomic) IBOutlet UILabel *showScannerCountdown;
@property (nonatomic) NSTimer *countdownTimer;
@property (nonatomic) NSTimer *dismissPopoverTimer;

@end

@implementation ACTPlaylistSettingsViewController{
    
    ACTDesignateTestShowViewController *controller;
    UIPopoverController *popoverDesignateTestShow;
}


-(void)initializeFile{
    
    [_screenName setText:@"SHOWLIST"];
        self.navigationItem.title = [NSString stringWithFormat:@"SHOWLIST SETTINGS"];
    _textField1.keyboardType = UIKeyboardTypeNumberPad;
    _textField5.keyboardType = UIKeyboardTypeNumberPad;
    
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    _manager = [NSFileManager defaultManager];
    [self initializeFile];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    _paths = nil;
    _docDir = nil;
    _filePath = nil;
    _data = nil;
    _masterSettings = nil;
    _showScannerCountdown = nil;
    _countdownTimer = nil;
    
}

-(IBAction)showScanner:(id)sender{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"1" forKey:@"scanningShows"];
    NSString *ip = [defaults objectForKey:@"serverIpAddress"];
    NSString *pass = @"http://wet_act:A3139gg1121@";
    NSString *fullpath = [NSString stringWithFormat:@"%@%@:8080/startShowScanner", pass, ip];     // StandardShows Scanner
//    NSString *fullpath = [NSString stringWithFormat:@"%@%@:8080/startTestShowScanner", pass, ip]; // TestShows Scanner
//    NSString *fullpath = [NSString stringWithFormat:@"%@%@:8080/startHighShowScanner", pass, ip]; // HighShows Scanner
    
   
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
           
    [manager GET:fullpath parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject){
         _showScannerCountdown.text = [NSString stringWithString:@"SCANNING SHOWS FROM SPM"];
        _countdownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDOwnTime) userInfo:nil repeats:YES];
        
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        _showScannerCountdown.text = [NSString stringWithString:@"ERROR SCANNING SHOWS"];
        NSLog(@"Error: %@", error);
        
    }];
    
}

-(void)countDOwnTime{
    [self checkScanStatus];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *ip = [defaults objectForKey:@"serverIpAddress"];
    NSString *pass = @"http://wet_act:A3139gg1121@";
    _scanState = [[defaults objectForKey:@"scanningShows"] intValue];
    _currentScanShow = [[defaults objectForKey:@"showScanned"] intValue];
    _totalNumShows = [[defaults objectForKey:@"numberOfSPMShows"] intValue];
    _currentScanTestShow = [[defaults objectForKey:@"testshowScanned"] intValue];
    _totalNumTestShows = [[defaults objectForKey:@"numberOfSPMTestShows"] intValue];
    if (_scanState == 1){
        if (_currentScanTestShow != 0){
           _showScannerCountdown.text = [NSString stringWithFormat:@" TEST SHOWS: %i / %i",_currentScanTestShow, _totalNumTestShows];
        } else {
           _showScannerCountdown.text = [NSString stringWithFormat:@" REG SHOWS: %i / %i",_currentScanShow, _totalNumShows];
        }
    } else {
        [_countdownTimer invalidate];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        NSString *fullpath = [NSString stringWithFormat:@"%@%@:8080/readShows", pass, ip];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
        
        [manager GET:fullpath parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject){
           _showScannerCountdown.text = [NSString stringWithString:@"SHOW SCAN COMPLETE"];
            [defaults setObject:responseObject forKey:@"shows"];
           
        }failure:^(AFHTTPRequestOperation *operation, NSError *error){
            
            NSLog(@"Failed to read shows after scanning them");
            NSLog(@"Error: %@", error);
            
        }];
    }
}

-(IBAction)slideFrameUp;{
    
    [self slideFrame:YES];
    
}

-(IBAction)slideFrameDown{
    [self slideFrame:NO];
    
}

-(void)slideFrame:(BOOL)up{
    
    const int movementDistance = 200;
    const float movementDuration = 0.5f;
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
    
}

-(void)viewDidLoad{
    
    [super viewDidLoad];
}

-(void)didReceiveMemoryWarning{
    
    [super didReceiveMemoryWarning];
    
}

-(IBAction)designateTestShowsPopover:(id)sender{
    
    controller = [[ACTDesignateTestShowViewController alloc] init];
    popoverDesignateTestShow = [[UIPopoverController alloc] initWithContentViewController:controller];
    popoverDesignateTestShow.delegate = self;
    
    if([popoverDesignateTestShow isPopoverVisible]){
        
        [popoverDesignateTestShow dismissPopoverAnimated:YES];
        
    }else{
        
        //the rectangle here is the frame of the object that presents the popover,
        //in this case, the UIButton…
        CGRect popRect = CGRectMake(self.view.center.x,self.view.center.y + 20,1,1);
        [popoverDesignateTestShow presentPopoverFromRect:popRect
                                                  inView:self.view
                                permittedArrowDirections:NO
                                                animated:YES];
        
        _dismissPopoverTimer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(dismissPopoverView) userInfo:nil repeats:YES];
        
    }
}

-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController{
    
    [self dismissPopoverView];
    [_dismissPopoverTimer invalidate];
    _dismissPopoverTimer = nil;
    
}

-(void)dismissPopoverView{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _dismiss = [[defaults objectForKey:@"dismissTestShows"] intValue];

    if (_dismiss){
        
        [_dismissPopoverTimer invalidate];
        _dismissPopoverTimer = nil;
        
        [popoverDesignateTestShow dismissPopoverAnimated:YES];
        [defaults setObject:@"0" forKey:@"dismissTestShows"];
        
    }
    
}




@end
