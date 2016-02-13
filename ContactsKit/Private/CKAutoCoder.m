//
//  CKAutoCoder.m
//  ContactsKit
//
//  Created by Sergey Popov on 02/03/16.
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

#import "CKAutoCoder.h"
#import <objc/runtime.h>

@implementation NSObject (AutoCoder)

- (void)enumerateIvarsOfClass:(Class)aClass usingBlock:(void (^)(NSString *name, const char *type, void *address))block
{
    if ([self isKindOfClass:aClass])
    {
        unsigned int count;
        Ivar *ivars = class_copyIvarList(aClass, &count);
        
        for (unsigned int i = 0; i < count; i++)
        {
            Ivar ivar = ivars[i];
            const char *name = ivar_getName(ivar);
            const char *type = ivar_getTypeEncoding(ivar);
            ptrdiff_t offset = ivar_getOffset(ivar);
            void *p = (UInt8 *)(__bridge void *)self + offset;
            
            block(@(name), type, p);
        }
        free(ivars);
    }
    else
    {
        NSString *reason = [NSString stringWithFormat:@"Cannot enumerate Ivars. The object is not kind of class %@.", NSStringFromClass(aClass)];
        [[NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil] raise];
    }
}

@end

@implementation NSCoder (AutoCoder)

- (void)encodeIvarsWithObject:(id)anObject ofClass:(Class)aClass ignoreIvars:(const void *)firstIvar, ...
{
    NSMutableArray *list = [[NSMutableArray alloc] init];
    if (firstIvar)
    {
        [list addObject:[NSValue valueWithPointer:firstIvar]];
        
        va_list argumentList;
        va_start(argumentList, firstIvar);
        void *next = NULL;
        while ((next = va_arg(argumentList, void *)) != NULL)
        {
            [list addObject:[NSValue valueWithPointer:next]];
        }
        va_end(argumentList);
    }
    
    [anObject enumerateIvarsOfClass:aClass usingBlock:^(NSString *name, const char *type, void *address) {
        
        if ([list containsObject:[NSValue valueWithPointer:address]])
        {
            return;
        }
        
        switch (type[0])
        {
            case '@':
                [self encodeObject:*(__unsafe_unretained id *)address forKey:name];
                break;
                
            case '#':
                [self encodeObject:NSStringFromClass(*(Class *)address) forKey:name];
                break;
                
            case ':':
                [self encodeObject:NSStringFromSelector(*(SEL *)address) forKey:name];
                break;
                
            case 'c':
                [self encodeObject:@(*(BOOL *)address) forKey:name];
                break;
                
            case 'C':
                [self encodeObject:@(*(unsigned char *)address) forKey:name];
                break;
                
            case 'i':
                [self encodeObject:@(*(int *)address) forKey:name];
                break;
                
            case 'I':
                [self encodeObject:@(*(unsigned int *)address) forKey:name];
                break;
                
            case 's':
                [self encodeObject:@(*(short *)address) forKey:name];
                break;
                
            case 'S':
                [self encodeObject:@(*(unsigned short *)address) forKey:name];
                break;
                
            case 'l':
                [self encodeObject:@(*(long *)address) forKey:name];
                break;
                
            case 'L':
                [self encodeObject:@(*(unsigned long *)address) forKey:name];
                break;
                
            case 'q':
                [self encodeObject:@(*(long long *)address) forKey:name];
                break;
                
            case 'Q':
                [self encodeObject:@(*(unsigned long long *)address) forKey:name];
                break;
                
            case 'f':
                [self encodeObject:@(*(float *)address) forKey:name];
                break;
                
            case 'd':
                [self encodeObject:@(*(double *)address) forKey:name];
                break;
                
            case 'B':
                [self encodeObject:@(*(bool *)address) forKey:name];
                break;
                
            case '*':
                if (*(char **)address != NULL)
                {
                    [self encodeBytes:(const uint8_t *)*(char **)address length:strlen(*(char **)address) forKey:name];
                }
                break;
                
            default:
            {
                NSString *reason = [NSString stringWithFormat:@"Cannot encode Ivar %@. Unsupported type %s.", name, type];
                [[NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil] raise];
            }
                break;
        }
        
    }];
}

