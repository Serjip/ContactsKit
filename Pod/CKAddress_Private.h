//
//  CKAddress_Private.h
//  ContactsKit
//
//  Created by Sergey Popov on 1/18/16.
//  Copyright (c) 2016 ttitt. All rights reserved.
//

#import "CKAddress.h"

@class CNPostalAddress;

@interface CKAddress ()

- (instancetype)initWithAddressDictionary:(NSDictionary *)dictionary NS_DEPRECATED(10_6, 10_10, 6_0, 9_0);
- (instancetype)initWithPostalAddress:(CNPostalAddress *)address NS_AVAILABLE(10_10, 9_0);

@end
