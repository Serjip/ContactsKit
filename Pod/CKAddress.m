//
//  CKAddress.m
//  ContactsKit
//
//  Created by Sergey Popov on 1/18/16.
//  Copyright (c) 2016 ttitt. All rights reserved.
//

#import "CKAddress_Private.h"
#import <AddressBook/AddressBook.h>
#import <Contacts/CNPostalAddress.h>

@implementation CKAddress

#pragma mark - Lifecycle

- (instancetype)initWithAddressDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        _street = dictionary[(__bridge NSString *)kABPersonAddressStreetKey];
        _city = dictionary[(__bridge NSString *)kABPersonAddressCityKey];
        _state = dictionary[(__bridge NSString *)kABPersonAddressStateKey];
        _zip = dictionary[(__bridge NSString *)kABPersonAddressZIPKey];
        _country = dictionary[(__bridge NSString *)kABPersonAddressCountryKey];
        _ISOCountryCode = dictionary[(__bridge NSString *)kABPersonAddressCountryCodeKey];
    }
    return self;
}

- (instancetype)initWithPostalAddress:(CNPostalAddress *)address
{
    self = [super init];
    if (self)
    {
        _street = address.street;
        _city = address.city;
        _state = address.state;
        _zip = address.postalCode;
        _country = address.country;
        _ISOCountryCode = address.ISOCountryCode;
    }
    return self;
}

#pragma mark - NSSecureCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        _street = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(street))];
        _city = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(city))];
        _state = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(state))];
        _zip = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(zip))];
        _country = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(country))];
        _ISOCountryCode = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(ISOCountryCode))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_street forKey:NSStringFromSelector(@selector(street))];
    [aCoder encodeObject:_city forKey:NSStringFromSelector(@selector(city))];
    [aCoder encodeObject:_state forKey:NSStringFromSelector(@selector(state))];
    [aCoder encodeObject:_zip forKey:NSStringFromSelector(@selector(zip))];
    [aCoder encodeObject:_country forKey:NSStringFromSelector(@selector(country))];
    [aCoder encodeObject:_ISOCountryCode forKey:NSStringFromSelector(@selector(ISOCountryCode))];
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    CKAddress *copy = [[[self class] alloc] init];
    if (copy)
    {
        copy->_street = [self.street copyWithZone:zone];
        copy->_city = [self.city copyWithZone:zone];
        copy->_state = [self.state copyWithZone:zone];
        copy->_zip = [self.zip copyWithZone:zone];
        copy->_country = [self.country copyWithZone:zone];
        copy->_ISOCountryCode = [self.ISOCountryCode copyWithZone:zone];
    }
    return copy;
}

#pragma mark - Equality

- (BOOL)isEqualToAddress:(CKAddress *)address
{
    if (! [self.street isEqualToString:address.street])
    {
        return NO;
    }
    if (! [self.city isEqualToString:address.city])
    {
        return NO;
    }
    if (! [self.state isEqualToString:address.state])
    {
        return NO;
    }
    if (! [self.zip isEqualToString:address.zip])
    {
        return NO;
    }
    if (! [self.country isEqualToString:address.country])
    {
        return NO;
    }
    if (! [self.ISOCountryCode isEqualToString:address.ISOCountryCode])
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
    
    if (! [object isKindOfClass:[CKAddress class]])
    {
        return NO;
    }
    
    return [self isEqualToAddress:object];
}

@end
