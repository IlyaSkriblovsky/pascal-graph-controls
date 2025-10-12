uses Control, Window, Button, Rect, CRT, Root;

var
  r: TRoot;

  btn: PButton;
  win: PWindow;

procedure Beep(hz: integer; duration: integer);
begin
  Sound(hz);
  Delay(duration);
  NoSound;
end;

procedure onClick400; far;
begin
  Beep(400, 100);
end;
procedure onClick600; far;
begin
  Beep(600, 100);
end;

begin
  r.Create;

  win := New(PWindow, Create(100, 300, 200, 150, 'My Controls!'));
  r.AddChild(win);

  btn := New(PButton, Create(30, 30, 80, 24, 'Click me'));
  btn^.onClick := onClick400;
  win^.AddChild(btn);

  btn := New(PButton, Create(200, 100, 120, 24, 'Don''t click'));
  btn^.onClick := onClick600;
  r.AddChild(btn);

  r.Run;
end.