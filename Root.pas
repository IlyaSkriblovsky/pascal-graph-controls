unit Root;

interface
uses Control;

type
  PRoot = ^TRoot;
  TRoot = object(TParent)
    public
      constructor Create;

      procedure Draw; virtual;

      procedure Run;
  end;

implementation
uses Graph, Mouse, CRT;

constructor TRoot.Create;
begin
  TParent.Create;
  rect.Assign(0, 0, GetMaxX, GetMaxY);
end;

procedure TRoot.Draw;
begin
  SetViewPort(0, 0, GetMaxX, GetMaxY, ClipOff);
  SetFillStyle(CloseDotFill, DarkGray);
  Bar(0, 0, GetMaxX, GetMaxY);

  TParent.Draw;
end;

procedure TRoot.Run;
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

  rect.Assign(0, 0, GetMaxX, GetMaxY);

  FillChar(prevMouse, SizeOf(prevMouse), 0);
  Draw;
  ShowCursor(true);
  while not KeyPressed
  do begin
    GetMouseState(mouse);
    if mouse.left and not prevMouse.left
    then MouseDown(mouse.x, mouse.y);
    if not mouse.left and prevMouse.left
    then MouseUp(mouse.x, mouse.y);
    Move(mouse, prevMouse, SizeOf(mouse))
  end;

  CloseGraph;
end;

end.