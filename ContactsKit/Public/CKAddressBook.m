//
//  CKAddressBook.m
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

#import "CKAddressBook_Private.h"
#import "CKContact_Private.h"
#import "CKMacros.h"
#import <AddressBook/AddressBook.h>

NSString *const CKAddressBookErrorDomain = @"CKAddressBookErrorDomain";
NSString *const CKAddressBookDidChangeNotification = @"CKAddressBookDidChangeNotification";
NSString *const CKAddressBookAddedContactsUserInfoKey = @"CKAddressBookAddedContactsUserInfoKey";
NSString *const CKAddressBookUpdatedContactsUserInfoKey = @"CKAddressBookUpdatedContactsUserInfoKey";
NSString *const CKAddressBookDeletedContactsUserInfoKey = @"CKAddressBookDeletedContactsUserInfoKey";

@implementation CKAddressBook {
@private
#if TARGET_OS_IOS
    ABAddressBookRef _addressBookRef;
#elif TARGET_OS_MAC
    BOOL _accessIsNotRequested;
    ABAddressBook *_addressBook;
#endif
    dispatch_queue_t _addressBookQueue;
}

#pragma mark - Properties

- (CKAddressBookAccess)access
{
#if TARGET_OS_IOS
    ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
    switch (status)
    {
        case kABAuthorizationStatusDenied:
        case kABAuthorizationStatusRestricted:
            return CKAddressBookAccessDenied;
            
        case kABAuthorizationStatusAuthorized:
            return CKAddressBookAccessGranted;
            
        default:
            return CKAddressBookAccessUnknown;
    }
#elif TARGET_OS_MAC
    if (_accessIsNotRequested)
    {
        return CKAddressBookAccessUnknown;
    }
    else if (_addressBook)
    {
        return CKAddressBookAccessGranted;
    }
    else
    {
        return CKAddressBookAccessDenied;
    }
#endif
}

#pragma mark - Lifecycle

- (instancetype)init
{
    self = [super init];
    if (self)
    {
#if TARGET_OS_IOS
        _addressBookRef = ABAddressBookCreate();
#elif TARGET_OS_MAC
        _accessIsNotRequested = YES;
#endif
        // Set addressbook queue
        NSString *queueName = [NSString stringWithFormat:@"com.ttitt.contactskit.queue.%d", arc4random()];
        _addressBookQueue = dispatch_queue_create(queueName.UTF8String, DISPATCH_QUEUE_SERIAL);
        
        // Set default field masks
        _fieldsMask = CKContactFieldDefault;
    }
    return self;
}

- (void)dealloc
{
    [self ck_removeObserver];
    
#if TARGET_OS_IOS
    if (_addressBookRef)
    {
        CFRelease(_addressBookRef);
    }
#endif
    
#if !OS_OBJECT_USE_OBJC
    dispatch_release(_addressBookQueue);
#endif
}

#pragma mark - Public

- (void)requestAccessWithCompletion:(void (^)(NSError *error))callback
{
    NSParameterAssert(callback);

    [self willChangeValueForKey:NSStringFromSelector(@selector(access))];

#if TARGET_OS_IOS
    ABAddressBookRequestAccessWithCompletion(_addressBookRef, ^(bool granted, CFErrorRef errorRef) {
        
        NSError *error = nil;
        if (! granted || errorRef)
        {
            NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : CKLocalizedString(@"Access denied", nil) };
            error = [NSError errorWithDomain:CKAddressBookErrorDomain code:1 userInfo:userInfo];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self didChangeValueForKey:NSStringFromSelector(@selector(access))];
            callback(error);
        });
    });
#elif TARGET_OS_MAC
    dispatch_async(_addressBookQueue, ^{
        
        _accessIsNotRequested = NO;
        
        if (! _addressBook)
        {
            _addressBook = [ABAddressBook addressBook];
        }
        
        NSError *error = nil;
        if (! _addressBook)
        {
            NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : CKLocalizedString(@"Access denied", nil) };
            error = [NSError errorWithDomain:CKAddressBookErrorDomain code:1 userInfo:userInfo];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self didChangeValueForKey:NSStringFromSelector(@selector(access))];
            callback(error);
        });
    });
