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
#define kABPersonNicknameProperty           (__bridge CFStringRef)kABNicknameProperty

#define kABPersonOrganizationProperty       (__bridge CFStringRef)kABOrganizationProperty
#define kABPersonJobTitleProperty           (__bridge CFStringRef)kABJobTitleProperty
#define kABPersonDepartmentProperty         (__bridge CFStringRef)kABDepartmentProperty

#define kABPersonNoteProperty               (__bridge CFStringRef)kABNoteProperty

#define kABPersonPhoneProperty              (__bridge CFStringRef)kABPhoneProperty
#define kABPersonEmailProperty              (__bridge CFStringRef)kABEmailProperty
#define kABPersonAddressProperty            (__bridge CFStringRef)kABAddressProperty
#define kABPersonSocialProfileProperty      (__bridge CFStringRef)kABSocialProfileProperty
#define kABPersonURLProperty                (__bridge CFStringRef)kABURLsProperty

#define kABPersonBirthdayProperty           (__bridge CFStringRef)kABBirthdayProperty
#define kABPersonCreationDateProperty       (__bridge CFStringRef)kABCreationDateProperty
#define kABPersonModificationDateProperty   (__bridge CFStringRef)kABModificationDateProperty

#define ABMultiValueGetCount    ABMultiValueCount

#endif

@implementation CKContact

#pragma mark - Lifecycle

