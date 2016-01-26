//
//  CKContact.m
//  ContactsKit
//
//  Created by Sergey Popov on 1/18/16.
//  Copyright (c) 2016 ttitt. All rights reserved.
//

#import "CKContact_Private.h"
#import "CKLabel_Private.h"
#import "CKAddress_Private.h"
#import "CKSocialProfile_Private.h"

#import "CKURL.h"
#import "CKPhone.h"
#import "CKEmail.h"

#import <AddressBook/AddressBook.h>

#if !(TARGET_OS_IOS)

#define ABPropertyID    CFStringRef
#define kABPersonFirstNameProperty          (__bridge CFStringRef)kABFirstNameProperty
#define kABPersonMiddleNameProperty         (__bridge CFStringRef)kABMiddleNameProperty
#define kABPersonLastNameProperty           (__bridge CFStringRef)kABLastNameProperty
#define kABPersonOrganizationProperty       (__bridge CFStringRef)kABOrganizationProperty
#define kABPersonJobTitleProperty           (__bridge CFStringRef)kABJobTitleProperty
#define kABPersonPhoneProperty              (__bridge CFStringRef)kABPhoneProperty
#define kABPersonEmailProperty              (__bridge CFStringRef)kABEmailProperty
#define kABPersonAddressProperty            (__bridge CFStringRef)kABAddressProperty
#define kABPersonBirthdayProperty           (__bridge CFStringRef)kABBirthdayProperty
#define kABPersonCreationDateProperty       (__bridge CFStringRef)kABCreationDateProperty
#define kABPersonModificationDateProperty   (__bridge CFStringRef)kABModificationDateProperty
#define kABPersonSocialProfileProperty      (__bridge CFStringRef)kABSocialProfileProperty
#define kABPersonNoteProperty               (__bridge CFStringRef)kABNoteProperty
#define kABPersonURLProperty                (__bridge CFStringRef)kABURLsProperty

#endif

@implementation CKContact

#pragma mark - Lifecycle

- (instancetype)initWithRecordRef:(ABRecordRef)recordRef fieldMask:(CKContactField)fieldMask
{
    self = [super init];
    if (self)
    {
        _fieldMask = fieldMask;
        
        if (fieldMask & CKContactFieldIdentifier)
        {
#if TARGET_OS_IOS
#warning Chagne the ID typ
            _identifier = [NSString stringWithFormat:@"%d",(int)ABRecordGetRecordID(recordRef)];
#elif TARGET_OS_MAC
            _identifier = (__bridge_transfer NSString *)ABRecordCopyUniqueId(recordRef);
#endif
        }
        
        if (fieldMask & CKContactFieldFirstName)
        {
            _firstName = [self stringProperty:kABPersonFirstNameProperty fromRecord:recordRef];
        }
        
        if (fieldMask & CKContactFieldMiddleName)
        {
            _middleName = [self stringProperty:kABPersonMiddleNameProperty fromRecord:recordRef];
        }
        
        if (fieldMask & CKContactFieldLastName)
        {
            _lastName = [self stringProperty:kABPersonLastNameProperty fromRecord:recordRef];
        }
        
        if (fieldMask & CKContactFieldCompany)
        {
            _company = [self stringProperty:kABPersonOrganizationProperty fromRecord:recordRef];
        }
        
        if (fieldMask & CKContactFieldJobTitle)
        {
            _jobTitle = [self stringProperty:kABPersonJobTitleProperty fromRecord:recordRef];
        }
        
        if (fieldMask & CKContactFieldPhones)
        {
            _phones = [self arrayObjectsOfClass:[CKPhone class] ofProperty:kABPersonPhoneProperty fromRecord:recordRef];
        }
        
        if (fieldMask & CKContactFieldEmails)
        {
            _emails = [self arrayObjectsOfClass:[CKEmail class] ofProperty:kABPersonEmailProperty fromRecord:recordRef];
        }
        
        if (fieldMask & CKContactFieldImageData)
        {
            _imageData = [self imageDataWithFullSize:YES fromRecord:recordRef];
        }
        
        if (fieldMask & CKContactFieldThumbnailData)
        {
            _thumbnailData = [self imageDataWithFullSize:NO fromRecord:recordRef];
        }
        
        if (fieldMask & CKContactFieldAddresses)
        {
            NSMutableArray *addresses = [[NSMutableArray alloc] init];
            NSArray *array = [self arrayProperty:kABPersonAddressProperty fromRecord:recordRef];
            for (NSDictionary *dictionary in array)
            {
                CKAddress *address = [[CKAddress alloc] initWithAddressDictionary:dictionary];
                [addresses addObject:address];
            }
            _addresses = addresses;
        }
        
        if (fieldMask & CKContactFieldBirthday)
        {
            _birthday = [self dateProperty:kABPersonBirthdayProperty fromRecord:recordRef];
        }
        
        if (fieldMask & CKContactFieldCreationDate)
        {
            _creationDate = [self dateProperty:kABPersonCreationDateProperty fromRecord:recordRef];
        }
        
        if (fieldMask & CKContactFieldModificationDate)
        {
            _modificationDate = [self dateProperty:kABPersonModificationDateProperty fromRecord:recordRef];
        }
        
        if (fieldMask & CKContactFieldSocialProfiles)
        {
            NSMutableArray *profiles = [[NSMutableArray alloc] init];
            NSArray *array = [self arrayProperty:kABPersonSocialProfileProperty fromRecord:recordRef];
            for (NSDictionary *dictionary in array)
            {
                CKSocialProfile *profile = [[CKSocialProfile alloc] initWithSocialDictionary:dictionary];
                [profiles addObject:profile];
            }
            
            _socialProfiles = profiles;
        }
        
        if (fieldMask & CKContactFieldNote)
        {
            _note = [self stringProperty:kABPersonNoteProperty fromRecord:recordRef];
        }
        
        if (fieldMask & CKContactFieldURLs)
        {
            _URLs = [self arrayObjectsOfClass:[CKURL class] ofProperty:kABPersonURLProperty fromRecord:recordRef];
        }
    }
    return self;
}

