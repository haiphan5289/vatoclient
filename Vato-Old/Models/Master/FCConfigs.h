//
//  FCConfigs.h
//  FaceCar
//
//  Created by Vu Dang on 10/7/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FCNotificationSetting.h"
#import "FCModel.h"


@interface FCConfigs : FCModel

@property(assign, nonatomic) int defaultRadius;
@property(assign, nonatomic) int masterVersion;
@property(assign, nonatomic) int mapZoom;
@property(assign, nonatomic) BOOL outCountryAllow;
@property(assign, nonatomic) BOOL zalopayEnable;
@property(assign, nonatomic) int distanceAllow;
@property(strong, nonatomic) FCNotificationSetting *notification;

@end
