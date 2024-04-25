unit Tests.Grijjy.PropertyBag;

interface

uses
  DUnitX.TestFramework, // DUnitX test framework unit
  Grijjy.PropertyBag;   // PropertyBag unit under test

type
  TTestTgoPropertyBag = class(TObject) // Test class for PropertyBag
  private
    FCUT: TgoPropertyBag; // Container for PropertyBag instance
    FChangedProp: String;
    FChangedCount: Integer;
    // Event handler for PropertyBag.OnChanged event
    procedure HandleChanged(const ASender: TgoPropertyBag; const APropertyName: String);
  public
    // Setup and teardown methods for test fixtures
    [Setup] procedure SetUp;
    [Teardown] procedure TearDown;

    // Test methods for PropertyBag functionality
    [Test] procedure TestAsBoolean;
    [Test] procedure TestAsInteger;
    [Test] procedure TestAsCardinal;
    [Test] procedure TestAsInt64;
    [Test] procedure TestAsUInt64;
    [Test] procedure TestAsSingle;
    [Test] procedure TestAsDouble;
    [Test] procedure TestAsPointer;
    [Test] procedure TestAsString;
    [Test] procedure TestAsInterface;
    [Test] procedure TestAsObject;
    [Test] procedure TestAsBytes;
    [Test] procedure TestAsArray;
    [Test] procedure TestAsRecord;
    [Test] procedure TestClear;
    [Test] procedure TestRemove;
    [Test] procedure TestCaseSensitive;
    [Test] procedure TestInterfaceInstanceCounts;
    [Test] procedure TestObjectInstanceCounts;
    [Test] procedure TestStringCopyOnWrite;
    [Test] procedure TestTBytesCopyOnWrite;
    [Test] procedure TestMixedTypes;
    [Test] procedure TestOnChanged;
  end;

implementation

uses
  System.Types, // Contains basic data types and conversion functions
  System.SysUtils; // Contains various utility functions

type
  TIntegerArray = TArray<Integer>; // Typedef for integer array

type
  TManagedRecord = record
    S: String;
  end;

type
  TFoo = class // Custom class for testing
  public class var
    InstanceCount: Integer; // Class variable for tracking instances
  private
    FValue: Integer;
  public
    constructor Create(const AValue: Integer);
    destructor Destroy; override;
    property Value: Integer read FValue write FValue;
  end;

type
  IBar = interface // Custom interface for testing
  ['{CC3437FD-CDE2-4A3A-BAFE-266394DF4018}']
    function GetValue: Integer;
    procedure SetValue(const AValue: Integer);
    property Value: Integer read GetValue write SetValue;
  end;

type
  TBar = class(TInterfacedObject, IBar) // Custom interfaced object for testing
  public class var
    InstanceCount: Integer; // Class variable for tracking instances
  private
    FValue: Integer;
  protected
    function GetValue: Integer;
    procedure SetValue(const AValue: Integer);
  public
    constructor Create(const AValue: Integer);
    destructor Destroy; override;
  end;

{ TFoo }

constructor TFoo.Create(const AValue: Integer);
begin
  Inc(InstanceCount); // Increment class variable when creating instance
  inherited Create;
  FValue := AValue;
end;

destructor TFoo.Destroy;
begin
  Dec(InstanceCount); // Decrement class variable when destroying instance
  inherited;
end;

{ TBar }

constructor TBar.Create(const AValue: Integer);
begin
  Inc(InstanceCount); // Increment class variable when creating instance
  inherited Create;
  FValue := AValue;
end;

destructor TBar.Destroy;
begin
  Dec(InstanceCount); // Decrement class variable when destroying instance
  inherited;
end;

function TBar.GetValue: Integer;
begin
  Result := FValue;
end;

procedure TBar.SetValue(const AValue: Integer);
begin
  FValue := AValue;
end;

{ TTestTgoPropertyBag }

procedure TTestTgoPropertyBag.HandleChanged(const ASender: TgoPropertyBag;
  const APropertyName: String);
begin
  Assert.AreEqual(FCUT, ASender); // Verify the sender is the expected PropertyBag
  FChangedProp := APropertyName; // Store the changed property name
  Inc(FChangedCount); // Increment the count of changes
end;

procedure TTestTgoPropertyBag.SetUp;
begin
  ReportMemoryLeaksOnShutdown := True; // Enable memory leak detection
  FCUT := TgoPropertyBag.Create; // Create a new PropertyBag instance
end;

procedure TTestTgoPropertyBag.TearDown;
begin
  FCUT.Free; // Free the PropertyBag instance
end;

// ... (Test methods follow)

initialization
  TDUnitX.RegisterTestFixture(TTestTgoPropertyBag); // Register the test fixture

end.
