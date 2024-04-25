unit Grijjy.TimerQueue.Win;
{ Windows based timer queue }

{$I Grijjy.inc}

interface

uses
  System.Classes, // for TObject and constructor/destructor syntax
  System.SysUtils, // for cardinal type and SysUtils functions
  System.SyncObjs, // for TCriticalSection
  System.DateUtils, // for DateUtils functions
  System.Generics.Collections, // for TDictionary
  Winapi.Windows; // for Windows API functions

type
  TgoTimer = class;
  TOnTimer = procedure(const ASender: TObject) of object; // event type for timer

  { Timer object }
  TgoTimer = class(TObject)
  private
    FHandle: THandle; // handle of the timer object
    FInterval: Cardinal; // timer interval in milliseconds
    FOnTimer: TOnTimer; // timer callback event
  public
    constructor Create; // constructor
    destructor Destroy; override; // destructor
  public
    { Handle of the timer object }
    property Handle: THandle read FHandle;

    { Timer interval in milliseconds }
    property Interval: Cardinal read FInterval;

    { Timer callback event  }
    property OnTimer: TOnTimer read FOnTimer write FOnTimer;
  end;

  { Timer queue instance }
  TgoTimerQueue = class(TObject)
  private
    FHandle: THandle; // handle of the timer queue
  private
    procedure _Release(const ATimer: TgoTimer); // procedure to release a timer
    procedure ReleaseAll; // procedure to release all timers
  public
    constructor Create; // constructor
    destructor Destroy; override; // destructor
  public
    { Adds a new timer to the queue}
    function Add(const AInterval: Cardinal; const AOnTimer: TOnTimer): THandle; // function to add a new timer

    { Release an existing timer }
    procedure Release(const AHandle: THandle); // procedure to release an existing timer

    { Change the internal rate of a timer }
    function SetInterval(const AHandle: THandle; const AInterval: Cardinal): Boolean; // function to change the interval of a timer
  end;

implementation

var
  _Timers: TDictionary<THandle, TgoTimer>; // dictionary to store all timers
  _TimersLock: TCriticalSection; // critical section to protect the dictionary

{ TgoTimer }

constructor TgoTimer.Create;
begin
  inherited;
  FHandle := INVALID_HANDLE_VALUE;
  FInterval := 0;
  FOnTimer := nil;
end;

destructor TgoTimer.Destroy;
begin
  inherited;
end;

{ TgoTimerQueue }

constructor TgoTimerQueue.Create;
begin
  FHandle := CreateTimerQueue;
end;

destructor TgoTimerQueue.Destroy;
begin
  ReleaseAll;
  DeleteTimerQueueEx(FHandle, INVALID_HANDLE_VALUE);
  FHandle := INVALID_HANDLE_VALUE;
end;

procedure WaitOrTimerCallback(Timer: TgoTimer; TimerOrWaitFired: ByteBool); stdcall;
begin
  if Timer <> nil then
  begin
    _TimersLock.Enter;
    try
      if not _Timers.ContainsKey(Timer.Handle) then
        Exit;
    finally
      _TimersLock.Leave;
    end;
    if TimerOrWaitFired then
      if Assigned(Timer.OnTimer) then
        Timer.OnTimer(Timer);
  end;
end;

function TgoTimerQueue.Add(const AInterval: Cardinal; const AOnTimer: TOnTimer): THandle;
var
  Timer: TgoTimer;
begin
  Result := 0;

  { create a timer object }
  Timer := TgoTimer.Create;
  Timer.FInterval := AInterval;
  Timer.FOnTimer := AOnTimer;
  if CreateTimerQueueTimer(Timer.FHandle, FHandle, @WaitOrTimerCallback, Timer, 0, AInterval, 0) then
  begin
    _TimersLock.Enter;
    try
      _Timers.Add(Timer.Handle, Timer);
      Result := Timer.Handle;
    finally
      _TimersLock.Leave;
    end;
  end
  else
    FreeAndNil(Timer);
end;

procedure TgoTimerQueue._Release(const ATimer: TgoTimer);
begin
  ATimer.OnTimer := nil;

  { the DeleteTimerQueueTimer API will block until all the callbacks are completed }
  if DeleteTimerQueueTimer(FHandle, ATimer.Handle, INVALID_HANDLE_VALUE) then
    ATimer.Free;
end;

procedure TgoTimerQueue.Release(const AHandle: THandle);
var
  Timer: TgoTimer;
begin
  Timer := nil;
  _TimersLock.Enter;
  try
    if _Timers.TryGetValue(AHandle, Timer) then
      _Timers.Remove(AHandle);
  finally
    _TimersLock.Leave;
  end;
  if Timer <> nil then
    _Release(Timer);
end;

procedure TgoTimerQueue.ReleaseAll;
var
  Timer: TgoTimer;
begin
  _TimersLock.Enter;
  try
    for Timer in _Timers.Values do
      _Release(Timer);
    _Timers.Clear;
  finally
    _TimersLock.Leave;
  end;
end;

function TgoTimerQueue.SetInterval(const AHandle: THandle; const AInterval: Cardinal): Boolean;
var
  Timer: TgoTimer;
begin
  Result := False;
  _TimersLock.Enter;
  try
    if _Timers.TryGetValue(AHandle, Timer) then
      if ChangeTimerQueueTimer(FHandle, Timer.Handle, 0, AInterval) then
      begin
        Timer.FInterval := AInterval;
        Result := True;
      end;
  finally
    _TimersLock.Leave;
  end;
end;

initialization
  _Timers := TDictionary<THandle, TgoTimer>.Create;
  _TimersLock := TCriticalSection.Create;

finalization
  _TimersLock.Enter;
  try
    _Timers.Free;
  finally
    _TimersLock.Leave;
  end;
  _TimersLock.Free;

end.
