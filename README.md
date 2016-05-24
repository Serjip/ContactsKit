<p align="center" >
  <img src="https://raw.githubusercontent.com/Serjip/ContactsKit/dev/image.png" alt="ContactsKit" title="ContactsKit" width=300>
</p>

ContactsKit is a library for easy contact management supports iOS and Mac OS X.

## Features
* Unifying linked contacts
* Support Mac OS X
* Contact management add, update, delete
* Support NSCoding
* Observing changes (adding, updating, deleting) for iOS

## Installation with CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party libraries like ContactsKit in your projects. See more on [cocoapods.org](http://cocoapods.org). You can install it with the following command:

```bash
$ gem install cocoapods
```

#### Podfile

To integrate ContactsKit into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '7.0'

pod 'ContactsKit'
```

Then, run the following command:

```bash
$ pod install
```
## Get started

Import ContactsKit into your porject


```objectivec
	
	#import <ContactsKit/ContactsKit.h>
	
```

Firstly you have to create an instance of the CKAddressBook, and request an access for getting contacts.
The user will only be prompted the first time access is requested.

```objectivec
	
	CKAddressBook *addressBook = [[CKAddressBook alloc] init];
    
    [addressBook requestAccessWithCompletion:^(NSError *error) {
        
        if (! error)
        {
			// Everything fine you can get contacts
        }
        else
        {
			// The app doesn't have a permission for getting contacts
			// You have to go to the settings and turn on contacts
        }
    }];

```

Then if the access is granted you can get contacts

```objectivec

	// Get fields from the mask
    CKContactField mask = CKContactFieldFirstName | CKContactFieldLastName | CKContactFieldBirthday;
    
    // Final sort of the contacts array
    NSArray *sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES] ];
    
    [addressBook contactsWithMask:mask uinify:NO sortDescriptors:sortDescriptors
                           filter:nil completion:^(NSArray *contacts, NSError *error) {
       
        if (! error)
        {
            // Do someting with contacts
        }
        
    }];

```

Or do the same by using the `CKAddressBookDelegate` protocol
 
```objectivec
	
	addressBook.fieldsMask = CKContactFieldFirstName | CKContactFieldLastName | CKContactFieldBirthday;
    addressBook.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES] ];
    addressBook.delegate = self;
    
    [addressBook fetchContacts];

```

Then the protocol method will called

```objectivec

	#pragma mark - CKAddressBookDelegate

	- (void)addressBook:(CKAddressBook *)addressBook didFetchContacts:(NSArray<CKContact *> *)contacts
	{
    	// Do something with contacts
	}

```