#endif
}

- (void)fetchContacts
{
    CKContactField fieldMask = self.fieldsMask;
    CKContactField mergeMask = self.unifyResults ? fieldMask : 0;
    NSArray *descriptors = [self.sortDescriptors copy];
    
    dispatch_async(_addressBookQueue, ^{
        
        id filter = nil;
        if ([self.delegate respondsToSelector:@selector(addressBook:shouldFetchContact:)])
        {
            filter = ^BOOL(CKContact *contact) {
                return [self.delegate addressBook:self shouldFetchContact:contact];
            };
        }
        
        NSError *error = nil;
        NSArray *contacts = [self ck_contactsWithFields:fieldMask merge:mergeMask sortDescriptors:descriptors filter:filter error:&error];
        
        if (! error)
        {
            if ([self.delegate respondsToSelector:@selector(addressBook:didFetchContacts:)])
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate addressBook:self didFetchContacts:contacts];
                });
            }
        }
        else
        {
            if ([self.delegate respondsToSelector:@selector(addressBook:didFailToFetch:)])
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate addressBook:self didFailToFetch:error];
                });
            }
        }
    });
}

- (void)contactsWithMask:(CKContactField)mask uinify:(BOOL)unify sortDescriptors:(NSArray *)sortDescriptors
                  filter:(BOOL (^) (CKContact *contact))filter completion:(void (^) (NSArray *contacts, NSError *error))callback
{
    NSParameterAssert(callback);
    
    dispatch_async(_addressBookQueue, ^{
       
        CKContactField mergeMask = unify ? mask : 0;
        NSError *error = nil;
        NSArray *contacts = [self ck_contactsWithFields:mask merge:mergeMask sortDescriptors:sortDescriptors filter:filter error:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            callback(contacts, error);
        });
    });
}

- (void)contactWithIdentifier:(NSString *)identifier
{
    CKContactField fieldMask = self.fieldsMask;
    CKContactField mergeMask = self.unifyResults ? fieldMask : 0;
    
    dispatch_async(_addressBookQueue, ^{
        
        NSError *error = nil;
        CKContact *contact = [self ck_contactWithIdentifier:identifier fields:fieldMask merge:mergeMask error:&error];
        
        if (! error)
        {
            if ([self.delegate respondsToSelector:@selector(addressBook:didFetchContacts:)])
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate addressBook:self didFetchContacts:@[contact]];
                });
            }
        }
        else
        {
            if ([self.delegate respondsToSelector:@selector(addressBook:didFailToFetch:)])
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate addressBook:self didFailToFetch:error];
                });
            }
        }
    });
}

- (void)contactWithIdentifier:(NSString *)identifier mask:(CKContactField)mask uinify:(BOOL)unify completion:(void (^) (CKContact *contact, NSError *error))callback
{
    NSParameterAssert(identifier);
    NSParameterAssert(callback);

    dispatch_async(_addressBookQueue, ^{
        
        CKContactField mergeMask = unify ? mask : 0;
        
        NSError *error = nil;
        CKContact *contact = [self ck_contactWithIdentifier:identifier fields:mask merge:mergeMask error:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            callback(contact, error);
        });
    });
}

- (void)addContact:(CKMutableContact *)contact completion:(void (^)(NSError *error))callback
{
    NSParameterAssert(callback);
    dispatch_async(_addressBookQueue, ^{
        NSError *error = nil;
        [self ck_addContact:contact error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            callback(error);
        });
    });
}

- (void)updateContact:(CKMutableContact *)contact completion:(void (^)(NSError *))callback
{
    NSParameterAssert(callback);
    
    dispatch_async(_addressBookQueue, ^{
        NSError *error = nil;
        [self ck_updateContact:contact error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            callback(error);
        });
    });
}