- (void)mergeLinkedRecordRef:(ABRecordRef)recordRef mergeMask:(CKContactField)mergeMask
{
    if (mergeMask & CKContactFieldFirstName)
    {
        if (! self.firstName)
        {
            _firstName = [self stringProperty:kABPersonFirstNameProperty fromRecord:recordRef];
        }
    }
    
    if (mergeMask & CKContactFieldMiddleName)
    {
        if (! self.middleName)
        {
            _middleName = [self stringProperty:kABPersonMiddleNameProperty fromRecord:recordRef];
        }
    }
    
    if (mergeMask & CKContactFieldLastName)
    {
        if (! self.lastName)
        {
            _lastName = [self stringProperty:kABPersonLastNameProperty fromRecord:recordRef];
        }
    }
    
    if (mergeMask & CKContactFieldCompany)
    {
        if (! self.company ||! self.company.length)
        {
            _company = [self stringProperty:kABPersonOrganizationProperty fromRecord:recordRef];
        }
    }
    
    if (mergeMask & CKContactFieldJobTitle)
    {
        if (! self.jobTitle ||! self.jobTitle.length)
        {
            _jobTitle = [self stringProperty:kABPersonJobTitleProperty fromRecord:recordRef];
        }
    }
    
    if (mergeMask & CKContactFieldPhones)
    {
        NSMutableArray *phones = [NSMutableArray arrayWithArray:self.phones];
        NSArray *phonesToMerge = [self arrayObjectsOfClass:[CKPhone class] ofProperty:kABPersonPhoneProperty fromRecord:recordRef];
        
        for (CKPhone *p in phonesToMerge)
        {
            if ([self.phones containsObject:p])
            {
                continue;
            }
            [phones addObject:p];
        }
        
        _phones = phones;
    }
    
    if (mergeMask & CKContactFieldEmails)
    {
        NSMutableArray *emails = [NSMutableArray arrayWithArray:self.emails];
        NSArray *emailsToMerge =  [self arrayObjectsOfClass:[CKEmail class] ofProperty:kABPersonEmailProperty fromRecord:recordRef];
        
        for (CKEmail *email in emailsToMerge)
        {
            if ([self.emails containsObject:email])
            {
                continue;
            }
            
            [emails addObject:email];
        }
        
        _emails = emails;
    }

    if (mergeMask & CKContactFieldImageData)
    {
        if (! self.imageData)
        {
            _imageData = [self imageDataWithFullSize:YES fromRecord:recordRef];
        }
    }
    
    if (mergeMask & CKContactFieldThumbnailData)
    {
        if (! self.thumbnailData)
        {
            _thumbnailData = [self imageDataWithFullSize:YES fromRecord:recordRef];
        }
    }
    
    if (mergeMask & CKContactFieldAddresses)
    {
        NSMutableArray *addresses = [NSMutableArray arrayWithArray:self.addresses];
        NSArray *array = [self arrayProperty:kABPersonAddressProperty fromRecord:recordRef];
        for (NSDictionary *dictionary in array)
        {
            CKAddress *address = [[CKAddress alloc] initWithAddressDictionary:dictionary];
            
            if ([self.addresses containsObject:address])
            {
                continue;
            }
            
            [addresses addObject:address];
        }
        _addresses = addresses;
    }
    
    if (mergeMask & CKContactFieldBirthday)
    {
        if (! self.birthday)
        {
            _birthday = [self dateProperty:kABPersonBirthdayProperty fromRecord:recordRef];
        }
    }

    if (mergeMask & CKContactFieldSocialProfiles)
    {
        NSMutableArray *profiles = [NSMutableArray arrayWithArray:self.socialProfiles];
        NSArray *array = [self arrayProperty:kABPersonSocialProfileProperty fromRecord:recordRef];
        for (NSDictionary *dictionary in array)
        {
            CKSocialProfile *profile = [[CKSocialProfile alloc] initWithSocialDictionary:dictionary];
            
            if ([self.socialProfiles containsObject:profile])
            {
                continue;
            }
            
            [profiles addObject:profile];
        }
        
        _socialProfiles = profiles;
    }

    if (mergeMask & CKContactFieldNote)
    {
        if (! self.note || ! self.note.length)
        {
            _note = [self stringProperty:kABPersonNoteProperty fromRecord:recordRef];
        }
    }
    
    if (mergeMask & CKContactFieldURLs)
    {
        NSMutableArray *URLs = [NSMutableArray arrayWithArray:self.URLs];
        
        NSArray *URLsToMerge = [self arrayObjectsOfClass:[CKURL class] ofProperty:kABPersonURLProperty fromRecord:recordRef];
        
        for (CKURL *Uwl in URLsToMerge)
        {
            if ([self.URLs containsObject:Uwl])
            {
                continue;
            }
            [URLs addObject:Uwl];
        }
        
        _URLs = URLs;
    }
}

