unit Button;

interface
uses Control, Rect, DrawUtil;

type
  PButton = ^TButton;
  TButton = object(TControl)
    public
      title: string;
      pressed: boolean;
      onClick: procedure(sender: PButton);

      constructor Create(x, y, width, height: integer; title_: string);

      procedure Draw(const drawPos: TDrawPos); virtual;
      procedure MouseDown(x, y: integer); virtual;
      procedure MouseUp(x, y: integer); virtual;
      procedure Click; virtual;

      function IsDisabled: boolean;
      procedure SetDisabled(disabled: boolean);

    private
      _disabled: boolean;
  end;

implementation
uses Graph, Utils;

constructor TButton.Create(x, y, width, height: integer; title_: string);
begin
  TControl.Create;
  rect.Assign(x, y, width, height);
  title := title_;
  pressed := false;
  _disabled := false;
  onClick := nil;
end;

function TButton.IsDisabled: boolean;
begin
  IsDisabled := _disabled;
end;

procedure TButton.SetDisabled(disabled: boolean);
begin
  _disabled := disabled;
end;

procedure TButton.Draw(const drawPos: TDrawPos);
var
  textOffset: integer;
  textX, textY: integer;
begin
  with rect do begin
    if pressed
    then begin
      SetColor(Black);
      drawPos.Line(0, 0, width, 0);
      drawPos.Line(0, 0, 0, height);

      SetColor(DarkGray);
      drawPos.Line(1, 1, 1, height-1);
      drawPos.Line(1, 1, width-1, 1);

      SetColor(White);
      drawPos.Line(width, 0, width, height);
      drawPos.Line(0, height, width, height);

      SetFillStyle(SolidFill, LightGray);
      drawPos.Bar(2, 2, width-1, height-1);
    end
    else begin
      SetColor(White);
      drawPos.Line(0, 0, width, 0);
      drawPos.Line(0, 0, 0, 0+height);

      SetColor(DarkGray);
      drawPos.Line(width-1, 1, width-1, height);
      drawPos.Line(1, height-1, width, height-1);

      SetColor(Black);
      drawPos.Line(width, 0, width, height);
      drawPos.Line(0, height, width, height);

      SetFillStyle(SolidFill, LightGray);
      drawPos.Bar(1, 1, width-2, height-2);
    end;

    SetTextJustify(LeftText, CenterText);
    textOffset := integer(pressed)*2;
    textX := MaxI(0, (width - TextWidth(title)) div 2) + textOffset;
    textY := height div 2 + textOffset;
    if _disabled
    then begin
      SetColor(White);
      drawPos.OutTextXY(textX+1, textY+1, title);
      SetColor(DarkGray);
    end
    else SetColor(Black);
    drawPos.OutTextXY(textX, textY, title);
  end;
end;

procedure TButton.MouseDown(x, y: integer);
begin
  if not _disabled
  then begin
    pressed := true;
    Redraw;
  end;
end;

procedure TButton.MouseUp(x, y: integer);
begin
  if not _disabled
  then begin
    pressed := false;
    Redraw;
  end;
end;

procedure TButton.Click;
begin
  if not _disabled and Assigned(onClick)
  then onClick(@self);
end;

end.