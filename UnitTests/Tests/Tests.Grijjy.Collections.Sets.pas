unit Tests.Grijjy.Collections.Sets;

interface

uses
  DUnitX.TestFramework, // Implements the testing framework for automated unit testing
  Tests.Grijjy.Collections.Base, // Base test class for collections
  Grijjy.Collections; // The collections library being tested

type
  TTestTgoSet<T> = class(TTestCollectionBase<T>) // Test class for the TgoSet collection
  private
    FCUT: TgoSet<T>; // The collection under test
    FValues: TArray<T>; // Array of values used for testing
    procedure FillSet; // Procedure to fill the set with test values
    procedure CheckItems(const AExpected: TArray<T>); // Procedure to check if the set contains the expected items
  public
    [Setup] // DUnitX attribute to execute before each test method
    procedure SetUp;

    [Teardown] // DUnitX attribute to execute after each test method
    procedure TearDown;

    // Test methods for various operations on the set
    [Test]
    procedure TestAdd;
    [Test]
    procedure TestRemove;
    [Test]
    procedure TestClear;
    [Test]
    procedure TestAddOrSet;
    [Test]
    procedure TestContains;
    [Test]
    procedure TestToArray;
    [Test]
    procedure TestGetEnumerator;
  end;

  TTestTgoObjectSet = class(TTestCollectionBase<TFoo>) // Test class for the TgoObjectSet collection
  private
    FCUT: TgoObjectSet<TFoo>; // The collection under test
    FValues: TArray<TFoo>; // Array of objects used for testing
    procedure FillSet; // Procedure to fill the set with test objects
    procedure CheckItems(const AExpectedIndices: array of Integer); // Procedure to check if the set contains the expected objects
  public
    [Setup] // DUnitX attribute to execute before each test method
    procedure SetUp;

    [Teardown] // DUnitX attribute to execute after each test method
    procedure TearDown;

    // Test methods for various operations on the set
    [Test]
    procedure TestAdd;
    [Test]
    procedure TestRemove;
    [Test]
    procedure TestClear;
    [Test]
    procedure TestAddOrSet;
    [Test]
    procedure TestContains;
    [Test]
    procedure TestToArray;
    [Test]
    procedure TestGetEnumerator;

    // Additional test method for the TgoObjectSet collection
    [Test]
    procedure TestExtract;
  end;

implementation

uses
  System.SysUtils, // Provides various utility functions
  System.Generics.Defaults; // Provides default implementations of generic interfaces

{ TTestTgoSet<T> }

procedure TTestTgoSet<T>.CheckItems(const AExpected: TArray<T>);
var
  Value: T;
  I: Integer;
begin
  Assert.AreEqual(Length(AExpected), FCUT.Count); // Check if the set count matches the expected count

  for I := 0 to Length(AExpected) - 1 do
  begin
    Value := AExpected[I]; // Get the expected item
    Assert.IsTrue(FCUT.Contains(Value)); // Check if the set contains the expected item
  end;
end;

procedure TTestTgoSet<T>.FillSet;
begin
  FValues := CreateValues(3); // Create an array of 3 test values
  FCUT.Add(FValues[0]); // Add the first value to the set
  FCUT.Add(FValues[1]); // Add the second value to the set
  FCUT.Add(FValues[2]); // Add the third value to the set
end;

procedure TTestTgoSet<T>.SetUp;
begin
  inherited; // Call the base class SetUp method
  FCUT := TgoSet<T>.Create; // Create a new set for testing
end;

procedure TTestTgoSet<T>.TearDown;
begin
  inherited; // Call the base class TearDown method
  FCUT.Free; // Free the set created for testing
end;

// Test methods for various operations on the set
procedure TTestTgoSet<T>.TestAdd;
begin
  FillSet;
  CheckItems(FValues);
end;

procedure TTestTgoSet<T>.TestAddOrSet;
var
  Values: TArray<T>;
begin
  Values := CreateValues(4); // Create an array of 4 test values
  FCUT.Add(Values[0]); // Add the first value to the set
  FCUT.Add(Values[1]); // Add the second value to the set
  FCUT.Add(Values[2]); // Add the third value to the set
  Assert.AreEqual(3, FCUT.Count); // Check if the set count matches the expected count

  FCUT.AddOrSet(Values[1]); // Add or set the second value to the set
  Assert.AreEqual(3, FCUT.Count); // Check if the set count matches the expected count

  FCUT.AddOrSet(Values[3]); // Add or set the fourth value to the set
  CheckItems(Values); // Check if the set contains the expected items
end;

procedure TTestTgoSet<T>.TestClear;
begin
  FillSet;
  Assert.AreEqual(3, FCUT.Count); // Check if the set count matches the expected count

  FCUT.Clear; // Clear the set
  Assert.AreEqual(0, FCUT.Count); // Check if the set count matches the expected count
end;

procedure TTestTgoSet<T>.TestContains;
var
  RogueValue: T;
