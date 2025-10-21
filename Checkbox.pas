unit Checkbox;

interface
uses Control, Rect;

type
  PCheckbox = ^TCheckbox;
  TCheckbox = object(TControl)
    public
      checked: boolean;
      title: string;
      onChange: procedure;

      constructor Create(x, y, width, height: integer; title_: string; checked_: boolean);

      procedure Draw; virtual;
      procedure Click; virtual;
  end;

implementation
uses Graph, Utils;

const
  BOX_SIZE = 13;
  GAP = 4;

constructor TCheckbox.Create(x, y, width, height: integer; title_: string; checked_: boolean);
begin
  TControl.Create;
  rect.Assign(x, y, width, height);
  title := title_;
  checked := checked_;
  onChange := nil;
end;

procedure TCheckbox.Draw;
var
  viewPort: ViewPortType;
begin
  with rect
  do begin
    SetColor(DarkGray);
    Line(x, y, x + BOX_SIZE-2, y);
    Line(x, y, x, y + BOX_SIZE-2);

    SetColor(Black);
    Line(x + 1, y + 1, x + BOX_SIZE-3, y + 1);
    Line(x + 1, y + 1, x + 1, y + BOX_SIZE-3);

    SetColor(LightGray);
    Line(x + BOX_SIZE-2, y+1, x + BOX_SIZE-2, y + BOX_SIZE-2);
    Line(x + 1, y + BOX_SIZE-2, x + BOX_SIZE-2, y + BOX_SIZE-2);

    SetColor(White);
    Line(x + BOX_SIZE-1, y, x + BOX_SIZE-1, y + BOX_SIZE-1);
    Line(x, y + BOX_SIZE-1, x + BOX_SIZE-1, y + BOX_SIZE-1);

    SetFillStyle(SolidFill, White);
    Bar(x + 2, y + 2, x + BOX_SIZE - 3, y + BOX_SIZE - 3);

    if checked
    then begin
      SetColor(Black);
      SetLineStyle(SolidLn, 0, ThickWidth);
      Line(x + 3, y + 6, x + 5, y + 8);
      Line(x + 5, y + 8, x + 9, y + 4);
      SetLineStyle(SolidLn, 0, NormWidth);
    end;

    SetInnerViewport(
      viewPort,
      x + BOX_SIZE + GAP, y,
      x + width - BOX_SIZE - GAP, y + height,
      ClipOn
    );
    SetTextJustify(LeftText, CenterText);
    SetColor(Black);
    OutTextXY(0, (height+1) div 2, title);
    SetViewSettings(viewPort);
  end;
end;

procedure TCheckbox.Click;
begin
  checked := not checked;
  if Assigned(onChange)
  then onChange;
  Redraw;
end;

end.