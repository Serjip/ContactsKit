//
//  CKAddressBook.m
//  ContactsKit
//
//  Created by Sergey Popov on 1/18/16.
//  Copyright (c) 2016 ttitt. All rights reserved.
//

#import "CKAddressBook.h"
#import "CKContact_Private.h"
#import <AddressBook/AddressBook.h>

NSString *const CKAddressBookDidChangeNotification = @"CKAddressBookDidChangeNotification";

@implementation CKAddressBook {
@private
#if TARGET_OS_IOS
    ABAddressBookRef _addressBookRef;
#elif TARGET_OS_MAC
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
    if (_addressBook)
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
        CFErrorRef errorRef = NULL;
#if TARGET_OS_IOS
        _addressBookRef = ABAddressBookCreateWithOptions(NULL, &errorRef);
#elif TARGET_OS_MAC
        _addressBook = [ABAddressBook addressBook];
#endif
        if (errorRef)
        {
            NSLog(@"%@", (__bridge_transfer NSString *)CFErrorCopyFailureReason(errorRef));
            return nil;
        }
        
        // Set addressbook queue
        _addressBookQueue = dispatch_queue_create("com.ttitt.contactskit.queue", DISPATCH_QUEUE_SERIAL);
        
        // Set default field masks
        _fieldsMask = CKContactFieldDefault;
    }
    return self;
}

- (void)dealloc
{
    [self stopObserveChanges];
    
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

- (void)requestAccessWithCompletion:(void (^)(BOOL granted, NSError *error))callback
{
    NSParameterAssert(callback);

#if TARGET_OS_IOS
    ABAddressBookRequestAccessWithCompletion(_addressBookRef, ^(bool granted, CFErrorRef errorRef) {
        NSError *error = (__bridge_transfer NSError *)(errorRef);
        callback(granted, error);
    });
#elif TARGET_OS_MAC

#warning Support osx

#endif
}

- (void)loadContacts
{
    CKContactField fieldMask = self.fieldsMask;
    CKContactField mergeMask = self.unifyLinkedContacts ? fieldMask : 0;
    NSArray *descriptors = [self.sortDescriptors copy];
    
    dispatch_async(_addressBookQueue, ^{
        
        id filter = nil;
        if ([self.delegate respondsToSelector:@selector(addressBook:shouldLoadContact:)])
        {
            filter = ^BOOL(CKContact *contact) {
                return [self.delegate addressBook:self shouldLoadContact:contact];
            };
        }
        
        NSArray *contacts = [self ck_contactsWithFieldMask:fieldMask mergeMask:mergeMask sortDescriptors:descriptors filter:filter];
        
        if ([self.delegate respondsToSelector:@selector(addressBook:didLoadContacts:)])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate addressBook:self didLoadContacts:contacts];
            });
        }
    });
}

- (void)contactsWithMask:(CKContactField)mask uinify:(BOOL)unify sortDescriptors:(NSArray *)descriptors
                  filter:(BOOL (^) (CKContact *contact))filter completion:(void (^) (NSArray *contacts))callback
{
    NSParameterAssert(callback);
    
    dispatch_async(_addressBookQueue, ^{
       
        CKContactField mergeMask = unify ? mask : 0;
        NSArray *contacts = [self ck_contactsWithFieldMask:mask mergeMask:mergeMask sortDescriptors:descriptors filter:filter];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            callback(contacts);
        });
    });
}

- (void)contactWithIdentifier:(NSString *)identifier
{
    CKContactField fieldMask = self.fieldsMask;
    CKContactField mergeMask = self.unifyLinkedContacts ? fieldMask : 0;
    
    dispatch_async(_addressBookQueue, ^{
        
        CKContact *contact = [self ck_contactWithIdentifier:identifier fieldMask:fieldMask mergeMask:mergeMask];
        
        if ([self.delegate respondsToSelector:@selector(addressBook:didLoadContact:)])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate addressBook:self didLoadContact:contact];
            });
        }
    });
}

- (void)contactWithIdentifier:(NSString *)identifier mask:(CKContactField)mask uinify:(BOOL)unify completion:(void (^) (CKContact *contact))callback
{
    NSParameterAssert(identifier);
    NSParameterAssert(callback);

    dispatch_async(_addressBookQueue, ^{
        
        CKContactField mergeMask = unify ? mask : 0;
        
        CKContact *contact = [self ck_contactWithIdentifier:identifier fieldMask:mask mergeMask:mergeMask];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            callback(contact);
        });
    });
}

- (void)startObserveChanges
{
    [self stopObserveChanges];
    
#if TARGET_OS_IOS
    ABAddressBookRegisterExternalChangeCallback(_addressBookRef, CKAddressBookExternalChangeCallback, (__bridge void *)(self));
#elif TARGET_OS_MAC
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(notificaitonDataBaseChanged:) name:kABDatabaseChangedNotification object:nil];
    [nc addObserver:self selector:@selector(notificaitonDatabaseChangedExternally:) name:kABDatabaseChangedExternallyNotification object:nil];
