unit Tests.Grijjy.Collections.RingBuffer;

interface

uses
  DUnitX.TestFramework; // The unit that contains the test framework

type
  TTestTgoRingBuffer = class // A class to hold the test methods for the RingBuffer
  public
    [Test] // A directive indicating that the following method is a test method
    procedure TestReadWrite; // A test method to test the read and write functionality of the RingBuffer

    [Test] // A directive indicating that the following method is a test method
    procedure TestTryReadWrite; // A test method to test the try read and write functionality of the RingBuffer
  end;

implementation

uses
  Grijjy.Collections; // The unit that contains the RingBuffer class

{ TTestTgoRingBuffer }

procedure TTestTgoRingBuffer.TestReadWrite;
var
  CUT: TgoRingBuffer<Byte>; // CUT stands for "Code Under Test"
  WriteBuffer, ReadBuffer: array [0..99] of Byte; // Buffers to hold the data to be written and read
  I: Integer; // A loop counter
begin
  CUT := TgoRingBuffer<Byte>.Create(100); // Create a new RingBuffer with a capacity of 100 bytes
  try
    Assert.AreEqual(0, CUT.Read(ReadBuffer)); // Assert that reading from an empty RingBuffer returns 0

    for I := 0 to 99 do
      WriteBuffer[I] := i; // Initialize the write buffer with the values 0 to 99
    Assert.AreEqual(100, CUT.Write(WriteBuffer)); // Assert that writing 100 bytes to the RingBuffer returns 100

    Assert.AreEqual(50, CUT.Read(ReadBuffer, 0, 50)); // Assert that reading 50 bytes from the RingBuffer returns the first 50 bytes
    for I := 0 to 49 do
      Assert.AreEqual(I, Integer(ReadBuffer[I])); // Assert that the read bytes have the expected values

    Assert.AreEqual(50, CUT.Write(WriteBuffer)); // Assert that writing 50 bytes to the RingBuffer returns 50

    Assert.AreEqual(100, CUT.Read(ReadBuffer)); // Assert that reading 100 bytes from the RingBuffer returns all the bytes
    for I := 0 to 49 do
      Assert.AreEqual(I + 50, Integer(ReadBuffer[I])); // Assert that the first 50 read bytes have the expected values
    for I := 0 to 49 do
      Assert.AreEqual(I, Integer(ReadBuffer[I + 50])); // Assert that the last 50 read bytes have the expected values
  finally
    CUT.Free; // Free the RingBuffer to release the memory
  end;
end;

procedure TTestTgoRingBuffer.TestTryReadWrite;
var
  CUT: TgoRingBuffer<Integer>; // CUT stands for "Code Under Test"
  WriteBuffer, ReadBuffer: array [0..70] of Integer; // Buffers to hold the data to be written and read
  I, J, Block, BlockCount, ReadValue, WriteValue: Integer; // Loop counters and variables to hold the read and write values
begin
  CUT := TgoRingBuffer<Integer>.Create(1000); // Create a new RingBuffer with a capacity of 1000 integers
  try
    Assert.IsFalse(CUT.TryRead(ReadBuffer)); // Assert that trying to read from an empty RingBuffer returns false

    for I := 0 to 13 do
      Assert.IsTrue(CUT.TryWrite(WriteBuffer)); // Write 14 blocks of 71 integers to the RingBuffer
    Assert.IsFalse(CUT.TryWrite(WriteBuffer)); // Assert that trying to write another block of 71 integers to the RingBuffer returns false

    for I := 0 to 13 do
      Assert.IsTrue(CUT.TryRead(ReadBuffer)); // Read 14 blocks of 71 integers from the RingBuffer
    Assert.IsFalse(CUT.TryRead(ReadBuffer)); // Assert that trying to read another block of 71 integers from the RingBuffer returns false
    Assert.AreEqual(0, CUT.Count); // Assert that the RingBuffer is empty

    ReadValue := 0;
    WriteValue := 0;

    for I := 0 to 999 do
    begin
      BlockCount := Random(5) + 1; // Generate a random number of blocks to write and read
      for Block := 0 to BlockCount - 1 do
      begin
        for J := 0 to 70 do
          WriteBuffer[J] := WriteValue; // Initialize the write buffer with the write value
        if (CUT.TryWrite(WriteBuffer)) then
          Inc(WriteValue); // Write the block of 71 integers to the RingBuffer
      end;

      BlockCount := Random(5) + 1; // Generate a random number of blocks to read
      for Block := 0 to BlockCount - 1 do
      begin
        if (CUT.TryRead(ReadBuffer)) then
        begin
          for J := 0 to 70 do
            Assert.AreEqual(ReadValue, ReadBuffer[J]); // Assert that the read values match the expected values
          Inc(ReadValue);
        end;
      end;
    end;

    while CUT.TryRead(ReadBuffer) do
    begin
      for J := 0 to 70 do
        Assert.AreEqual(ReadValue, ReadBuffer[J]); // Assert that the read values match the expected values
      Inc(ReadValue);
    end;
  finally
    CUT.Free; // Free the RingBuffer to release the memory
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TTestTgoRingBuffer); // Register the test fixture with the test framework

end.

