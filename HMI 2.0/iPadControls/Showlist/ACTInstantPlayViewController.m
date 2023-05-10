//
//  ACTInstantPlayViewController.m
//  iPadControls
//
//  Created by Ryan Manalo on 11/21/14.
//  Copyright (c) 2014 WET. All rights reserved.
//

#import "ACTInstantPlayViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "iPadControls-Swift.h"

@interface ACTInstantPlayViewController ()

@property (weak, nonatomic) IBOutlet UITableView *showTable;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;

@property (weak, nonatomic) NSArray *paths;
@property (weak, nonatomic) NSString *docDir;
@property (weak, nonatomic) NSString *filePath;

@property (nonatomic) NSMutableDictionary *settings;
@property (nonatomic) NSTimer *getStopButton;
@property (nonatomic) UILabel *playingShow;
@property (nonatomic) UILabel *timeRemaining;
@property (nonatomic) UIImageView *eStop;
@property (nonatomic) UIImageView *showStopperFire;
@property (nonatomic) UIImageView *showStopperWind;
@property (nonatomic) UIImageView *showStopperWaterLevel;
@property (nonatomic) UIImageView *showStopperAirPressure;
@property (nonatomic) UIImageView *showStopperLockOut;
@property (nonatomic) UIImageView *showStopperRATmode;
@property (nonatomic) NSMutableArray *shows;
@property (nonatomic) UITableViewCell *lastCell;
@property (nonatomic) NSString *ip;
@property (nonatomic) NSString *data;
@property (nonatomic) NSMutableArray *serverErrorCount;
@property (nonatomic) NSInteger canPlayShowOarsmen;
@property (nonatomic) NSInteger thereAreOarsmen;
@property (nonatomic) NSInteger selectedShow;
@property (nonatomic) NSInteger selectedShowDuration;
@property (nonatomic) NSUserDefaults * defaults;
@property (nonatomic, strong) NSDictionary *langData;

@property (nonatomic) int  offSetRegisters;
@property (nonatomic) int  gotInfo;
@property (nonatomic) int  state;
@property (nonatomic) bool isPlaying;
@property (nonatomic) bool justPressedPlay;
@property (nonatomic) bool justPressedStop;

@end

@interface UITableViewCell (ChangeHighlight)

@end

@implementation ACTInstantPlayViewController


#pragma mark - view life cycle

-(void)viewDidLoad{

    [super viewDidLoad];
    
}

#pragma mark - view will appear

-(void)viewWillAppear:(BOOL)animated{
    
    _manager = [NSFileManager defaultManager];
    _defaults = [NSUserDefaults standardUserDefaults];
    
    //Read All The Shows From Local Storage
    [self readInternalShowFile];
    
    //Get Language settings based on device language
    [self getLanguageData];
    
    //Configure text components on the screen
    [self initializeUIComponents];
    
    //Start the initial screen communication configuration
    [self initializeFile];

    
}

#pragma mark - View Will Disappear

-(void)viewWillDisappear:(BOOL)animated{
    
    //Invalidate Play Stop Status Check Point
    [_getStopButton invalidate];
    _getStopButton = nil;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithInt:0] forKey:@"instantPlaySelectedShow"];
    
    [super viewWillDisappear:NO];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

#pragma mark - Memory Management

-(void)didReceiveMemoryWarning{
    
    [super didReceiveMemoryWarning];
    
}

#pragma mark - Construct The Controller

-(void)initializeFile{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _ip = [defaults objectForKey:@"serverIpAddress"];
    
    //Get initial State of SPM: Auto or Hand Mode
    _state = [[defaults objectForKey:@"playMode"] intValue];
    [defaults setObject:[NSNumber numberWithInt:_state] forKey:@"toggledStatus"];
    
    //Start observing for notifications from central station
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkForConnection) name:@"updateSystemStat" object:nil];
    
}

