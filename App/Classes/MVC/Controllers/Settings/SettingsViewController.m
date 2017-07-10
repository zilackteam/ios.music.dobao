//
//  SettingsViewController.m

//
//  Created by Toan Nguyen on 1/22/16.
//  Copyright © 2016 Zilack. All rights reserved.
//

#import "SettingsViewController.h"
#import "AppUtils.h"
#import "DAAlertController.h"
#import "TimePickerViewController.h"

typedef NS_OPTIONS(NSInteger, SettingStyle) {
    SettingStyleLanguage = 0,
    SettingStyleMusicTimeOff,
    SettingStyleFileType,
    SettingStyleContact,
    SettingStyleApplicationInformation
};

@interface SettingsViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self useMainBackgroundOpacity:1];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorColor = RGBA(212, 212, 212, 1);
    self.title = LocalizedString(@"tlt_setting");
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_tableView reloadData];
}

- (void)updateLocalization {
    self.title = LocalizedString(@"tlt_setting");
    
    [self.tableView reloadData];
}

- (NSString *)dateDifference:(NSDate *)date
{
    const NSTimeInterval secondsPerDay = 60 * 60 * 24;
    NSTimeInterval diff = [date timeIntervalSinceNow] * -1.0;
    
    if (diff < 0)
        return @"In the future";
    
    diff /= secondsPerDay;
    if (diff < 1)
        return @"Today";
    else if (diff < 2)
        return @"Yesterday";
    else if (diff < 8)
        return @"Last week";
    else
        return [date description];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
        cell.backgroundColor = [UIColor clearColor];
        
        UIView *view = [[UIView alloc] initWithFrame:cell.bounds];
        view.backgroundColor = RGBA(68, 68, 68, 0.2);
        cell.selectedBackgroundView = view;
    }
    
    SettingStyle style = (SettingStyle)indexPath.row;
    NSString *title;
    NSString *detail = @"";
    switch (style) {
        case SettingStyleLanguage:
        {
            title = LocalizedString(@"tlt_language");
            detail = ([AppSettings language] == LanguageEnglish)?LocalizedString(@"tlt_language_english"):LocalizedString(@"tlt_language_vietnamese");
        }
            break;
        case SettingStyleMusicTimeOff:
        {
            title = LocalizedString(@"tlt_music_time_off");
            NSDate *dateTime = [AppSettings timeOff];
            if (dateTime) {
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"[dd/MM/yyyy] : HH:mm:ss"];
                
                detail = [formatter stringFromDate:dateTime];
            } else {
                detail = @"";
            }
        }
            break;
        case SettingStyleContact:
        {
            title = LocalizedString(@"tlt_contact");
        }
            break;
        case SettingStyleFileType:
        {
            title = LocalizedString(@"tlt_file_type");
            detail = ([AppSettings musicQuality] == MusicQuality320)?@"320 Kbps": @"128 Kbps";
        }
            break;
        case SettingStyleApplicationInformation:
        {
            title = LocalizedString(@"tlt_app_information");
            detail = @"";
        }
            break;
        default:
            break;
    }
    
    cell.textLabel.text = title;
    cell.textLabel.textColor = RGB(34, 34, 34);
    cell.textLabel.font = [UIFont fontWithName:APPLICATION_FONT size:16];
    cell.detailTextLabel.font = [UIFont fontWithName:APPLICATION_FONT size:16];
    cell.detailTextLabel.text = detail;
    cell.detailTextLabel.textColor = RGB(34, 34, 34);
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SettingStyle style = (SettingStyle)indexPath.row;
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *title = cell.textLabel.text;
    
    NSMutableArray *options = [NSMutableArray array];
    switch (style) {
        case SettingStyleLanguage:
        {
            DAAlertAction *langVIAction = [DAAlertAction actionWithTitle:LocalizedString(@"tlt_language_vietnamese")
                                                                   style:DAAlertActionStyleDefault handler:^{
                                                                       [AppSettings setLanguage:LanguageVietnamese];
                                                                   }];
            DAAlertAction *langENAction = [DAAlertAction actionWithTitle:LocalizedString(@"tlt_language_english")
                                                                    style:DAAlertActionStyleDefault handler:^{
                                                                        [AppSettings setLanguage:LanguageEnglish];
                                                                    }];
            [options addObject:langVIAction];
            [options addObject:langENAction];
        }
            break;
        case SettingStyleMusicTimeOff:
        {
            TimePickerViewController *timerPickerViewController = [[TimePickerViewController alloc] init];
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:timerPickerViewController];
            
            [self.navigationController presentViewController:navigationController animated:YES completion:^{
            }];
            
            return;
        }
            break;
        case SettingStyleContact:
        {
            return;
        }
            break;
        case SettingStyleFileType:
        {
            DAAlertActionStyle style = ([AppSettings musicQuality] == MusicQuality128)?DAAlertActionStyleDestructive:DAAlertActionStyleDefault;
            DAAlertAction *quantity128Action = [DAAlertAction actionWithTitle:LocalizedString(@"tlt_music_type_128")
                                                                   style:style handler:^{
                                                                       [AppSettings setMusicQuality:MusicQuality128];
                                                                       [tableView reloadData];
                                                                   }];
            
            style = ([AppSettings musicQuality] == MusicQuality320)?DAAlertActionStyleDestructive:DAAlertActionStyleDefault;
            DAAlertAction *quantity320Action = [DAAlertAction actionWithTitle:LocalizedString(@"tlt_music_type_320")
                                                                   style:style handler:^{
                                                                       [AppSettings setMusicQuality:MusicQuality320];
                                                                       [tableView reloadData];
                                                                   }];
            [options addObject:quantity128Action];
            [options addObject:quantity320Action];
        }
            break;
        case SettingStyleApplicationInformation:
        {
            return;
        }
            break;
        default:
            break;
    }
    
    [DAAlertController showActionSheetInViewController:self fromSourceView:nil withTitle:title message:@"" actions:options permittedArrowDirections:UIPopoverArrowDirectionDown];
}

@end
