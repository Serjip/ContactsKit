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

#import <Contacts/CNContact.h>

@implementation CKContact

#pragma mark - Lifecycle

- (instancetype)initWithRecordRef:(ABRecordRef)recordRef fieldMask:(CKContactField)fieldMask
{
    self = [super init];
    if (self)
    {
        _fieldMask = fieldMask;
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
        if (fieldMask & CKContactFieldCompositeName)
        {
            _compositeName = (__bridge_transfer NSString *)ABRecordCopyCompositeName(recordRef);
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
            _emails = [self arrayObjectsOfClass:[CKEmail class] ofProperty:kABPersonPhoneProperty fromRecord:recordRef];
        }
        if (fieldMask & CKContactFieldPhoto)
        {
            _photo = [self imagePropertyFullSize:YES fromRecord:recordRef];
        }
        if (fieldMask & CKContactFieldThumbnail)
        {
            _thumbnail = [self imagePropertyFullSize:NO fromRecord:recordRef];
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
        if (fieldMask & CKContactFieldRecordID)
        {
            _recordID = [NSNumber numberWithInteger:ABRecordGetRecordID(recordRef)];
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

- (void)mergeLinkedRecordRef:(ABRecordRef)recordRef fieldMask:(CKContactField)fieldMask
{
    if (fieldMask & CKContactFieldFirstName)
    {
        if (! self.firstName)
        {
            _firstName = [self stringProperty:kABPersonFirstNameProperty fromRecord:recordRef];
        }
    }
    
    if (fieldMask & CKContactFieldMiddleName)
    {
        if (! self.middleName)
        {
            _middleName = [self stringProperty:kABPersonMiddleNameProperty fromRecord:recordRef];
        }
    }
    
    if (fieldMask & CKContactFieldLastName)
    {
        if (! self.lastName)
        {
            _lastName = [self stringProperty:kABPersonLastNameProperty fromRecord:recordRef];
        }
    }
    
    if (fieldMask & CKContactFieldCompositeName)
    {
        if (! self.compositeName)
        {
            _compositeName = (__bridge_transfer NSString *)ABRecordCopyCompositeName(recordRef);
        }
    }
    
    if (fieldMask & CKContactFieldCompany)
    {
        if (! self.company ||! self.company.length)
        {
            _company = [self stringProperty:kABPersonOrganizationProperty fromRecord:recordRef];
        }
    }
    
    if (fieldMask & CKContactFieldJobTitle)
    {
        if (! self.jobTitle ||! self.jobTitle.length)
        {
            _jobTitle = [self stringProperty:kABPersonJobTitleProperty fromRecord:recordRef];
        }
    }
    
    if (fieldMask & CKContactFieldPhones)
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
    
    if (fieldMask & CKContactFieldEmails)
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

    if (fieldMask & CKContactFieldPhoto)
    {
        if (! self.photo)
        {
            _photo = [self imagePropertyFullSize:YES fromRecord:recordRef];
        }
    }
    
    if (fieldMask & CKContactFieldThumbnail)
    {
        if (! self.thumbnail)
        {
            _thumbnail = [self imagePropertyFullSize:NO fromRecord:recordRef];
        }
    }
    
    if (fieldMask & CKContactFieldAddresses)
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
    
    if (fieldMask & CKContactFieldBirthday)
    {
        if (! self.birthday)
        {
            _birthday = [self dateProperty:kABPersonBirthdayProperty fromRecord:recordRef];
        }
    }

    if (fieldMask & CKContactFieldSocialProfiles)
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

    if (fieldMask & CKContactFieldNote)
    {
        if (! self.note || ! self.note.length)
        {
            _note = [self stringProperty:kABPersonNoteProperty fromRecord:recordRef];
        }
    }
    
    if (fieldMask & CKContactFieldURLs)
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


- (instancetype)initWithContact:(CNContact *)contact fieldMask:(CKContactField)fieldMask
{
    self = [super init];
    if (self)
    {
        _fieldMask = fieldMask;
        
        if (fieldMask & CKContactFieldFirstName)
        {
            _firstName = contact.givenName;
        }
        if (fieldMask & CKContactFieldMiddleName)
        {
            _middleName = contact.middleName;
        }
        if (fieldMask & CKContactFieldLastName)
        {
            _lastName = contact.familyName;
        }
        if (fieldMask & CKContactFieldCompositeName)
        {
#warning Composite name
            _compositeName = contact.givenName;
        }
        if (fieldMask & CKContactFieldCompany)
        {
            _company = contact.organizationName;
        }
        if (fieldMask & CKContactFieldJobTitle)
        {
            _jobTitle = contact.jobTitle;
        }
        if (fieldMask & CKContactFieldPhones)
        {
            NSMutableArray *phones = [[NSMutableArray alloc] initWithCapacity:contact.phoneNumbers.count];
            for (CNPhoneNumber *phoneNumber in contact.phoneNumbers)
            {
                [phones addObject:[[CKPhone alloc] initWithLabledValue:phoneNumber]];
            }
            _phones = phones;
        }
        if (fieldMask & CKContactFieldEmails)
        {
            NSMutableArray *emails = [[NSMutableArray alloc] initWithCapacity:contact.emailAddresses.count];
            for (CNLabeledValue *email in contact.emailAddresses)
            {
#warning Emails
                [emails addObject:[[CKEmail alloc] initWithLabledValue:email]];
            }
            _emails = emails;
        }
        if (fieldMask & CKContactFieldPhoto)
        {
            _photo = [UIImage imageWithData:contact.imageData scale:[UIScreen mainScreen].scale];
        }
        if (fieldMask & CKContactFieldThumbnail)
        {
            _thumbnail = [UIImage imageWithData:contact.thumbnailImageData scale:[UIScreen mainScreen].scale];
        }
        if (fieldMask & CKContactFieldAddresses)
        {
            NSMutableArray *addresses = [[NSMutableArray alloc] initWithCapacity:contact.postalAddresses.count];
            for (CNPostalAddress *addr in contact.postalAddresses)
            {
                [addresses addObject:[[CKAddress alloc] initWithPostalAddress:addr]];
            }
            _addresses = addresses;
        }
        if (fieldMask & CKContactFieldRecordID)
        {
#warning Check the record id
            _recordID = @(contact.identifier.integerValue);
        }
        if (fieldMask & CKContactFieldBirthday)
        {
#warning Check the birthday
            _birthday = [[NSCalendar currentCalendar] dateFromComponents:contact.birthday];
        }
        if (fieldMask & CKContactFieldCreationDate)
        {
#warning Date
        }
        if (fieldMask & CKContactFieldModificationDate)
        {
#warning Date
        }
        if (fieldMask & CKContactFieldSocialProfiles)
        {
            NSMutableArray *profiles = [[NSMutableArray alloc] init];
            for (CNSocialProfile *profile in contact.socialProfiles)
            {
                [profiles addObject:[[CKSocialProfile alloc] initWithSocialProfile:profile]];
            }
            _socialProfiles = profiles;
        }
        if (fieldMask & CKContactFieldNote)
        {
            _note = contact.note;
        }
        if (fieldMask & CKContactFieldURLs)
        {
            NSMutableArray *URLs = [[NSMutableArray alloc] initWithCapacity:contact.urlAddresses.count];
            for (CNLabeledValue *url in contact.postalAddresses)
            {
#warning URLs
                [URLs addObject:[[CKURL alloc] initWithLabledValue:url]];
            }
            _URLs = URLs;
        }
    }
    return self;
}

- (void)mergeLinkedContact:(CNContact *)contact fieldMask:(CKContactField)fieldMask
{
#warning Merge it
}

#pragma mark - NSSecureCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        _firstName = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(firstName))];
        _middleName = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(middleName))];
        _lastName = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(lastName))];
        _compositeName = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(compositeName))];
        _company = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(company))];
        _jobTitle = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(jobTitle))];
        _phones = [aDecoder decodeObjectOfClass:[NSArray class] forKey:NSStringFromSelector(@selector(phones))];
        _emails = [aDecoder decodeObjectOfClass:[NSArray class] forKey:NSStringFromSelector(@selector(emails))];
        _addresses = [aDecoder decodeObjectOfClass:[NSArray class] forKey:NSStringFromSelector(@selector(addresses))];
        _recordID = [aDecoder decodeObjectOfClass:[NSNumber class] forKey:NSStringFromSelector(@selector(recordID))];
        _birthday = [aDecoder decodeObjectOfClass:[NSDate class] forKey:NSStringFromSelector(@selector(birthday))];
        _creationDate = [aDecoder decodeObjectOfClass:[NSDate class] forKey:NSStringFromSelector(@selector(creationDate))];
        _modificationDate = [aDecoder decodeObjectOfClass:[NSDate class] forKey:NSStringFromSelector(@selector(modificationDate))];
        _socialProfiles = [aDecoder decodeObjectOfClass:[NSArray class] forKey:NSStringFromSelector(@selector(socialProfiles))];
        _note = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(note))];
        _URLs = [aDecoder decodeObjectOfClass:[NSArray class] forKey:NSStringFromSelector(@selector(URLs))];
        
        NSData *thumbData = [aDecoder decodeObjectOfClass:[NSData class] forKey:NSStringFromSelector(@selector(thumbnail))];
        _thumbnail = [[UIImage alloc] initWithData:thumbData];
        
        NSData *photoData = [aDecoder decodeObjectOfClass:[NSData class] forKey:NSStringFromSelector(@selector(photo))];
        _photo = [[UIImage alloc] initWithData:photoData];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_firstName forKey:NSStringFromSelector(@selector(firstName))];
    [aCoder encodeObject:_middleName forKey:NSStringFromSelector(@selector(middleName))];
    [aCoder encodeObject:_lastName forKey:NSStringFromSelector(@selector(lastName))];
    [aCoder encodeObject:_compositeName forKey:NSStringFromSelector(@selector(compositeName))];
    [aCoder encodeObject:_company forKey:NSStringFromSelector(@selector(company))];
    [aCoder encodeObject:_jobTitle forKey:NSStringFromSelector(@selector(jobTitle))];
    [aCoder encodeObject:_phones forKey:NSStringFromSelector(@selector(phones))];
    [aCoder encodeObject:_emails forKey:NSStringFromSelector(@selector(emails))];
    [aCoder encodeObject:_addresses forKey:NSStringFromSelector(@selector(addresses))];
    [aCoder encodeObject:_recordID forKey:NSStringFromSelector(@selector(recordID))];
    [aCoder encodeObject:_birthday forKey:NSStringFromSelector(@selector(birthday))];
    [aCoder encodeObject:_creationDate forKey:NSStringFromSelector(@selector(creationDate))];
    [aCoder encodeObject:_modificationDate forKey:NSStringFromSelector(@selector(modificationDate))];
    [aCoder encodeObject:_socialProfiles forKey:NSStringFromSelector(@selector(socialProfiles))];
    [aCoder encodeObject:_note forKey:NSStringFromSelector(@selector(note))];
    [aCoder encodeObject:_URLs forKey:NSStringFromSelector(@selector(URLs))];

    [aCoder encodeObject:UIImagePNGRepresentation(_thumbnail) forKey:NSStringFromSelector(@selector(thumbnail))];
    [aCoder encodeObject:UIImagePNGRepresentation(_photo) forKey:NSStringFromSelector(@selector(photo))];
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
        copy->_firstName = [self.firstName copyWithZone:zone];
        copy->_middleName = [self.middleName copyWithZone:zone];
        copy->_lastName = [self.lastName copyWithZone:zone];
        copy->_compositeName = [self.compositeName copyWithZone:zone];
        copy->_company = [self.company copyWithZone:zone];
        copy->_jobTitle = [self.jobTitle copyWithZone:zone];
        copy->_phones = [self.phones copyWithZone:zone];
        copy->_emails = [self.emails copyWithZone:zone];
        copy->_addresses = [self.addresses copyWithZone:zone];
        copy->_recordID = [self.recordID copyWithZone:zone];
        copy->_birthday = [self.birthday copyWithZone:zone];
        copy->_creationDate = [self.creationDate copyWithZone:zone];
        copy->_modificationDate = [self.modificationDate copyWithZone:zone];
        copy->_socialProfiles = [self.socialProfiles copyWithZone:zone];
        copy->_note = [self.note copyWithZone:zone];
        copy->_URLs = [self.URLs copyWithZone:zone];
        
        // Dont copy the images
        copy->_thumbnail = self.thumbnail;
        copy->_photo = self.photo;
    }
    return copy;
}

