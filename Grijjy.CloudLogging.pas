unit Grijjy.CloudLogging;

interface

...

type
  { Logging levels for the GrijjyLog.Send and GrijjyLog.SetLogLevel routines. }
  TgoLogLevel = (
    { Informational message. By default, informational messages are logged in
      DEBUG mode, but not in RELEASE mode.
      Call Grijjy.SetLogLevel(TgoLogLevel.Info) to always log
      informational messages (as well as all other message levels) }
    Info,

    { Warning message. Warning messages are logged by default, unless you call
      grSetLogLevel(TgoLogLevel.Error) to only log error messages. }
    Warning,

    { Error message. Error messages are always logged. }
    Error
  );

