unit Profiler.ScopedTrace;

interface

uses
  Profiler.Trace;

type

  TScopedTrace = class(TInterfacedObject, ITrace)
    private
      FScopeName: string;
      FEventType: TTraceEventType;
      FTracer: ITracer;

      class threadvar FClockTicks: Int64;
      class constructor Create;

    private { ITrace }
      function GetScopeName: string;
      function GetEventType: TTraceEventType;
      function GetElapsedTicks: Int64;

    public
      class function NewInstance: TObject; override;
      procedure FreeInstance; override;
      function _AddRef: Integer; stdcall;
      function _Release: Integer; stdcall;

      constructor Create(const ScopeName: string; Tracer: ITracer);
  end;

implementation

uses
  System.Diagnostics;

class constructor TScopedTrace.Create;
begin
  TStopwatch.Create; // initialize the stopwatch variables
end;

class function TScopedTrace.NewInstance: TObject;
begin
  if FClockTicks > 0 then // if start is zero, elapsed will be zero
    FClockTicks := TStopwatch.GetTimeStamp - FClockTicks;
  Result := inherited;
end;

procedure TScopedTrace.FreeInstance;
begin
  inherited;
  FClockTicks := TStopwatch.GetTimeStamp;
end;

function TScopedTrace._AddRef: Integer;
begin
  Result := inherited;
  if FRefCount = 1 then
    begin
      FEventType := TTraceEventType.Enter;
      FTracer.Log(Self); // refcount will be 2
      FClockTicks := TStopwatch.GetTimeStamp;
    end;
end;

function TScopedTrace._Release: Integer;
begin
  if FRefCount = 1 then
    begin
      FClockTicks := TStopwatch.GetTimeStamp - FClockTicks;
      FEventType := TTraceEventType.Leave;
      FTracer.Log(Self); // refcount will be 2
    end;
  Result := inherited;
end;

constructor TScopedTrace.Create(const ScopeName: string; Tracer: ITracer);
begin
  FScopeName := string(ScopeName);
  FTracer := Tracer;
end;

function TScopedTrace.GetScopeName: string;
begin
  Result := FScopeName;
end;

function TScopedTrace.GetEventType: TTraceEventType;
begin
  Result := FEventType;
end;

function TScopedTrace.GetElapsedTicks: Int64;
begin
  Result := FClockTicks;
end;

end.
