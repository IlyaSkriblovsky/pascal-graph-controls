unit Window;

interface
uses Control, Rect, Parent;

type
  PWindow = ^TWindow;
  TWindow = object(TParent)
    public
      title: string;

      constructor Create(rect_: TRect; title_: string);

      procedure Draw; virtual;
  end;

implementation
uses Graph, Utils, Mouse;

constructor TWindow.Create(rect_: TRect; title_: string);
begin
  TParent.Create;
  rect := rect_;
  title := title_;
end;

procedure DrawChild(control: PControl); far;
begin
  control^.Draw;
end;

procedure TWindow.Draw;
const
  captionWidth = 18;

var
  viewPort: ViewPortType;

begin
  with rect do begin
    SetColor(LightGray);
    Line(x, y, x+width-1, y);
    Line(x, y, x, y+height-1);
    SetColor(White);
    Line(x+1, y+1, x+width-2, y+1);
    Line(x+1, y+1, x+1, y+height-2);

    SetColor(DarkGray);
    Line(x+1, y+height-1, x+width-1, y+height-1);
    Line(x+width-1, y+1, x+width-1, y+height-1);
    SetColor(Black);
    Line(x, y+height, x+width, y+height);
    Line(x+width, y, x+width, y+height);

    SetColor(LightGray);
    Rectangle(x+2, y+2, x+width-2, y+height-2);

    SetFillStyle(SolidFill, Blue);
    Bar(x+3, y+3, x+width-3, y+3+captionWidth);

    SetColor(White);
    SetViewPort(x+3, y+3, x+width-3, y+3+captionWidth, ClipOn);
    SetTextJustify(LeftText, CenterText);
    OutTextXY(2, captionWidth div 2, title);
    SetViewPort(0, 0, GetMaxX, GetMaxY, ClipOff);

    SetFillStyle(SolidFill, LightGray);
    Bar(x+3, y+3+captionWidth, x+width-3, y+height-3);

    SetInnerViewport(viewPort, x+3, y+3+captionWidth, x+width-3, y+height-3, ClipOn);
    children.ForEach(DrawChild);
    SetViewSettings(viewPort);
  end;
end;

end.