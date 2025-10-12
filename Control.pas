unit Control;

interface
uses Rect;

type
  PControl = ^TControl;

  TControlProc = procedure(control: PControl);
  TControlWithPtrProc = procedure(control: PControl; ptr: Pointer);

  PControlIter = ^TControlIter;
  TControlIter = object
    public
      constructor Create;

      procedure Add(control: PControl);
      function Remove(control: PControl; destroy: boolean): boolean;
      procedure Clear(destroy: boolean);

      function Length: integer;
      procedure ForEach(proc: TControlProc);
      procedure ForEachWithPtr(proc: TControlWithPtrProc; ptr: Pointer);

    private 
      cur: PControl;
      next: PControlIter;
  end;

  TControl = object
    public
      rect: TRect;

      destructor Destroy;

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

constructor TControlIter.Create;
begin
  cur := nil;
  next := nil;
end;

procedure TControlIter.Add(control: PControl);
var iter: PControlIter;
begin
  iter := @self;
  while iter^.cur <> nil
  do iter := iter^.next;
  iter^.cur := control;
  iter^.next := New(PControlIter, Create);
end;

function TControlIter.Remove(control: PControl; destroy: boolean): boolean;
var
  iter, tmp: PControlIter;
begin
  if cur = nil
  then Remove := false
  else if cur = control
  then begin
    Remove := true;
    if destroy
    then Dispose(cur, Destroy);
    if Assigned(next)
    then begin
      tmp := next;
      cur := tmp^.cur;
      next := tmp^.next;
      Dispose(tmp);
    end
    else begin
      if destroy
      then Dispose(cur, Destroy);
      cur := nil;
    end;
  end
  else if Assigned(next)
  then begin
    Remove := next^.Remove(control, destroy);
  end
  else Remove := false;
end;

procedure TControlIter.Clear(destroy: boolean);
begin
  while cur <> nil
  do Remove(cur, destroy);
end;

procedure TControlIter.ForEach(proc: TControlProc);
var
  iter: PControlIter;
begin
  iter := @self;
  while iter^.cur <> nil
  do begin
    proc(iter^.cur);
    iter := iter^.next;
  end;
end;

procedure TControlIter.ForEachWithPtr(proc: TControlWithPtrProc; ptr: Pointer);
var
  iter: PControlIter;
begin
  iter := @self;
  while iter^.cur <> nil
  do begin
    proc(iter^.cur, ptr);
    iter := iter^.next;
  end;
end;

function TControlIter.Length: integer;
var
  iter: PControlIter;
  len: integer;
begin
  len := 0;
  iter := @self;
  while iter^.cur <> nil
  do begin
    Inc(len);
    iter := iter^.next;
  end;
  Length := len;
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

destructor TControl.Destroy; begin end;
procedure TControl.Draw; begin end;
procedure TControl.MouseDown; begin end;
procedure TControl.MouseUp; begin end;
procedure TControl.Click; begin end;

end.