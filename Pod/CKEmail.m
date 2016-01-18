//
//  CKEmail.m
//  ContactsKit
//
//  Created by Sergey Popov on 1/18/16.
//  Copyright (c) 2016 ttitt. All rights reserved.
//

#import "CKEmail.h"
#import "CKLabel_Private.h"
#import <Contacts/Contacts.h>

@implementation CKEmail

#pragma mark - Lifecycle

- (instancetype)initWithMultiValue:(ABMultiValueRef)multiValue index:(CFIndex)index
{
    self = [super initWithMultiValue:multiValue index:index];
    if(self)
    {
        _address = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(multiValue, index);
    }
    return self;
}

- (instancetype)initWithLabledValue:(CNLabeledValue *)labledValue
{
    self = [super initWithLabledValue:labledValue];
    if(self)
    {
        _address = labledValue.value;
    }
    return self;
}

#pragma mark - NSSecureCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        _address = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(address))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_address forKey:NSStringFromSelector(@selector(address))];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    CKEmail *copy = [super copyWithZone:zone];
    if (copy)
    {
        copy->_address = [self.address copyWithZone:zone];
    }
    return copy;
}

#pragma mark - Equality

- (BOOL)isEqualToAddress:(CKEmail *)email
{
    return ([email.address isEqualToString:self.address] && [email.originalLabel isEqualToString:self.originalLabel]);
}

- (BOOL)isEqual:(id)object
{
    if (self == object)
    {
        return YES;
    }
    
    if (! [object isKindOfClass:[CKEmail class]])
    {
        return NO;
    }
    
    return [self isEqualToAddress:object];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ (%@)", self.address, self.originalLabel];
}

@end
