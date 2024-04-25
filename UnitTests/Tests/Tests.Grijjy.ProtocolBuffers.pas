unit Tests.Grijjy.ProtocolBuffers;

{$INCLUDE 'Grijjy.inc'}

interface

uses
  System.Types,   // Contains basic data types such as Integer, Boolean, etc.
  System.Classes, // Contains classes like TObject, TStrings, etc.
  System.SysUtils, // Contains various utility functions like formatting, etc.
  DUnitX.TestFramework, // Unit for DUnitX testing framework
  Grijjy.ProtocolBuffers; // Unit for the Protocol Buffers library

type
  TPhoneType = (Mobile, Home, Work); // Enum for phone types

  TPhoneNumber = record // Record for phone number
  public
    [Serialize(1)] // Attribute to specify the field number for serialization
    Number: String; // Phone number

    [Serialize(2)]
    PhoneType: TPhoneType; // Phone type
  public
    procedure Initialize; // Initialization method
  end;

  TGroup = (Family, Friends, Work); // Enum for groups
  TGroups = set of TGroup; // Type for a set of groups

  TPerson = record // Record for person
  public
    [Serialize(1)]
    Name: String; // Person's name

    [Serialize(2)]
    Id: UInt32; // Person's ID

    [Serialize(3)]
    Email: String; // Person's email

    [Serialize(4)]
    Phone: TArray<TPhoneNumber>; // Array of phone numbers
  end;

  TPersonEx = record // Record for person with additional fields
    [Serialize(1)]
    Person: TPerson; // Inner person record

    [Serialize(2)]
    Groups: TGroups; // Groups the person belongs to
  end;

  TAllTypes = record // Record for testing all data types
  public
    type
      TNestedMessage = record
      public
        [Serialize(1)]
        BB: Int32; // Nested message field
      end;
    type
      TNestedEnum = (Foo, Bar, Baz); // Nested enum
  public
    [Serialize( 1)]
    MyUInt8: UInt8; // Unsigned 8-bit integer

    [Serialize( 2)]
    MyUInt16: UInt16; // Unsigned 16-bit integer

    [Serialize( 3)]
    MyUInt32: UInt32; // Unsigned 32-bit integer

    [Serialize( 4)]
    MyUInt64: UInt6
