unit Grijjy.TimerQueue;
{ Cross platform thread pool timer queue }

{ This unit provides a method to execute timer events in a thread
  that occur outside of the main application or UI thread.  Most operating
  systems provide an efficient kernel managed thread pool specificially for
  threaded timers and we utilize that in this unit for each OS. }

{$I Grijjy.inc}

interface

uses
  System.Classes,
  System.SysUtils,

