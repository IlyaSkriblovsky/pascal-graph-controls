unit Utils;

interface
uses Graph;

function MaxI(a, b: integer): integer;

procedure SetInnerViewport(
  var viewPort: ViewPortType;
  x1, y1, x2, y2: integer;
  clip: boolean
);
procedure SetViewSettings(viewPort: ViewPortType);

procedure WaitForVSync;

implementation

function MaxI(a, b: integer): integer;
begin
  if a > b
  then MaxI := a
  else MaxI := b;
end;

procedure SetInnerViewport(
  var viewPort: ViewPortType;
  x1, y1, x2, y2: integer;
  clip: boolean
);
begin
  GetViewSettings(viewPort);
  SetViewPort(viewPort.x1+x1, viewPort.y1+y1, viewPort.x1+x2, viewPort.y1+y2, clip);
end;

procedure SetViewSettings(viewPort: ViewPortType);
begin
  SetViewPort(viewPort.x1, viewPort.y1, viewPort.x2, viewPort.y2, viewPort.Clip);
end;

procedure WaitForVSync;
begin
  repeat
  until (Port[$3DA] and 8) <> 0;
end;

end.