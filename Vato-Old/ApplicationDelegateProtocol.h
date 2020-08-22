//
//  ApplicationDelegateProtocol.h
//  Vato
//
//  Created by Dung Vu on 8/29/19.
//  Copyright © 2019 Vato. All rights reserved.
//

#ifndef ApplicationDelegateProtocol_h
#define ApplicationDelegateProtocol_h
typedef void(^BlockHandlerTaskDelegate)(UIBackgroundFetchResult result);
@protocol ApplicationDelegateProtocol <NSObject>
- (void) cleanUp;
- (void) signOut;
- (BlockHandlerTaskDelegate) getTaskHandler;

@end

#endif /* ApplicationDelegateProtocol_h */