- (void)deleteContact:(CKMutableContact *)contact completion:(void (^)(NSError *error))callback
{
    NSParameterAssert(callback);
    dispatch_async(_addressBookQueue, ^{
        NSError *error = nil;
        [self ck_deleteContact:contact error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            callback(error);
        });
    });
}

- (void)startObserveChanges
{
    [self ck_removeObserver];
    
#if TARGET_OS_IOS
    ABAddressBookRegisterExternalChangeCallback(_addressBookRef, CKAddressBookExternalChangeCallback, (__bridge void *)(self));
    
    if (self.observeContactsDiff)
    {
        dispatch_async(_addressBookQueue, ^{
            
            NSArray *inserted, *updated, *deleted;
            _contacts = [self ck_newContactsWithOldConctacts:_contacts inserted:&inserted updated:&updated deleted:&deleted];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self ck_recordsChangedInserted:inserted updated:updated deleted:deleted];
            });
        });
    }
    
#elif TARGET_OS_MAC
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(notificaitonDataBaseChanged:) name:kABDatabaseChangedNotification object:_addressBook];
    [nc addObserver:self selector:@selector(notificaitonDatabaseChangedExternally:) name:kABDatabaseChangedExternallyNotification object:_addressBook];
#endif
}

- (void)stopObserveChanges
{
    [self ck_removeObserver];
#if TARGET_OS_IOS
    _contacts = nil;
#endif
}

#pragma mark - NSSecureCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [self init];
    if (self)
    {
        _contacts = [aDecoder decodeObjectOfClass:[NSArray class] forKey:NSStringFromSelector(@selector(contacts))];
        _sortDescriptors = [aDecoder decodeObjectOfClass:[NSArray class] forKey:NSStringFromSelector(@selector(sortDescriptors))];
        
        _unifyResults = [aDecoder decodeBoolForKey:NSStringFromSelector(@selector(unifyResults))];
        _observeContactsDiff = [aDecoder decodeBoolForKey:NSStringFromSelector(@selector(observeContactsDiff))];
        
        NSNumber *fieldMask = [aDecoder decodeObjectOfClass:[NSNumber class] forKey:NSStringFromSelector(@selector(fieldMask))];
        _fieldsMask = fieldMask.unsignedIntegerValue;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_contacts forKey:NSStringFromSelector(@selector(contacts))];
    [aCoder encodeObject:_sortDescriptors forKey:NSStringFromSelector(@selector(sortDescriptors))];
    
    [aCoder encodeBool:_unifyResults forKey:NSStringFromSelector(@selector(unifyResults))];
    [aCoder encodeBool:_observeContactsDiff forKey:NSStringFromSelector(@selector(observeContactsDiff))];
    
    NSNumber *fieldMask = [NSNumber numberWithUnsignedInteger:_fieldsMask];
    [aCoder encodeObject:fieldMask forKey:NSStringFromSelector(@selector(fieldMask))];
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

#pragma mark - Private

