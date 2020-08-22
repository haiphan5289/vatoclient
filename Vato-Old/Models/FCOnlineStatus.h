//
//  FCKeepAlive.h
//  FaceCar
//
//  Created by vudang on 12/5/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import "FCModel.h"

@interface FCOnlineStatus : FCModel

@property(strong, nonatomic) FCLocation* location;
@property(assign, nonatomic) NSInteger status;
@property(assign, nonatomic) long long lastOnline;

@end
