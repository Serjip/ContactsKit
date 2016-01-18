//
//  CKSocialProfile_Private.h
//  ContactsKit
//
//  Created by Sergey Popov on 1/18/16.
//  Copyright (c) 2016 ttitt. All rights reserved.
//

#import "CKSocialProfile.h"

@class CNSocialProfile;

@interface CKSocialProfile ()

- (instancetype)initWithSocialDictionary:(NSDictionary *)dictionary  NS_DEPRECATED(10_6, 10_9, 6_0, 9_0);
- (instancetype)initWithSocialProfile:(CNSocialProfile *)socialProfile NS_AVAILABLE(10_10, 9_0);

@end
