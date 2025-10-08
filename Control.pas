unit Control;

interface
uses Rect;

type
  PControl = ^TControl;

  PControlIter = ^ControlIter;
  ControlIter = object
    public
      constructor Create;
      procedure Add(control: PControl);

    private
      _cur: PControl;
      _next: PControlIter;
  end;

  TControl = object
    public
      rect: TRect;

      procedure Draw; virtual;
      procedure MouseDown; virtual;
      procedure MouseUp; virtual;
  end;

procedure DrawControls(controls: PControlIter);
procedure RunControls(controls: PControlIter);


implementation
uses CRT, Graph, Mouse, Utils;

{ CONTROL LIST }

constructor ControlIter.Create;
begin
  _cur := nil;
  _next := nil;
end;

procedure ControlIter.Add(control: PControl);
var
  iter: PControlIter;
begin
  iter := @self;
  while iter^._cur <> nil
  do iter := iter^._next;
  iter^._cur := control;
  iter^._next := New(PControlIter);
  iter^._next^.Create;
end;

{ UTILS }

procedure DrawControls(controls: PControlIter);
var
  iter: PControlIter;
begin
  iter := controls;
  while iter^._cur <> nil do
  begin
    iter^._cur^.Draw;
    iter := iter^._next;
  end;
end;


procedure OnMousePress(controls: PControlIter; x, y: integer);
var iter: PControlIter;
begin
  iter := controls;
  while iter^._cur <> nil do
  begin
    if iter^._cur^.rect.ContainsPoint(x, y)
    then iter^._cur^.MouseDown;
    iter := iter^._next;
  end;
end;
procedure OnMouseRelease(controls: PControlIter; x, y: integer);
var iter: PControlIter;
begin
  iter := controls;
  while iter^._cur <> nil do
  begin
    if iter^._cur^.rect.ContainsPoint(x, y)
    then iter^._cur^.MouseUp;
    iter := iter^._next;
  end;
end;

procedure RunControls(controls: PControlIter);
var
  Driver, Mode: Integer;
  prevMouse, mouse: MouseState;

begin
  Driver := Detect;
  InitGraph(Driver, Mode, 'c:\tp\bgi');
  if GraphResult <> grOk then
  begin
    WriteLn('Can''t initialize graphics mode');
    Halt;
  end;

  SetFillStyle(SolidFill, LightGray);
  Bar(0, 0, 640, 480);

  FillChar(prevMouse, SizeOf(prevMouse), 0);
  DrawControls(controls);
  ShowCursor(true);
  while not KeyPressed
  do begin
    GetMouseState(mouse);
    if mouse.left and not prevMouse.left
    then OnMousePress(controls, mouse.x, mouse.y);
    if not mouse.left and prevMouse.left
    then OnMouseRelease(controls, mouse.x, mouse.y);
    Move(mouse, prevMouse, SizeOf(mouse))
  end;
  CloseGraph;
end;

{ CONTROL }

procedure TControl.Draw;
begin
end;

procedure TControl.MouseDown;
begin
end;

procedure TControl.MouseUp;
begin
end;

end.