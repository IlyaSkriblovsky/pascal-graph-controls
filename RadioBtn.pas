unit RadioBtn;

interface
uses Control, Rect, DrawUtil;

type
  PRadioButton = ^TRadioButton;
  PRadioGroup = ^TRadioGroup;

  TRadioGroup = object
    public
      constructor Create;

      procedure Select(button: PRadioButton);
      function GetSelected: PRadioButton;
      
    private
      selected: PRadioButton;
  end;

  TRadioButton = object(TControl)
    public
      checked: boolean;
      title: string;
      group: PRadioGroup;
      onChange: procedure(sender: PRadioButton);

      constructor Create(
        x, y, width, height: integer;
        title_: string;
        group_: PRadioGroup;
        checked_: boolean
      );
      destructor Destroy; virtual;

      procedure Draw(const drawPos: TDrawPos); virtual;
      procedure Click; virtual;
      procedure SetChecked(value: boolean);

    private
      procedure HandleCheckedChange(value: boolean);
  end;

implementation
uses Graph, Utils;

const
  RADIUS = 6;
  DIAMETER = 12;
  GAP = 4;

constructor TRadioGroup.Create;
begin
  selected := nil;
end;

procedure TRadioGroup.Select(button: PRadioButton);
begin
  if selected = button
  then Exit;

  if Assigned(selected)
  then selected^.HandleCheckedChange(false);

  selected := button;

  if Assigned(selected)
  then selected^.HandleCheckedChange(true);
end;

function TRadioGroup.GetSelected: PRadioButton;
begin
  GetSelected := selected;
end;

constructor TRadioButton.Create(
  x, y, width, height: integer;
  title_: string;
  group_: PRadioGroup;
  checked_: boolean
);
begin
  TControl.Create;
  rect.Assign(x, y, width, height);
  title := title_;
  group := group_;
  checked := false;
  onChange := nil;

  if checked_
  then SetChecked(true)
  else checked := false;
end;

destructor TRadioButton.Destroy;
begin
  if Assigned(group) and (group^.GetSelected = @self)
  then group^.Select(nil);
  TControl.Destroy;
end;

procedure TRadioButton.Draw(const drawPos: TDrawPos);
var
  labelPos: TDrawPos;
  labelWidth: integer;
begin
  SetColor(DarkGray);
  SetFillStyle(SolidFill, White);
  drawPos.FillEllipse(RADIUS, RADIUS, RADIUS, RADIUS);

  SetColor(Black);
  drawPos.Arc(RADIUS, RADIUS, 45, 225, RADIUS-1);
  SetColor(White);
  drawPos.Arc(RADIUS, RADIUS, 225, 405, RADIUS);
  SetColor(LightGray);
  drawPos.Arc(RADIUS, RADIUS, 225, 405, RADIUS-1);

  if checked
  then begin
    SetColor(Black);
    SetFillStyle(SolidFill, Black);
    drawPos.FillEllipse(RADIUS, RADIUS, RADIUS-4, RADIUS-4);
  end;

  labelWidth := MaxI(0, rect.width - (DIAMETER + GAP));
  drawPos.Clip(DIAMETER + GAP, 0, labelWidth, rect.height, labelPos);
  SetTextJustify(LeftText, CenterText);
  SetColor(Black);
  labelPos.OutTextXY(0, (rect.height+1) div 2, title);
end;

procedure TRadioButton.Click;
begin
  SetChecked(true);
end;

procedure TRadioButton.SetChecked(value: boolean);
begin
  if Assigned(group)
  then group^.Select(@self)
  else if not checked
        then HandleCheckedChange(true);
end;

procedure TRadioButton.HandleCheckedChange(value: boolean);
begin
  checked := value;
  if Assigned(onChange)
  then onChange(@self);
  Redraw;
end;

end.
