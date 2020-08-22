//
//  FCFavorite.m
//  FaceCar
//
//  Created by Vu Dang on 6/6/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import "FCFavorite.h"

@implementation FCFavorite

- (instancetype) init {
    self = [super init];
    if (self) {
        AppLog([FIRAuth auth].currentUser.uid)
        self.reporterFirebaseid = [FIRAuth auth].currentUser.uid;
    }
    
    return self;
}
@end
