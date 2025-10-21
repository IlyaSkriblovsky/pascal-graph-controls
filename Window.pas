unit Window;

interface
uses Control, Rect, Button;

type
  PWindow = ^TWindow;
  PCloseButton = ^TCloseButton;
  TCloseButton = object(TButton)
    public
      constructor Create(x, y, width, height: integer; window_: PWindow);

      procedure Draw; virtual;
      procedure Click; virtual;

    private
      window: PWindow;
  end;
  
  TWindow = object(TParent)
    public
      title: string;
      onClose: procedure(window: PWindow);

      constructor Create(x, y, width, height: integer; title_: string);

      procedure GetMargins(var margins: TMargins); virtual;
      procedure Draw; virtual;

      procedure MouseDown(x, y: integer); virtual;
  end;

implementation
uses Graph, Utils, Mouse;

const
  captionWidth = 18;
  closeWidth = 14;
  closeHeight = 13;


{ CLOSE BUTTON }

constructor TCloseButton.Create(x, y, width, height: integer; window_: PWindow);
begin
  TButton.Create(x, y, width, height, '');
  window := window_;
  SetParent(window_);
  SetObeysParentMargins(false);
end;

procedure TCloseButton.Draw;
var
  viewPort: ViewPortType;
  iconOffset: integer;
begin
  TButton.Draw;
  with rect do begin
    iconOffset := integer(pressed);

    SetColor(Black);
    SetInnerViewport(viewPort, x+3+iconOffset, y+3+iconOffset, x+width, y+height, ClipOn);
    Line(0, 0, width-8, height-7);
    Line(1, 0, width-7, height-7);

    Line(width-8, 0, 0, height-7);
    Line(width-7, 0, 1, height-7);
    SetViewSettings(viewPort);
  end;
end;

procedure TCloseButton.Click;
begin
  if Assigned(window^.onClose)
  then window^.onClose(window);
end;

{ WINDOW }

constructor TWindow.Create(x, y, width, height: integer; title_: string);
begin
  TParent.Create;
  rect.Assign(x, y, width, height);
  title := title_;

  onClose := nil;

  AddChild(New(PCloseButton, Create(width-closeWidth-4, 5, closeWidth, closeHeight, @self)));
end;

procedure TWindow.GetMargins(var margins: TMargins);
begin
  margins.left := 3;
  margins.top := 3 + captionWidth;
  margins.right := 3;
  margins.bottom := 3;
end;

procedure TWindow.Draw;
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
    OutTextXY(4, captionWidth div 2, title);
    SetViewSettings(viewPort);

    SetFillStyle(SolidFill, LightGray);
    Bar(x+3, y+3+captionWidth, x+width-3, y+height-3);

    TParent.Draw;

    GetViewSettings(viewPort);
  end;
end;

procedure TWindow.MouseDown(x, y: integer);
begin
  TParent.MouseDown(x, y);
end;

end.