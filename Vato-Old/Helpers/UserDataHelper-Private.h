//
//  UserDataHelper-Private.h
//  FaceCar
//
//  Created by tony on 10/5/18.
//  Copyright © 2018 Vato. All rights reserved.
//

#ifndef UserDataHelper_Private_h
#define UserDataHelper_Private_h

#import "UserDataHelper.h"
#import <FirebaseAuth/FirebaseAuth.h>

@interface UserDataHelper(Private)

- (void) getAuthToken:(nullable FIRAuthTokenCallback) callback;
@end

#endif /* UserDataHelper_Private_h */
