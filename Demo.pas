uses Control, Window, Button, Rect, CRT, Root, Graph, Checkbox, RadioBtn;

type
  PWindowData = ^TWindowData;
  TWindowData = object
    radioGroup: TRadioGroup;
    beepHz: integer;

    constructor Create;
  end;

var
  r: TRoot;
  btn: PButton;

  nextWinX, nextWinY: integer;
  newWindowBeepHz: integer;


constructor TWindowData.Create;
begin
  radioGroup.Create;
  beepHz := 440;
end;

procedure Beep(hz: integer; duration: integer);
begin
  Sound(hz);
  Delay(duration);
  NoSound;
end;

procedure OnCloseWindow(window: PWindow); far;
begin
  Dispose(PWindowData(window^.userData));
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
var
  winData: PWindowData;
begin
  if not sender^.checked
  then Exit;

  winData := PWindowData(sender^.GetParent^.userData);
  winData^.beepHz := integer(sender^.userData);
end;

procedure OnBeepButton(sender: PButton); far;
begin
  Beep(PWindowData(sender^.GetParent^.userData)^.beepHz, 50);
end;

function CreateWindow: PWindow;
var
  win: PWindow;
  btn: PButton;
  cbx: PCheckbox;
  rbx: PRadioButton;

  winData: PWindowData;

begin
  win := New(PWindow, Create(nextWinX, nextWinY, 250, 120, 'New Window'));
  win^.onClose := OnCloseWindow;

  winData := New(PWindowData, Create);
  win^.userData := winData;

  btn := New(PButton, Create(30, 30, 80, 24, 'Beep'));
  btn^.SetDisabled(false);
  btn^.onClick := OnBeepButton;
  win^.AddChild(btn);

  cbx := New(PCheckbox, Create(30, 70, 120, 13, 'Enabled', true));
  cbx^.userData := btn;
  cbx^.onChange := OnCheckboxChange;
  win^.AddChild(cbx);

  rbx := New(PRadioButton, Create(10, 10, 80, 13, 'Low', @winData^.radioGroup, true));
  rbx^.onChange := OnRadioChange;
  rbx^.userData := Pointer(440);
  win^.AddChild(rbx);

  rbx := New(PRadioButton, Create(90, 10, 80, 13, 'High', @winData^.radioGroup, false));
  rbx^.onChange := OnRadioChange;
  rbx^.userData := Pointer(880);
  win^.AddChild(rbx);

  r.AddChild(win);

  nextWinX := (nextWinX + 20) mod (GetMaxX - 250);
  nextWinY := (nextWinY + 20) mod (GetMaxY - 120);
end;

procedure OnNewWindow(sender: PButton); far;
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

  {CreateWindow;}

  r.Run;

  r.Destroy;
end.