#pragma mark - NSSecureCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        _identifier = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(identifier))];
        _firstName = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(firstName))];
        _middleName = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(middleName))];
        _lastName = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(lastName))];
        _company = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(company))];
        _jobTitle = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(jobTitle))];
        _phones = [aDecoder decodeObjectOfClass:[NSArray class] forKey:NSStringFromSelector(@selector(phones))];
        _emails = [aDecoder decodeObjectOfClass:[NSArray class] forKey:NSStringFromSelector(@selector(emails))];
        _addresses = [aDecoder decodeObjectOfClass:[NSArray class] forKey:NSStringFromSelector(@selector(addresses))];
        _birthday = [aDecoder decodeObjectOfClass:[NSDate class] forKey:NSStringFromSelector(@selector(birthday))];
        _creationDate = [aDecoder decodeObjectOfClass:[NSDate class] forKey:NSStringFromSelector(@selector(creationDate))];
        _modificationDate = [aDecoder decodeObjectOfClass:[NSDate class] forKey:NSStringFromSelector(@selector(modificationDate))];
        _socialProfiles = [aDecoder decodeObjectOfClass:[NSArray class] forKey:NSStringFromSelector(@selector(socialProfiles))];
        _note = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(note))];
        _URLs = [aDecoder decodeObjectOfClass:[NSArray class] forKey:NSStringFromSelector(@selector(URLs))];
        
        _imageData = [aDecoder decodeObjectOfClass:[NSData class] forKey:NSStringFromSelector(@selector(imageData))];
        _thumbnailData = [aDecoder decodeObjectOfClass:[NSData class] forKey:NSStringFromSelector(@selector(thumbnailData))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_identifier forKey:NSStringFromSelector(@selector(identifier))];
    [aCoder encodeObject:_firstName forKey:NSStringFromSelector(@selector(firstName))];
    [aCoder encodeObject:_middleName forKey:NSStringFromSelector(@selector(middleName))];
    [aCoder encodeObject:_lastName forKey:NSStringFromSelector(@selector(lastName))];
    [aCoder encodeObject:_company forKey:NSStringFromSelector(@selector(company))];
    [aCoder encodeObject:_jobTitle forKey:NSStringFromSelector(@selector(jobTitle))];
    [aCoder encodeObject:_phones forKey:NSStringFromSelector(@selector(phones))];
    [aCoder encodeObject:_emails forKey:NSStringFromSelector(@selector(emails))];
    [aCoder encodeObject:_addresses forKey:NSStringFromSelector(@selector(addresses))];
    [aCoder encodeObject:_birthday forKey:NSStringFromSelector(@selector(birthday))];
    [aCoder encodeObject:_creationDate forKey:NSStringFromSelector(@selector(creationDate))];
    [aCoder encodeObject:_modificationDate forKey:NSStringFromSelector(@selector(modificationDate))];
    [aCoder encodeObject:_socialProfiles forKey:NSStringFromSelector(@selector(socialProfiles))];
    [aCoder encodeObject:_note forKey:NSStringFromSelector(@selector(note))];
    [aCoder encodeObject:_URLs forKey:NSStringFromSelector(@selector(URLs))];

    [aCoder encodeObject:_imageData forKey:NSStringFromSelector(@selector(imageData))];
    [aCoder encodeObject:_thumbnailData forKey:NSStringFromSelector(@selector(thumbnailData))];
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    CKContact *copy = [[[self class] alloc] init];
    if (copy)
    {
        copy->_identifier = [self.identifier copyWithZone:zone];
        copy->_firstName = [self.firstName copyWithZone:zone];
        copy->_middleName = [self.middleName copyWithZone:zone];
        copy->_lastName = [self.lastName copyWithZone:zone];
        copy->_company = [self.company copyWithZone:zone];
        copy->_jobTitle = [self.jobTitle copyWithZone:zone];
        copy->_phones = [self.phones copyWithZone:zone];
        copy->_emails = [self.emails copyWithZone:zone];
        copy->_addresses = [self.addresses copyWithZone:zone];
        copy->_birthday = [self.birthday copyWithZone:zone];
        copy->_creationDate = [self.creationDate copyWithZone:zone];
        copy->_modificationDate = [self.modificationDate copyWithZone:zone];
        copy->_socialProfiles = [self.socialProfiles copyWithZone:zone];
        copy->_note = [self.note copyWithZone:zone];
        copy->_URLs = [self.URLs copyWithZone:zone];
    
        copy->_imageData = [self.imageData copyWithZone:zone];
        copy->_thumbnailData = [self.thumbnailData copyWithZone:zone];
    }
    return copy;
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"%p %@ %@", self, self.firstName, self.lastName];
}

