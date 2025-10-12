unit Window;

interface
uses Control, Rect;

type
  PWindow = ^TWindow;
  TWindow = object(TParent)
    public
      title: string;

      constructor Create(x, y, width, height: integer; title_: string);

      procedure GetMargins(var margins: TMargins); virtual;
      procedure Draw; virtual;
  end;

implementation
uses Graph, Utils, Mouse;

constructor TWindow.Create(x, y, width, height: integer; title_: string);
begin
  TParent.Create;
  rect.Assign(x, y, width, height);
  title := title_;
end;

procedure TWindow.GetMargins(var margins: TMargins);
begin
  margins.left := 3;
  margins.top := 3 + 18;
  margins.right := 3;
  margins.bottom := 3;
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
    SetInnerViewport(viewPort, x+3, y+3, x+width-3, y+3+captionWidth, ClipOn);
    SetTextJustify(LeftText, CenterText);
    OutTextXY(2, captionWidth div 2, title);
    SetViewSettings(viewPort);

    SetFillStyle(SolidFill, LightGray);
    Bar(x+3, y+3+captionWidth, x+width-3, y+height-3);

    SetRelativeViewport(viewPort);
    TParent.Draw;
    SetViewSettings(viewPort);
  end;
end;

end.