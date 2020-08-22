//
//  FCShipViewModel.h
//  FaceCar
//
//  Created by facecar on 3/9/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FCShipViewModel : NSObject

@property (strong, nonatomic) NSMutableArray* listSerivce;
@property (strong, nonatomic) FCShipService* serviceSelected;

- (void) getListShipService: (void (^) (NSMutableArray* list)) handler;

@end