-(void)getLanguageData{
    
    NSArray *availableLanguages = @[@"zh", @"ko", @"en", @"es", @"ar", @"ru", @"tr"];
    NSString *bestMatchedLanguage = [NSBundle preferredLocalizationsFromArray:(availableLanguages) forPreferences:[NSLocale preferredLanguages]][0];
    if([bestMatchedLanguage isEqualToString:@"zh"]){
        bestMatchedLanguage = [bestMatchedLanguage stringByReplacingOccurrencesOfString:@"zh" withString:@"zh-Hans"];
    }
    
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"languages" ofType:@"json"];
    NSData* json = [NSData dataWithContentsOfFile:filePath];
    NSDictionary* data = [NSJSONSerialization JSONObjectWithData:json
                                                         options:NSJSONReadingAllowFragments
                                                           error:nil];
    
    _langData = [[NSDictionary alloc] initWithDictionary:data[bestMatchedLanguage][@"playlist"]];
    
    self.navigationItem.title = _langData[@"SHOWS"];
    
}

-(void)initializeUIComponents{
    
    _playingShow = [[UILabel alloc] initWithFrame:CGRectMake(265, 180, 530, 75)];
    _playingShow.font = [UIFont fontWithName:@"Verdana" size:18];
    _playingShow.textColor = [UIColor colorWithRed:130.0f/255.0f green:180.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
    _playingShow.text = @"NOW PLAYING ";
    _playingShow.textAlignment = NSTextAlignmentLeft;
    _playingShow.alpha = 0;
    [self.view addSubview:_playingShow];
    
    _timeRemaining = [[UILabel alloc] initWithFrame:CGRectMake(705, 180, 200, 75)];
    _timeRemaining.font = [UIFont fontWithName:@"Verdana" size:18];
    _timeRemaining.textColor = [UIColor colorWithRed:130.0f/255.0f green:180.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
    _timeRemaining.text = @"TIME:";
    _timeRemaining.alpha = 0;
    
    [self.view addSubview:_timeRemaining];
    
    _selectedShow = 0;
    
}

//NOTE: Readl All The Shows From Local Storage

-(void)readInternalShowFile{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults objectForKey:@"shows"]){
        
        _shows = [[NSMutableArray alloc] initWithArray:[defaults objectForKey:@"shows"]];
        [_showTable reloadData];
        
    }
}

-(void)createShowTableView{
    
    _showTable.backgroundColor = [UIColor colorWithRed:50.0f/255.0f green:50.0f/255.0f blue:50.0f/255.0f alpha:1.0f];
    _showTable.delegate = self;
    _showTable.dataSource = self;
    _showTable.scrollEnabled = YES;
    [self.view addSubview:_showTable];
    
}

#pragma mark - State Machine

