//
//  CKContact.h
//  ContactsKit
//
//  Created by Sergey Popov on 1/18/16.
//  Copyright (c) 2016 ttitt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKTypes.h"

@class CKURL, CKPhone, CKSocialProfile, CKAddress, CKEmail;

@interface CKContact : NSObject <NSCopying, NSSecureCoding>

@property (nonatomic, strong, readonly) NSString *firstName;
@property (nonatomic, strong, readonly) NSString *middleName;
@property (nonatomic, strong, readonly) NSString *lastName;
@property (nonatomic, strong, readonly) NSString *compositeName;
@property (nonatomic, strong, readonly) NSString *company;
@property (nonatomic, strong, readonly) NSString *jobTitle;
@property (nonatomic, strong, readonly) NSArray<CKPhone *> *phones;
@property (nonatomic, strong, readonly) NSArray<CKEmail *> *emails;
@property (nonatomic, strong, readonly) NSArray<CKAddress *> *addresses;
@property (nonatomic, strong, readonly) UIImage *photo;
@property (nonatomic, strong, readonly) UIImage *thumbnail;
@property (nonatomic, strong, readonly) NSNumber *recordID;
@property (nonatomic, strong, readonly) NSDate *birthday;
@property (nonatomic, strong, readonly) NSDate *creationDate NS_DEPRECATED(10_6, 10_10, 6_0, 9_0);
@property (nonatomic, strong, readonly) NSDate *modificationDate NS_DEPRECATED(10_6, 10_10, 6_0, 9_0);
@property (nonatomic, strong, readonly) NSArray<CKSocialProfile *> *socialProfiles;
@property (nonatomic, strong, readonly) NSString *note;
@property (nonatomic, strong, readonly) NSArray<CKURL *> *URLs;

@end
