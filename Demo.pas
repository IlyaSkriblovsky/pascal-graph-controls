uses Control, Window, Button, Rect, CRT;

var
  ctrls: ControlIter;
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
  win := New(PWindow);
  r.Assign(100, 300, 200, 150);
  win^.Create(r, 'My Controls!');
  ctrls.Add(win);

  btn := New(PButton);
  r.Assign(100, 100, 80, 24);
  btn^.Create(r, 'Beep');
  btn^.onClick := onClick;
  ctrls.Add(btn);

  btn := New(PButton);
  r.Assign(200, 100, 120, 24);
  btn^.Create(r, 'Don''t click');
  ctrls.Add(btn);

  RunControls(@ctrls);
end.