//
//  CKSocialContact.h
//  ContactsKit
//
//  Created by Sergey Popov on 1/18/16.
//  Copyright (c) 2016 ttitt. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, CKSocialProfileService)
{
    CKSocialProfileServiceUnknown  = 0,
    CKSocialProfileServiceFacebook = 1,
    CKSocialProfileServiceTwitter  = 2,
    CKSocialProfileServiceLinkedIn = 3,
    CKSocialProfileServiceFlickr   = 4,
    CKSocialProfileServiceMyspace  = 5,
};

@interface CKSocialProfile : NSObject <NSCopying, NSSecureCoding>

@property (nonatomic, strong, readonly) NSURL *URL;
@property (nonatomic, strong, readonly) NSString *username;
@property (nonatomic, strong, readonly) NSString *userIdentifier;
@property (nonatomic, strong, readonly) NSString *service;
@property (nonatomic, assign, readonly) CKSocialProfileService serviceType;

@end
