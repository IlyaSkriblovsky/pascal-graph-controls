unit Checkbox;

interface
uses Control, Rect, DrawUtil;

type
  PCheckbox = ^TCheckbox;
  TCheckbox = object(TControl)
    public
      checked: boolean;
      title: string;
      onChange: procedure(sender: PCheckbox);

      constructor Create(x, y, width, height: integer; title_: string; checked_: boolean);

      procedure Draw(const drawPos: TDrawPos); virtual;
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

procedure TCheckbox.Draw(const drawPos: TDrawPos);
var
  viewPort: ViewPortType;
  labelPos: TDrawPos;
begin
  SetColor(DarkGray);
  drawPos.Line(0, 0, BOX_SIZE-2, 0);
  drawPos.Line(0, 0, 0, BOX_SIZE-2);

  SetColor(Black);
  drawPos.Line(1, 1, BOX_SIZE-3, 1);
  drawPos.Line(1, 1, 1, BOX_SIZE-3);

  SetColor(LightGray);
  drawPos.Line(BOX_SIZE-2, 0+1, BOX_SIZE-2, BOX_SIZE-2);
  drawPos.Line(1, BOX_SIZE-2, BOX_SIZE-2, BOX_SIZE-2);

  SetColor(White);
  drawPos.Line(BOX_SIZE-1, 0, BOX_SIZE-1, BOX_SIZE-1);
  drawPos.Line(0, BOX_SIZE-1, BOX_SIZE-1, BOX_SIZE-1);

  SetFillStyle(SolidFill, White);
  drawPos.Bar(2, 2, BOX_SIZE - 3, BOX_SIZE - 3);

  if checked
  then begin
    SetColor(Black);
    SetLineStyle(SolidLn, 0, ThickWidth);
    drawPos.Line(3, 6, 5, 8);
    drawPos.Line(5, 8, 9, 4);
    SetLineStyle(SolidLn, 0, NormWidth);
  end;

  drawPos.Clip(BOX_SIZE + GAP, 0, rect.width - (BOX_SIZE + GAP), rect.height, labelPos);
  SetTextJustify(LeftText, CenterText);
  SetColor(Black);
  labelPos.OutTextXY(0, (rect.height+1) div 2, title);
end;

procedure TCheckbox.Click;
begin
  checked := not checked;
  if Assigned(onChange)
  then onChange(@self);
  Redraw;
end;

end.