-(void)checkForConnection{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *serverConnectionStatus = [defaults objectForKey:@"ServerConnectionStatus"];
    NSString *plcConnectionStatus   = [defaults objectForKey:@"MITTLAGPLCConnectionStatus"];
    
    if ([plcConnectionStatus isEqualToString:@"MITTLAGPLCConnected"] && [serverConnectionStatus isEqualToString:@"serverConnected"]){
        
        [self readStopButton];
        [self getCurrentShowInfo];
        
        //Hide the no connection view
       
        self.noConnectionView.alpha = 0;
      
        
        //For the first time on view appearence fetch all necessary data and generate shows table
        if (_gotInfo == 0){
            
            [self readInternalShowFile];
            [self createShowTableView];
            _gotInfo = 1;
            
            //Get initial State of SPM: Auto or Hand Mode
            _state = [[defaults objectForKey:@"playMode"] intValue];
            [defaults setObject:[NSNumber numberWithInt:_state] forKey:@"toggledStatus"];
            
        }
        
    } else {
        //Show the no connection view
        self.noConnectionView.alpha = 1;

        if ([plcConnectionStatus isEqualToString:@"plcFailed"] || [serverConnectionStatus isEqualToString:@"serverFailed"]) {
            if ([serverConnectionStatus isEqualToString:@"serverConnected"]) {
                 self.noConnectionLabel.text = @"PLC CONNECTION FAILED, SERVER GOOD";
            } else if ([plcConnectionStatus isEqualToString:@"MITTLAGPLCConnected"]) {
                 self.noConnectionLabel.text = @"SERVER CONNECTION FAILED, PLC GOOD";
            } else {
                 self.noConnectionLabel.text = @"SERVER AND PLC CONNECTION FAILED";
            }
        }
        
         if ([plcConnectionStatus isEqualToString:@"connectingPLC"] || [serverConnectionStatus isEqualToString:@"connectingServer"]) {
             if ([serverConnectionStatus isEqualToString:@"serverConnected"]) {
                   self.noConnectionLabel.text = @"CONNECTING TO PLC, SERVER CONNECTED";
             } else if ([serverConnectionStatus isEqualToString:@"MITTLAGPLCConnected"]) {
                   self.noConnectionLabel.text = @"CONNECTING TO SERVER, PLC CONNECTED";
             } else {
                   self.noConnectionLabel.text = @"CONNECTING TO SERVER AND PLC..";
             }
         }
        
        if ([plcConnectionStatus isEqualToString:@"poorPLC"] && [serverConnectionStatus isEqualToString:@"poorServer"]) {
             self.noConnectionLabel.text = @"SERVER AND PLC POOR CONNECTION";
        } else if ([plcConnectionStatus isEqualToString:@"poorPLC"]) {
             self.noConnectionLabel.text = @"PLC POOR CONNECTION, SERVER CONNECTED";
        } else if ([serverConnectionStatus isEqualToString:@"poorServer"]) {
            self.noConnectionLabel.text = @"SERVER POOR CONNECTION, PLC CONNECTED";
        }
     
    }
}