- (NSArray *)ck_contactsWithFields:(CKContactField)fields merge:(CKContactField)merge sortDescriptors:(NSArray *)descriptors
                            filter:(BOOL (^) (CKContact *contact))filter error:(NSError **)error
{
    if (! [self ck_checkAccess:error])
    {
        return nil;
    }
    
#if TARGET_OS_IOS
    
    // Gettings the array of people
    CFArrayRef peopleArrayRef = ABAddressBookCopyArrayOfAllPeople(_addressBookRef);
    CFIndex contactCount = CFArrayGetCount(peopleArrayRef);
    NSMutableArray *contacts = [[NSMutableArray alloc] initWithCapacity:(NSUInteger)contactCount];
    NSMutableIndexSet *linkedContactsIDs = [[NSMutableIndexSet alloc] init];

    for (CFIndex i = 0; i < contactCount; i++)
    {
        ABRecordRef recordRef = (ABRecordRef)CFArrayGetValueAtIndex(peopleArrayRef, i);
        
        // Checking already added contacts
        if ([linkedContactsIDs containsIndex:ABRecordGetRecordID(recordRef)])
        {
            continue;
        }
        
        // Create the contact
        CKContact *contact = [[CKContact alloc] initWithRecordRef:recordRef fieldMask:fields];
        
        // Filter the contact if needed
        if (! filter || filter(contact))
        {
            [contacts addObject:contact];
        }

        CFArrayRef linkedPeopleArrayRef = ABPersonCopyArrayOfAllLinkedPeople(recordRef);
        CFIndex linkedCount = CFArrayGetCount(linkedPeopleArrayRef);
        // Merge linked contact info
        for (CFIndex j = 0; linkedCount > 1 && j < linkedCount; j++)
        {
            ABRecordRef linkedRecordRef = (ABRecordRef)CFArrayGetValueAtIndex(linkedPeopleArrayRef, j);
            // Don't merge the same contact
            if (linkedRecordRef == recordRef)
            {
                continue;
            }
            
            if (merge)
            {
                [contact mergeLinkedRecordRef:linkedRecordRef mergeMask:merge];
                [linkedContactsIDs addIndex:ABRecordGetRecordID(linkedRecordRef)];
            }
        }
        CFRelease(linkedPeopleArrayRef);
    }
    CFRelease(peopleArrayRef);
#elif TARGET_OS_MAC
    
    NSMutableArray *contacts = [[NSMutableArray alloc] init];
    NSMutableSet *linkedContactsIDs = [NSMutableSet set];
    for (ABPerson *record in [_addressBook people])
    {
        // Checking already added contacts
        if ([linkedContactsIDs containsObject:record.uniqueId])
        {
            continue;
        }
        
        ABRecordRef recordRef = (__bridge ABRecordRef)(record);
        CKContact *contact = [[CKContact alloc] initWithRecordRef:recordRef fieldMask:fields];
        
        // Filter the contact if needed
        if (! filter || filter(contact))
        {
            [contacts addObject:contact];
        }
        
        // Check the method by selector response, because it's only for OSX 10.8
        NSArray *linkedPeople;
        if ([record respondsToSelector:@selector(linkedPeople)])
        {
           linkedPeople = [record linkedPeople];
        }
        
        if (linkedPeople.count > 1)
        {
            for (ABPerson *linkedRecord in linkedPeople)
            {
                // Don't merge the same contact
                if ([linkedRecord isEqual:record])
                {
                    continue;
                }
                
                if (merge)
                {
                    ABRecordRef linkedRecordRef = (__bridge ABRecordRef)(linkedRecord);
                    [contact mergeLinkedRecordRef:linkedRecordRef mergeMask:merge];
                    [linkedContactsIDs addObject:linkedRecord.uniqueId];
                }
            }
        }
    }
#endif
    // Sort
    [contacts sortUsingDescriptors:descriptors];
    
    // Done
    return [[NSArray alloc] initWithArray:contacts];
}

- (CKContact *)ck_contactWithIdentifier:(NSString *)identifier fields:(CKContactField)fields merge:(CKContactField)merge error:(NSError **)error
{
    NSParameterAssert(identifier);
    
    CKContact *contact = nil;
    
#if TARGET_OS_IOS
    
    if (! _addressBookRef)
    {
        if (error)
        {
            NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : CKLocalizedString(@"Access denied", nil) };
            *error = [NSError errorWithDomain:CKAddressBookErrorDomain code:1 userInfo:userInfo];
        }
        return nil;
    }
    
    ABRecordRef recordRef = ABAddressBookGetPersonWithRecordID(_addressBookRef, (int32_t)identifier.integerValue);
    if (recordRef != NULL)
    {
        contact = [[CKContact alloc] initWithRecordRef:recordRef fieldMask:fields];
        
        CFArrayRef linkedPeopleArrayRef = ABPersonCopyArrayOfAllLinkedPeople(recordRef);
        CFIndex linkedCount = CFArrayGetCount(linkedPeopleArrayRef);
        // Merge linked contact info
        for (CFIndex j = 0; linkedCount > 1 && j < linkedCount; j++)
        {
            ABRecordRef linkedRecordRef = (ABRecordRef)CFArrayGetValueAtIndex(linkedPeopleArrayRef, j);
            // Don't merge the same contact
            if (linkedRecordRef == recordRef)
            {
                continue;
            }
            
            if (merge)
            {
                [contact mergeLinkedRecordRef:linkedRecordRef mergeMask:merge];
            }
        }
        CFRelease(linkedPeopleArrayRef);
    }
