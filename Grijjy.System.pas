unit Grijjy.System;

{$INCLUDE 'Grijjy.inc'}

interface

type
  {
    Abstract base class for classes that can implement interfaces, but are not
    reference counted (unless on ARC systems of course). If you want your class
    to be reference counted, derive from TInterfacedObject instead.
  }
  TgoNonRefCountedObject = class abstract(TObject)
  {$REGION 'Internal Declarations'}
  protected
    { IInterface }
    // QueryInterface method is used to check if the implementing object supports
    // the provided interface identifier (IID). If it does, the method returns a
    // pointer to the interface; otherwise, it returns E_NOINTERFACE.
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    // _AddRef method increments the reference count for the interface.
    function _AddRef: Integer; stdcall;
    // _Release method decrements the reference count for the interface.
    function _Release: Integer; stdcall;
  {$ENDREGION 'Internal Declarations'}
  end;

implementation

{ TgoNonRefCountedObject }

{
  QueryInterface method is overridden in this abstract class to provide a default
  implementation for classes derived from TgoNonRefCountedObject.
}
function TgoNonRefCountedObject.QueryInterface(const IID: TGUID;
  out Obj): HResult;
begin
  if GetInterface(IID, Obj) then
    Result := S_OK // Indicates that the interface is supported.
  else
    Result := E_NOINTERFACE; // Indicates that the interface is not supported.
end;

{
  _AddRef method is overridden in this abstract class to provide a default
  implementation for classes derived from TgoNonRefCountedObject.
  This implementation returns -1, which is not a valid reference count.
}
function TgoNonRefCountedObject._AddRef: Integer;
begin
  Result := -1;
end;

{
  _Release method is overridden in this abstract class to provide a default
  implementation for classes derived from TgoNonRefCountedObject.
  This implementation returns -1, which is not a valid reference count.
}
function TgoNonRefCountedObject._Release: Integer;
begin
  Result := -1;
end;

end.