begin
  FillSet;
  RogueValue := CreateValue(3); // Create a rogue value for testing
  Assert.IsTrue(FCUT.Contains(FValues[0])); // Check if the set contains the first value
  Assert.IsTrue(FCUT.Contains(FValues[1])); // Check if the set contains the second value
  Assert.IsTrue(FCUT.Contains(FValues[2])); // Check if the set contains the third value
  Assert.IsFalse(FCUT.Contains(RogueValue)); // Check if the set does not contain the rogue value
end;

procedure TTestTgoSet<T>.TestGetEnumerator;
var
  Value: T;
  B: Byte;
  C: IEqualityComparer<T>;
begin
  FillSet;
  C := TEqualityComparer<T>.Default; // Get the default comparer for the type
  B := 0; // Initialize the result variable
  for Value in FCUT do // Iterate over the set
  begin
    if (C.Equals(Value, FValues[0])) then
      B := B or $01 // Set the first bit if the value matches the first test value
    else if (C.Equals(Value, FValues[1])) then
      B := B or $02 // Set the second bit if the value matches the second test value
    else if (C.Equals(Value, FValues[2])) then
      B := B or $04 // Set the third bit if the value matches the third test value
    else
      Assert.Fail('Unexpected item'); // Fail the test if the value does not match any test value
  end;
  Assert.AreEqual($07, Integer(B)); // Check if the result variable matches the expected value
end;

procedure TTestTgoSet<T>.TestRemove;
var
  RogueValue: T;
  V: TArray<T>;
begin
  FillSet;
  RogueValue := CreateValue(3); // Create a rogue value for testing
  Assert.AreEqual(3, FCUT.Count); // Check if the set count matches the expected count

  FCUT.Remove(RogueValue); // Remove the rogue value from the set
  Assert.AreEqual(3, FCUT.Count); // Check if the set count matches the expected count
  CheckItems(FValues); // Check if the set contains the expected items

  FCUT.Remove(FValues[0]); // Remove the first value from the set
  Assert.AreEqual(2, FCUT.Count); // Check if the set count matches the expected count
  SetLength(V, 2); // Initialize the result array
  V[0] := FValues[1]; // Set the first element of the result array
  V[1] := FValues[2]; // Set the second element of the result array
  CheckItems(V); // Check if the set contains the expected items

  FCUT.Remove(FValues[2]); // Remove the third value from the set
  Assert.AreEqual(1, FCUT.Count); // Check if the set count matches the expected count
  SetLength(V, 1); // Initialize the result array
  V[0] := FValues[1]; // Set the first element of the result array
  CheckItems(V); // Check if the set contains the expected items

  FCUT.Remove(FValues[1]); // Remove the second value from the set
  Assert.AreEqual(0, FCUT.Count); // Check if the set count matches the expected count
end;

procedure TTestTgoSet<T>.TestToArray;
var
  A: TArray<T>;
  C: IEqualityComparer<T>;
  I: Integer;
  B: Byte;
begin
  FillSet;
  C := TEqualityComparer<T>.Default; // Get the default comparer for the type
  A := FCUT.ToArray; // Get the array representation of the set
  Assert.AreEqual(3, Length(A)); // Check if the array length matches the expected length
  B := 0; // Initialize the result variable
  for I := 0 to 2 do
  begin
    if C.Equals(A[I], FValues[0]) then
      B := B or $01 // Set the first bit if the array element matches the first test value
    else if C.Equals(A[I], FValues[1]) then
      B := B or $02 // Set the second bit if the array element matches the second test value
    else if C.Equals(A[I], FValues[2]) then
      B := B or $04 // Set the third bit if the array element matches the third test value
    else
      Assert.Fail('Unexpected item'); // Fail the test if the array element does not match any test value
  end;
  Assert.AreEqual($07, Integer(B)); // Check if the result variable matches the expected value
end;

{ TTestTgoObjectSet }

procedure TTestTgoObjectSet.CheckItems(
  const AExpectedIndices: array of Integer);
var
  I: Integer;
  Value: TFoo;
begin
  Assert.AreEqual(Length(AExpectedIndices), FCUT.Count); // Check if the set count matches the expected count

  for I := 0 to Length(AExpectedIndices) - 1 do
  begin
    Value := FValues[AExpectedIndices[I]]; // Get the expected object
    Assert.IsTrue(FCUT.Contains(Value)); // Check if the set contains the expected object
  end;
end;

procedure TTestTgoObjectSet.FillSet;
var
  I: Integer;
begin
  SetLength(FValues, 3); // Initialize the array of objects
  for I := 0 to 2 do
  begin
    FValues[I] := TFoo.Create(I); // Create a new object and add it to the array
    FCUT.Add(FValues[I]); // Add the object to the set
  end;
end;

procedure TTestTgoObjectSet.SetUp;
begin
  inherited; // Call the base class SetUp method
  FCUT := TgoObjectSet<TFoo>.Create; // Create a new set for testing
end;

