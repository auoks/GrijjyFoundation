unit Grijjy.MemoryPool; (* A reusable memory pooling class unit*)

(*
{$I Grijjy.inc} - Includes the Grijjy.inc file
*)

interface

(*
uses
  System.Classes, System.SysUtils, System.SyncObjs, System.Generics.Collections; - Imports necessary classes and units
*)

const
  MAX_BLOCKS_QUEUED = 1024; (* The maximum number of blocks that can be queued in the memory pool *)

type
  TgoMemoryPool = class(TObject)
  private
    FBlockSize: Integer; (* The size of each memory block in the pool *)
    FMaxBlocksQueued: Integer; (* The maximum number of blocks that can be queued in the memory pool *)
    FBlocks: TQueue<Pointer>; (* A queue of available memory blocks *)
    FLock: TCriticalSection; (* A critical section to protect concurrent access to the memory pool *)
    function GetCount: Integer; (* Returns the current number of memory blocks in the pool *)
    function GetSize: Integer; (* Returns the total size of all memory blocks in the pool *)
    procedure Clear; (* Frees all memory blocks in the pool *)
  public
    constructor Create(const ABlockSize: Integer; const AMaxBlocksQueued: Integer = MAX_BLOCKS_QUEUED); (* Creates a new memory pool with the specified block size and maximum queue size *)
    destructor Destroy; override; (* Frees all memory blocks and the critical section when the memory pool is destroyed *)
  public
    function RequestMem: Pointer; overload; (* Requests a memory block from the pool *)
    function RequestMem(const AName: String): Pointer; overload; (* Requests a memory block from the pool with a specified name *)
    procedure ReleaseMem(P: Pointer); overload; (* Releases a memory block back to the pool *)
    procedure ReleaseMem(P: Pointer; const AName: String); overload; (* Releases a memory block back to the pool with a specified name *)
  public
    property BlockSize: Integer read FBlockSize; (* The size of each memory block in the pool *)
    property Count: Integer read GetCount; (* The current number of memory blocks in the pool *)
    property Size: Integer read GetSize; (* The total size of all memory blocks in the pool *)
  end;

implementation

{ TgoMemoryPool }

constructor TgoMemoryPool.Create(const ABlockSize: Integer; const AMaxBlocksQueued: Integer = MAX_BLOCKS_QUEUED);
begin
  FBlockSize := ABlockSize;
  FMaxBlocksQueued := AMaxBlocksQueued;
  FBlocks := TQueue<Pointer>.Create;
  FLock := TCriticalSection.Create;
end;

destructor TgoMemoryPool.Destroy;
begin
  Clear;
  FLock.Enter;
  try
    FBlocks.Free;
  finally
    FLock.Leave;
  end;
  FLock.Free;
  inherited Destroy;
end;

function TgoMemoryPool.RequestMem: Pointer;
begin
  Result := nil;
  FLock.Enter;
  try
    if FBlocks.Count > 0 then
      Result := FBlocks.Dequeue;
  finally
    FLock.Leave;
  end;
  if Result = nil then
  begin
    GetMem(Result, FBlockSize);
    if Result <> nil then
      FillChar(Result^, FBlockSize, 0);
  end;
end;

function TgoMemoryPool.RequestMem(const AName: String): Pointer;
begin
  Result := nil;
  FLock.Enter;
  try
    if FBlocks.Count > 0 then
      Result := FBlocks.Dequeue;
  finally
    FLock.Leave;
  end;
  if Result = nil then
  begin
    GetMem(Result, FBlockSize);
    if Result <> nil then
      FillChar(Result^, FBlockSize, 0);
  end;
end;

procedure TgoMemoryPool.ReleaseMem(P: Pointer);
begin
  if P <> nil then
  begin
    FLock.Enter;
    try
      if FBlocks.Count < FMaxBlocksQueued then
      begin
        FBlocks.Enqueue(P);
        Exit;
      end;
    finally
      FLock.Leave;
    end;
    FreeMem(P);
  end;
end;

procedure TgoMemoryPool.ReleaseMem(P: Pointer; const AName: String);
begin
  if P <> nil then
  begin
    FLock.Enter;
    try
      if FBlocks.Count < FMaxBlocksQueued then
      begin
        FBlocks.Enqueue(P);
        Exit;
      end;
    finally
      FLock.Leave;
    end;
    FreeMem(P);
  end;
end;

procedure TgoMemoryPool.Clear;
begin
  FLock.Enter;
  try
    while FBlocks.Count > 0 do
      FreeMem(FBlocks.Dequeue);
  finally
    FLock.Leave;
  end;
end;

function TgoMemoryPool.GetCount: Integer;
begin
  Result := FBlocks.Count;
end;

function TgoMemoryPool.GetSize: Integer;
begin
  Result := FBlocks.Count * FBlockSize;
end;

end.