#elif TARGET_OS_MAC
    
    if (! _addressBook)
    {
        if (error)
        {
            NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : CKLocalizedString(@"Access denied", nil) };
            *error = [NSError errorWithDomain:CKAddressBookErrorDomain code:1 userInfo:userInfo];
        }
        return nil;
    }
    
    ABRecord *record = [_addressBook recordForUniqueId:identifier];
    if (record)
    {
        ABRecordRef recordRef = (__bridge ABRecordRef)(record);
        CKContact *contact = [[CKContact alloc] initWithRecordRef:recordRef fieldMask:fields];
        
        // Check the method by selector response, because it's only for OSX 10.8
        NSArray *linkedPeople;
        if ([record respondsToSelector:@selector(linkedPeople)])
        {
            linkedPeople = [(ABPerson *)record linkedPeople];
        }
        
        if (linkedPeople.count > 1)
        {
            for (ABPerson *linkedRecord in linkedPeople)
            {
                // Don't merge the same contact
                if ([linkedRecord isEqual:record])
                {
                    continue;
                }
                
                if (merge)
                {
                    ABRecordRef linkedRecordRef = (__bridge ABRecordRef)(linkedRecord);
                    [contact mergeLinkedRecordRef:linkedRecordRef mergeMask:merge];
                }
            }
        }
    }
#endif
    return contact;
}

- (BOOL)ck_addContact:(CKMutableContact *)contact error:(NSError **)error
{
    NSParameterAssert(contact);
    
    BOOL result = [self ck_checkAccess:error];
    ABRecordRef recordRef = NULL;
    
#if TARGET_OS_IOS
    
    if (result)
    {
        ABRecordRef sourceRef = ABAddressBookGetSourceWithRecordID(_addressBookRef, kABSourceTypeLocal);
        recordRef = ABPersonCreateInSource(sourceRef);
        result = [contact setRecordRef:recordRef error:error];
    }
    
    if (result)
    {
        CFErrorRef errorRef = NULL;
        result = ABAddressBookAddRecord(_addressBookRef, recordRef, &errorRef);
        
        if (error && errorRef != NULL)
        {
            *error = (__bridge_transfer NSError *)(errorRef);
        }
        else if (errorRef != NULL)
        {
            CFRelease(errorRef);
        }
    }
    
    if (result)
    {
        result = [self ck_saveAddressBook:error];
    }
    
    if (result && recordRef)
    {
        // TODO: check the added externaly changed callback for dupplicate calls
        if (self.observeContactsDiff)
        {
            CKContactField fields = CKContactFieldModificationDate | CKContactFieldCreationDate;
            CKContact *addedContact = [[CKContact alloc] initWithRecordRef:recordRef fieldMask:fields];
            
            // Add the new contact for cont
            NSMutableArray *contacts = [_contacts mutableCopy];
            [contacts addObject:addedContact];
            _contacts = [[NSArray alloc] initWithArray:contacts];
            contact.identifier = addedContact.identifier;
            
            // TODO: If the field mask is not read only update the contact modification date and creation date
        }
        else
        {
            contact.identifier = @(ABRecordGetRecordID(recordRef)).stringValue;
        }
    }
    
    if (recordRef)
    {
        CFRelease(recordRef);
    }
#elif TARGET_OS_MAC
    
    ABRecord *record = nil;
    
    if (result)
    {
        record = [[ABRecord alloc] initWithAddressBook:_addressBook];
        recordRef = (__bridge ABRecordRef)(record);
        
        result = [contact setRecordRef:recordRef error:error];
    }
    
    if (result)
    {
        result = [self ck_saveAddressBook:error];
    }
    
    if (result)
    {
        contact.identifier = record.uniqueId;
    }
#endif
    
    return result;
}

