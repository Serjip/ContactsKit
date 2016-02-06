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
    CKSocialProfileServiceTwitter,       // Twitter
    CKSocialProfileServiceFacebook,      // Facebook
    CKSocialProfileServiceLinkedIn,      // LinkedIn
    CKSocialProfileServiceFlickr,        // Flickr
    CKSocialProfileServiceMyspace,       // Myspace
    CKSocialProfileServiceSinaWeibo,     // SinaWeibo
};

@interface CKSocialProfile : NSObject <NSCopying, NSMutableCopying, NSSecureCoding>

@property (nonatomic, strong, readonly) NSURL *URL;
@property (nonatomic, strong, readonly) NSString *username;
@property (nonatomic, strong, readonly) NSString *userIdentifier;
@property (nonatomic, strong, readonly) NSString *service;
@property (nonatomic, assign, readonly) CKSocialProfileService serviceType;

@end

@interface CKMutableSocialProfile : CKSocialProfile

@property (nonatomic, strong) NSURL *URL;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *userIdentifier;
@property (nonatomic, strong) NSString *service;
@property (nonatomic, assign) CKSocialProfileService serviceType;

@end
