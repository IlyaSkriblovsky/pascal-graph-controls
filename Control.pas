unit Control;

interface
uses Rect, Graph;

type
  PControl = ^TControl;
  PParent = ^TParent;

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

      constructor Create;
      destructor Destroy;

      procedure Draw; virtual;
      procedure Redraw;
      procedure MouseDown(x, y: integer); virtual;
      procedure MouseUp(x, y: integer); virtual;
      procedure Click; virtual;

    private
      _parent: PParent;
  end;

  TParent = object(TControl)
    public
      constructor Create;
      destructor Destroy;

      procedure GetMargins(var margins: TMargins); virtual;

      procedure AddChild(control: PControl);
      procedure RemoveChild(control: PControl);

      procedure Draw; virtual;

      procedure SetAbsoluteViewport;
      procedure SetRelativeViewport(var viewPort: ViewPortType);

      procedure MouseDown(x, y: integer); virtual;
      procedure MouseUp(x, y: integer); virtual;

    private
      children: TControlIter;
      mouseCapture: PControl;
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

{ CONTROL }

constructor TControl.Create;
begin
  _parent := nil;
end;

destructor TControl.Destroy; begin end;
procedure TControl.Draw; begin end;
procedure TControl.MouseDown(x, y: integer); begin end;
procedure TControl.MouseUp(x, y: integer); begin end;
procedure TControl.Click; begin end;

procedure TControl.Redraw;
begin
  if Assigned(_parent)
  then _parent^.SetAbsoluteViewport;
  Draw;
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

procedure TParent.Draw;
begin
  children.ForEach(DrawChild);
end;

procedure TParent.SetAbsoluteViewport;
var
  viewPort: ViewPortType;
  margins: TMargins;
begin
  GetMargins(margins);

  if Assigned(_parent)
  then begin
    _parent^.SetAbsoluteViewport;
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

procedure TParent.SetRelativeViewport(var viewPort: ViewPortType);
var
  margin: TMargins;
begin
  GetMargins(margin);
  SetInnerViewport(
    viewPort,
    rect.x+margin.left,
    rect.y+margin.top,
    rect.x+rect.width-margin.right,
    rect.y+rect.height-margin.bottom,
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
  GetMargins(margins);
  pointAndCapture.x := x - margins.left;
  pointAndCapture.y := y - margins.top;
  pointAndCapture.capture := nil;
  children.ForEachWithPtr(ChildMouseDown, @pointAndCapture);
  mouseCapture := pointAndCapture.capture;
end;

procedure TParent.MouseUp(x, y: integer);
var
  margins: TMargins;
begin
  if Assigned(mouseCapture)
  then begin
    GetMargins(margins);
    if mouseCapture^.rect.ContainsPoint(x - margins.left, y - margins.top)
    then mouseCapture^.Click;
    mouseCapture^.MouseUp(
      x - mouseCapture^.rect.x - margins.left, 
      y - mouseCapture^.rect.y - margins.top
    );
    mouseCapture := nil;
  end;
end;


end.