- (BOOL)ck_updateContact:(CKMutableContact *)contact error:(NSError **)error
{
    NSParameterAssert(contact);
    
    BOOL result = [self ck_checkAccess:error];
    ABRecordRef recordRef = NULL;
    
    if (result)
    {
#if TARGET_OS_IOS
        recordRef = ABAddressBookGetPersonWithRecordID(_addressBookRef, (int32_t)contact.identifier.integerValue);
#elif TARGET_OS_MAC
        recordRef = (__bridge ABRecordRef)([_addressBook recordForUniqueId:contact.identifier]);
#endif
        
        if (recordRef == NULL)
        {
            if (error)
            {
                NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : CKLocalizedString(@"Contact not found", nil)};
                *error = [NSError errorWithDomain:CKAddressBookErrorDomain code:1 userInfo:userInfo];
            }
            result = NO;
        }
    }
    
    if (result)
    {
        [contact setRecordRef:recordRef error:error];
    }
    
    if (result)
    {
        result = [self ck_saveAddressBook:error];
    }
    
#if TARGET_OS_IOS
    // TODO: check the updated externaly changed callback for dupplicate calls
    if (result && self.observeContactsDiff)
    {
        CKContactField fields = CKContactFieldModificationDate | CKContactFieldCreationDate;
        CKContact *updatedContact = [[CKContact alloc] initWithRecordRef:recordRef fieldMask:fields];
        
        // Update contact in observed contacts
        NSInteger index = NSNotFound;
        for (NSInteger i = 0; i < _contacts.count; i++)
        {
            CKContact *contact = [_contacts objectAtIndex:i];
            if ([contact.identifier isEqualToString:updatedContact.identifier])
            {
                index = i;
                break;
            }
        }
        
        if (index != NSNotFound)
        {
            NSMutableArray *contacts = [_contacts mutableCopy];
            [contacts replaceObjectAtIndex:index withObject:updatedContact];
            _contacts = [[NSArray alloc] initWithArray:contacts];
            if (contact.fieldMask & CKContactFieldModificationDate)
            {
                contact.modificationDate = updatedContact.modificationDate;
            }
        }
    }
#endif

    return result;
}

- (BOOL)ck_deleteContact:(CKMutableContact *)contact error:(NSError **)error
{
    NSParameterAssert(contact);
    
    BOOL result = [self ck_checkAccess:error];
    
#if TARGET_OS_IOS
    
    ABRecordRef recordRef = ABAddressBookGetPersonWithRecordID(_addressBookRef, (int32_t)contact.identifier.integerValue);
    
    if (recordRef != NULL)
    {
        CFErrorRef errorRef = NULL;
        result = ABAddressBookRemoveRecord(_addressBookRef, recordRef, &errorRef);
        
        if (error && errorRef != NULL)
        {
            *error = (__bridge_transfer NSError *)(errorRef);
        }
        else if (errorRef != NULL)
        {
            CFRelease(errorRef);
        }
    }
    else
    {
        if (error)
        {
            NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : CKLocalizedString(@"Contact not found", nil)};
            *error = [NSError errorWithDomain:CKAddressBookErrorDomain code:1 userInfo:userInfo];
        }
        result = NO;
    }
    
#elif TARGET_OS_MAC
    
    ABRecord *record = [_addressBook recordForUniqueId:contact.identifier];
    if (record)
    {
        result = [_addressBook removeRecord:record error:error];
    }
    else
    {
        if (error)
        {
            NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : CKLocalizedString(@"Contact not found", nil)};
            *error = [NSError errorWithDomain:CKAddressBookErrorDomain code:1 userInfo:userInfo];
        }
        result = NO;
    }
    
#endif
    
    if (result)
    {
        result = [self ck_saveAddressBook:error];
    }
    
