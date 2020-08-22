//
//  FCZone.h
//  FC
//
//  Created by facecar on 5/6/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCModel.h"

@interface FCZone : FCModel

@property (strong, nonatomic) NSString* postcode;
@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSString* polyline;
@property (assign, nonatomic) NSInteger id;

@end
