uses Control, Window, Button, Rect, CRT, Root, Graph, Checkbox, RadioButton;

var
  r: TRoot;
  btn: PButton;
  radioSlow: PRadioButton;
  radioFast: PRadioButton;
  radioGroup: TRadioGroup;

  nextWinX, nextWinY: integer;
  newWindowBeepHz: integer;

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

procedure OnCheckboxChange(sender: PCheckbox); far;
var
  btn: PButton;
begin
  btn := sender^.userData;
  btn^.SetDisabled(not sender^.checked);
  btn^.Redraw;
end;

procedure OnRadioChange(sender: PRadioButton); far;
begin
  if not sender^.checked
  then Exit;

  if sender = radioSlow
  then newWindowBeepHz := 440
  else if sender = radioFast
       then newWindowBeepHz := 880;
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
  btn^.SetDisabled(true);
  win^.AddChild(btn);

  cbx := New(PCheckbox, Create(30, 70, 120, 13, 'Check me', false));
  cbx^.userData := btn;
  cbx^.onChange := OnCheckboxChange;
  win^.AddChild(cbx);

  r.AddChild(win);

  Beep(newWindowBeepHz, 120);

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
  newWindowBeepHz := 440;

  r.Create;

  btn := New(PButton, Create(200, 100, 120, 24, 'New window'));
  btn^.onClick := OnNewWindow;
  r.AddChild(btn);

  radioGroup.Create;
  radioSlow := New(PRadioButton, Create(200, 140, 160, 16, 'Low beep (440 Hz)', @radioGroup, true));
  radioSlow^.onChange := OnRadioChange;
  r.AddChild(radioSlow);

  radioFast := New(PRadioButton, Create(200, 160, 160, 16, 'High beep (880 Hz)', @radioGroup, false));
  radioFast^.onChange := OnRadioChange;
  r.AddChild(radioFast);

  CreateWindow;

  r.Run;

  r.Destroy;
end.