#if TARGET_OS_IOS
    // TODO: delete contact from observed contacts
    if (result && self.observeContactsDiff)
    {
        // Update contact in observed contacts
        NSInteger index = NSNotFound;
        for (NSInteger i = 0; i < _contacts.count; i++)
        {
            CKContact *contact_ = [_contacts objectAtIndex:i];
            if ([contact_.identifier isEqualToString:contact.identifier])
            {
                index = i;
                break;
            }
        }
        
        if (index != NSNotFound)
        {
            NSMutableArray *contacts = [_contacts mutableCopy];
            [contacts removeObjectAtIndex:index];
            _contacts = [[NSArray alloc] initWithArray:contacts];
        }
    }
#endif
    
    return result;
}

- (BOOL)ck_checkAccess:(NSError **)error
{
    switch (self.access)
    {
        case CKAddressBookAccessGranted:
            return YES;
        
        case CKAddressBookAccessDenied:
            if (error)
            {
                NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : CKLocalizedString(@"Access denied", nil)};
                *error = [NSError errorWithDomain:CKAddressBookErrorDomain code:1 userInfo:userInfo];
            }
            return NO;
        
        case CKAddressBookAccessUnknown:
            if (error)
            {
                NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : CKLocalizedString(@"Access unknown", nil)};
                *error = [NSError errorWithDomain:CKAddressBookErrorDomain code:1 userInfo:userInfo];
            }
            return NO;
    }
}

- (BOOL)ck_saveAddressBook:(NSError **)error
{
    BOOL result = YES;
    
#if TARGET_OS_IOS
    
    if (result)
    {
        result = ABAddressBookHasUnsavedChanges(_addressBookRef);
        if (! result && error)
        {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey : CKLocalizedString(@"Address book hasn't changes", nil)};
            *error = [NSError errorWithDomain:CKAddressBookErrorDomain code:2 userInfo:userInfo];
        }
    }
    
    if (result)
    {
        CFErrorRef errorRef = NULL;
        result = ABAddressBookSave(_addressBookRef, &errorRef);
        
        if (error && errorRef != NULL)
        {
            *error = (__bridge_transfer NSError *)(errorRef);
        }
        else if (errorRef != NULL)
        {
            CFRelease(errorRef);
        }
    }
#elif TARGET_OS_MAC
    
    if (result)
    {
        result = [_addressBook hasUnsavedChanges];
        if (! result && error)
        {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey : CKLocalizedString(@"Address book hasn't changes", nil)};
            *error = [NSError errorWithDomain:CKAddressBookErrorDomain code:2 userInfo:userInfo];
        }
    }
    
    if (result)
    {
        result = [_addressBook saveAndReturnError:error];
    }
#endif
    
    return result;
}

- (void)ck_removeObserver
{
#if TARGET_OS_IOS
    ABAddressBookUnregisterExternalChangeCallback(_addressBookRef, CKAddressBookExternalChangeCallback, (__bridge void *)(self));
#elif TARGET_OS_MAC
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self name:kABDatabaseChangedNotification object:_addressBook];
    [nc removeObserver:self name:kABDatabaseChangedExternallyNotification object:_addressBook];
#endif
}

- (void)ck_recordsChangedInserted:(NSArray *)inserted updated:(NSArray *)updated deleted:(NSArray *)deleted
{
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    [userInfo setValue:inserted forKey:CKAddressBookAddedContactsUserInfoKey];
    [userInfo setValue:updated forKey:CKAddressBookUpdatedContactsUserInfoKey];
    [userInfo setValue:deleted forKey:CKAddressBookDeletedContactsUserInfoKey];
    
    if (inserted.count || updated.count || deleted.count)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:CKAddressBookDidChangeNotification object:self userInfo:userInfo];
    }
    
    if ([self.delegate respondsToSelector:@selector(addressBook:didChangeForType:contactsIds:)])
    {
        if (inserted.count)
        {
            [self.delegate addressBook:self didChangeForType:CKAddressBookChangeTypeAdd contactsIds:inserted];
        }
        
        if (updated.count)
        {
            [self.delegate addressBook:self didChangeForType:CKAddressBookChangeTypeUpdate contactsIds:updated];
        }
        
        if (deleted.count)
        {
            [self.delegate addressBook:self didChangeForType:CKAddressBookChangeTypeDelete contactsIds:deleted];
        }
    }
}

