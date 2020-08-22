//
//  FCAppConfigure.h
//  FaceCar
//
//  Created by facecar on 3/12/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "FCModel.h"
#import "FCHelp.h"
#import "FCMaintenance.h"
#import "FCBookConfigure.h"
#import "FCBookRadius.h"
#import "FCPriceAddition.h"
#import "FCPeakHours.h"
#import "FCLinkConfigure.h"
#import "FCClientConfig.h"
@class RequestDriversConfig;
//#if DEV
//#import "VATO_DEV-Swift.h"
//#else
//#import "VATO-Swift.h"
//#endif

@interface FCAppConfigure : FCModel

@property (strong, nonatomic) NSString* push_key;
@property (strong, nonatomic) NSArray* google_api_key;
@property (strong, nonatomic) NSArray<FCPriceAddition>* booking_price_additional; // list price addition for request booking
@property (strong, nonatomic) NSString* support_client; // link support khach hang (google docs)
@property (assign, nonatomic) long long time_prevent_invite; // // 01.04.2018 0:00:00 -> chặn không cho chia sẻ mã
@property (strong, nonatomic) NSArray<FCHelp>* client_help_menus; // menu tro giup
@property (strong, nonatomic) FCMaintenance* maintenance;
@property (strong, nonatomic) FCBookConfigure* booking_configure;
@property (strong, nonatomic) RequestDriversConfig* request_driver_config;
@property (strong, nonatomic) NSArray<FCClientConfig>* client_config;
@property (strong, nonatomic) NSArray<FCBookRadius>* booking_radius;
@property (strong, nonatomic) NSArray<FCPeakHours>* peak_hours; // danh sách các khung giờ cao điểm
@property (strong, nonatomic) NSArray<FCLinkConfigure>* app_link_configure;
@property (strong, nonatomic) NSArray<FCLinkConfigure>* topup_configure;
@end
