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

- (void)loadContacts
{
    CKContactField fieldMask = self.fieldsMask;
    CKContactField mergeMask = self.mergeMask;
    NSArray *descriptors = [self.sortDescriptors copy];
    
#if TARGET_OS_IOS
    ABAddressBookRequestAccessWithCompletion(_addressBookRef, ^(bool granted, CFErrorRef errorRef) {
        NSError *error = (__bridge NSError *)(errorRef);
#elif TARGET_OS_MAC
        BOOL granted = YES;
        NSError *error = nil;
        
        if (! _addressBook)
        {
            granted = NO;
        }
#endif
        dispatch_async(_addressBookQueue, ^{
            NSArray *array = nil;
            
            if (granted)
            {
                array = [self ck_loadContactsWithFieldMask:fieldMask mergeMask:mergeMask sortDescriptors:descriptors];
            }
            
            if (error)
            {
                if ([self.delegate respondsToSelector:@selector(addressBook:didFailLoadContacts:)])
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.delegate addressBook:self didFailLoadContacts:error];
                    });
                }
            }
            else
            {
                if ([self.delegate respondsToSelector:@selector(addressBook:didLoadContacts:)])
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.delegate addressBook:self didLoadContacts:array];
                    });
                }
            }
        });
#if TARGET_OS_IOS
    });
#endif
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

- (NSArray *)ck_loadContactsWithFieldMask:(CKContactField)fieldMask mergeMask:(CKContactField)mergeMask sortDescriptors:(NSArray *)descriptors
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
        if (! [self.delegate respondsToSelector:@selector(addressBook:shouldAddContact:)] || [self.delegate addressBook:self shouldAddContact:contact])
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
        if (! [self.delegate respondsToSelector:@selector(addressBook:shouldAddContact:)] || [self.delegate addressBook:self shouldAddContact:contact])
        {
            [contacts addObject:contact];
        }
        
        NSArray *linkedPeople = [record linkedPeople];
        if (linkedPeople.count > 0)
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
}

#elif TARGET_OS_MAC

#pragma mark - Notifications

- (void)notificaitonDataBaseChanged:(NSNotification *)aNotification
{
//    NSArray *insertedRecords = [aNotification.userInfo objectForKey:kABInsertedRecords];
//    NSArray *deletedRecords = [aNotification.userInfo objectForKey:kABDeletedRecords];
//    NSArray *updatedRecords = [aNotification.userInfo objectForKey:kABUpdatedRecords];
#warning Future using
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
}

#endif

@end
