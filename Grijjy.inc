{$SCOPEDENUMS ON}  // Enable scoped enums

{$IF Defined(ANDROID) or Defined(IOS)}  // If building for Android or iOS
  {$DEFINE MOBILE}  // Define the MOBILE compiler constant
{$ENDIF}  // End of the conditional block
