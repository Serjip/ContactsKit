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
    ABAddressBookRef _addressBookRef;
    dispatch_queue_t _addressBookQueue;
}

#pragma mark - Properties

- (CKAddressBookAccess)access
{
    return [CKAddressBook access];
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
        _addressBookRef = (__bridge  ABAddressBookRef)[ABAddressBook addressBook];
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
    if (_addressBookRef)
    {
        CFRelease(_addressBookRef);
    }
#if !OS_OBJECT_USE_OBJC
    dispatch_release(_addressBookQueue);
#endif
}

#pragma mark - Public

+ (CKAddressBookAccess)access
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
    return 0;
#warning Access status
#endif
}

- (void)loadContacts
{
    CKContactField fieldMask = self.fieldsMask;
    CKContactField mergeMask = self.mergeMask;
    NSArray *descriptors = [self.sortDescriptors copy];
    
//#if TARGET_OS_IOS
//    ABAddressBookRequestAccessWithCompletion(_addressBookRef, ^(bool granted, CFErrorRef errorRef) {
//        dispatch_async(_addressBookQueue, ^{
//            NSArray *array = nil;
//            NSError *error = nil;
//            
//            if (granted)
//            {
//                
//            }
//            else if (errorRef)
//            {
//                error = (__bridge NSError *)errorRef;
//            }
//            
//            if (error)
//            {
//                if ([self.delegate respondsToSelector:@selector(addressBook:didFailLoadContacts:)])
//                {
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [self.delegate addressBook:self didFailLoadContacts:error];
//                    });
//                }
//            }
//            else
//            {
//                if ([self.delegate respondsToSelector:@selector(addressBook:didLoadContacts:)])
//                {
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [self.delegate addressBook:self didLoadContacts:array];
//                    });
//                }
//            }
//        });
//    });
//#endif
    
    
    NSArray *array = [self ck_loadContactsWithFieldMask:fieldMask mergeMask:mergeMask sortDescriptors:descriptors];
    [self.delegate addressBook:self didLoadContacts:array];
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
#elif TARGET_OS_MAC
    CFArrayRef peopleArrayRef = ABCopyArrayOfAllPeople(_addressBookRef);
#endif
    CFIndex contactCount = CFArrayGetCount(peopleArrayRef);
    NSMutableArray *contacts = [[NSMutableArray alloc] initWithCapacity:(NSUInteger)contactCount];
    NSMutableSet *linkedContactsIDs = [NSMutableSet set];
    
    for (CFIndex i = 0; i < contactCount; i++)
    {
#if TARGET_OS_IOS
        ABRecordRef recordRef = CFArrayGetValueAtIndex(peopleArrayRef, i);
#elif TARGET_OS_MAC
        ABPersonRef recordRef = (ABPersonRef)CFArrayGetValueAtIndex(peopleArrayRef, i);
#endif
        
        // Checking already added contacts
        id linkedID;
#if TARGET_OS_IOS
        linkedID = @(ABRecordGetRecordID(recordRef));
#elif TARGET_OS_MAC
        linkedID = (__bridge_transfer NSString *)ABRecordCopyUniqueId(recordRef);
#endif
        if ([linkedContactsIDs containsObject:linkedID])
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
        
#if TARGET_OS_IOS
        CFArrayRef linkedPeopleArrayRef = ABPersonCopyArrayOfAllLinkedPeople(recordRef);
        CFIndex linkedCount = CFArrayGetCount(linkedPeopleArrayRef);
        if (linkedCount > 1)
        {
            // Merge linked contact info
            for (CFIndex j = 0; j < linkedCount; j++)
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
        }
        CFRelease(linkedPeopleArrayRef);
#elif TARGET_OS_MAC
        
        NSMutableArray *array = [NSMutableArray array];
        for (ABPerson *person in [(__bridge ABPerson *)recordRef linkedPeople])
        {
//            NSLog(@"%@", person);
            [array addObject:person];
        }
#endif
    }
    CFRelease(peopleArrayRef);
    
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
    NSArray *insertedRecords = [aNotification.userInfo objectForKey:kABInsertedRecords];
    NSArray *deletedRecords = [aNotification.userInfo objectForKey:kABDeletedRecords];
    NSArray *updatedRecords = [aNotification.userInfo objectForKey:kABUpdatedRecords];
}

- (void)notificaitonDatabaseChangedExternally:(NSNotification *)aNotification
{
    NSArray *insertedRecords = [aNotification.userInfo objectForKey:kABInsertedRecords];
    NSArray *deletedRecords = [aNotification.userInfo objectForKey:kABDeletedRecords];
    NSArray *updatedRecords = [aNotification.userInfo objectForKey:kABUpdatedRecords];
}

#endif

@end