#endif
}

- (void)stopObserveChanges
{
#if TARGET_OS_IOS
    ABAddressBookUnregisterExternalChangeCallback(_addressBookRef, CKAddressBookExternalChangeCallback, (__bridge void *)(self));
#elif TARGET_OS_MAC
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self name:kABDatabaseChangedNotification object:nil];
    [nc removeObserver:self name:kABDatabaseChangedExternallyNotification object:nil];
#endif
}

#pragma mark - Private

- (NSArray *)ck_contactsWithFieldMask:(CKContactField)fieldMask mergeMask:(CKContactField)mergeMask sortDescriptors:(NSArray *)descriptors filter:(BOOL (^) (CKContact *contact))filter
{
    // Gettings the array of people
#if TARGET_OS_IOS
    CFArrayRef peopleArrayRef = ABAddressBookCopyArrayOfAllPeople(_addressBookRef);
    CFIndex contactCount = CFArrayGetCount(peopleArrayRef);
    NSMutableArray *contacts = [[NSMutableArray alloc] initWithCapacity:(NSUInteger)contactCount];
    NSMutableSet *linkedContactsIDs = [NSMutableSet set];

    for (CFIndex i = 0; i < contactCount; i++)
    {
        ABRecordRef recordRef = (ABRecordRef)CFArrayGetValueAtIndex(peopleArrayRef, i);
        
        // Checking already added contacts
        if ([linkedContactsIDs containsObject:@(ABRecordGetRecordID(recordRef))])
        {
            continue;
        }
        
        // Create the contact
        CKContact *contact = [[CKContact alloc] initWithRecordRef:recordRef fieldMask:fieldMask];
        
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
            
            if (mergeMask)
            {
                [contact mergeLinkedRecordRef:linkedRecordRef mergeMask:mergeMask];
                [linkedContactsIDs addObject:@(ABRecordGetRecordID(recordRef))];
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
        CKContact *contact = [[CKContact alloc] initWithRecordRef:recordRef fieldMask:fieldMask];
        
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
                
                if (mergeMask)
                {
                    ABRecordRef linkedRecordRef = (__bridge ABRecordRef)(linkedRecord);
                    [contact mergeLinkedRecordRef:linkedRecordRef mergeMask:mergeMask];
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

- (CKContact *)ck_contactWithIdentifier:(NSString *)identifier fieldMask:(CKContactField)fieldMask mergeMask:(CKContactField)mergeMask
{
    NSParameterAssert(identifier);
    
    CKContact *contact = nil;
    
#if TARGET_OS_IOS
    ABRecordRef recordRef = ABAddressBookGetPersonWithRecordID(_addressBookRef, (int32_t)identifier.integerValue);
    if (recordRef != NULL)
    {
        contact = [[CKContact alloc] initWithRecordRef:recordRef fieldMask:fieldMask];
        
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
            
            if (mergeMask)
            {
                [contact mergeLinkedRecordRef:linkedRecordRef mergeMask:mergeMask];
            }
        }
        CFRelease(linkedPeopleArrayRef);
    }
#elif TARGET_OS_MAC
    ABRecord *record = [_addressBook recordForUniqueId:identifier];
    if (record)
    {
        ABRecordRef recordRef = (__bridge ABRecordRef)(record);
        CKContact *contact = [[CKContact alloc] initWithRecordRef:recordRef fieldMask:fieldMask];
        
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
                
                if (mergeMask)
                {
                    ABRecordRef linkedRecordRef = (__bridge ABRecordRef)(linkedRecord);
                    [contact mergeLinkedRecordRef:linkedRecordRef mergeMask:mergeMask];
                }
            }
        }
    }
#endif
    return contact;
}

#if TARGET_OS_IOS

#pragma mark - Callbacks

static void CKAddressBookExternalChangeCallback(ABAddressBookRef addressBookRef, CFDictionaryRef __unused info, void *context)
{
    ABAddressBookRevert(addressBookRef);
    CKAddressBook *addressBook = (__bridge CKAddressBook *)(context);
    
    if ([addressBook.delegate respondsToSelector:@selector(addressBookDidChnage:)])
    {
        [addressBook.delegate addressBookDidChnage:addressBook];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CKAddressBookDidChangeNotification object:addressBook userInfo:nil];
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
//    Future using
//    NSArray *insertedRecords = [aNotification.userInfo objectForKey:kABInsertedRecords];
//    NSArray *deletedRecords = [aNotification.userInfo objectForKey:kABDeletedRecords];
//    NSArray *updatedRecords = [aNotification.userInfo objectForKey:kABUpdatedRecords];
    
    if ([self.delegate respondsToSelector:@selector(addressBookDidChnage:)])
    {
        [self.delegate addressBookDidChnage:self];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CKAddressBookDidChangeNotification object:self userInfo:nil];
}

#endif

@end
