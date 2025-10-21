uses Control, Window, Button, Rect, CRT, Root, Graph, Checkbox;

var
  r: TRoot;
  btn: PButton;

  nextWinX, nextWinY: integer;

procedure Beep(hz: integer; duration: integer);
begin
  Sound(hz);
  Delay(duration);
  NoSound;
end;

procedure OnCloseWindow(window: PWindow); far;
begin
  r.RemoveChild(window);
  r.Redraw;
end;

function CreateWindow: PWindow;
var
  win: PWindow;
  btn: PButton;
  cbx: PCheckbox;

begin
  win := New(PWindow, Create(nextWinX, nextWinY, 250, 120, 'New Window'));
  win^.onClose := OnCloseWindow;

  btn := New(PButton, Create(30, 30, 80, 24, 'Click me'));
  win^.AddChild(btn);

  cbx := New(PCheckbox, Create(30, 70, 120, 13, 'Check me', false));
  win^.AddChild(cbx);

  r.AddChild(win);
  
  nextWinX := (nextWinX + 20) mod (GetMaxX - 250);
  nextWinY := (nextWinY + 20) mod (GetMaxY - 120);

end;

procedure OnNewWindow; far;
begin
  CreateWindow;
  r.Redraw;
end;

begin
  nextWinX := 150;
  nextWinY := 150;

  r.Create;

  btn := New(PButton, Create(200, 100, 120, 24, 'New window'));
  btn^.onClick := OnNewWindow;
  r.AddChild(btn);

  CreateWindow;

  r.Run;

  r.Destroy;
end.