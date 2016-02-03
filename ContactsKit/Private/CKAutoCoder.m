//
//  CKAutoCoder.m
//  ContactsKit
//
//  Created by Sergey Popov on 03.02.16.
//
//

#import "CKAutoCoder.h"
#import <objc/runtime.h>

@implementation NSObject (AutoCoder)

- (void)enumerateIvarsUsingBlock:(void (^)(NSString *name, const char *type, void *address))block
{
    unsigned int count;
    Ivar *ivars = class_copyIvarList([self class], &count);
    
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

@end

@implementation NSCoder (AutoCoder)

- (void)encodeIvars:(id)object ignoreIvars:(const void *)firstIvar, ...
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
    
    [object enumerateIvarsUsingBlock:^(NSString *name, const char *type, void *address) {
        
        NSLog(@"%@", name);
        
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

- (void)decodeIvars:(id)object ignoreIvars:(const void *)firstIvar, ...
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
    
    [object enumerateIvarsUsingBlock:^(NSString *name, const char *type, void *address) {
        
        NSLog(@"%@", name);
        
        if ([list containsObject:[NSValue valueWithPointer:address]])
        {
            return;
        }
        
        switch (type[0])
        {
            case '@':
            {
                Ivar ivar = class_getInstanceVariable([object class], name.UTF8String);
                object_setIvar(object, ivar, [self decodeObjectForKey:name]);
                break;
            }
            case '#':
            {
                Ivar ivar = class_getInstanceVariable([object class], name.UTF8String);
                NSString *className = [self decodeObjectForKey:name];
                if (className)
                {
                    object_setIvar(object, ivar, NSClassFromString(className));
                }
                break;
            }
            case ':':
            {
                NSString *selName = [self decodeObjectForKey:name];
                if (selName)
                {
                    *(SEL *)address = NSSelectorFromString(selName);
                }
                break;
            }
                
            case 'c':
                *(BOOL *)address = [[self decodeObjectForKey:name] boolValue];
                break;
                
            case 'C':
                *(unsigned char *)address = [[self decodeObjectForKey:name] unsignedCharValue];
                break;
                
            case 'i':
                *(int *)address = [[self decodeObjectForKey:name] intValue];
                break;
                
            case 'I':
                *(unsigned int *)address = [[self decodeObjectForKey:name] unsignedIntValue];
                break;
                
            case 's':
                *(short *)address = [[self decodeObjectForKey:name] shortValue];
                break;
                
            case 'S':
                *(unsigned short *)address = [[self decodeObjectForKey:name] unsignedShortValue];
                break;
                
            case 'l':
                *(long *)address = [[self decodeObjectForKey:name] longValue];
                break;
                
            case 'L':
                *(unsigned long *)address = [[self decodeObjectForKey:name] unsignedLongValue];
                break;
                
            case 'q':
                *(long long *)address = [[self decodeObjectForKey:name] longLongValue];
                break;
                
            case 'Q':
                *(unsigned long long *)address = [[self decodeObjectForKey:name] unsignedLongLongValue];
                break;
                
            case 'f':
                *(float *)address = [[self decodeObjectForKey:name] floatValue];
                break;
                
            case 'd':
                *(double *)address = [[self decodeObjectForKey:name] doubleValue];
                break;
                
            case 'B':
                *(bool *)address = [[self decodeObjectForKey:name] boolValue];
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
            }
                break;
        }
    }];
}

@end
