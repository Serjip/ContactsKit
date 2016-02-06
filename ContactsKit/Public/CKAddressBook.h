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
    CKContactFieldFirstName         = 1 << 1,
    CKContactFieldLastName          = 1 << 2,
    CKContactFieldMiddleName        = 1 << 3,
    CKContactFieldNickname          = 1 << 4,

    CKContactFieldCompany           = 1 << 10,
    CKContactFieldJobTitle          = 1 << 11,
    CKContactFieldDepartment        = 1 << 12,
    
    CKContactFieldNote              = 1 << 15,
    
    CKContactFieldImageData         = 1 << 20,
    CKContactFieldThumbnailData     = 1 << 21,
    
    CKContactFieldPhones            = 1 << 30,
    CKContactFieldEmails            = 1 << 31,
    CKContactFieldAddresses         = 1 << 31,
    CKContactFieldInstantMessengers = 1 << 33,
    CKContactFieldSocialProfiles    = 1 << 34,
    CKContactFieldURLs              = 1 << 35,
    
    CKContactFieldBirthday          = 1 << 40,
    
    CKContactFieldCreationDate      = 1 << 45,
    CKContactFieldModificationDate  = 1 << 46,
    
    CKContactFieldDefault          = CKContactFieldFirstName | CKContactFieldLastName | CKContactFieldPhones,
    CKContactFieldAll              = NSUIntegerMax
};

@class CKContact, CKMutableContact;
@protocol CKAddressBookDelegate;

@interface CKAddressBook : NSObject

@property (nonatomic, readonly) CKAddressBookAccess access;
@property (nonatomic, weak) id<CKAddressBookDelegate> delegate;

@property (nonatomic, assign) CKContactField fieldsMask;
@property (nonatomic, assign) BOOL unifyLinkedContacts NS_AVAILABLE(10_8, 6_0);
@property (nonatomic, strong) NSArray<NSSortDescriptor *> *sortDescriptors;

- (void)requestAccessWithCompletion:(void (^)(NSError *error))callback;

- (void)loadContacts;
- (void)contactsWithMask:(CKContactField)mask uinify:(BOOL)unify sortDescriptors:(NSArray *)descriptors
                  filter:(BOOL (^) (CKContact *contact))filter completion:(void (^) (NSArray *contacts, NSError *error))callback;

- (void)contactWithIdentifier:(NSString *)identifier;
- (void)contactWithIdentifier:(NSString *)identifier mask:(CKContactField)mask uinify:(BOOL)unify
                   completion:(void (^) (CKContact *contact, NSError *error))callback;

- (void)addContact:(CKMutableContact *)contact;
- (void)addContact:(CKMutableContact *)contact completion:(void (^)(NSError *error))callback;

- (void)startObserveChanges;
- (void)stopObserveChanges;

@end

@protocol CKAddressBookDelegate <NSObject>

@optional
- (void)addressBookDidChnage:(CKAddressBook *)addressBook;
- (BOOL)addressBook:(CKAddressBook *)addressBook shouldLoadContact:(CKContact *)contact;
- (void)addressBook:(CKAddressBook *)addressBook didLoadContact:(CKContact *)contact;
- (void)addressBook:(CKAddressBook *)addressBook didLoadContacts:(NSArray<CKContact *> *)contacts;
- (void)addressBook:(CKAddressBook *)addressBook didFailLoad:(NSError *)error;

@end

extern NSString *const CKAddressBookErrorDomain;
extern NSString *const CKAddressBookDidChangeNotification;
