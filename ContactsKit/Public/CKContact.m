//
//  CKContact.m
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

#import "CKContact_Private.h"

#import "CKLabel_Private.h"
#import "CKAddress_Private.h"
#import "CKMessenger_Private.h"
#import "CKSocialProfile_Private.h"

#import "CKURL.h"
#import "CKDate.h"
#import "CKEmail.h"
#import "CKPhone.h"

#import "CKMacros.h"
#import "CKAutoCoder.h"
#import "CKAddressBook.h"

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
        
        if (fieldMask & CKContactFieldNamePrefix)
        {
            _namePrefix = [self stringProperty:kABPersonPrefixProperty fromRecord:recordRef];
        }
        
        if (fieldMask & CKContactFieldNameSuffix)
        {
            _nameSuffix = [self stringProperty:kABPersonSuffixProperty fromRecord:recordRef];
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
            _addresses = [[NSArray  alloc] initWithArray:addresses];
        }
        
        if (fieldMask & CKContactFieldInstantMessengers)
        {
            NSMutableArray *messengers = [[NSMutableArray alloc] init];
            NSArray *array = [self arrayProperty:kABPersonInstantMessageProperty fromRecord:recordRef];
            for (NSDictionary *dictionary in array)
            {
                CKMessenger *messenger = [[CKMessenger alloc] initWithMessengerDictionary:dictionary];
                [messengers addObject:messenger];
            }
            _instantMessengers = [[NSArray  alloc] initWithArray:messengers];
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
            _socialProfiles = [[NSArray  alloc] initWithArray:profiles];
        }
        
        if (fieldMask & CKContactFieldURLs)
        {
            _URLs = [self arrayObjectsOfClass:[CKURL class] ofProperty:kABPersonURLProperty fromRecord:recordRef];
        }
        
        if (fieldMask & CKContactFieldDates)
        {
            _dates = [self arrayObjectsOfClass:[CKDate class] ofProperty:kABPersonDateProperty fromRecord:recordRef];
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
    
    if (mergeMask & CKContactFieldNamePrefix)
    {
        if (! self.namePrefix)
        {
            _namePrefix = [self stringProperty:kABPersonPrefixProperty fromRecord:recordRef];
        }
    }
    
    if (mergeMask & CKContactFieldNameSuffix)
    {
        if (! self.nameSuffix)
        {
            _nameSuffix = [self stringProperty:kABPersonSuffixProperty fromRecord:recordRef];
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
        if (! self.note)
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
        NSMutableArray *phones = [[NSMutableArray alloc] initWithArray:self.phones];
        NSArray *phonesToMerge = [self arrayObjectsOfClass:[CKPhone class] ofProperty:kABPersonPhoneProperty fromRecord:recordRef];
        
        for (CKPhone *p in phonesToMerge)
        {
            if ([self.phones containsObject:p])
            {
                continue;
            }
            [phones addObject:p];
        }
        
        _phones = [[NSArray alloc] initWithArray:phones];
    }
    
    if (mergeMask & CKContactFieldEmails)
    {
        NSMutableArray *emails = [[NSMutableArray alloc] initWithArray:self.emails];
        NSArray *emailsToMerge =  [self arrayObjectsOfClass:[CKEmail class] ofProperty:kABPersonEmailProperty fromRecord:recordRef];
        
        for (CKEmail *email in emailsToMerge)
        {
            if ([self.emails containsObject:email])
            {
                continue;
            }
            
            [emails addObject:email];
        }
        
        _emails = [[NSArray alloc] initWithArray:emails];
    }

    if (mergeMask & CKContactFieldAddresses)
    {
        NSMutableArray *addresses = [[NSMutableArray alloc] initWithArray:self.addresses];
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
        _addresses = [[NSArray alloc] initWithArray:addresses];
    }
    
    if (mergeMask & CKContactFieldInstantMessengers)
    {
        NSMutableArray *messengers = [NSMutableArray arrayWithArray:self.instantMessengers];
        NSArray *array = [self arrayProperty:kABPersonInstantMessageProperty fromRecord:recordRef];
        for (NSDictionary *dictionary in array)
        {
            CKMessenger *messenger = [[CKMessenger alloc] initWithMessengerDictionary:dictionary];
            
            if ([self.instantMessengers containsObject:messenger])
            {
                continue;
            }
            
            [messengers addObject:messenger];
        }
        
        _instantMessengers = [[NSArray alloc] initWithArray:messengers];
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
        
        _socialProfiles = [[NSArray alloc] initWithArray:profiles];
    }
    
    if (mergeMask & CKContactFieldURLs)
    {
        NSMutableArray *URLs = [[NSMutableArray alloc] initWithArray:self.URLs];
        NSArray *URLsToMerge = [self arrayObjectsOfClass:[CKURL class] ofProperty:kABPersonURLProperty fromRecord:recordRef];
        
        for (CKURL *url in URLsToMerge)
        {
            if ([self.URLs containsObject:url])
            {
                continue;
            }
            [URLs addObject:url];
        }
        
        _URLs = [[NSArray alloc] initWithArray:URLs];
    }
    
    if (mergeMask & CKContactFieldDates)
    {
        NSMutableArray *dates = [[NSMutableArray alloc] initWithArray:self.dates];
        NSArray *datesToMerge = [self arrayObjectsOfClass:[CKDate class] ofProperty:kABPersonDateProperty fromRecord:recordRef];
        
        for (CKDate *date in datesToMerge)
        {
            if ([self.dates containsObject:date])
            {
                continue;
            }
            [dates addObject:date];
        }
        
        _dates = [[NSArray alloc] initWithArray:dates];
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
    CKContact *copy = [[[self class] allocWithZone:zone] init];
    if (copy)
    {
        copy->_identifier = [self.identifier copyWithZone:zone];
        copy->_firstName = [self.firstName copyWithZone:zone];
        copy->_middleName = [self.middleName copyWithZone:zone];
        copy->_lastName = [self.lastName copyWithZone:zone];
        copy->_nickname = [self.nickname copyWithZone:zone];
        copy->_namePrefix = [self.namePrefix copyWithZone:zone];
        copy->_nameSuffix = [self.nameSuffix copyWithZone:zone];
        
        copy->_company = [self.company copyWithZone:zone];
        copy->_jobTitle = [self.jobTitle copyWithZone:zone];
        copy->_department = [self.department copyWithZone:zone];
        
        copy->_note = [self.note copyWithZone:zone];
        
        copy->_imageData = [self.imageData copyWithZone:zone];
        copy->_thumbnailData = [self.thumbnailData copyWithZone:zone];
        
        copy->_phones = [self.phones copyWithZone:zone];
        copy->_emails = [self.emails copyWithZone:zone];
        copy->_addresses = [self.addresses copyWithZone:zone];
        copy->_instantMessengers = [self.instantMessengers copyWithZone:zone];
        copy->_socialProfiles = [self.socialProfiles copyWithZone:zone];
        copy->_URLs = [self.URLs copyWithZone:zone];
        copy->_dates = [self.dates copyWithZone:zone];
        
        copy->_birthday = [self.birthday copyWithZone:zone];
        copy->_creationDate = [self.creationDate copyWithZone:zone];
        copy->_modificationDate = [self.modificationDate copyWithZone:zone];
    }
    return copy;
}

#pragma mark - NSMutableCopying

- (id)mutableCopyWithZone:(nullable NSZone *)zone
{
    CKMutableContact *mutableCopy = [[CKMutableContact allocWithZone:zone] init];
    if (mutableCopy)
    {
        mutableCopy.identifier = [self.identifier copyWithZone:zone];
        mutableCopy.firstName = [self.firstName copyWithZone:zone];
        mutableCopy.middleName = [self.middleName copyWithZone:zone];
        mutableCopy.lastName = [self.lastName copyWithZone:zone];
        mutableCopy.nickname = [self.nickname copyWithZone:zone];
        mutableCopy.namePrefix = [self.namePrefix copyWithZone:zone];
        mutableCopy.nameSuffix = [self.nameSuffix copyWithZone:zone];
        
        mutableCopy.company = [self.company copyWithZone:zone];
        mutableCopy.jobTitle = [self.jobTitle copyWithZone:zone];
        mutableCopy.department = [self.department copyWithZone:zone];
        
        mutableCopy.note = [self.note copyWithZone:zone];
        
        mutableCopy.imageData = [self.imageData copyWithZone:zone];
        mutableCopy.thumbnailData = [self.thumbnailData copyWithZone:zone];
        
        mutableCopy.phones = [self.phones copyWithZone:zone];
        mutableCopy.emails = [self.emails copyWithZone:zone];
        mutableCopy.addresses = [self.addresses copyWithZone:zone];
        mutableCopy.instantMessengers = [self.instantMessengers copyWithZone:zone];
        mutableCopy.socialProfiles = [self.socialProfiles copyWithZone:zone];
        mutableCopy.URLs = [self.URLs copyWithZone:zone];
        mutableCopy.dates = [self.dates copyWithZone:zone];
        
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
        [aDecoder decodeIvarsWithObject:self ofClass:[CKContact class] ignoreIvars:nil];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeIvarsWithObject:self ofClass:[CKContact class] ignoreIvars:nil];
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

#pragma mark - Equality

- (BOOL)isEqualToContact:(CKContact *)contact
{
    if (! contact)
    {
        return NO;
    }
    
    if (! CK_IS_EQUAL(self.identifier, contact.identifier))
    {
        return NO;
    }
    
    if (! CK_IS_EQUAL(self.firstName, contact.firstName))
    {
        return NO;
    }
    
    if (! CK_IS_EQUAL(self.lastName, contact.lastName))
    {
        return NO;
    }
    
    if (! CK_IS_EQUAL(self.middleName, contact.middleName))
    {
        return NO;
    }
    
    if (! CK_IS_EQUAL(self.nickname, contact.nickname))
    {
        return NO;
    }
    
    if (! CK_IS_EQUAL(self.namePrefix, contact.namePrefix))
    {
        return NO;
    }
    
    if (! CK_IS_EQUAL(self.nameSuffix, contact.nameSuffix))
    {
        return NO;
    }
    
    if (! CK_IS_EQUAL(self.company, contact.company))
    {
        return NO;
    }
    
    if (! CK_IS_EQUAL(self.jobTitle, contact.jobTitle))
    {
        return NO;
    }
    
    if (! CK_IS_EQUAL(self.department, contact.department))
    {
        return NO;
    }
    
    if (! CK_IS_EQUAL(self.note, contact.note))
    {
        return NO;
    }
    
    if (! CK_IS_EQUAL(self.imageData, contact.imageData))
    {
        return NO;
    }
    
    if (! CK_IS_EQUAL(self.thumbnailData, contact.thumbnailData))
    {
        return NO;
    }
    
    if (! CK_IS_EQUAL(self.phones, contact.phones))
    {
        return NO;
    }
    
    if (! CK_IS_EQUAL(self.instantMessengers, contact.instantMessengers))
    {
        return NO;
    }
    
    if (! CK_IS_EQUAL(self.socialProfiles, contact.socialProfiles))
    {
        return NO;
    }
    
    if (! CK_IS_EQUAL(self.emails, contact.emails))
    {
        return NO;
    }
    
    if (! CK_IS_EQUAL(self.addresses, contact.addresses))
    {
        return NO;
    }
    
    if (! CK_IS_EQUAL(self.URLs, contact.URLs))
    {
        return NO;
    }
    
    if (! CK_IS_EQUAL(self.dates, contact.dates))
    {
        return NO;
    }
    
    if (! CK_IS_EQUAL(self.birthday, contact.birthday))
    {
        return NO;
    }
    
    if (! CK_IS_EQUAL(self.creationDate, contact.creationDate))
    {
        return NO;
    }
    
    if (! CK_IS_EQUAL(self.modificationDate, contact.modificationDate))
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

- (NSUInteger)hash
{
    return self.identifier.hash;
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"%p %@ %@ %@", self, self.identifier, self.firstName, self.lastName];
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
    return [[NSArray  alloc] initWithArray:array];
}

- (NSArray *)arrayObjectsOfClass:(Class)class ofProperty:(ABPropertyID)property fromRecord:(ABRecordRef)recordRef
{
    NSMutableArray *objects = [NSMutableArray array];
    [self enumerateMultiValueOfProperty:property fromRecord:recordRef withBlock:^(ABMultiValueRef multiValue, CFIndex index) {
        id obj = [[class alloc] initWithMultiValue:multiValue index:index];
        [objects addObject:obj];
    }];
    return [[NSArray  alloc] initWithArray:objects];
}

@end

@implementation CKMutableContact

@synthesize identifier, firstName, lastName, middleName, nickname, namePrefix, nameSuffix;
@synthesize company, jobTitle, department;
@synthesize note, imageData, thumbnailData;
@synthesize phones, emails, addresses, instantMessengers, socialProfiles, URLs, dates;
@synthesize birthday, creationDate, modificationDate;

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    return [super mutableCopyWithZone:zone];
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [aDecoder decodeIvarsWithObject:self ofClass:[CKMutableContact class] ignoreIvars:nil];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeIvarsWithObject:self ofClass:[CKMutableContact class] ignoreIvars:nil];
}

#pragma mark - Instace

- (BOOL)setRecordRef:(ABRecordRef)recordRef error:(NSError **)error
{
    BOOL result = YES;
    
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
    
    if (result && self.namePrefix)
    {
        result = [self setValue:self.namePrefix forProperty:kABPersonPrefixProperty toRecord:recordRef error:error];
    }
    
    if (result && self.nameSuffix)
    {
        result = [self setValue:self.nameSuffix forProperty:kABPersonSuffixProperty toRecord:recordRef error:error];
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
        result = [self enumerateLabels:self.phones property:kABPersonPhoneProperty record:recordRef error:error];
    }
    
    if (result && self.emails)
    {
        result = [self enumerateLabels:self.emails property:kABPersonEmailProperty record:recordRef error:error];
    }
    
    if (result && self.URLs)
    {
        result = [self enumerateLabels:self.URLs property:kABPersonURLProperty record:recordRef error:error];
    }
    
    if (result && self.dates)
    {
        result = [self enumerateLabels:self.dates property:kABPersonDateProperty record:recordRef error:error];
    }
    
    if (result && self.instantMessengers)
    {
        result = [self enumerateValues:self.instantMessengers property:kABPersonInstantMessageProperty type:kABMultiDictionaryPropertyType
                                record:recordRef block:^BOOL(CKMessenger *value, ABMutableMultiValueRef mutableMultiValueRef) {
                                    return [value addPropertiesToMultiValue:mutableMultiValueRef];
                                } error:error];
    }
    
    if (result && self.socialProfiles)
    {
        result = [self enumerateValues:self.socialProfiles property:kABPersonSocialProfileProperty type:kABMultiDictionaryPropertyType
                                record:recordRef block:^BOOL(CKSocialProfile *value, ABMutableMultiValueRef mutableMultiValueRef) {
            return [value addPropertiesToMultiValue:mutableMultiValueRef];
        } error:error];
    }
    
    if (result && self.addresses)
    {
        result = [self enumerateValues:self.addresses property:kABPersonAddressProperty type:kABMultiDictionaryPropertyType
                                record:recordRef block:^BOOL(CKAddress *value, ABMutableMultiValueRef mutableMultiValueRef) {
            return [value addPropertiesToMultiValue:mutableMultiValueRef];
        } error:error];
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
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : CKLocalizedString(@"Cannot set property", nil)};
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
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : CKLocalizedString(@"Cannot set property", nil)};
        *error = [NSError errorWithDomain:CKAddressBookErrorDomain code:1 userInfo:userInfo];
    }
    return result;
}

