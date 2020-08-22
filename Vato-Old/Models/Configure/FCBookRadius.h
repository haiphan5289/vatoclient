//
//  FCBookRadius.h
//  FaceCar
//
//  Created by facecar on 5/13/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "FCModel.h"

@protocol FCBookRadius;
@interface FCBookRadius : FCModel
@property(nonatomic, assign) NSInteger zoneId;
@property(nonatomic, assign) NSInteger max;
@property(nonatomic, assign) NSInteger min;
@property(nonatomic, assign) NSInteger minDistance;
@property(nonatomic, assign) NSInteger percent;
@end
