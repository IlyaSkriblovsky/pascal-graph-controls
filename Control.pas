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
      cur: PControl;
      next: PControlIter;
  end;

  TControl = object
    public
      rect: TRect;

      procedure Draw; virtual;
      procedure MouseDown; virtual;
      procedure MouseUp; virtual;
      procedure Click; virtual;
  end;

var
  mouseCapture: PControl;

procedure InitControls;
procedure DrawControls(controls: PControlIter);
procedure RunControls(controls: PControlIter);


implementation
uses CRT, Graph, Mouse, Utils;

{ CONTROL LIST }

constructor ControlIter.Create;
begin
  cur := nil;
  next := nil;
end;

procedure ControlIter.Add(control: PControl);
var
  iter: PControlIter;
begin
  iter := @self;
  while iter^.cur <> nil
  do iter := iter^.next;
  iter^.cur := control;
  iter^.next := New(PControlIter);
  iter^.next^.Create;
end;

{ UTILS }

procedure InitControls;
begin
  mouseCapture := nil;
end;

procedure DrawControls(controls: PControlIter);
var
  iter: PControlIter;
begin
  iter := controls;
  while iter^.cur <> nil do
  begin
    iter^.cur^.Draw;
    iter := iter^.next;
  end;
end;


procedure OnMousePress(controls: PControlIter; x, y: integer);
var iter: PControlIter;
begin
  iter := controls;
  while iter^.cur <> nil do
  begin
    if iter^.cur^.rect.ContainsPoint(x, y)
    then begin
      mouseCapture := iter^.cur;
      iter^.cur^.MouseDown;
    end;
    iter := iter^.next;
  end;
end;
procedure OnMouseRelease(x, y: integer);
begin
  if Assigned(mouseCapture)
  then begin
    if mouseCapture^.rect.ContainsPoint(x, y)
    then mouseCapture^.Click;
    mouseCapture^.MouseUp;
    mouseCapture := nil;
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

  SetFillStyle(SolidFill, Brown);
  Bar(0, 0, GetMaxX, GetMaxY);

  FillChar(prevMouse, SizeOf(prevMouse), 0);
  DrawControls(controls);
  ShowCursor(true);
  while not KeyPressed
  do begin
    GetMouseState(mouse);
    if mouse.left and not prevMouse.left
    then OnMousePress(controls, mouse.x, mouse.y);
    if not mouse.left and prevMouse.left
    then OnMouseRelease(mouse.x, mouse.y);
    Move(mouse, prevMouse, SizeOf(mouse))
  end;
  CloseGraph;
end;

{ CONTROL }

procedure TControl.Draw; begin end;
procedure TControl.MouseDown; begin end;
procedure TControl.MouseUp; begin end;
procedure TControl.Click; begin end;

end.