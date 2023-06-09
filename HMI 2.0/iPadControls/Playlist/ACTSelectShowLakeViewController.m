//
//  ACTSelectShowLakeViewController.m
//  iPadControls
//
//  Created by Rakesh Raveendra on 1/9/23.
//  Copyright © 2023 WET. All rights reserved.
//

#import "ACTSelectShowLakeViewController.h"
#import "AFHTTPRequestOperationManager.h"

@interface ACTSelectShowLakeViewController ()
@property (nonatomic) UITableView *showTable;
@property (nonatomic) NSMutableArray *lakeshows;
@property (nonatomic) NSMutableArray *showColors;
@property (nonatomic) NSArray *paths;
@property (nonatomic) NSString *docDir;
@property (nonatomic) NSString *filePath;
@property (nonatomic) NSString *data;
@property (nonatomic) NSInteger selectedShow;
@property (nonatomic) ACTPlaylistLakeViewController *controller;
@property (nonatomic) NSMutableDictionary *settings;
@property (nonatomic) UIPickerView *loopPicker;
@property (nonatomic) int loopCount;
@property (nonatomic) UILabel *selectAShow;
@property (nonatomic, strong) NSDictionary *langData;
@end

@implementation ACTSelectShowLakeViewController


-(void)readInternalShowFile{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults objectForKey:@"lakeshows"]){
        
        _lakeshows = [[NSMutableArray alloc] initWithArray:[defaults objectForKey:@"lakeshows"]];
        [_showTable reloadData];
        _showColors = [[NSMutableArray alloc] init];
        
        for(int i = 0; i <_lakeshows.count; i++){
            
            [_showColors addObject:_lakeshows[i][@"color"]];
            
        }
    }
}

-(void)createShowTableView{
    
    UILabel *lakeshows = [[UILabel alloc] initWithFrame:CGRectMake(130, 42, 140, 25)];
    lakeshows.textColor = [UIColor colorWithRed:200.0f/255.0f green:200.0f/255.0f blue:200.0f/255.0f alpha:1.0f];
    lakeshows.font = [UIFont fontWithName:@"Verdana" size:24];
    lakeshows.textAlignment = NSTextAlignmentCenter;
    lakeshows.text = _langData[@"SHOWS"];
    [self.view addSubview:lakeshows];

    _showTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 100, 400, 270) style:UITableViewStylePlain];
    _showTable.backgroundColor = [UIColor colorWithRed:50.0f/255.0f green:50.0f/255.0f blue:50.0f/255.0f alpha:1.0f];
    _showTable.scrollEnabled = NO;
    _showTable.delegate = self;
    _showTable.dataSource = self;
    _showTable.scrollEnabled = YES;
    
    [self.view addSubview:_showTable];
    
}

#pragma mark - Table View Data Source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _lakeshows.count  - 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"EditableTextCell"];

    int duration = [[[_lakeshows objectAtIndex:indexPath.row + 1] objectForKey:@"duration"] intValue];
    int min = duration/60;
    int sec = duration % 60;
    
    
    if ([[_lakeshows objectAtIndex:indexPath.row + 1] objectForKey:@"test"]) {
        bool testShow = [[[_lakeshows objectAtIndex:indexPath.row + 1] objectForKey:@"test"] boolValue];
        
        if (duration == 0 || testShow ) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.hidden = YES;
        }
    } else {
        if (duration == 0 ) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.hidden = YES;
        }
    }
    
    
    cell.textLabel.text = [[_lakeshows objectAtIndex:indexPath.row + 1] objectForKey:@"name"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@%d:%@%d", min < 10 ? @"0" : @"" , min,  sec < 10 ? @"0" : @"", sec];
    
    cell.detailTextLabel.textColor =[UIColor colorWithRed:200.0f/255.0f green:200.0f/255.0f blue:200.0f/255.0f alpha:1.0f];
    cell.detailTextLabel.font = [UIFont fontWithName:@"Verdana" size:16];
    
    cell.textLabel.textColor =[UIColor colorWithRed:200.0f/255.0f green:200.0f/255.0f blue:200.0f/255.0f alpha:1.0f];
    cell.textLabel.font = [UIFont fontWithName:@"Verdana" size:16];
    cell.backgroundColor = [UIColor colorWithRed:50.0f/255.0f green:50.0f/255.0f blue:50.0f/255.0f alpha:1.0f];
    
    
    UIView* separatorLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 400, 0.27)];/// change size as you need.
    separatorLineView.backgroundColor = [UIColor colorWithRed:150.0f/255.0f green:150.0f/255.0f blue:150.0f/255.0f alpha:1.0f];// you can also put image here
    [cell.contentView addSubview:separatorLineView];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    float heightForRow = 40;
    int duration = [[[_lakeshows objectAtIndex:indexPath.row + 1] objectForKey:@"lakeduration"] intValue];
    
    
    if ([[_lakeshows objectAtIndex:indexPath.row + 1] objectForKey:@"laketest"]) {
        bool testShow = [[[_lakeshows objectAtIndex:indexPath.row + 1] objectForKey:@"laketest"] boolValue];
        
        if (duration == 0 || testShow ) {
            return 0;
        }
    } else {
        if (duration == 0 ) {
            return 0;
        }
    }
    
    return heightForRow;
    
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return (indexPath.section == 0);
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = (UITableViewCell *)[_showTable cellForRowAtIndexPath:indexPath];
    
    if (![cell.detailTextLabel.text isEqual:@"00:00"]){
        
        _selectedShow = indexPath.row + 1;
        _selectAShow.alpha = 0;
        
    }else{
        
        NSLog(@"selected %ld", (long)_selectedShow);
        [_showTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:_selectedShow - 1 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];

    }

}

