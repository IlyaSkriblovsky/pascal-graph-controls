unit Root;

interface
uses Control, DrawUtil;

type
  PRoot = ^TRoot;
  TRoot = object(TParent)
    public
      constructor Create;

      procedure Draw(const drawPos: TDrawPos); virtual;

      procedure Run;
  end;

implementation
uses Graph, Mouse, CRT;

constructor TRoot.Create;
begin
  TParent.Create(0, 0, GetMaxX, GetMaxY);
end;

procedure TRoot.Draw(const drawPos: TDrawPos);
begin
  SetFillStyle(CloseDotFill, DarkGray);
  drawPos.Bar(0, 0, rect.width, rect.height);

  TParent.Draw(drawPos);
end;

procedure TRoot.Run;
var
  Driver, Mode: Integer;
  prevMouse, mouse: MouseState;
  drawPos: TDrawPos;

begin
  Driver := Detect;
  InitGraph(Driver, Mode, 'c:\tp\bgi');
  if GraphResult <> grOk then
  begin
    WriteLn('Can''t initialize graphics mode');
    Halt;
  end;

  rect.Assign(0, 0, GetMaxX, GetMaxY);
  drawPos.ResetToScreen;

  FillChar(prevMouse, SizeOf(prevMouse), 0);
  Draw(drawPos);
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