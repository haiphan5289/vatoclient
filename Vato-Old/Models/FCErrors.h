//
//  FCError.h
//  FaceCar
//
//  Created by facecar on 11/20/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, FCErrorCode) {
    
    FCErrorCodeInvalidPhoneNumber = 1000,
    
    FCErrorCodeWrongFormatPhoneNumber = 1001,
    
    FCErrorCodeInvalidSMSCode = 2000
};

@interface FCErrors : NSError

@end
