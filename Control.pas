unit Control;

interface
uses Rect, Graph;

type
  PControl = ^TControl;
  PParent = ^TParent;

  TControlProc = procedure(control: PControl);
  TControlWithPtrProc = procedure(control: PControl; ptr: Pointer);
  TControlPredicate = function(control: PControl): boolean;

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
      procedure ForEachIf(cond: TControlPredicate; proc: TControlProc);
      procedure ForEachIfWithPtr(cond: TControlPredicate; proc: TControlWithPtrProc; ptr: Pointer);

    private 
      cur: PControl;
      next: PControlIter;
  end;

  TControl = object
    public
      rect: TRect;

      constructor Create;
      destructor Destroy;

      procedure Draw; virtual;
      procedure Redraw; virtual;
      procedure MouseDown(x, y: integer); virtual;
      procedure MouseUp(x, y: integer); virtual;
      procedure Click; virtual;

      procedure SetParent(parent: PParent);
      function GetParent: PParent;
      procedure SetObeysParentMargins(obeys: boolean);
      function ObeysParentMargins: boolean;

    private
      _parent: PParent;
      _obeysParentMargins: boolean;
  end;

  TParent = object(TControl)
    public
      mouseCapture: PControl;

      constructor Create;
      destructor Destroy;

      procedure GetMargins(var margins: TMargins); virtual;

      procedure AddChild(control: PControl);
      procedure RemoveChild(control: PControl);

      procedure Draw; virtual;

      procedure SetAbsoluteViewport(withMargins: boolean);
      procedure SetRelativeViewport(var viewPort: ViewPortType; withMargins: boolean);

      procedure MouseDown(x, y: integer); virtual;
      procedure MouseUp(x, y: integer); virtual;

    private
      children: TControlIter;
  end;


implementation
uses CRT, Mouse, Utils;

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
begin
  ForEachIf(nil, proc);
end;

procedure TControlIter.ForEachIf(cond: TControlPredicate; proc: TControlProc);
var
  iter: PControlIter;
begin
  iter := @self;
  while iter^.cur <> nil
  do begin
    if not Assigned(cond) or cond(iter^.cur)
    then proc(iter^.cur);
    iter := iter^.next;
  end;
end;

procedure TControlIter.ForEachIfWithPtr(cond: TControlPredicate; proc: TControlWithPtrProc; ptr: Pointer);
var
  iter: PControlIter;
begin
  iter := @self;
  while iter^.cur <> nil
  do begin
    if not Assigned(cond) or cond(iter^.cur)
    then proc(iter^.cur, ptr);
    iter := iter^.next;
  end;
end;

procedure TControlIter.ForEachWithPtr(proc: TControlWithPtrProc; ptr: Pointer);
begin
  ForEachIfWithPtr(nil, proc, ptr);
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

{ CONTROL }

constructor TControl.Create;
begin
  _parent := nil;
  _obeysParentMargins := true;
end;

procedure TControl.SetParent(parent: PParent);
begin
  _parent := parent;
end;

function TControl.GetParent: PParent;
begin
  GetParent := _parent;
end;

procedure TControl.SetObeysParentMargins(obeys: boolean);
begin
  _obeysParentMargins := obeys;
end;

function TControl.ObeysParentMargins: boolean;
begin
  ObeysParentMargins := _obeysParentMargins;
end;

destructor TControl.Destroy; begin end;
procedure TControl.Draw; begin end;
procedure TControl.MouseDown(x, y: integer); begin end;
procedure TControl.MouseUp(x, y: integer); begin end;
procedure TControl.Click; begin end;

procedure TControl.Redraw;
begin
  if Assigned(_parent)
  then _parent^.SetAbsoluteViewport(_obeysParentMargins);
  ShowCursor(false);
  Draw;
  ShowCursor(true);
end;

{ PARENT }

type
  TPointAndCapture = record
    x, y: integer;
    capture: PControl;
  end;

constructor TParent.Create;
begin
  children.Create;
  mouseCapture := nil;
end;

destructor TParent.Destroy;
begin
  children.Clear(true);
end;

procedure TParent.GetMargins(var margins: TMargins);
begin
  FillChar(margins, SizeOf(margins), 0);
