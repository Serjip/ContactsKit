//
//  CKLabel.m
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

#import "CKLabel_Private.h"
#import "CKMacros.h"

NSString * const CKLabelHome = @"_$!<Home>!$_";
NSString * const CKLabelWork = @"_$!<Work>!$_";
NSString * const CKLabelOther = @"_$!<Other>!$_";

@implementation CKLabel

#pragma mark - Properties

- (NSString *)localizedLabel
{
    return [CKLabel localizedStringForLabel:self.originalLabel];
}

#pragma mark - Lifecycle

- (instancetype)initWithMultiValue:(ABMultiValueRef)multiValue index:(CFIndex)index
{
    self = [super init];
    if(self)
    {        
        _originalLabel = (__bridge_transfer NSString *)ABMultiValueCopyLabelAtIndex(multiValue, index);
    }
    return self;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    CKLabel *copy = [[[self class] allocWithZone:zone] init];
    if (copy)
    {
        copy->_originalLabel = [self.originalLabel copyWithZone:zone];
    }
    return copy;
}

#pragma mark - NSSecureCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        _originalLabel = [aDecoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(originalLabel))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_originalLabel forKey:NSStringFromSelector(@selector(originalLabel))];
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

#pragma mark - Equal

- (BOOL)isEqualToLabel:(CKLabel *)label
{
    if (! label)
    {
        return NO;
    }
    
    return CK_IS_EQUAL(self.originalLabel, label.originalLabel);
}

- (BOOL)isEqual:(id)object
{
    if (self == object)
    {
        return YES;
    }
    
    if (! [object isKindOfClass:[CKLabel class]])
    {
        return NO;
    }
    
    return [self isEqualToLabel:object];
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"%p %@", self, self.originalLabel];
}

#pragma mark - Class Methods

+ (NSString *)localizedStringForLabel:(NSString *)label
{
#if TARGET_OS_IOS
    return (__bridge_transfer NSString *)ABAddressBookCopyLocalizedLabel((__bridge CFStringRef)(label));
#elif TARGET_OS_MAC
    return (__bridge_transfer NSString *)ABCopyLocalizedPropertyOrLabel((__bridge CFStringRef)(label));
#endif
}

+ (NSArray *)labels
{
    return [[NSArray alloc] initWithObjects:CKLabelHome, CKLabelWork, CKLabelOther, nil];
}

+ (NSArray *)localizedLabels
{
    NSMutableArray *localizedLabels = [[NSMutableArray alloc] init];
    for (NSString *label in [self labels])
    {
        NSString *localizedLabel = [self localizedStringForLabel:label];
        [localizedLabels addObject:localizedLabel];
    }
    return localizedLabels;
}

#pragma mark - Instance

- (BOOL)setLabledValue:(ABMutableMultiValueRef)mutableMultiValue
{
    return NO;
}

@end
