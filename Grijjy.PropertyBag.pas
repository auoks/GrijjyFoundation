unit Grijjy.PropertyBag;

interface

uses
  System.SysUtils; (* for string manipulation and other utility functions *)

type
  TgoPropertyBagChangedEvent = procedure(const ASender: TgoPropertyBag;
    const APropertyName: String) of object; (* event type for property change notifications *)

  TgoPropertyBag = class
  {$REGION 'Internal Declarations'}
  private const
    EMPTY_HASH = -1; (* a constant for an empty hash value *)
  private type
    TValueKind = (
      vkBoolean, vkInteger, vkCardinal, vkSingle, vkPointer,
      vkInt64, vkUInt64, vkDouble,
      vkObject, vkString, vkInterface, vkDynArray, vkRecord);
    TItem = record
      Hash: Integer; (* hash value for fast lookup *)
      Name: Pointer; (* a pointer to the property name string *)
      {$IFDEF DEBUG}
      TypeInfo: Pointer; (* type information for debugging purposes *)
      {$ENDIF}
      case Kind: TValueKind of
        vkBoolean  : (AsBoolean: Boolean);
        vkInteger  : (AsInteger: Integer);
        vkCardinal : (AsCardinal: Cardinal);
        vkSingle   : (AsSingle: Single);
        vkPointer  : (AsPointer: Pointer);
        vkString   : (AsString: Pointer);
        vkObject   : (AsObject: Pointer);
        vkInterface: (AsInterface: Pointer);
        vkDynArray : (AsDynArray: Pointer);
        vkRecord   : (AsRecord: Pointer);
        vkInt64    : (AsInt6