end;

procedure TParent.AddChild(control: PControl);
begin
  control^._parent := @self;
  children.Add(control);
end;

procedure TParent.RemoveChild(control: PControl);
begin
  control^._parent := nil;
  children.Remove(control, true);
end;

procedure DrawChild(control: PControl); far;
begin
  control^.Draw;
end;

function ControlObeysMargins(control: PControl): boolean; far;
begin
  ControlObeysMargins := control^.ObeysParentMargins;
end;
function ControlDoesntObeyMargins(control: PControl): boolean; far;
begin
  ControlDoesntObeyMargins := not control^.ObeysParentMargins;
end;

procedure TParent.Draw;
var
  viewPort: ViewPortType;
begin
  SetRelativeViewport(viewPort, false);
  children.ForEachIf(ControlDoesntObeyMargins, DrawChild);
  SetViewSettings(viewPort);

  SetRelativeViewport(viewPort, true);
  children.ForEachIf(ControlObeysMargins, DrawChild);
  SetViewSettings(viewPort);
end;

procedure TParent.SetAbsoluteViewport(withMargins: boolean);
var
  viewPort: ViewPortType;
  margins: TMargins;
begin
  if withMargins
  then GetMargins(margins)
  else begin
    margins.left := 0;
    margins.top := 0;
    margins.right := 0;
    margins.bottom := 0;
  end;

  if Assigned(_parent)
  then begin
    _parent^.SetAbsoluteViewport(_obeysParentMargins);
    SetInnerViewport(
      viewPort,
      rect.x+margins.left,
      rect.y+margins.top,
      rect.x+rect.width-margins.right,
      rect.y+rect.height-margins.bottom,
      ClipOn
    );
  end
  else begin
    SetViewPort(
      rect.x+margins.left,
      rect.y+margins.top,
      rect.x+rect.width-margins.right,
      rect.y+rect.height-margins.bottom,
      ClipOn
    );
  end;
end;

procedure TParent.SetRelativeViewport(var viewPort: ViewPortType; withMargins: boolean);
var
  margins: TMargins;
begin
  if withMargins
  then GetMargins(margins)
  else begin
    margins.left := 0;
    margins.top := 0;
    margins.right := 0;
    margins.bottom := 0;
  end;
  SetInnerViewport(
    viewPort,
    rect.x + margins.left,
    rect.y + margins.top,
    rect.x + rect.width - margins.right,
    rect.y + rect.height - margins.bottom,
    ClipOn
  );
end;

procedure ChildMouseDown(control: PControl; ptr: Pointer); far;
var
  point: ^TPointAndCapture;
begin
  point := ptr;
  if control^.rect.ContainsPoint(point^.x, point^.y)
  then begin
    point^.capture := control;
    control^.MouseDown(point^.x - control^.rect.x, point^.y - control^.rect.y);
  end;
end;

procedure TParent.MouseDown(x, y: integer);
var
  pointAndCapture: TPointAndCapture;
  margins: TMargins;
begin
  pointAndCapture.x := x;
  pointAndCapture.y := y;
  pointAndCapture.capture := nil;
  children.ForEachIfWithPtr(ControlDoesntObeyMargins, ChildMouseDown, @pointAndCapture);

  GetMargins(margins);
  pointAndCapture.x := x - margins.left;
  pointAndCapture.y := y - margins.top;
  children.ForEachIfWithPtr(ControlObeysMargins, ChildMouseDown, @pointAndCapture);

  mouseCapture := pointAndCapture.capture;
end;

procedure TParent.MouseUp(x, y: integer);
var
  margins: TMargins;
begin
  if Assigned(mouseCapture)
  then begin
    if mouseCapture^.ObeysParentMargins
    then GetMargins(margins)
    else begin
      margins.left := 0;
      margins.top := 0;
      margins.right := 0;
      margins.bottom := 0;
    end;

    mouseCapture^.MouseUp(
      x - mouseCapture^.rect.x - margins.left, 
      y - mouseCapture^.rect.y - margins.top
    );
    if mouseCapture^.rect.ContainsPoint(x - margins.left, y - margins.top)
    then mouseCapture^.Click;
    mouseCapture := nil;
  end;
end;


end.