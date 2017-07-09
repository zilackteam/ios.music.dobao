//
//  TimePickerViewController.m

//
//  Created by thanhvu on 2/27/16.
//  Copyright © 2016 Zilack. All rights reserved.
//

#import "TimePickerViewController.h"
#import "SBFlatDatePicker.h"
#import "SBFlatDatePickerDelegate.h"

@interface TimePickerViewController ()<SBFLatDatePickerDelegate>

@property(nonatomic, strong) UILabel *timeSettingLabel;
@end

@implementation TimePickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self useMainBackgroundOpacity:0.05];
    
    self.title = LocalizedString(@"tlt_music_time_off");
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(onCancel)];
    
    self.navigationItem.rightBarButtonItem = barButtonItem;
    
    //Init the datePicker view and set self as delegate
    SBFlatDatePicker *datePicker = [[SBFlatDatePicker alloc] initWithFrame:CGRectMake(0, 90, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - 90)];
    [datePicker setDelegate:self];
    [datePicker setBackgroundColor:RGBA(68, 68, 68, 1)];
    
    datePicker.dayRange = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)];
    
    datePicker.minuterange = [NSMutableIndexSet indexSet];
    [datePicker.minuterange addIndex:0];
    [datePicker.minuterange addIndex:15];
    [datePicker.minuterange addIndex:30];
    [datePicker.minuterange addIndex:45];
    
    datePicker.dayFormat = @"dd/MM/yyyy";
    
    [self setView:datePicker];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSDate *dateTime = [AppSettings timeOff];
    if (dateTime) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"[dd/MM/yyyy] : HH:mm:ss"];
        _timeSettingLabel.text = [formatter stringFromDate:dateTime];
    } else {
    }
}

- (void)onCancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SBFlatDatePicker Delegate
- (void)flatDatePicker:(SBFlatDatePicker *)datePicker saveDate:(NSDate *)date {
    
    [AppSettings setTimeOff:date];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