#pragma mark - Private

- (NSString *)stringProperty:(ABPropertyID)property fromRecord:(ABRecordRef)recordRef
{
    return (__bridge_transfer NSString *)ABRecordCopyValue(recordRef, property);
}

- (NSDate *)dateProperty:(ABPropertyID)property fromRecord:(ABRecordRef)recordRef
{
    return (__bridge_transfer NSDate *)ABRecordCopyValue(recordRef, property);
}

- (NSData *)imageDataWithFullSize:(BOOL)isFullSize fromRecord:(ABRecordRef)recordRef
{
#if TARGET_OS_IOS
    ABPersonImageFormat format = isFullSize ? kABPersonImageFormatOriginalSize : kABPersonImageFormatThumbnail;
    return (__bridge_transfer NSData *)ABPersonCopyImageDataWithFormat(recordRef, format);
#elif TARGET_OS_MAC
    return (__bridge_transfer NSData *)ABPersonCopyImageData(recordRef);
#endif
}

- (void)enumerateMultiValueOfProperty:(ABPropertyID)property fromRecord:(ABRecordRef)recordRef
                            withBlock:(void (^)(ABMultiValueRef multiValue, CFIndex index))block
{
    ABMultiValueRef multiValue = ABRecordCopyValue(recordRef, property);
    if (multiValue)
    {
#if TARGET_OS_IOS
        CFIndex count = ABMultiValueGetCount(multiValue);
#elif TARGET_OS_MAC
        CFIndex count = ABMultiValueCount(multiValue);
#endif
        for (CFIndex i = 0; i < count; i++)
        {
            block(multiValue, i);
        }
        CFRelease(multiValue);
    }
}

- (NSArray *)arrayProperty:(ABPropertyID)property fromRecord:(ABRecordRef)recordRef
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [self enumerateMultiValueOfProperty:property fromRecord:recordRef withBlock:^(ABMultiValueRef multiValue, CFIndex index) {
        id value = (__bridge_transfer id)ABMultiValueCopyValueAtIndex(multiValue, index);
        if (value)
        {
            [array addObject:value];
        }
    }];
    return [NSArray arrayWithArray:array];
}

- (NSArray *)arrayObjectsOfClass:(Class)class ofProperty:(ABPropertyID)property fromRecord:(ABRecordRef)recordRef
{
    NSMutableArray *objects = [NSMutableArray array];
    [self enumerateMultiValueOfProperty:property fromRecord:recordRef withBlock:^(ABMultiValueRef multiValue, CFIndex index) {
        id obj = [[class alloc] initWithMultiValue:multiValue index:index];
        [objects addObject:obj];
    }];
    return [NSArray arrayWithArray:objects];
}

@end