- (instancetype)initWithRecordRef:(ABRecordRef)recordRef fieldMask:(CKContactField)fieldMask
{
    self = [super init];
    if (self)
    {
        _fieldMask = fieldMask;
        
#if TARGET_OS_IOS
        _identifier = [NSString stringWithFormat:@"%d",(int)ABRecordGetRecordID(recordRef)];
#elif TARGET_OS_MAC
        _identifier = (__bridge_transfer NSString *)ABRecordCopyUniqueId(recordRef);
#endif
        
        // Names
        
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
        
        if (fieldMask & CKContactFieldNickname)
        {
            _nickname = [self stringProperty:kABPersonNicknameProperty fromRecord:recordRef];
        }
        
        // Corp
        
        if (fieldMask & CKContactFieldCompany)
        {
            _company = [self stringProperty:kABPersonOrganizationProperty fromRecord:recordRef];
        }
        
        if (fieldMask & CKContactFieldJobTitle)
        {
            _jobTitle = [self stringProperty:kABPersonJobTitleProperty fromRecord:recordRef];
        }
        
        if (fieldMask & CKContactFieldJobTitle)
        {
            _department = [self stringProperty:kABPersonDepartmentProperty fromRecord:recordRef];
        }
        
        // Note
        if (fieldMask & CKContactFieldNote)
        {
            _note = [self stringProperty:kABPersonNoteProperty fromRecord:recordRef];
        }
        
        // Images
        
        if (fieldMask & CKContactFieldImageData)
        {
            _imageData = [self imageDataWithFullSize:YES fromRecord:recordRef];
        }
        
        if (fieldMask & CKContactFieldThumbnailData)
        {
            _thumbnailData = [self imageDataWithFullSize:NO fromRecord:recordRef];
        }
        
        // Arrays
        
        if (fieldMask & CKContactFieldPhones)
        {
            _phones = [self arrayObjectsOfClass:[CKPhone class] ofProperty:kABPersonPhoneProperty fromRecord:recordRef];
        }
        
        if (fieldMask & CKContactFieldEmails)
        {
            _emails = [self arrayObjectsOfClass:[CKEmail class] ofProperty:kABPersonEmailProperty fromRecord:recordRef];
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
        
        if (fieldMask & CKContactFieldURLs)
        {
            _URLs = [self arrayObjectsOfClass:[CKURL class] ofProperty:kABPersonURLProperty fromRecord:recordRef];
        }
        
        // Dates
        
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
        
    }
    return self;
}

- (void)mergeLinkedRecordRef:(ABRecordRef)recordRef mergeMask:(CKContactField)mergeMask
{
    // Names
    
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
    
    if (mergeMask & CKContactFieldNickname)
    {
        if (! self.nickname)
        {
            _nickname = [self stringProperty:kABPersonNicknameProperty fromRecord:recordRef];
        }
    }
    
    // Corp
    
    if (mergeMask & CKContactFieldCompany)
    {
        if (! self.company ||! self.company.length)
        {
            _company = [self stringProperty:kABPersonOrganizationProperty fromRecord:recordRef];
        }
    }
    
    if (mergeMask & CKContactFieldJobTitle)
    {
        if (! self.jobTitle)
        {
            _jobTitle = [self stringProperty:kABPersonJobTitleProperty fromRecord:recordRef];
        }
    }
    
    if (mergeMask & CKContactFieldDepartment)
    {
        if (! self.department)
        {
            _department = [self stringProperty:kABPersonDepartmentProperty fromRecord:recordRef];
        }
    }
    
    // Note
    
    if (mergeMask & CKContactFieldNote)
    {
        if (! self.note || ! self.note.length)
        {
            _note = [self stringProperty:kABPersonNoteProperty fromRecord:recordRef];
        }
    }
    
    // Images
    
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
            _thumbnailData = [self imageDataWithFullSize:NO fromRecord:recordRef];
        }
    }
    
    // Arrays
    
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
    
    if (mergeMask & CKContactFieldURLs)
    {
        NSMutableArray *URLs = [NSMutableArray arrayWithArray:self.URLs];
        
        NSArray *URLsToMerge = [self arrayObjectsOfClass:[CKURL class] ofProperty:kABPersonURLProperty fromRecord:recordRef];
        
        for (CKURL *url in URLsToMerge)
        {
            if ([self.URLs containsObject:url])
            {
                continue;
            }
            [URLs addObject:url];
        }
        
        _URLs = URLs;
    }
    
    // Dates
    
    if (mergeMask & CKContactFieldBirthday)
    {
        if (! self.birthday)
        {
            _birthday = [self dateProperty:kABPersonBirthdayProperty fromRecord:recordRef];
        }
    }
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
        copy->_nickname = [self.nickname copyWithZone:zone];
        
        copy->_company = [self.company copyWithZone:zone];
        copy->_jobTitle = [self.jobTitle copyWithZone:zone];
        copy->_department = [self.department copyWithZone:zone];
        
        copy->_note = [self.note copyWithZone:zone];
        
        copy->_imageData = [self.imageData copyWithZone:zone];
        copy->_thumbnailData = [self.thumbnailData copyWithZone:zone];
        
        copy->_phones = [self.phones copyWithZone:zone];
        copy->_emails = [self.emails copyWithZone:zone];
        copy->_addresses = [self.addresses copyWithZone:zone];
        copy->_socialProfiles = [self.socialProfiles copyWithZone:zone];
        copy->_URLs = [self.URLs copyWithZone:zone];
        
        copy->_birthday = [self.birthday copyWithZone:zone];
        copy->_creationDate = [self.creationDate copyWithZone:zone];
        copy->_modificationDate = [self.modificationDate copyWithZone:zone];
    }
    return copy;
}

#pragma mark - NSMutableCopying

