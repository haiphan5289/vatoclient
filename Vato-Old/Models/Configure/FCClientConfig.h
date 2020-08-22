//
//  FCClientConfig.h
//  FaceCar
//
//  Created by tony on 8/21/18.
//  Copyright © 2018 Vato. All rights reserved.
//

#import "FCModel.h"

@protocol FCClientConfig;
@interface FCClientConfig : FCModel
@property (nonatomic, assign) BOOL active;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, assign) NSInteger type;
@end
