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
    CKContactFieldDefault          = CKContactFieldFirstName | CKContactFieldLastName | CKContactFieldPhones,
    CKContactFieldAll              = NSUIntegerMax
};

@class CKContact;
@protocol CKAddressBookDelegate;

@interface CKAddressBook : NSObject

@property (nonatomic, readonly) CKAddressBookAccess access;
@property (nonatomic, assign) CKContactField fieldsMask;
@property (nonatomic, assign) BOOL unifyLinkedContacts NS_AVAILABLE(10_8, 6_0);
@property (nonatomic, strong) NSArray<NSSortDescriptor *> *sortDescriptors;
@property (nonatomic, weak) id<CKAddressBookDelegate> delegate;

- (void)requestAccessWithCompletion:(void (^)(BOOL granted, NSError *error))callback;

- (void)loadContacts;
- (void)loadContactsWithCompletion:(void (^) (NSArray<CKContact *> *contacts))callback;

- (void)loadContactWithIdentifier:(NSString *)identifier;
- (void)loadContactWithIdentifier:(NSString *)identifier completion:(void (^) (CKContact *contact))callback;

- (void)startObserveChanges;
- (void)stopObserveChanges;

@end

@protocol CKAddressBookDelegate <NSObject>

@optional
- (void)addressBookDidChnage:(CKAddressBook *)addressBook;
- (BOOL)addressBook:(CKAddressBook *)addressBook shouldLoadContact:(CKContact *)contact;
- (void)addressBook:(CKAddressBook *)addressBook didLoadContact:(CKContact *)contact orError:(NSError *)error;
- (void)addressBook:(CKAddressBook *)addressBook didLoadContacts:(NSArray<CKContact *> *)contacts orError:(NSError *)error;

@end
