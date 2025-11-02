unit Window;

interface
uses Control, Rect, Button, DrawUtil;

type
  PWindow = ^TWindow;
  PCloseButton = ^TCloseButton;
  TCloseButton = object(TButton)
    public
      constructor Create(x, y, width, height: integer; window_: PWindow);

      procedure Draw(const drawPos: TDrawPos); virtual;
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
      procedure Draw(const drawPos: TDrawPos); virtual;

      procedure MouseDown(x, y: integer); virtual;

    private
      procedure HandleWindowMove;
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

procedure TCloseButton.Draw(const drawPos: TDrawPos);
var
  crossPos: TDrawPos;
  iconOffset: integer;
begin
  TButton.Draw(drawPos);

  with rect
  do begin
    iconOffset := integer(pressed);
    SetColor(Black);
    drawPos.Clip(3+iconOffset, 3+iconOffset, width-3-iconOffset, height-3-iconOffset, crossPos);
    crossPos.Line(0, 0, width-8, height-7);
    crossPos.Line(1, 0, width-7, height-7);

    crossPos.Line(width-8, 0, 0, height-7);
    crossPos.Line(width-7, 0, 1, height-7);
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
  TParent.Create(x, y, width, height);
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

procedure TWindow.Draw(const drawPos: TDrawPos);
var
  captionDrawPos: TDrawPos;
begin
  with rect
  do begin
    SetColor(LightGray);
    drawPos.Line(0, 0, width-1, 0);
    drawPos.Line(0, 0, 0, height-1);
    SetColor(White);
    drawPos.Line(1, 1, width-2, 1);
    drawPos.Line(1, 1, 1, height-2);

    SetColor(DarkGray);
    drawPos.Line(1, height-1, width-1, height-1);
    drawPos.Line(width-1, 1, width-1, height-1);
    SetColor(Black);
    drawPos.Line(0, height, width, height);
    drawPos.Line(width, 0, width, height);

    SetColor(LightGray);
    drawPos.Rectangle(2, 2, width-2, height-2);

    SetFillStyle(SolidFill, Blue);
    drawPos.Bar(3, 3, width-3, 3+captionWidth);

    SetColor(White);
    drawPos.Clip(3, 3, width-6, captionWidth, captionDrawPos);
    SetTextJustify(LeftText, CenterText);
    captionDrawPos.OutTextXY(4, captionWidth div 2, title);

    SetFillStyle(SolidFill, LightGray);
    drawPos.Bar(3, 3+captionWidth, width-3, height-3);

    TParent.Draw(drawPos);
  end;
end;

procedure TWindow.MouseDown(x, y: integer);
begin
  TParent.MouseDown(x, y);

  if mouseCapture = nil
  then begin
    if (x >= 3) and (x <= rect.width - 3) 
      and (y > 3) and (y < captionWidth+3)
    then begin
      HandleWindowMove;
    end;
  end;
end;

procedure DrawContour(rect: TRect);
begin
  SetWriteMode(XORPut);
  SetColor(White);
  SetLineStyle(UserBitLn, $AAAA, NormWidth);

  with rect
  do begin
    Rectangle(x, y, x+width, y+height);
    Rectangle(x+1, y+1, x+width-1, y+height-1);
    Rectangle(x+2, y+2, x+width-2, y+height-2);
  end;

  SetLineStyle(SolidLn, 0, NormWidth);
  SetWriteMode(CopyPut);
end;


procedure TWindow.HandleWindowMove;
var
  prevMouse, mouse: MouseState;
  offsetX, offsetY: integer;
  parent: PControl;

begin
  SetViewPort(0, 0, GetMaxX, GetMaxY, ClipOff);

  GetMouseState(mouse);
  offsetX := mouse.x - rect.x;
  offsetY := mouse.y - rect.y;

  DrawContour(rect);
  while mouse.left
  do begin
    Move(mouse, prevMouse, SizeOf(mouse));
    GetMouseState(mouse);

    if (mouse.x <> prevMouse.x) or (mouse.y <> prevMouse.y)
    then begin
      ShowCursor(false);
      DrawContour(rect);
      rect.x := mouse.x - offsetX;
      rect.y := mouse.y - offsetY;
      WaitForVSync;
      DrawContour(rect);
      ShowCursor(true);
    end;
  end;

  parent := GetParent;
  if Assigned(parent)
  then parent^.Redraw
  else Redraw;
end;

end.