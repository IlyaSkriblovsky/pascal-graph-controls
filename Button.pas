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
  end;

implementation
uses Graph, Utils, Mouse;

constructor TButton.Create(x, y, width, height: integer; title_: string);
begin
  TControl.Create;
  rect.Assign(x, y, width, height);
  title := title_;
  pressed := false;
  onClick := nil;
end;

procedure TButton.Draw;
var
  viewPort: ViewPortType;
  textOffset: integer;
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
    SetColor(Black);
    textOffset := integer(pressed)*2;
    OutTextXY(
      MaxI(0, (width - TextWidth(title)) div 2) + textOffset,
      height div 2 -1 + textOffset,
      title
    );
    SetViewSettings(viewPort);
  end;
end;

procedure TButton.MouseDown(x, y: integer);
begin
  pressed := true;
  Redraw;
end;

procedure TButton.MouseUp(x, y: integer);
begin
  pressed := false;
  Redraw;
end;

procedure TButton.Click;
begin
  if Assigned(onClick)
  then onClick;
end;

end.