//
//  CKAddress.m
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

#import "CKAddress_Private.h"
#import "CKMacros.h"
#import "CKAutoCoder.h"

@implementation CKAddress

#pragma mark - Lifecycle

- (instancetype)initWithAddressDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        _street = [dictionary objectForKey:kABAddressStreetKey];
        _city = [dictionary objectForKey:kABAddressCityKey];
        _state = [dictionary objectForKey:kABAddressStateKey];
        _ZIP = [dictionary objectForKey:kABAddressZIPKey];
        _country = [dictionary objectForKey:kABAddressCountryKey];
        _ISOCountryCode = [dictionary objectForKey:kABAddressCountryCodeKey];
    }
    return self;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    CKAddress *copy = [[[self class] allocWithZone:zone] init];
    if (copy)
    {
        copy->_street = [self.street copyWithZone:zone];
        copy->_city = [self.city copyWithZone:zone];
        copy->_state = [self.state copyWithZone:zone];
        copy->_ZIP = [self.ZIP copyWithZone:zone];
        copy->_country = [self.country copyWithZone:zone];
        copy->_ISOCountryCode = [self.ISOCountryCode copyWithZone:zone];
    }
    return copy;
}

#pragma mark - NSMutableCopying

- (id)mutableCopyWithZone:(NSZone *)zone
{
    CKMutableAddress *mutableCopy = [[CKMutableAddress allocWithZone:zone] init];
    if (mutableCopy)
    {
        mutableCopy.street = [self.street copyWithZone:zone];
        mutableCopy.city = [self.city copyWithZone:zone];
        mutableCopy.state = [self.state copyWithZone:zone];
        mutableCopy.ZIP = [self.ZIP copyWithZone:zone];
        mutableCopy.country = [self.country copyWithZone:zone];
        mutableCopy.ISOCountryCode = [self.ISOCountryCode copyWithZone:zone];
    }
    return mutableCopy;
}

#pragma mark - NSSecureCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        [aDecoder decodeIvarsWithObject:self ofClass:[CKAddress class] ignoreIvars:nil];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeIvarsWithObject:self ofClass:[CKAddress class] ignoreIvars:nil];
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

#pragma mark - Equality

- (BOOL)isEqualToAddress:(CKAddress *)address
{
    if (! address)
    {
        return NO;
    }
    
    if (! CK_IS_EQUAL(self.street, address.street))
    {
        return NO;
    }
    if (! CK_IS_EQUAL(self.city, address.city))
    {
        return NO;
    }
    if (! CK_IS_EQUAL(self.state, address.state))
    {
        return NO;
    }
    if (! CK_IS_EQUAL(self.ZIP, address.ZIP))
    {
        return NO;
    }
    if (! CK_IS_EQUAL(self.country, address.country))
    {
        return NO;
    }
    if (! CK_IS_EQUAL(self.ISOCountryCode, address.ISOCountryCode))
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

- (NSUInteger)hash
{
    return self.street.hash ^ self.city.hash ^ self.state.hash ^ self.ZIP.hash ^ self.country.hash ^ self.ISOCountryCode.hash;
}

#pragma mark - Public Instace

- (BOOL)addPropertiesToMultiValue:(ABMutableMultiValueRef)mutableMultiValueRef
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:self.street forKey:kABAddressStreetKey];
    [dictionary setValue:self.city forKey:kABAddressCityKey];
    [dictionary setValue:self.state forKey:kABAddressStateKey];
    [dictionary setValue:self.ZIP forKey:kABAddressZIPKey];
    [dictionary setValue:self.country forKey:kABAddressCountryKey];
    [dictionary setValue:self.ISOCountryCode forKey:kABAddressCountryCodeKey];
    
#if TARGET_OS_IOS
    return ABMultiValueAddValueAndLabel(mutableMultiValueRef, (__bridge CFTypeRef)(dictionary), NULL, NULL);
#elif TARGET_OS_MAC
    return ABMultiValueAdd(mutableMultiValueRef, (__bridge CFTypeRef)(dictionary), NULL, NULL);
#endif
}

@end

@implementation CKMutableAddress

@synthesize street, city, state, ZIP, country, ISOCountryCode;

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
        [aDecoder decodeIvarsWithObject:self ofClass:[CKMutableAddress class] ignoreIvars:nil];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeIvarsWithObject:self ofClass:[CKMutableAddress class] ignoreIvars:nil];
}

@end
