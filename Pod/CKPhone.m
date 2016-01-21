//
//  CKPhone.m
//  ContactsKit
//
//  Created by Sergey Popov on 1/18/16.
//  Copyright (c) 2016 ttitt. All rights reserved.
//

#import "CKPhone.h"
#import "CKLabel_Private.h"

@implementation CKPhone

#pragma mark - Lifecycle

- (instancetype)initWithMultiValue:(ABMultiValueRef)multiValue index:(CFIndex)index
{
    self = [super initWithMultiValue:multiValue index:index];
    if(self)
    {
        _number = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(multiValue, index);
    }
    return self;
}

#pragma mark - NSSecureCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        _number = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(number))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_number forKey:NSStringFromSelector(@selector(number))];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    CKPhone *copy = [super copyWithZone:zone];
    if (copy)
    {
        copy->_number = [self.number copyWithZone:zone];
    }
    return copy;
}

#pragma mark - Equality

- (BOOL)isEqualToPhone:(CKPhone *)phone
{
    return ([phone.number isEqualToString:self.number] && [phone.originalLabel isEqual:self.originalLabel]);
}

- (BOOL)isEqual:(id)object
{
    if (self == object)
    {
        return YES;
    }
    
    if (! [object isKindOfClass:[CKPhone class]])
    {
        return NO;
    }
    
    return [self isEqualToPhone:object];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ (%@)", self.number, self.originalLabel];
}

@end
