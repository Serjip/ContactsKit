#Change Log

## 2.0.1 / 2016-05-24
* Bugfix access check

## 2.0.0 / 2016-05-24
* Added a couple of comments
* Rename methods for fetching contacts
* Added name suffix and namePrefix

## 1.2.1 / 2016-03-13
* Added CKDate class
* Minore fixex
* Property `fieldMask` now is public

## 1.2.0 / 2016-02-21
* Added new a delegate method for observe of the diff changed contacts
* Added suppors of nscoder for CKAddressBook

## 1.1.0 / 2016-02-11
* Added nickname, department properties
* Fixed merging issue thumbnailData
* Rename property zip -> ZIP
* Added mutable classes
* Added CKMessenger class
* Added methods for getting labels
* Added methods for "Add", "Delete", "Update" a contact

## 1.0.2 / 2016-01-30
* Added getttings contacts with block
* Added method for requesting an access of the address book
* Fixed unifying contacts for `10.8+`
* Added method for getting contact with `identifier`
* Fixed bug when the init method returns nil
* Rename delegate mehods
* Changed mergeMask property to unifyLinkedContacts (BOOL)
* Added changelog :P

## 1.0.1 / 2016-01-26

* Added OSX `10.7+` supports & example
* Changed property of class CKPhone phone->number
* Changed property `CKContact` recordID->Identifier
* Remove property compositeName of `CKContact` 
* Fixed bug with getting emails

## 1.0.0 / 2016-01-19

* First release