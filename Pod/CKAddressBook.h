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
    CKContactFieldPhoto            = 1 << 6,
    CKContactFieldThumbnail        = 1 << 7,
    CKContactFieldCompositeName    = 1 << 8,
    CKContactFieldAddresses        = 1 << 9,
    CKContactFieldRecordID         = 1 << 10,
    CKContactFieldBirthday         = 1 << 11,
    CKContactFieldCreationDate     = 1 << 12,
    CKContactFieldModificationDate = 1 << 13,
    CKContactFieldMiddleName       = 1 << 14,
    CKContactFieldSocialProfiles   = 1 << 15,
    CKContactFieldNote             = 1 << 16,
    CKContactFieldURLs             = 1 << 17,
    CKContactFieldDefault          = CKContactFieldFirstName | CKContactFieldLastName | CKContactFieldPhones,
    CKContactFieldAll              = NSUIntegerMax
};

@class CKContact;
@protocol CKAddressBookDelegate;

@interface CKAddressBook : NSObject

@property (nonatomic, readonly) CKAddressBookAccess access;
@property (nonatomic, assign) CKContactField fieldsMask;
@property (nonatomic, assign) CKContactField mergeFieldsMask;
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