- (void)ck_recordsChanged
{
    [[NSNotificationCenter defaultCenter] postNotificationName:CKAddressBookDidChangeNotification object:self userInfo:nil];
    
    if ([self.delegate respondsToSelector:@selector(addressBookDidChnage:)])
    {
        [self.delegate addressBookDidChnage:self];
    }
}

#if TARGET_OS_IOS

- (void)ck_addressBookChangedExternally
{
    dispatch_async(_addressBookQueue, ^{
        
        // Revert changes
        ABAddressBookRevert(_addressBookRef);
        
        if (self.observeContactsDiff)
        {
            NSArray *inserted, *updated, *deleted;
            _contacts = [self ck_newContactsWithOldConctacts:_contacts inserted:&inserted updated:&updated deleted:&deleted];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self ck_recordsChangedInserted:inserted updated:updated deleted:deleted];
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self ck_recordsChanged];
            });
        }
        
    });
}

- (NSArray *)ck_newContactsWithOldConctacts:(NSArray *)oldContacts inserted:(NSArray **)inserted updated:(NSArray **)updated deleted:(NSArray **)deleted
{
    CKContactField fields = CKContactFieldModificationDate | CKContactFieldCreationDate;
    CKContactField merge = self.unifyResults ? fields : 0;
    
    NSArray *newContacts = [self ck_contactsWithFields:fields merge:merge sortDescriptors:nil filter:nil error:nil];
    
    // If old contacts doesnt exists do not process the diff
    if (oldContacts.count)
    {
        NSMutableArray *changedContacts = [[NSMutableArray alloc] initWithArray:newContacts];
        
        // Get changed contacts
        [changedContacts removeObjectsInArray:oldContacts];
        
        NSMutableArray *insertedRecords = [[NSMutableArray alloc] init];
        NSMutableArray *updatedRecords = [[NSMutableArray alloc] init];
        
        for (CKContact *contact in changedContacts)
        {
            if ([contact.creationDate isEqualToDate:contact.modificationDate])
            {
                [insertedRecords addObject:contact];
            }
            else
            {
                [updatedRecords addObject:contact];
            }
        }
        
        NSString *keyPath = @"identifier";
        
        // Transform to array of Ids
        *inserted = [insertedRecords valueForKeyPath:keyPath];
        *updated = [updatedRecords valueForKeyPath:keyPath];
        
        // Deleted contacts diff
        NSMutableArray *deletedRecords = [[oldContacts valueForKeyPath:keyPath] mutableCopy];
        [deletedRecords removeObjectsInArray:[newContacts valueForKeyPath:keyPath]];
        *deleted = deletedRecords;
    }
    
    return newContacts;
}

#pragma mark - Callbacks

static void CKAddressBookExternalChangeCallback(ABAddressBookRef addressBookRef, CFDictionaryRef __unused info, void *context)
{
    CKAddressBook *addressBook = (__bridge CKAddressBook *)(context);
    [addressBook ck_addressBookChangedExternally];
}

#elif TARGET_OS_MAC

#pragma mark - Notifications

- (void)notificaitonDataBaseChanged:(NSNotification *)aNotification
{
//    Future using
//    NSArray *insertedRecords = [aNotification.userInfo objectForKey:kABInsertedRecords];
//    NSArray *deletedRecords = [aNotification.userInfo objectForKey:kABDeletedRecords];
//    NSArray *updatedRecords = [aNotification.userInfo objectForKey:kABUpdatedRecords];
}

- (void)notificaitonDatabaseChangedExternally:(NSNotification *)aNotification
{
    NSArray *insertedRecords = [aNotification.userInfo objectForKey:kABInsertedRecords];
    NSArray *updatedRecords = [aNotification.userInfo objectForKey:kABUpdatedRecords];
    NSArray *deletedRecords = [aNotification.userInfo objectForKey:kABDeletedRecords];
    
    [self ck_recordsChangedInserted:insertedRecords updated:updatedRecords deleted:deletedRecords];
}

#endif

@end
