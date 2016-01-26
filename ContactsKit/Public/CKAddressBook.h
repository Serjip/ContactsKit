//
//  CKAddressBook.h
//  ContactsKit
//
//  Created by Sergey Popov on 1/18/16.
//  Copyright (c) 2016 ttitt. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, CKAddressBookAccess)
{
    CKAddressBookAccessUnknown = 0,
    CKAddressBookAccessGranted = 1,
    CKAddressBookAccessDenied  = 2
};

typedef NS_OPTIONS(NSUInteger , CKContactField)
{
    CKContactFieldIdentifier       = 1 << 0,
    CKContactFieldFirstName        = 1 << 1,
    CKContactFieldLastName         = 1 << 2,
    CKContactFieldCompany          = 1 << 3,
    CKContactFieldJobTitle         = 1 << 4,
    CKContactFieldPhones           = 1 << 5,
    CKContactFieldEmails           = 1 << 6,
    CKContactFieldImageData        = 1 << 7,
    CKContactFieldThumbnailData    = 1 << 8,
    CKContactFieldAddresses        = 1 << 9,
    CKContactFieldBirthday         = 1 << 10,
    CKContactFieldCreationDate     = 1 << 11,
    CKContactFieldModificationDate = 1 << 12,
    CKContactFieldMiddleName       = 1 << 13,
    CKContactFieldSocialProfiles   = 1 << 14,
    CKContactFieldNote             = 1 << 15,
    CKContactFieldURLs             = 1 << 16,
    CKContactFieldDefault          = CKContactFieldIdentifier | CKContactFieldFirstName | CKContactFieldLastName | CKContactFieldPhones,
    CKContactFieldAll              = NSUIntegerMax
};

@class CKContact;
@protocol CKAddressBookDelegate;

@interface CKAddressBook : NSObject

@property (nonatomic, readonly) CKAddressBookAccess access;
@property (nonatomic, assign) CKContactField fieldsMask;
@property (nonatomic, assign) CKContactField mergeMask;
@property (nonatomic, strong) NSArray<NSSortDescriptor *> *sortDescriptors;
@property (nonatomic, weak) id<CKAddressBookDelegate> delegate;

+ (CKAddressBookAccess)access;

- (void)loadContacts;

- (void)startObserveChanges;
- (void)stopObserveChanges;

@end

@protocol CKAddressBookDelegate <NSObject>

@optional
- (void)addressBookDidChnage:(CKAddressBook *)addressBook;
- (void)addressBook:(CKAddressBook *)addressBook didLoadContacts:(NSArray<CKContact *> *)contacts;
- (void)addressBook:(CKAddressBook *)addressBook didFailLoadContacts:(NSError *)error;
- (BOOL)addressBook:(CKAddressBook *)addressBook shouldAddContact:(CKContact *)contact;

@end
