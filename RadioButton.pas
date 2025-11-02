unit RadioButton;

interface
uses Control, Rect, DrawUtil;

type
  PRadioButton = ^TRadioButton;
  PRadioGroup = ^TRadioGroup;

  TRadioGroup = object
    private
      selected: PRadioButton;
    public
      constructor Create;

      procedure Select(button: PRadioButton);
      function GetSelected: PRadioButton;
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
  end;

implementation
uses Graph, Utils;

const
  DEFAULT_RADIUS = 6;
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
  then begin
    selected^.checked := false;
    if Assigned(selected^.onChange)
    then selected^.onChange(selected);
    selected^.Redraw;
  end;

  selected := button;

  if Assigned(selected)
  then begin
    selected^.checked := true;
    if Assigned(selected^.onChange)
    then selected^.onChange(selected);
    selected^.Redraw;
  end;
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
  radius: integer;
  diameter: integer;
  centerY: integer;
  drawX, drawY: integer;
  labelWidth: integer;
begin
  radius := MinI(DEFAULT_RADIUS, MaxI(2, rect.height div 2));
  diameter := radius * 2;
  centerY := rect.height div 2;
  if rect.height > diameter
  then centerY := ClipI(centerY, radius, rect.height - radius);

  drawX := drawPos.x - drawPos.clipX1 + radius;
  drawY := drawPos.y - drawPos.clipY1 + centerY;

  SetViewPort(drawPos.clipX1, drawPos.clipY1, drawPos.clipX2, drawPos.clipY2, ClipOn);

  SetColor(DarkGray);
  Circle(drawX, drawY, radius);
  SetFillStyle(SolidFill, White);
  FillEllipse(drawX, drawY, MaxI(1, radius - 1), MaxI(1, radius - 1));

  if checked
  then begin
    SetColor(Black);
    SetFillStyle(SolidFill, Black);
    FillEllipse(drawX, drawY, MaxI(1, radius - 3), MaxI(1, radius - 3));
  end;

  labelWidth := MaxI(0, rect.width - (diameter + GAP));
  drawPos.Clip(diameter + GAP, 0, labelWidth, rect.height, labelPos);
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
  if value
  then begin
    if Assigned(group)
    then group^.Select(@self)
    else if not checked
         then begin
           checked := true;
           if Assigned(onChange)
           then onChange(@self);
           Redraw;
         end;
  end
  else begin
    if Assigned(group)
    then begin
      if group^.GetSelected = @self
      then group^.Select(nil)
      else if checked
           then begin
             checked := false;
             if Assigned(onChange)
             then onChange(@self);
             Redraw;
           end;
    end
    else if checked
         then begin
           checked := false;
           if Assigned(onChange)
           then onChange(@self);
           Redraw;
         end;
  end;
end;

end.
