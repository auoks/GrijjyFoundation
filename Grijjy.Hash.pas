unit Grijjy.Hash;

{$INCLUDE 'Grijjy.inc'}

{$OVERFLOWCHECKS OFF} // This is required since overflow checks will fail, but the code works fine without them.

interface

type
  { Incremental Murmur-2 hash.
      See https://sites.google.com/site/murmurhash/
    Uses the CMurmurHash2A variant, which can be used incrementally.
    The results are *not* the same as for goMurmurHash2 in Grijjy.SysUtils }
  TgoHashMurmur2 = record
  {$REGION 'Internal Declarations'}
  private const
    M = $5bd1e995; // Magic constant for MurmurHash2
    R = 24; // Number of bits to rotate by
  private
    FHash: Cardinal; // The current hash value
    FTail: Cardinal; // The tail of the hash value
    FCount: Cardinal; // The number of bytes in the tail
    FSize: Cardinal; // The total number of bytes hashed
  private
    class procedure Mix(var H, K: Cardinal); static; inline;
    // Mixes the hash and a 4-byte value
  private
    procedure MixTail(var AData: PByte; var ALength: Integer);
    // Mixes the tail of the hash with new data
  {$ENDREGION 'Internal Declarations'}
  public
    { Starts a new hash.

      Parameters:
        ASeed: (optional) seed value for the hash.

      This is identical to calling Reset. }
    class function Create(const ASeed: Integer = 0): TgoHashMurmur2; static; inline;

    { Restarts the hash

      Parameters:
        ASeed: (optional) seed value for the hash.

      This is identical to using Create. }
    procedure Reset(const ASeed: Integer = 0); inline;

    { Updates the hash with new data.

      Parameters:
        AData: the data to hash
        ALength: the size of the data in bytes. }
    procedure Update(const AData; ALength: Integer);

    { Finishes the hash and returns the hash code.

      Returns:
        The hash code }
    function Finish: Cardinal;
  end;

implementation

{ TgoHashMurmur2 }

class function TgoHashMurmur2.Create(const ASeed: Integer): TgoHashMurmur2;
begin
  Result.Reset(ASeed);
end;

function TgoHashMurmur2.Finish: Cardinal;
begin
  Mix(FHash, FTail); // Mix the current hash and tail
  Mix(FHash, FSize); // Mix the current hash and the total number of bytes hashed

  FHash := FHash xor (FHash shr 13); // Finalize the hash
  FHash := FHash * M;
  FHash := FHash xor (FHash shr 15);

  Result := FHash; // Return the final hash value
end;

class procedure TgoHashMurmur2.Mix(var H, K: Cardinal);
begin
  K := K * M; // Mix the input value
  K := K xor (K shr R); // Rotate the bits
  K := K * M; // Mix again
  H := H * M; // Mix the hash value
  H := H xor K; // Combine the hash and input values
end;

procedure TgoHashMurmur2.MixTail(var AData: PByte; var ALength: Integer);
begin
  while (ALength <> 0) and ((ALength < 4) or (FCount <> 0)) do
  // Mix the tail with new data until the tail is full or there is no more data
  begin
    FTail := FTail or (AData^ shl (FCount * 8)); // Add the new byte to the tail
    Inc(AData); // Move to the next byte
    Inc(FCount); // Increment the tail length
    Dec(ALength); // Decrement the data length

    if (FCount = 4) then
    // If the tail is full, mix it with the hash and reset the tail
    begin
      Mix(FHash, FTail);
      FTail := 0;
      FCount := 0;
    end;
  end;
end;

procedure TgoHashMurmur2.Reset(const ASeed: Integer);
begin
  FHash := ASeed; // Reset the hash value
  FTail := 0; // Reset the tail
  FCount := 0; // Reset the tail length
  FSize := 0; // Reset the total number of bytes hashed
end;

procedure TgoHashMurmur2.Update(const AData; ALength: Integer);
var
  Data: PByte;
  K: Cardinal;
begin
  Inc(FSize, ALength); // Increment the total number of bytes hashed
  Data := @AData; // Get a pointer to the data
  MixTail(Data, ALength); // Mix the tail with the new data
  while (ALength >= 4) do
  // Mix the hash with 4-byte blocks of data
  begin
    K := PCardinal(Data)^; // Get the 4-byte value
    Mix(FHash, K); // Mix the hash and the 4-byte value
    Inc(Data, 4); // Move to the next 4-byte block
    Dec(ALength, 4); // Decrement the data length
  end;
  MixTail(Data, ALength); // Mix the tail with any remaining data
end;

end.
