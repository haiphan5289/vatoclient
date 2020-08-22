//
//  FCGiftDetailViewController.m
//  FaceCar
//
//  Created by facecar on 8/31/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCGiftDetailViewController.h"
#import "NavigatorHelper.h"
#import "UIView+Border.h"
#import "NSObject+Helper.h"
#import "APIHelper.h"
#import "UserDataHelper.h"
#import "FCGiftViewModel.h"
#import "FCWebViewController.h"
#import "FacecarNavigationViewController.h"
#import "VehicleServiceUtil.h"

@interface FCGiftDetailViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imgCover;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblHeadLine;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;
@property (weak, nonatomic) IBOutlet UILabel *lblArea;
@property (weak, nonatomic) IBOutlet UILabel *lblContent;
@property (weak, nonatomic) IBOutlet UIButton *btnUsing;
@property (weak, nonatomic) IBOutlet UILabel *lblCounter;

@end

@implementation FCGiftDetailViewController

- (instancetype) initView {
    self = (FCGiftDetailViewController*) [[NavigatorHelper shareInstance] getViewControllerById:@"FCGiftDetailViewController" inStoryboard:@"FCGiftDetailViewController"];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"close-w"]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(closePressed:)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    self.navigationItem.title = @"Thông báo";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                           target:self
                                                                                           action:@selector(onShareClicked:)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.estimatedRowHeight = 100;
    if (self.gift) {
        [self loadDetailData];
    }
}

- (void) loadDetailData {
    if (self.gift.url.length == 0) {
        self.navigationItem.rightBarButtonItem = nil;
    }
    
//    [self.imgCover setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[self.gift.banner stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]
//                           placeholderImage:[UIImage imageNamed:@"promo-cover"]
//                                    success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
//                                        self.imgCover.image = image;
//                                        
//                                    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
//                                        
//                                    }];
    self.lblTitle.text = self.gift.title;
    self.lblHeadLine.text = self.gift.headline;
//    if (self.gift.startDate) {
//        self.lblTime.text = [NSString stringWithFormat:@"Từ %@ - Đến %@", [self getDateTimeString: self.gift.startDate],  [self getDateTimeString: self.gift.endDate]];
//    }
//    else {
//        self.lblTime.text = [NSString stringWithFormat:@"Đến %@", [self getDateTimeString: self.gift.endDate]];
//    }
    NSString* str = self.gift.description;
    self.lblContent.text = str;
    
//    [[FirebaseHelper shareInstance] getZoneByLocation:CLLocationCoordinate2DMake(_gift.startLat, _gift.startLon) handler:^(FCZone * zone) {
//        if (zone)
//            self.lblArea.text = zone.name;
//        else
//            self.lblArea.text = @"VietNam";
//
//    }];
    
//    NSArray* services = [VehicleServiceUtil splitService:_gift.service];
//    NSMutableArray* arr = [[NSMutableArray alloc] init];
//    for (NSNumber* service in services) {
//        NSString* name = [VehicleServiceUtil getServiceName:[service integerValue]];
//        [arr addObject:name];
//    }
//
//    NSString* name = [arr componentsJoinedByString:@", "];
//    self.lblCounter.text = name;
    
    [self.tableView reloadData];
}

#pragma mark - Action Handler

- (void) closePressed: (id) sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void) onShareClicked: (id) sender {
    NSString* url = self.gift.url;
    if (url.length == 0)
        return;
    
    
    NSString *title = [NSString stringWithFormat:@"Cùng tham gia các chương trình khuyến mãi hấp dẫn cùng VATO nào!\n\n%@",url];
    NSArray* dataToShare = @[title];
    
    UIActivityViewController* activityViewController =[[UIActivityViewController alloc] initWithActivityItems:dataToShare applicationActivities:nil];
    activityViewController.excludedActivityTypes = @[UIActivityTypeAirDrop];
    [self presentViewController:activityViewController animated:YES completion:^{}];
}

- (IBAction) usingClicked:(id) sender {
}

#pragma mark - TableView Delegate
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            return [UIScreen mainScreen].bounds.size.width * 2/3;
        }
        
        return UITableViewAutomaticDimension;
    }
    
    if (self.gift.url.length == 0 && indexPath.section == 1) {
        return 0;
    }
    
    return 45.0f;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0.1f;
    }
    
    return 10.0f;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        FCWebViewController* vc = [[FCWebViewController alloc] initViewWithViewModel:[[FCWebViewModel alloc] initWithUrl:self.gift.url]];
        FacecarNavigationViewController *navController = [[FacecarNavigationViewController alloc]initWithRootViewController:vc];
        [self.navigationController presentViewController:navController
                                                animated:YES
                                              completion:nil];
    }
}

@end
