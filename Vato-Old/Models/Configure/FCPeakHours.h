//
//  FCPeakHours.h
//  FaceCar
//
//  Created by facecar on 5/22/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "FCModel.h"

@protocol FCPeakHours;
@interface FCPeakHours : FCModel
@property (nonatomic, assign) NSInteger start;
@property (nonatomic, assign) NSInteger end;
@end
