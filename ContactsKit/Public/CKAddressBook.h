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

/*!
 * @abstract The authorization the user has given the application to access an entity type.
 */
typedef NS_ENUM(NSUInteger, CKAddressBookAccess)
{
    /*! The user has not yet made a choice regarding whether the application may access contact data. */
    CKAddressBookAccessUnknown = 0,
    /*! The application is authorized to access contact data. */
    CKAddressBookAccessGranted = 1,
    /*! The user explicitly denied access to contact data for the application. */
    CKAddressBookAccessDenied  = 2
};

typedef NS_ENUM(NSUInteger, CKAddressBookChangeType)
{
    CKAddressBookChangeTypeAdd      = 0,
    CKAddressBookChangeTypeUpdate   = 1,
    CKAddressBookChangeTypeDelete   = 2
};

@interface CKAddressBook : NSObject <NSSecureCoding>

@property (weak, nonatomic) id<CKAddressBookDelegate> delegate;

/*!
 * @abstract Indicates the current authorization status to access contact data.
 * @discussion Based upon the access, the application could display or hide its UI elements that would access any Contacts API. This method is thread safe.
 */
@property (assign, nonatomic, readonly) CKAddressBookAccess access;

/*!
 * @abstract The address book can observer difference of the changed contacts. To enable this feature set YES.
 * @discussion Inserted, Updated and Deleted contacts identifiers will be received in the delegate method `addressBook:didChangeForType:contactsIds:` or in `CKAddressBookDidChangeNotification`. To observe contacts differences call `startObserveChanges`.
 */
@property (assign, nonatomic) BOOL observeContactsDiff;

/*!
 * @abstract Field mask is a masl of the properties that will be loded
 * @discussion Identifier is obligatory property. Propeties not in the field mas will be nil or 0
 */
@property (assign, nonatomic) CKContactField fieldsMask;

/*!
 * @abstract To return linked contacts as unified contacts.
 * @discussion If YES returns unified contacts, otherwise returns individual contacts. Default is NO.
 * @note A unified contact is the aggregation of properties from a set of linked individual contacts. If an individual contact is not linked then the unified contact is simply that individual contact.
 */
@property (assign, nonatomic) BOOL unifyResults NS_AVAILABLE(10_8, 6_0);

/*!
 * @abstract The order of the fetched contacts
 * @discussion It's for the delegate methods only. If sort description is nil, contacts returnded in the system order.
 */
@property (strong, nonatomic) NSArray<NSSortDescriptor *> *sortDescriptors;

/*!
 * @abstract Request access to the user's contacts.
 * @discussion Users are able to grant or deny access to contact data on a per-application basis. To request access to contact data, call requestAccessWithCompletion:. This will not block the application while the user is being asked to grant or deny access. The user will only be prompted the first time access is requested; any subsequent CKAddressBook calls will use the existing permissions. The completion handler is called on an main queue.
 * @param callback This block is called upon completion. If the user grants access then error is nil. Otherwise access denied with an error.
 */
- (void)requestAccessWithCompletion:(void (^)(NSError *error))callback;

/*!
 * @abstract Fetching all contacts from the address book.
 * @discussion Call the delegate method `addressBook:didFetchContacts:` after completion. During the fetching will call the filter delegate method `addressBook:shouldFetchContact:`.
 */
- (void)fetchContacts;

/*!
 * @abstract Fetching all contacts from the address book.
 * @param mask is a properties to fetch
 * @param unify merging linked contact
 * @param sortDescriptors is sort of the contacts list
 * @param filter is a filter for the contacts, if block returns NO that contact will not added to the contact list.
 * @param callback This block is called upon completion fetching all contacts
 */
- (void)contactsWithMask:(CKContactField)mask uinify:(BOOL)unify sortDescriptors:(NSArray *)sortDescriptors
                  filter:(BOOL (^) (CKContact *contact))filter completion:(void (^) (NSArray *contacts, NSError *error))callback;

/*!
 * @abstract Fetch contact with identifier
 * @discussion method will fetch contact after completion will call delegate method `addressBook:didFetchContacts:`. Field mask gettings from the addressbook param `fieldsMask` the same with the `unifyResults` param.
 * @param identifier is a unique contact identifier
 */
- (void)contactWithIdentifier:(NSString *)identifier;

/*!
 * @abstract Fetch contacts with identifier
 */
- (void)contactWithIdentifier:(NSString *)identifier mask:(CKContactField)mask uinify:(BOOL)unify
                   completion:(void (^) (CKContact *contact, NSError *error))callback;

/*!
 * @abstract Add a new contact to the address book.
 * @discussion The contact is added if error is nil
 * @param contact The new contact to add.
 * @param callback This block is called upon completion.
 */
- (void)addContact:(CKMutableContact *)contact completion:(void (^)(NSError *error))callback;

/*!
 * @abstract Update an existing contact in the address book.
 * @discussion The contact is updated if error is nil
 * @param contact The contact to update.
 * @param callback This block is called upon completion.
 */
- (void)updateContact:(CKMutableContact *)contact completion:(void (^)(NSError *error))callback;

/*!
 * @abstract Delete a contact from the address book.
 * @discussion The contact is deleted if error is nil
 * @param contact The contact to delete.
 * @param callback This block is called upon completion.
 */
- (void)deleteContact:(CKMutableContact *)contact completion:(void (^)(NSError *error))callback;

- (void)startObserveChanges;
- (void)stopObserveChanges;

@end

@protocol CKAddressBookDelegate <NSObject>

@optional
- (void)addressBookDidChnage:(CKAddressBook *)addressBook;
- (void)addressBook:(CKAddressBook *)addressBook didChangeForType:(CKAddressBookChangeType)type contactsIds:(NSArray<NSString *> *)ids;
- (BOOL)addressBook:(CKAddressBook *)addressBook shouldFetchContact:(CKContact *)contact;
- (void)addressBook:(CKAddressBook *)addressBook didFetchContacts:(NSArray<CKContact *> *)contacts;
- (void)addressBook:(CKAddressBook *)addressBook didFailToFetch:(NSError *)error;

@end

extern NSString *const CKAddressBookErrorDomain;

/*!
 * @abstract Notification posted when changes occur in another CNContactStore.
 */
extern NSString *const CKAddressBookDidChangeNotification;
extern NSString *const CKAddressBookAddedContactsUserInfoKey;   // Array of added contacts identifiers
extern NSString *const CKAddressBookUpdatedContactsUserInfoKey; // Array of updated contacts identifiers
extern NSString *const CKAddressBookDeletedContactsUserInfoKey; // Array of deleted contacts identifiers
