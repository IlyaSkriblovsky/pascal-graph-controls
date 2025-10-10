unit Button;

interface
uses Control, Rect;

type
  TOnClick = procedure;

  PButton = ^TButton;
  TButton = object(TControl)
    public
      title: string;
      pressed: boolean;
      onClick: TOnClick;

      constructor Create(rect_: TRect; title_: string);

      procedure Draw; virtual;
      procedure MouseDown; virtual;
      procedure MouseUp; virtual;
      procedure Click; virtual;
  end;

implementation
uses Graph, Utils, Mouse;

constructor TButton.Create(rect_: TRect; title_: string);
begin
  rect := rect_;
  title := title_;
  pressed := false;
  onClick := nil;
end;

procedure TButton.Draw;
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

    SetColor(Black);
    SetViewPort(x+2, y+2, x+width-2, y+height-2, ClipOn);
    SetTextJustify(LeftText, CenterText);
    OutTextXY(
      MaxI(0, (width - TextWidth(title)) div 2) + integer(pressed),
      height div 2 -1 + integer(pressed),
      title
    );
    SetViewPort(0, 0, GetMaxX, GetMaxY, ClipOff);
  end;
end;

procedure TButton.MouseDown;
begin
  pressed := true;
  ShowCursor(false);
  Draw;
  ShowCursor(true);
end;

procedure TButton.MouseUp;
begin
  pressed := false;
  ShowCursor(false);
  Draw;
  ShowCursor(true);
end;

procedure TButton.Click;
begin
  if Assigned(onClick)
  then onClick;
end;

end.