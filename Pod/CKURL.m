//
//  CKURL.m
//  ContactsKit
//
//  Created by Sergey Popov on 1/18/16.
//  Copyright (c) 2016 ttitt. All rights reserved.
//

#import "CKURL.h"
#import "CKLabel_Private.h"

#import <Contacts/Contacts.h>

@implementation CKURL

#pragma mark - Lifecycle

- (instancetype)initWithMultiValue:(ABMultiValueRef)multiValue index:(CFIndex)index
{
    self = [super initWithMultiValue:multiValue index:index];
    if(self)
    {
        _URLString = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(multiValue, index);
    }
    return self;
}

- (instancetype)initWithLabledValue:(CNLabeledValue *)labledValue
{
    self = [super initWithLabledValue:labledValue];
    if(self)
    {
        _URLString = labledValue.value;
    }
    return self;
}

#pragma mark - NSSecureCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        _URLString = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(URLString))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_URLString forKey:NSStringFromSelector(@selector(URLString))];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    CKURL *copy = [super copyWithZone:zone];
    if (copy)
    {
        copy->_URLString = [self.URLString copyWithZone:zone];
    }
    return copy;
}

#pragma mark - Equality

- (BOOL)isEqualToURL:(CKURL *)URL
{
    return ([URL.URLString isEqualToString:self.URLString] && [URL.originalLabel isEqualToString:self.originalLabel]);
}

- (BOOL)isEqual:(id)object
{
    if (self == object)
    {
        return YES;
    }
    
    if (! [object isKindOfClass:[CKURL class]])
    {
        return NO;
    }
    
    return [self isEqualToURL:object];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ (%@)", self.URLString, self.originalLabel];
}

@end
