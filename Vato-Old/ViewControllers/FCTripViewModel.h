//
//  FCTripViewModel.h
//  FaceCar
//
//  Created by vudang on 5/23/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FCBooking.h"

@interface FCTripViewModel : NSObject

@property (strong, nonatomic) FCBooking* booking;
@property (assign, nonatomic) BOOL bookIsDeteleted;
@property (assign, nonatomic) NSInteger cartypeSelected;
@property (assign, nonatomic) BOOL fromManagerBook;
@property (strong, nonatomic) FCLocation * lastDriverLocation;
@property (strong, nonatomic) FCBookCommand* status;

- (instancetype) initViewModel: (FCBooking*) book
                       cartype: (NSInteger) type
                   fromManager: (BOOL) fromManager;

@end