- (id)mutableCopyWithZone:(nullable NSZone *)zone
{
    CKMutableContact *mutableCopy = [[CKMutableContact alloc] init];
    if (mutableCopy)
    {
        mutableCopy.identifier = [self.identifier copyWithZone:zone];
        mutableCopy.firstName = [self.firstName copyWithZone:zone];
        mutableCopy.middleName = [self.middleName copyWithZone:zone];
        mutableCopy.lastName = [self.lastName copyWithZone:zone];
        mutableCopy.nickname = [self.nickname copyWithZone:zone];
        
        mutableCopy.company = [self.company copyWithZone:zone];
        mutableCopy.jobTitle = [self.jobTitle copyWithZone:zone];
        mutableCopy.department = [self.department copyWithZone:zone];
        
        mutableCopy.note = [self.note copyWithZone:zone];
        
        mutableCopy.imageData = [self.imageData copyWithZone:zone];
        mutableCopy.thumbnailData = [self.thumbnailData copyWithZone:zone];
        
        mutableCopy.phones = [self.phones copyWithZone:zone];
        mutableCopy.emails = [self.emails copyWithZone:zone];
        mutableCopy.addresses = [self.addresses copyWithZone:zone];
        mutableCopy.socialProfiles = [self.socialProfiles copyWithZone:zone];
        mutableCopy.URLs = [self.URLs copyWithZone:zone];
        
        mutableCopy.birthday = [self.birthday copyWithZone:zone];
        mutableCopy.creationDate = [self.creationDate copyWithZone:zone];
        mutableCopy.modificationDate = [self.modificationDate copyWithZone:zone];
    }
    return mutableCopy;
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
        _nickname = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(nickname))];
        
        _company = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(company))];
        _jobTitle = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(jobTitle))];
        _department = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(department))];

        _note = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(note))];
        
        _imageData = [aDecoder decodeObjectOfClass:[NSData class] forKey:NSStringFromSelector(@selector(imageData))];
        _thumbnailData = [aDecoder decodeObjectOfClass:[NSData class] forKey:NSStringFromSelector(@selector(thumbnailData))];
        
        _phones = [aDecoder decodeObjectOfClass:[NSArray class] forKey:NSStringFromSelector(@selector(phones))];
        _emails = [aDecoder decodeObjectOfClass:[NSArray class] forKey:NSStringFromSelector(@selector(emails))];
        _addresses = [aDecoder decodeObjectOfClass:[NSArray class] forKey:NSStringFromSelector(@selector(addresses))];
        _socialProfiles = [aDecoder decodeObjectOfClass:[NSArray class] forKey:NSStringFromSelector(@selector(socialProfiles))];
        _URLs = [aDecoder decodeObjectOfClass:[NSArray class] forKey:NSStringFromSelector(@selector(URLs))];
        
        _birthday = [aDecoder decodeObjectOfClass:[NSDate class] forKey:NSStringFromSelector(@selector(birthday))];
        _creationDate = [aDecoder decodeObjectOfClass:[NSDate class] forKey:NSStringFromSelector(@selector(creationDate))];
        _modificationDate = [aDecoder decodeObjectOfClass:[NSDate class] forKey:NSStringFromSelector(@selector(modificationDate))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_identifier forKey:NSStringFromSelector(@selector(identifier))];
    [aCoder encodeObject:_firstName forKey:NSStringFromSelector(@selector(firstName))];
    [aCoder encodeObject:_middleName forKey:NSStringFromSelector(@selector(middleName))];
    [aCoder encodeObject:_lastName forKey:NSStringFromSelector(@selector(lastName))];
    [aCoder encodeObject:_nickname forKey:NSStringFromSelector(@selector(nickname))];
    
    [aCoder encodeObject:_company forKey:NSStringFromSelector(@selector(company))];
    [aCoder encodeObject:_jobTitle forKey:NSStringFromSelector(@selector(jobTitle))];
    [aCoder encodeObject:_department forKey:NSStringFromSelector(@selector(department))];
    
    [aCoder encodeObject:_note forKey:NSStringFromSelector(@selector(note))];

    [aCoder encodeObject:_imageData forKey:NSStringFromSelector(@selector(imageData))];
    [aCoder encodeObject:_thumbnailData forKey:NSStringFromSelector(@selector(thumbnailData))];
    
    [aCoder encodeObject:_phones forKey:NSStringFromSelector(@selector(phones))];
    [aCoder encodeObject:_emails forKey:NSStringFromSelector(@selector(emails))];
    [aCoder encodeObject:_addresses forKey:NSStringFromSelector(@selector(addresses))];
    [aCoder encodeObject:_socialProfiles forKey:NSStringFromSelector(@selector(socialProfiles))];
    [aCoder encodeObject:_URLs forKey:NSStringFromSelector(@selector(URLs))];

    [aCoder encodeObject:_birthday forKey:NSStringFromSelector(@selector(birthday))];
    [aCoder encodeObject:_creationDate forKey:NSStringFromSelector(@selector(creationDate))];
    [aCoder encodeObject:_modificationDate forKey:NSStringFromSelector(@selector(modificationDate))];
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

#pragma mark - Equality

