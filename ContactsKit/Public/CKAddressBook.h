//
//  CKAddressBook.h
//  ContactsKit
//
//  Created by Sergey Popov on 1/18/16.
//  Copyright (c) 2016 Sergey Popov <serj@ttitt.ru>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//  DEALINGS IN THE SOFTWARE.
//

#import <ContactsKit/CKContact.h>

@protocol CKAddressBookDelegate;

typedef NS_ENUM(NSUInteger, CKAddressBookAccess)
{
    CKAddressBookAccessUnknown = 0,
    CKAddressBookAccessGranted = 1,
    CKAddressBookAccessDenied  = 2
};

typedef NS_ENUM(NSUInteger, CKAddressBookChangeType)
{
    CKAddressBookChangeTypeAdd      = 0,
    CKAddressBookChangeTypeUpdate   = 1,
    CKAddressBookChangeTypeDelete   = 2
};

@interface CKAddressBook : NSObject <NSSecureCoding>

@property (nonatomic, assign, readonly) CKAddressBookAccess access;
@property (nonatomic, weak) id<CKAddressBookDelegate> delegate;

@property (nonatomic, assign) BOOL observeContactsDiff;
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

- (void)addContact:(CKMutableContact *)contact completion:(void (^)(NSError *error))callback;
- (void)updateContact:(CKMutableContact *)contact completion:(void (^)(NSError *error))callback;
- (void)deleteContact:(CKMutableContact *)contact completion:(void (^)(NSError *error))callback;

- (void)startObserveChanges;
- (void)stopObserveChanges;

@end

@protocol CKAddressBookDelegate <NSObject>

@optional
- (void)addressBookDidChnage:(CKAddressBook *)addressBook;
- (void)addressBook:(CKAddressBook *)addressBook didChangeForType:(CKAddressBookChangeType)type contactsIds:(NSArray<NSString *> *)ids;
- (BOOL)addressBook:(CKAddressBook *)addressBook shouldLoadContact:(CKContact *)contact;
- (void)addressBook:(CKAddressBook *)addressBook didLoadContact:(CKContact *)contact;
- (void)addressBook:(CKAddressBook *)addressBook didLoadContacts:(NSArray<CKContact *> *)contacts;
- (void)addressBook:(CKAddressBook *)addressBook didFailLoad:(NSError *)error;

@end

extern NSString *const CKAddressBookErrorDomain;

extern NSString *const CKAddressBookDidChangeNotification;
extern NSString *const CKAddressBookAddedContactsUserInfoKey;   // Array of added contacts identifiers
extern NSString *const CKAddressBookUpdatedContactsUserInfoKey; // Array of updated contacts identifiers
extern NSString *const CKAddressBookDeletedContactsUserInfoKey; // Array of deleted contacts identifiers
