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

constructor TButton.Create(
  rect_: TRect;
  title_: string
);
begin
  self.rect := rect_;
  title := title_;
  pressed := false;
  onClick := nil;
end;

procedure TButton.Draw;
begin
  if pressed
  then begin
    SetColor(Black);
    Line(rect.x, rect.y, rect.x+rect.width, rect.y);
    Line(rect.x, rect.y, rect.x, rect.y+rect.height);

    SetColor(DarkGray);
    Line(rect.x+1, rect.y+1, rect.x+1, rect.y+rect.height-1);
    Line(rect.x+1, rect.y+1, rect.x+rect.width-1, rect.y+1);

    SetColor(White);
    Line(rect.x+rect.width, rect.y, rect.x+rect.width, rect.y+rect.height);
    Line(rect.x, rect.y+rect.height, rect.x+rect.width, rect.y+rect.height);

    SetFillStyle(SolidFill, LightGray);
    Bar(rect.x+2, rect.y+2, rect.x+rect.width-1, rect.y+rect.height-1);
  end
  else begin
    SetColor(White);
    Line(rect.x, rect.y, rect.x+rect.width, rect.y);
    Line(rect.x, rect.y, rect.x, rect.y+rect.height);

    SetColor(DarkGray);
    Line(rect.x+rect.width-1, rect.y+1, rect.x+rect.width-1, rect.y+rect.height);
    Line(rect.x+1, rect.y+rect.height-1, rect.x+rect.width, rect.y+rect.height-1);

    SetColor(Black);
    Line(rect.x+rect.width, rect.y, rect.x+rect.width, rect.y+rect.height);
    Line(rect.x, rect.y+rect.height, rect.x+rect.width, rect.y+rect.height);

    SetFillStyle(SolidFill, LightGray);
    Bar(rect.x+1, rect.y+1, rect.x+rect.width-2, rect.y+rect.height-2);
  end;

  SetColor(Black);
  SetViewPort(rect.x+2, rect.y+2, rect.x+rect.width-2, rect.y+rect.height-2, ClipOn);
  SetTextJustify(LeftText, CenterText);
  OutTextXY(
    MaxI(0, (rect.width - TextWidth(title)) div 2) + integer(pressed),
    rect.height div 2 -1 + integer(pressed),
    title
  );
  SetViewPort(0, 0, GetMaxX, GetMaxY, ClipOff);
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