- (BOOL)isEqualToContact:(CKContact *)contact
{
    if (! [self.identifier isEqualToString:contact.identifier])
    {
        return NO;
    }
    return YES;
}

- (BOOL)isEqual:(id)object
{
    if (self == object)
    {
        return YES;
    }
    if (! [object isKindOfClass:[CKContact class]])
    {
        return NO;
    }
    return [self isEqualToContact:object];
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
        CFIndex count = ABMultiValueGetCount(multiValue);
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

@implementation CKMutableContact

@synthesize identifier, firstName, lastName, middleName, nickname;
@synthesize company, jobTitle, department;
@synthesize note, imageData, thumbnailData;
@synthesize phones, emails, addresses, socialProfiles, URLs;
@synthesize birthday, creationDate, modificationDate;

- (BOOL)setRecordRef:(ABRecordRef)recordRef error:(NSError **)error
{
    BOOL result = YES;
    
    if (self.identifier)
    {
#warning ID
    }
    
    // Names
    
    if (result && self.firstName)
    {
        result = [self setValue:self.firstName forProperty:kABPersonFirstNameProperty toRecord:recordRef error:error];
    }
    
    if (result && self.lastName)
    {
        result = [self setValue:self.lastName forProperty:kABPersonLastNameProperty toRecord:recordRef error:error];
    }
    
    if (result && self.middleName)
    {
        result = [self setValue:self.middleName forProperty:kABPersonMiddleNameProperty toRecord:recordRef error:error];
    }
    
    if (result && self.nickname)
    {
        result = [self setValue:self.nickname forProperty:kABPersonNicknameProperty toRecord:recordRef error:error];
    }
    
    // Corp
    
    if (result && self.company)
    {
        result = [self setValue:self.company forProperty:kABPersonOrganizationProperty toRecord:recordRef error:error];
    }
    
    if (result && self.jobTitle)
    {
        result = [self setValue:self.jobTitle forProperty:kABPersonJobTitleProperty toRecord:recordRef error:error];
    }
    
    if (result && self.department)
    {
        result = [self setValue:self.department forProperty:kABPersonDepartmentProperty toRecord:recordRef error:error];
    }
    
    // Note
    
    if (result && self.note)
    {
        result = [self setValue:self.note forProperty:kABPersonNoteProperty toRecord:recordRef error:error];
    }
    
    // Image
    
    if (result && self.imageData)
    {
        result = [self setImageData:self.imageData toRecord:recordRef error:error];
    }
    
    // Arrays
    
    if (result && self.phones)
    {
#warning Phones
    }
    
    // Dates
    
    if (result && self.birthday)
    {
        result = [self setValue:self.birthday forProperty:kABPersonBirthdayProperty toRecord:recordRef error:error];
    }
    
    return result;
}

#pragma mark - Private

- (BOOL)setValue:(id)value forProperty:(ABPropertyID)property toRecord:(ABRecordRef)recordRef error:(NSError **)error
{
#if TARGET_OS_IOS
    BOOL result = ABRecordSetValue(recordRef, property, (__bridge CFTypeRef)(value), NULL);
#elif TARGET_OS_MAC
    BOOL result = ABRecordSetValue(recordRef, property, (__bridge CFTypeRef)(value));
#endif
    
    if (! result && error)
    {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : NSLocalizedString(@"Cannot set property", nil)};
        *error = [NSError errorWithDomain:CKAddressBookErrorDomain code:1 userInfo:userInfo];
    }
    return result;
}

- (BOOL)setImageData:(NSData *)data toRecord:(ABRecordRef)recordRef error:(NSError **)error
{
#if TARGET_OS_IOS
    BOOL result = ABPersonSetImageData(recordRef, (__bridge CFDataRef)(data), NULL);
#elif TARGET_OS_MAC
    BOOL result = ABPersonSetImageData(recordRef, (__bridge CFDataRef)(data));
#endif
    
    if (! result && error)
    {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : NSLocalizedString(@"Cannot set property", nil)};
        *error = [NSError errorWithDomain:CKAddressBookErrorDomain code:1 userInfo:userInfo];
    }
    return result;
}

@end
