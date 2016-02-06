//
//  CKContact.h
//  ContactsKit
//
//  Created by Sergey Popov on 1/18/16.
//  Copyright (c) 2016 ttitt. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CKURL, CKPhone, CKSocialProfile, CKAddress, CKEmail, CKMessenger;

@interface CKContact : NSObject <NSCopying, NSMutableCopying, NSSecureCoding>

@property (nonatomic, strong, readonly) NSString *identifier;

@property (nonatomic, strong, readonly) NSString *firstName;
@property (nonatomic, strong, readonly) NSString *middleName;
@property (nonatomic, strong, readonly) NSString *lastName;
@property (nonatomic, strong, readonly) NSString *nickname;

@property (nonatomic, strong, readonly) NSString *company;
@property (nonatomic, strong, readonly) NSString *jobTitle;
@property (nonatomic, strong, readonly) NSString *department;

@property (nonatomic, strong, readonly) NSString *note;

@property (nonatomic, strong, readonly) NSData *imageData;
@property (nonatomic, strong, readonly) NSData *thumbnailData;

@property (nonatomic, strong, readonly) NSArray<CKPhone *> *phones;
@property (nonatomic, strong, readonly) NSArray<CKEmail *> *emails;
@property (nonatomic, strong, readonly) NSArray<CKAddress *> *addresses;
@property (nonatomic, strong, readonly) NSArray<CKMessenger *> *instantMessengers;
@property (nonatomic, strong, readonly) NSArray<CKSocialProfile *> *socialProfiles;
@property (nonatomic, strong, readonly) NSArray<CKURL *> *URLs;

@property (nonatomic, strong, readonly) NSDate *birthday;
@property (nonatomic, strong, readonly) NSDate *creationDate;
@property (nonatomic, strong, readonly) NSDate *modificationDate;

@end


@interface CKMutableContact : CKContact

@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *middleName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *nickname;

@property (nonatomic, strong) NSString *company;
@property (nonatomic, strong) NSString *jobTitle;
@property (nonatomic, strong) NSString *department;

@property (nonatomic, strong) NSString *note;

@property (nonatomic, strong) NSData *imageData;

@property (nonatomic, strong) NSArray<CKPhone *> *phones;
@property (nonatomic, strong) NSArray<CKEmail *> *emails;
@property (nonatomic, strong) NSArray<CKAddress *> *addresses;
@property (nonatomic, strong) NSArray<CKMessenger *> *instantMessengers;
@property (nonatomic, strong) NSArray<CKSocialProfile *> *socialProfiles;
@property (nonatomic, strong) NSArray<CKURL *> *URLs;

@property (nonatomic, strong) NSDate *birthday;

@end
