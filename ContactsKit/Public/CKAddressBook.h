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
    CKContactFieldFirstName        = 1 << 0,
    CKContactFieldLastName         = 1 << 1,
    CKContactFieldCompany          = 1 << 2,
    CKContactFieldJobTitle         = 1 << 3,
    CKContactFieldPhones           = 1 << 4,
    CKContactFieldEmails           = 1 << 5,
    CKContactFieldImageData        = 1 << 6,
    CKContactFieldThumbnailData    = 1 << 7,
    CKContactFieldAddresses        = 1 << 8,
    CKContactFieldBirthday         = 1 << 9,
    CKContactFieldCreationDate     = 1 << 10,
    CKContactFieldModificationDate = 1 << 11,
    CKContactFieldMiddleName       = 1 << 12,
    CKContactFieldSocialProfiles   = 1 << 13,
    CKContactFieldNote             = 1 << 14,
    CKContactFieldURLs             = 1 << 15,
    CKContactFieldDefault          = CKContactFieldFirstName | CKContactFieldLastName | CKContactFieldPhones,
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