procedure TTestTgoObjectSet.TearDown;
var
  I: Integer;
begin
  for I := 0 to Length(FValues) - 1 do
    FValues[I] := nil; // Free the objects created for testing
  FCUT.Free; // Free the set created for testing
  FCUT := nil;
  inherited; // Call the base class TearDown method
end;

// Test methods for various operations on the set
procedure TTestTgoObjectSet.TestAdd;
begin
  FillSet;
  CheckItems([0, 1, 2]);
end;

procedure TTestTgoObjectSet.TestAddOrSet;
begin
  FillSet;
  Assert.AreEqual(3, FCUT.Count); // Check if the set count matches the expected count

  FCUT.AddOrSet(FValues[1]); // Add or set the second object to the set
  Assert.AreEqual(3, FCUT.Count); // Check if the set count matches the expected count

  SetLength(FValues, 4); // Initialize the array of objects
  FValues[3] := TFoo.Create(5); // Create a new object and add it to the array
  FCUT.AddOrSet(FValues[3]); // Add or set the fourth object to the set
  CheckItems([0, 1, 2, 3]); // Check if the set contains the expected objects
end;

procedure TTestTgoObjectSet.TestClear;
begin
  FillSet;
  Assert.AreEqual(3, FCUT.Count); // Check if the set count matches the expected count

  FCUT.Clear; // Clear the set
  Assert.AreEqual(0, FCUT.Count); // Check if the set count matches the expected count
end;

procedure TTestTgoObjectSet.TestContains;
var
  RogueValue: TFoo;
begin
  FillSet;
  RogueValue := TFoo.Create(5); // Create a rogue object for testing
  Assert.IsTrue(FCUT.Contains(FValues[0])); // Check if the set contains the first object
  Assert.IsTrue(FCUT.Contains(FValues[1])); // Check if the set contains the second object
  Assert.IsTrue(FCUT.Contains(FValues[2])); // Check if the set contains the third object
  Assert.IsFalse(FCUT.Contains(RogueValue)); // Check if the set does not contain the rogue object
  RogueValue.Free; // Free the rogue object
end;

procedure TTestTgoObjectSet.TestExtract;
var
  Value, RogueValue: TFoo;
begin
  FillSet;
  RogueValue := TFoo.Create(5); // Create a rogue object for testing

  Value := FCUT.Extract(FValues[1]); // Extract the second object from the set
  Assert.IsNotNull(Value); // Check if the extracted object is not null
  Value.Free; // Free the extracted object

  Value := FCUT.Extract(RogueValue); // Extract the rogue object from the set
  Assert.IsNull(Value); // Check if the extracted object is null
  RogueValue.Free; // Free the rogue object
end;

procedure TTestTgoObjectSet.TestGetEnumerator;
var
  Value: TFoo;
  B: Byte;
begin
  FillSet;
  B := 0; // Initialize the result variable
  for Value in FCUT do // Iterate over the set
  begin
    if (Value.Value = 0) then
      B := B or $01 // Set the first bit if the object value matches the first test value
    else if (Value.Value = 1) then
      B := B or $02 // Set the second bit if the object value matches the second test value
    else if (Value.Value = 2) then
      B := B or $04 // Set the third bit if the object value matches the third test value
    else
      Assert.Fail('Unexpected item'); // Fail the test if the object value does not match any test value
  end;
  Assert.AreEqual($07, Integer(B)); // Check if the result variable matches the expected value
end;

procedure TTestTgoObjectSet.TestRemove;
var
  RogueValue: TFoo;
begin
  FillSet;
  RogueValue := TFoo.Create(3); // Create a rogue object for testing
  Assert.AreEqual(3, FCUT.Count); // Check if the set count matches the expected count

  FCUT.Remove(RogueValue); // Remove the rogue object from the set
  Assert.AreEqual(3, FCUT.Count); // Check if the set count matches the expected count
  CheckItems([0, 1, 2]); // Check if the set contains the expected objects
  RogueValue.Free; // Free the rogue object

  FCUT.Remove(FValues[0]); // Remove the first object from the set
  Assert.AreEqual(2, FCUT.Count); // Check if the set count matches the expected count
  CheckItems([1, 2]); // Check if the set contains the expected objects

  FCUT.Remove(FValues[2]); // Remove the third object from the set
  Assert.AreEqual(1, FCUT.Count); // Check if the set count matches the expected count
  CheckItems([1]); // Check if the set contains the expected object

  FCUT.Remove(FValues[1]); // Remove the second object from the set
  Assert.AreEqual(0, FCUT.Count); // Check if the set count matches the expected count
end;

procedure TTestTgoObjectSet.TestToArray;
var
  A: TArray<TFoo>;
  I: Integer;
  B: Byte;
begin
  FillSet;
  A := FCUT.ToArray; // Get the array representation of the set
  Assert.AreEqual(3, Length(A)); // Check if the array length matches the expected length
  B := 0; // Initialize the result variable
  for I := 0 to 2 do
  begin
   