-(void)getCurrentShowInfo{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    int showPlaying = [[defaults objectForKey:@"playStatus"] intValue];
    int currentShow = [[defaults objectForKey:@"currentShowNumber"] intValue];
    int playType = [[defaults objectForKey:@"Show Type"] intValue];
    
    if (playType == 1){
        currentShow = currentShow - 1024;
        NSLog(@"Current Show:  %d",currentShow);
    }
    NSString *showName = [defaults objectForKey:@"currentShowName"];
    NSLog(@"Current Show:  %@",showName);
    NSString *dateStr =  [defaults objectForKey:@"deflate"];
    
    if (showPlaying && currentShow != 0){
        
        _playingShow.text = [NSString stringWithFormat:@"%@: %@", _langData[@"NOW PLAYING"],showName];
        
        if (_playingShow.text.length > 35){
         
            _playingShow.frame = CGRectMake(265 - (_playingShow.text.length - 35)*4, 180, 600, 75);
            _timeRemaining.frame = CGRectMake(705 + (_playingShow.text.length - 35)*4, 180, 200, 75);
            
        }else{
            
            _playingShow.frame = CGRectMake(265, 180, 530, 75);
            _timeRemaining.frame = CGRectMake(705, 180, 200, 75);
            
        }
     
        NSString *blah = [dateStr substringWithRange:NSMakeRange(1, dateStr.length - 2)];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        
        [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
        NSDate *date = [dateFormat dateFromString:blah];
        [dateFormat setDateFormat:@"mm:ss"];
        NSString *date2 = [dateFormat stringFromDate:date];
        
        int minString2 = [[date2 substringToIndex:2] intValue];
        int secString2 = [[date2 substringFromIndex:3] intValue];
        
        NSDate *now =  [[NSDate alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
        NSString *nowString = [dateFormat stringFromDate:now];
        NSString *nowString2 = [nowString substringFromIndex:14];
        NSString *nowString3 = [nowString2 substringToIndex:5];
        
        int minString = [[nowString3 substringToIndex:2] intValue];
        int secString = [[nowString3 substringFromIndex:3] intValue];
        
        if (minString2 > minString){
            minString += 60;
        }
        
        int totalSeconds = secString - secString2 + (minString - minString2)*60;
        int showremaining = [[defaults objectForKey:@"show time remaining"] intValue];
        int showDuration = [[defaults objectForKey:@"showDuration"] intValue] - showremaining;
        int min = showDuration/60;
        int sec = showDuration % 60;
        
        _timeRemaining.text = [NSString stringWithFormat:@"%@: %d:%d", _langData[@"TIME"], min, sec];
        
        if(showDuration <= 0 ){

            _timeRemaining.alpha = 1;
            _playingShow.alpha = 1;
            _lastCell.detailTextLabel.textColor = [UIColor colorWithRed:200.0f/255.0f green:200.0f/255.0f blue:200.0f/255.0f alpha:1.0f];
            _lastCell.textLabel.textColor = [UIColor colorWithRed:200.0f/255.0f green:200.0f/255.0f blue:200.0f/255.0f alpha:1.0f];

        }else{

            _timeRemaining.alpha = 1;
            _playingShow.alpha = 1;
            _lastCell.detailTextLabel.textColor = [UIColor colorWithRed:130.0f/255.0f green:180.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
            _lastCell.textLabel.textColor = [UIColor colorWithRed:130.0f/255.0f green:180.0f/255.0f blue:0.0f/255.0f alpha:1.0f];

        }
        
        _canPlayShowOarsmen = 0;

    }else if (!showPlaying){
        
        _canPlayShowOarsmen = 1;
        _playingShow.alpha = 0;
        _timeRemaining.alpha = 0;
        
    }else{
        
        _playingShow.alpha = 0;
        _timeRemaining.alpha = 0;
        _canPlayShowOarsmen = 0;
        
    }
    
}

-(void)readStopButton{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _state = [[defaults objectForKey:@"playMode"] intValue];
    
    //Check if System is in Manual mode or Auto Mode or Off
    if (_state == 0){
        
        _autoMode.alpha = 1;
        _handMode.alpha = 0;
        [self rotateAutoModeImage:YES];
        _stopButton.hidden = YES;
        
    } else if (_state == 2){
        _autoMode.alpha = 0;
        _handMode.alpha = 0;
        [self rotateAutoModeImage:NO];
        _stopButton.hidden = YES;
    } else if (_state == 1) {
        _autoMode.alpha = 0;
        _handMode.alpha = 1;
        [self rotateAutoModeImage:NO];
        _stopButton.hidden = NO;
        
    }
    
    int showPlayingStatus = [[defaults objectForKey:@"playStatus"] intValue];
    int currentShow = [[defaults objectForKey:@"currentShowNumber"] intValue];
    int playType = [[defaults objectForKey:@"Show Type"] intValue];
    
    if (playType == 1){
        currentShow = currentShow - 1024;
    }
    
    //Check if show is playing or not
    
    if (showPlayingStatus == 1 && currentShow != 0){
        
        if ([_stopButton isEnabled] == NO && _justPressedPlay == YES){
            [_stopButton setEnabled:YES];
            _justPressedPlay = NO;
        }
        
        [_stopButton setImage:[UIImage imageNamed:@"stopButton"] forState:UIControlStateNormal];
        _isPlaying = YES;
        
    }else{
        
        [_stopButton setImage:[UIImage imageNamed:@"playButton"] forState:UIControlStateNormal];
        _isPlaying = NO;
        
        if ([_stopButton isEnabled] == NO && _justPressedStop == YES){
            [_stopButton setEnabled:YES];
            _justPressedStop = NO;
        }
    }
    
}

#pragma mark - Auto and Hand Mode

-(void)rotateAutoModeImage:(BOOL)value{
    
    if(value){
        
        CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        animation.fromValue = @0.0f;
        animation.toValue = @(2*M_PI);
        animation.duration = 1.0f;
        animation.repeatCount = HUGE_VALF;
        [_autoMode.layer addAnimation:animation forKey:@"rotation"];
        
    }else{
        
        CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        animation.fromValue = @0.0f;
        animation.toValue = @0.0f;
        [_autoMode.layer addAnimation:animation forKey:@"rotation"];
        
    }
    
}

#pragma mark - Table View Data Source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _shows.count  - 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"EditableTextCell"];
    
    int duration = [[[_shows objectAtIndex:indexPath.row + 1] objectForKey:@"duration"] intValue];
    int showNumber = [[[_shows objectAtIndex:indexPath.row + 1] objectForKey:@"number"] intValue];
    int min = duration/60;
    int sec = duration % 60;
    
    if (duration == 0){
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.hidden = YES;
    }
    _selectedShow = [[_defaults objectForKey:@"instantPlaySelectedShow"] intValue];
    
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = [[_shows objectAtIndex:indexPath.row + 1] objectForKey:@"name"];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@%d:%@%d", min < 10 ? @"0" : @"" , min,  sec < 10 ? @"0" : @"", sec];
        
        cell.detailTextLabel.textColor =[UIColor colorWithRed:200.0f/255.0f green:200.0f/255.0f blue:200.0f/255.0f alpha:1.0f];
        cell.detailTextLabel.font = [UIFont fontWithName:@"Verdana" size:16];
        
        cell.textLabel.textColor =[UIColor colorWithRed:200.0f/255.0f green:200.0f/255.0f blue:200.0f/255.0f alpha:1.0f];
        cell.textLabel.font = [UIFont fontWithName:@"Verdana" size:16];
        cell.backgroundColor = [UIColor colorWithRed:50.0f/255.0f green:50.0f/255.0f blue:50.0f/255.0f alpha:1.0f];
  
   
    if (indexPath.row == _selectedShow - 1){
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.detailTextLabel.textColor = [UIColor colorWithRed:130.0f/255.0f green:180.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
        cell.textLabel.textColor = [UIColor colorWithRed:130.0f/255.0f green:180.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
        
    }
    
//    if (indexPath.row == _selectedShow - 1){
//
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        cell.detailTextLabel.textColor = [UIColor colorWithRed:130.0f/255.0f green:180.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
//        cell.textLabel.textColor = [UIColor colorWithRed:130.0f/255.0f green:180.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
//
//    }
    
    UIView *separatorLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 550, 0.27)];
    separatorLineView.backgroundColor = [UIColor colorWithRed:150.0f/255.0f green:150.0f/255.0f blue:150.0f/255.0f alpha:1.0f];
    [cell.contentView addSubview:separatorLineView];
    
    return cell;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    float heightForRow = 40;
    int duration = [[[_shows objectAtIndex:indexPath.row + 1] objectForKey:@"duration"] intValue];
    
    if(duration == 0)
        return 0;
    else
        return heightForRow;
    
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return (indexPath.section == 0);
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //Select show to play
    [self playShow:indexPath];
    
}

#pragma mark - Play/Stop Shows

-(void)playShow:(NSIndexPath *)indexPath{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (_lastCell){
        _lastCell.detailTextLabel.textColor = [UIColor colorWithRed:200.0f/255.0f green:200.0f/255.0f blue:200.0f/255.0f alpha:1.0f];
        _lastCell.textLabel.textColor =  [UIColor colorWithRed:200.0f/255.0f green:200.0f/255.0f blue:200.0f/255.0f alpha:1.0f];
    }
    
    UITableViewCell *cell = (UITableViewCell *)[_showTable cellForRowAtIndexPath:indexPath];
    
    _lastCell = (UITableViewCell *)[_showTable cellForRowAtIndexPath:indexPath];
    
    if(![cell.detailTextLabel.text isEqual:@"00:00"]){
        
        _selectedShow = [[[_shows objectAtIndex:indexPath.row + 1] objectForKey:@"number"] intValue];
        _selectedShowDuration = [[[_shows objectAtIndex:indexPath.row + 1] objectForKey:@"duration"] intValue];
        
        //If Show System is in Manual Mode then highlight the show on selection
        if (_state == 1){
            
            [defaults setObject:[NSNumber numberWithInt:(int)indexPath.row + 1] forKey:@"instantPlaySelectedShow"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.detailTextLabel.textColor = [UIColor colorWithRed:130.0f/255.0f green:180.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
            cell.textLabel.textColor = [UIColor colorWithRed:130.0f/255.0f green:180.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
        }
        
    }else{
        
        [_showTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:_selectedShow - 1 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
        
    }
    
    NSString *fullpath = [NSString stringWithFormat:@"http://wet_act:A3139gg1121@%@:8080/autoManPlay?0",_ip];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    
    [manager GET:fullpath parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject){
        
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        
    }];
    
    if ([[[_shows objectAtIndex:indexPath.row + 1] objectForKey:@"test"] intValue] == 1){
        NSArray *updatePlaylist = @[@41, @[[NSNumber numberWithInt:(int)_selectedShow], @1, @1, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0,@0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0],[NSNumber numberWithInt:(int)_selectedShowDuration]];
        
        fullpath = [NSString stringWithFormat:@"http://wet_act:A3139gg1121@%@:8080/writePlaylists",_ip];
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:updatePlaylist options:NSJSONWritingPrettyPrinted error:nil];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSString *escapedDataString = [jsonString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
        NSString *strURL = [NSString stringWithFormat:@"%@?%@", fullpath, escapedDataString];
        
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
        
        [manager GET:strURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject){

        }failure:^(AFHTTPRequestOperation *operation, NSError *error){
            
        }];
    } else {
        NSArray *updatePlaylist = @[@41, @[[NSNumber numberWithInt:(int)_selectedShow], @1, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0,@0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0],[NSNumber numberWithInt:(int)_selectedShowDuration]];
        
        fullpath = [NSString stringWithFormat:@"http://wet_act:A3139gg1121@%@:8080/writePlaylists",_ip];
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:updatePlaylist options:NSJSONWritingPrettyPrinted error:nil];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSString *escapedDataString = [jsonString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
        NSString *strURL = [NSString stringWithFormat:@"%@?%@", fullpath, escapedDataString];
        
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
        
        [manager GET:strURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject){

        }failure:^(AFHTTPRequestOperation *operation, NSError *error){
            
        }];
    }
    
    _lastCell = (UITableViewCell *)[_showTable cellForRowAtIndexPath:indexPath];

}

-(IBAction)stopQuickPlay:(id)sender{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    if (_isPlaying == YES){
        
        NSString *fullpath = [NSString stringWithFormat:@"http://wet_act:A3139gg1121@%@:8080/autoManPlay?0",_ip];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
        
        [manager GET:fullpath parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject){
            
            _lastCell.detailTextLabel.textColor = [UIColor colorWithRed:200.0f/255.0f green:200.0f/255.0f blue:200.0f/255.0f alpha:1.0f];
            _lastCell.textLabel.textColor = [UIColor colorWithRed:200.0f/255.0f green:200.0f/255.0f blue:200.0f/255.0f alpha:1.0f];
            [_stopButton setEnabled:NO];
            _justPressedStop = YES;
            
        }failure:^(AFHTTPRequestOperation *operation, NSError *error){
            
        }];
        
    }else{
        
        NSString *fullpath = [NSString stringWithFormat:@"http://wet_act:A3139gg1121@%@:8080/autoManPlay?1",_ip];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
        
        [manager GET:fullpath parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject){
            
            [_stopButton setEnabled:NO];
            _justPressedPlay = YES;
            
        }failure:^(AFHTTPRequestOperation *operation, NSError *error){
            
        }];
    
    }

}

@end