- (void)decodeIvarsWithObject:(id)anObject ofClass:(Class)aClass ignoreIvars:(const void *)firstIvar, ...
{
    NSMutableArray *list = [[NSMutableArray alloc] init];
    if (firstIvar)
    {
        [list addObject:[NSValue valueWithPointer:firstIvar]];
        
        va_list argumentList;
        va_start(argumentList, firstIvar);
        void *next = NULL;
        while ((next = va_arg(argumentList, void *)) != NULL)
        {
            [list addObject:[NSValue valueWithPointer:next]];
        }
        va_end(argumentList);
    }
    
    [anObject enumerateIvarsOfClass:aClass usingBlock:^(NSString *name, const char *type, void *address) {
        
        if ([list containsObject:[NSValue valueWithPointer:address]])
        {
            return;
        }
        
        switch (type[0])
        {
            case '@':
            {
                Ivar ivar = class_getInstanceVariable([anObject class], name.UTF8String);
                NSString *className = @(strndup(type + 2, strlen(type) - 3));
                Class class = NSClassFromString(className);
                if (class != Nil)
                {
                    object_setIvar(anObject, ivar, [self decodeObjectOfClass:class forKey:name]);
                }
                break;
            }
            case '#':
            {
                Ivar ivar = class_getInstanceVariable([anObject class], name.UTF8String);
                NSString *className = [self decodeObjectOfClass:[NSString class] forKey:name];
                if (className)
                {
                    object_setIvar(anObject, ivar, NSClassFromString(className));
                }
                break;
            }
            case ':':
            {
                NSString *selector = [self decodeObjectOfClass:[NSString class] forKey:name];
                if (selector)
                {
                    *(SEL *)address = NSSelectorFromString(selector);
                }
                break;
            }
                
            case 'c':
                *(BOOL *)address = [[self decodeObjectOfClass:[NSNumber class] forKey:name] boolValue];
                break;
                
            case 'C':
                *(unsigned char *)address = [[self decodeObjectOfClass:[NSNumber class] forKey:name] unsignedCharValue];
                break;
                
            case 'i':
                *(int *)address = [[self decodeObjectOfClass:[NSNumber class] forKey:name] intValue];
                break;
                
            case 'I':
                *(unsigned int *)address = [[self decodeObjectOfClass:[NSNumber class] forKey:name] unsignedIntValue];
                break;
                
            case 's':
                *(short *)address = [[self decodeObjectOfClass:[NSNumber class] forKey:name] shortValue];
                break;
                
            case 'S':
                *(unsigned short *)address = [[self decodeObjectOfClass:[NSNumber class] forKey:name] unsignedShortValue];
                break;
                
            case 'l':
                *(long *)address = [[self decodeObjectOfClass:[NSNumber class] forKey:name] longValue];
                break;
                
            case 'L':
                *(unsigned long *)address = [[self decodeObjectOfClass:[NSNumber class] forKey:name] unsignedLongValue];
                break;
                
            case 'q':
                *(long long *)address = [[self decodeObjectOfClass:[NSNumber class] forKey:name] longLongValue];
                break;
                
            case 'Q':
                *(unsigned long long *)address = [[self decodeObjectOfClass:[NSNumber class] forKey:name] unsignedLongLongValue];
                break;
                
            case 'f':
                *(float *)address = [[self decodeObjectOfClass:[NSNumber class] forKey:name] floatValue];
                break;
                
            case 'd':
                *(double *)address = [[self decodeObjectOfClass:[NSNumber class] forKey:name] doubleValue];
                break;
                
            case 'B':
                *(bool *)address = [[self decodeObjectOfClass:[NSNumber class] forKey:name] boolValue];
                break;
                
            case '*':
            {
                NSUInteger len = 0;
                const uint8_t *bytes = [self decodeBytesForKey:name returnedLength:&len];
                if (len > 0)
                {
                    *(char **)address = malloc(len + 1);
                    memcpy(*(char **)address, bytes, len);
                    (*(char **)address)[len] = '\0';
                }
                break;
            }
            default:
            {
                NSString *reason = [NSString stringWithFormat:@"Cannot decode Ivar %@. Unsupported type %s.", name, type];
                [[NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil] raise];
                break;
            }
        }
    }];
}

@end
