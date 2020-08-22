//
//  FCDriverSearch.h
//  FaceCar
//
//  Created by facecar on 5/13/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "FCModel.h"

@interface FCDriverSearch : FCModel

@property (strong, nonatomic) NSString* firebaseId;
@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSString* avatarUrl;
@property (strong, nonatomic) FCLocation* location;
@property (assign, nonatomic) NSInteger id;
@property (assign, nonatomic) double cash;
@property (assign, nonatomic) double coin;
@property (assign, nonatomic) NSInteger service;

/**
 TRUE if driver enough money for booking
 */
@property (assign, nonatomic) BOOL satisfied;

@end
