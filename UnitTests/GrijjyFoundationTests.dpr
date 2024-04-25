program GrijjyFoundationTests;

{$IFNDEF TESTINSIGHT} // If the TESTINSIGHT symbol is not defined
{$APPTYPE CONSOLE}   // The application type is console
{$ENDIF}

{$STRONGLINKTYPES ON} // Enable strong linking types

uses // Import the following units
  System.SysUtils, // For basic system utilities
  DUnitX.TestFramework, // For the DUnitX test framework
  DUnitX.Loggers.Console, // For logging to the console
  DUnitX.Loggers.Xml.NUnit, // For generating NUnit compatible XML output
  Tests.Grijjy.Collections.Base, // Test unit for Grijjy collections (base)
  Tests.Grijjy.Collections.Sets, // Test unit for Grijjy collections (sets)
  Tests.Grijjy.Collections.RingBuffer, // Test unit for Grijjy collections (ring buffer)
  Tests.Grijjy.Collections.Lists, // Test unit for Grijjy collections (lists)
  Tests.Grijjy.Collections.Dictionaries, // Test unit for Grijjy collections (dictionaries)
  Tests.Grijjy.Bson, // Test unit for Grijjy BSON
  Tests.Grijjy.Bson.IO, // Test unit for Grijjy BSON I/O
  Tests.Grijjy.Bson.Serialization, // Test unit for Grijjy BSON serialization
  Tests.Grijjy.ProtocolBuffers, // Test unit for Grijjy Protocol Buffers
  Tests.Grijjy.PropertyBag; // Test unit for Grijjy Property Bag

var
  runner : ITestRunner; // The test runner
  results : IRunResults; // The test results
  logger : ITestLogger; // The test logger
  nunitLogger : ITestLogger; // The NUnit compatible XML logger
begin
{$IFDEF TESTINSIGHT} // If the TESTINSIGHT symbol is defined
  TestInsight.DUnitX.RunRegisteredTests; // Run registered tests for TestInsight
  exit;
{$ENDIF}
  try
    // Check command line options and exit if invalid
    TDUnitX.CheckCommandLine;

    // Create the test runner
    runner := TDUnitX.CreateRunner;

    // Tell the runner to use RTTI to find Fixtures
    runner.UseRTTI := True;

    // Tell the runner how to log things
    // Log to the console window
    logger := TDUnitXConsoleLogger.Create(true);
    runner.AddLogger(logger);

    // Generate an NUnit compatible XML file
    nunitLogger := TDUnitXXMLNUnitFileLogger.Create(TDUnitX.Options.XMLOutputFile);
    runner.AddLogger(nunitLogger);
    runner.FailsOnNoAsserts := False; // When true, Assertions must be made during tests

    // Run tests
    results := runner.Execute;

    // Exit with an error code if not all tests passed
    if not results.AllPassed then
      System.ExitCode := EXIT_ERRORS;

    {$IFNDEF CI} // If not running under CI
    // Pause the console window when done
    if TDUnitX.Options.ExitBehavior = TDUnitXExitBehavior.Pause then
    begin
      System.Write('Done.. press <Enter> key to quit.');
      System.Readln;
    end;
    {$ENDIF}
  except
    on E: Exception do
      System.Writeln(E.ClassName, ': ', E.Message);
  end;
end.

