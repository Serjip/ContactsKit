//
//  CKDate.m
//  ContactsKit
//
//  Created by Sergey Popov on 3/12/16.
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

#import "CKDate.h"
#import "CKLabel_Private.h"
#import "CKMacros.h"

NSString * const CKDateAnniversary = @"_$!<Anniversary>!$_";

@implementation CKDate

#pragma mark - Lifecycle

- (instancetype)initWithMultiValue:(ABMultiValueRef)multiValue index:(CFIndex)index
{
    self = [super initWithMultiValue:multiValue index:index];
    if(self)
    {
        _value = (__bridge_transfer NSDate *)ABMultiValueCopyValueAtIndex(multiValue, index);
    }
    return self;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    CKDate *copy = [super copyWithZone:zone];
    if (copy)
    {
        copy->_value = [self.value copyWithZone:zone];
    }
    return copy;
}

#pragma mark - NSMutableCopying

- (id)mutableCopyWithZone:(NSZone *)zone
{
    CKMutableDate *mutableCopy = [[CKMutableDate allocWithZone:zone] init];
    if (mutableCopy)
    {
        mutableCopy.originalLabel = [self.originalLabel copyWithZone:zone];
        mutableCopy.value = [self.value copyWithZone:zone];
    }
    return mutableCopy;
}

#pragma mark - NSSecureCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        _value = [aDecoder decodeObjectOfClass:[NSDate class] forKey:NSStringFromSelector(@selector(value))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_value forKey:NSStringFromSelector(@selector(value))];
}

#pragma mark - Equality

- (BOOL)isEqualToDate:(CKDate *)date
{
    if (! [super isEqual:date])
    {
        return NO;
    }
    
    return CK_IS_EQUAL(self.value, date.value);
}

- (BOOL)isEqual:(id)object
{
    if (self == object)
    {
        return YES;
    }
    
    if (! [object isKindOfClass:[CKDate class]])
    {
        return NO;
    }
    
    return [self isEqualToDate:object];
}

- (NSUInteger)hash
{
    return self.value.hash ^ self.originalLabel.hash;
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ (%@)", self.value, self.originalLabel];
}

#pragma mark - Class methods

+ (NSArray *)labels
{
    return @[CKDateAnniversary, CKLabelOther];
}

#pragma mark - Instance

- (BOOL)setLabledValue:(ABMutableMultiValueRef)mutableMultiValue
{
#if TARGET_OS_IOS
    return ABMultiValueAddValueAndLabel(mutableMultiValue, (__bridge CFTypeRef)(self.value), (__bridge CFStringRef)(self.originalLabel), NULL);
#elif TARGET_OS_MAC
    return ABMultiValueAdd(mutableMultiValue, (__bridge CFTypeRef)(self.value), (__bridge CFStringRef)(self.originalLabel), NULL);
#endif
}

@end

@implementation CKMutableDate

@dynamic originalLabel;
@synthesize value;

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    return [super mutableCopyWithZone:zone];
}

@end