#pragma mark - Private

- (NSString *)stringProperty:(ABPropertyID)property fromRecord:(ABRecordRef)recordRef
{
    CFTypeRef valueRef = (ABRecordCopyValue(recordRef, property));
    return (__bridge_transfer NSString *)valueRef;
}

- (NSArray *)arrayProperty:(ABPropertyID)property fromRecord:(ABRecordRef)recordRef
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [self enumerateMultiValueOfProperty:property fromRecord:recordRef
                              withBlock:^(ABMultiValueRef multiValue, CFIndex index)
    {
        id value = (__bridge_transfer id)ABMultiValueCopyValueAtIndex(multiValue, index);
        if (value)
        {
            [array addObject:value];
        }
    }];
    return [NSArray arrayWithArray:array];
}

- (NSDate *)dateProperty:(ABPropertyID)property fromRecord:(ABRecordRef)recordRef
{
    CFDateRef dateRef = (ABRecordCopyValue(recordRef, property));
    return (__bridge_transfer NSDate *)dateRef;
}

- (UIImage *)imagePropertyFullSize:(BOOL)isFullSize fromRecord:(ABRecordRef)recordRef
{
    ABPersonImageFormat format = isFullSize ? kABPersonImageFormatOriginalSize : kABPersonImageFormatThumbnail;
    NSData *data = (__bridge_transfer NSData *)ABPersonCopyImageDataWithFormat(recordRef, format);
    return [UIImage imageWithData:data scale:UIScreen.mainScreen.scale];
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

- (NSArray *)arrayObjectsOfClass:(Class)class ofProperty:(ABPropertyID)property fromRecord:(ABRecordRef)recordRef
{
    NSMutableArray *objects = [NSMutableArray array];
    [self enumerateMultiValueOfProperty:kABPersonPhoneProperty fromRecord:recordRef withBlock:^(ABMultiValueRef multiValue, CFIndex index) {
        id obj = [[class alloc] initWithMultiValue:multiValue index:index];
        if (obj)
        {
            [objects addObject:obj];
        }
    }];
    return [NSArray arrayWithArray:objects];
}

@end
