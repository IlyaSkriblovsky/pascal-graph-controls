uses Control, Button, Rect, CRT;

var
  ctrls: ControlIter;
  btn: PButton;
  r: TRect;

procedure onClick; far;
begin
  Sound(400);
  Delay(100);
  NoSound;
end;

begin
  btn := New(PButton);
  r.Assign(100, 100, 80, 24);
  btn^.Create(r, 'Click me');
  btn^.onClick := onClick;
  ctrls.Add(btn);

  btn := New(PButton);
  r.Assign(200, 100, 120, 24);
  btn^.Create(r, 'Don''t click');
  ctrls.Add(btn);

  RunControls(@ctrls);
end.