-(void)viewDidLoad{
    
    NSArray *availableLanguages = @[@"zh", @"ko", @"en", @"es", @"ar", @"ru", @"tr"];
    NSString *bestMatchedLanguage = [NSBundle preferredLocalizationsFromArray:(availableLanguages) forPreferences:[NSLocale preferredLanguages]][0];

    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"languages" ofType:@"json"];
    NSData* json = [NSData dataWithContentsOfFile:filePath];
    
    NSDictionary* data = [NSJSONSerialization JSONObjectWithData:json
                                                         options:NSJSONReadingAllowFragments
                                                           error:nil];
    
    _langData = [[NSDictionary alloc] initWithDictionary:data[bestMatchedLanguage][@"playlist"]];
    
    [super viewDidLoad];
    _manager = [NSFileManager defaultManager];

    [self readInternalShowFile];
    
    self.preferredContentSize = CGSizeMake(400.0, 660);
    self.view.backgroundColor = [UIColor colorWithRed:60.0f/255.0f green:60.0f/255.0f blue:60.0f/255.0f alpha:1.0f];
    [self createShowTableView];
    [self createPicker];
    
    _selectAShow = [[UILabel alloc] initWithFrame:CGRectMake(210,490, 180, 25)];
    _selectAShow.textColor = [UIColor colorWithRed:235.0f/255.0f green:30.0f/255.0f blue:35.0f/255.0f alpha:1.0f];
    _selectAShow.font = [UIFont fontWithName:@"Verdana" size:14];
    _selectAShow.textAlignment = NSTextAlignmentCenter;
    _selectAShow.text = @"SELECT SHOW";
    _selectAShow.alpha = 0;
    [self.view addSubview:_selectAShow];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:NO];
    
    _manager = nil;
    _contents = nil;
    _showTable = nil;
    _lakeshows = nil;
    _showColors = nil;
    _paths = nil;
    _docDir = nil;
    _filePath = nil;
    _data = nil;
    _controller = nil;
    _settings = nil;
    _loopPicker = nil;
    _selectAShow = nil;
    _langData = nil;

}

-(void)createPicker{
    
    UILabel *loopLabel = [[UILabel alloc] initWithFrame:CGRectMake(100,395, 200, 20)];
    loopLabel.textColor = [UIColor colorWithRed:200.0f/255.0f green:200.0f/255.0f blue:200.0f/255.0f alpha:1.0f];
    loopLabel.font = [UIFont fontWithName:@"Verdana" size:18];
    loopLabel.textAlignment = NSTextAlignmentCenter;
    loopLabel.text = _langData[@"LOOP COUNT"];
    [self.view addSubview:loopLabel];
    
    UIButton *addButton = [[UIButton alloc] initWithFrame:CGRectMake(165,595, 70, 30)];
    [addButton setBackgroundImage:[UIImage imageNamed:@"button_background"] forState:UIControlStateNormal];
    [addButton setTitle:_langData[@"ADD"] forState:UIControlStateNormal];
    [addButton.titleLabel setFont:[UIFont fontWithName:@"Verdana-Bold" size:12]];
    [addButton addTarget:self action:@selector(addShow) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:addButton];
    
    _loopPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(-7,415, 407, 179)];
    _loopPicker.delegate = self;
    _loopPicker.showsSelectionIndicator = YES;
    _loopPicker.backgroundColor = [UIColor colorWithRed:60.0f/255.0f green:60.0f/255.0f blue:60.0f/255.0f alpha:1.0f];
    
    [self.view addSubview:_loopPicker];
    
    [_loopPicker selectRow:0 inComponent:0 animated:NO];
    _loopCount = 1;
    
}

-(void)addShow{
    
    if(_selectedShow){
    
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[NSNumber numberWithInt: (int)_selectedShow] forKey:@"lakeselectedShow"];
        [defaults setObject:[NSNumber numberWithInt: (int)_loopCount] forKey:@"lakeloopCount"];
        [defaults setObject:[NSNumber numberWithInt: (int)1] forKey:@"lakedismiss"];

    }else{
        _selectAShow.alpha = 1;
    }

}

-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, pickerView.frame.size.width, 44)];
    label.textColor = [UIColor colorWithRed:200.0f/255.0f green:200.0f/255.0f blue:200.0f/255.0f alpha:1.0f];
    label.font = [UIFont fontWithName:@"Verdana" size:24];
    label.text = [NSString stringWithFormat:@" %i", (int)row+1];
    label.textAlignment = NSTextAlignmentCenter;
    return label;
    
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component{
    
    _loopCount = (int)row + 1;
    NSLog(@"loop count: %i", _loopCount);
    
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    
    NSUInteger numRows = 10;
    return numRows;
    
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    return [NSString stringWithFormat:@"%i", (int)row + 1];
}

-(CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    int sectionWidth = 400;
    return sectionWidth;
}

@end
