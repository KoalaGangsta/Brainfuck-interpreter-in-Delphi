unit Brainfuck;

interface

uses
  Generics.Collections,
  Sysutils;

type
  TMemory = class
  private
    FCount : byte;
    FCurrentIndex :byte;
    FValues : array of integer;
    function FGetCurrentValue: Integer;
    function FGetValueByIndex(AIndex : integer): Integer;
  public
    procedure Next;
    procedure Prev;
    procedure Inc;
    procedure Dec;
    constructor Create(ASize : Byte = 255);
    property CurrentValue : Integer read FGetCurrentValue;
    property CurrentIndex : byte read FCurrentIndex;
    property Count : byte read FCount;
    property Values[AIndex : integer] : integer read FGetValueByIndex;
  end;

  TInterpreterLoop = record
  public
    StartIndex : integer;
    StartPointerIndex : integer;
  end;

  TInterpreter = class
  private
    FMemory : TMemory;
    FCode : string;
    FPosition : integer;
    FInitialized : boolean;

    FLoopData : TList<TInterpreterLoop>;

    FOutput : string;

    procedure FSetCode(Value : string);
  public
    constructor Create();

    procedure Initialize;
    procedure Finalize;

    function Next : boolean;

    property Memory : TMemory read FMemory;

    property Code : string read FCode write FSetCode;
    property Initialized : boolean read FInitialized;
    property Output : string read FOutput;
    property Position : integer read FPosition;
  end;

implementation

function Loop(APosition : Integer; AIndex : integer) : TInterpreterLoop;
begin
  Result.StartIndex := APosition;
  Result.StartPointerIndex := AIndex;
end;

{ TMemory }

constructor TMemory.Create(ASize: Byte);
begin
  SetLength(FValues, ASize);
  FCount := ASize;
  FCurrentIndex := 0;
end;

procedure TMemory.Dec;
begin
  FValues[FCurrentIndex] := CurrentValue-1;
end;

function TMemory.FGetCurrentValue: Integer;
begin
  Result := FValues[FCurrentIndex];
end;

function TMemory.FGetValueByIndex(AIndex: integer): Integer;
begin
  Result := FValues[AIndex];
end;

procedure TMemory.Inc;
begin
  FValues[FCurrentIndex] := CurrentValue+1;
end;

procedure TMemory.Next;
begin
  if (FCurrentIndex+1) < Count then
    System.Inc(FCurrentIndex)
  else
    FCurrentIndex := 0;
end;

procedure TMemory.Prev;
begin
  if (FCurrentIndex-1) >= 0 then
    System.Dec(FCurrentIndex)
  else
    FCurrentIndex := Count-1;
end;

{ TInterpreter }

constructor TInterpreter.Create;
begin
  FLoopData := TList<TInterpreterLoop>.Create;
end;

procedure TInterpreter.Finalize;
begin
  FMemory.Free;

end;

procedure TInterpreter.FSetCode(Value: string);
begin
  if Initialized then
    Finalize;

  FCode := Value;
end;

procedure TInterpreter.Initialize;
begin
  FPosition := 1;
  FMemory := TMemory.Create(255);
  FOutput := '';
  FLoopData.Clear;
end;

function TInterpreter.Next : Boolean;
var
  LChar : char;
begin
  LChar := FCode[FPosition];

  case LChar of
    '>': Memory.Next;
    '<': Memory.Prev;
    '+': Memory.Inc;
    '-': Memory.Dec;
    '.': FOutput := FOutput + chr(Memory.CurrentValue);
    '[': FLoopData.Add(Loop(FPosition, Memory.CurrentIndex));
    ']': begin
      if Memory.Values[FLoopData[FLoopData.Count-1].StartPointerIndex] <> 0 then
        FPosition := FLoopData[FLoopData.Count-1].StartIndex
      else
        FLoopData.Delete(FLoopData.Count-1);
    end;
  end;

  inc(FPosition);
  Result := FPosition <= Length(FCode);
end;

end.