- (BOOL)enumerateLabels:(NSArray<CKLabel *> *)labels property:(ABPropertyID)property record:(ABRecordRef)recordRef error:(NSError **)error
{
    return [self enumerateValues:labels property:property type:kABMultiStringPropertyType record:recordRef block:^BOOL(CKLabel *label, ABMutableMultiValueRef mutableMultiValueRef) {
        
        return [label setLabledValue:mutableMultiValueRef];
        
    } error:error];
}


- (BOOL)enumerateValues:(NSArray *)values property:(ABPropertyID)property type:(ABPropertyType)type record:(ABRecordRef)recordRef
                  block:(BOOL (^) (id value, ABMutableMultiValueRef mutableMultiValueRef))block error:(NSError **)error
{
    BOOL result = YES;
    
#if TARGET_OS_IOS
    ABMutableMultiValueRef mutableMultiValueRef = ABMultiValueCreateMutable(type);
#elif TARGET_OS_MAC
    ABMutableMultiValueRef mutableMultiValueRef = ABMultiValueCreateMutable();
#endif
    
    for (id value in values)
    {
        result = block(value, mutableMultiValueRef);
        
        if (! result)
        {
            break;
        }
    }
    
    if (result)
    {
#if TARGET_OS_IOS
        result = ABRecordSetValue(recordRef, property, mutableMultiValueRef, NULL);
#elif TARGET_OS_MAC
        result = ABRecordSetValue(recordRef, property, mutableMultiValueRef);
#endif
    }
    
    if (mutableMultiValueRef != NULL)
    {
        CFRelease(mutableMultiValueRef);
    }
    
    if (! result && error)
    {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : CKLocalizedString(@"Cannot set property", nil)};
        *error = [NSError errorWithDomain:CKAddressBookErrorDomain code:1 userInfo:userInfo];
    }
    return result;
}

@end
