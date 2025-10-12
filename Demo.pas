uses Control, Window, Button, Rect, CRT, Parent;

var
  ctrls: TControlIter;
  btn: PButton;
  win: PWindow;
  r: TRect;

procedure onClick; far;
begin
  Sound(400);
  Delay(100);
  NoSound;
end;

begin
  r.Assign(100, 300, 200, 150);
  win := New(PWindow, Create(r, 'My Controls!'));
  ctrls.Add(win);

  r.Assign(30, 30, 80, 24);
  btn := New(PButton, Create(r, 'Beep'));
  btn^.onClick := onClick;
  { ctrls.Add(btn); }
  win^.AddChild(btn);

  r.Assign(200, 100, 120, 24);
  btn := New(PButton, Create(r, 'Don''t click'));
  ctrls.Add(btn);

  RunControls(@ctrls);
end.