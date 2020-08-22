//
//  FCShipService.h
//  FaceCar
//
//  Created by facecar on 3/9/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "FCModel.h"

@interface FCShipService : FCModel

@property (assign, nonatomic) BOOL enable;
@property (assign, nonatomic) BOOL choose; // yes -> default choose this
@property (assign, nonatomic) NSInteger fee;
@property (assign, nonatomic) NSInteger id;
@property (assign, nonatomic) NSInteger type;
@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSString* desc;

@end
