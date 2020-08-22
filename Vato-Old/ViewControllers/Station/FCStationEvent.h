//
//  FCStationEvent.h
//  FaceCar
//
//  Created by facecar on 9/20/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <JSONModel/JSONModel.h>
#import "FCGift.h"

@interface FCStationEvent : JSONModel
@property (strong, nonatomic) NSArray<FCGift>* list;
@property (strong, nonatomic) NSString* token;
@property (assign, nonatomic) NSInteger total;
@end
