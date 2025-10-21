unit Button;

interface
uses Control, Rect;

type
  PButton = ^TButton;
  TButton = object(TControl)
    public
      title: string;
      pressed: boolean;
      onClick: procedure;

      constructor Create(x, y, width, height: integer; title_: string);

      procedure Draw; virtual;
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

procedure TButton.Draw;
var
  viewPort: ViewPortType;
  textOffset: integer;
  textX, textY: integer;
begin
  with rect do begin
    if pressed
    then begin
      SetColor(Black);
      Line(x, y, x+width, y);
      Line(x, y, x, y+height);

      SetColor(DarkGray);
      Line(x+1, y+1, x+1, y+height-1);
      Line(x+1, y+1, x+width-1, y+1);

      SetColor(White);
      Line(x+width, y, x+width, y+height);
      Line(x, y+height, x+width, y+height);

      SetFillStyle(SolidFill, LightGray);
      Bar(x+2, y+2, x+width-1, y+height-1);
    end
    else begin
      SetColor(White);
      Line(x, y, x+width, y);
      Line(x, y, x, y+height);

      SetColor(DarkGray);
      Line(x+width-1, y+1, x+width-1, y+height);
      Line(x+1, y+height-1, x+width, y+height-1);

      SetColor(Black);
      Line(x+width, y, x+width, y+height);
      Line(x, y+height, x+width, y+height);

      SetFillStyle(SolidFill, LightGray);
      Bar(x+1, y+1, x+width-2, y+height-2);
    end;

    SetInnerViewport(viewPort, x+2, y+2, x+width-2, y+height-2, ClipOn);
    SetTextJustify(LeftText, CenterText);
    textOffset := integer(pressed)*2;
    textX := MaxI(0, (width - TextWidth(title)) div 2) + textOffset;
    textY := height div 2 -1 + textOffset;
    if _disabled
    then begin
      SetColor(White);
      OutTextXY(textX+1, textY+1, title);
      SetColor(DarkGray);
    end
    else SetColor(Black);
    OutTextXY(textX, textY, title);
    SetViewSettings(viewPort);
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
  then onClick;
end;

end.