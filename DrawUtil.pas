unit DrawUtil;

interface
uses Rect;

type
  PDrawPos = ^TDrawPos;
  TDrawPos = object
    x: integer;
    y: integer;

    clipX1: integer;
    clipY1: integer;
    clipX2: integer;
    clipY2: integer;

    procedure ResetToScreen;
    procedure Clip(x_, y_, width, height: integer; var result: TDrawPos);
    procedure ClipRect(const child: TRect; var result: TDrawPos);

    procedure Line(x1, y1, x2, y2: integer);
    procedure Rectangle(x1, y1, x2, y2: integer);
    procedure Bar(x1, y1, x2, y2: integer);
    procedure OutTextXY(tx, ty: integer; text: string);
  end;

procedure WaitForVSync;

implementation
uses Graph, Utils;

procedure TDrawPos.ResetToScreen;
begin
  x := 0;
  y := 0;
  clipX1 := 0;
  clipY1 := 0;
  clipX2 := GetMaxX;
  clipY2 := GetMaxY;
end;

procedure TDrawPos.Clip(x_, y_, width, height: integer; var result: TDrawPos);
var
  clipX1_, clipY1_: integer;
begin
  result.x := x + x_;
  result.y := y + y_;

  { Making a copy for the case if result = self }
  clipX1_ := clipX1;
  clipY1_ := clipY1;

  result.clipX1 := ClipI(result.x, clipX1, clipX2);
  result.clipY1 := ClipI(result.y, clipY1, clipY2);
  result.clipX2 := ClipI(result.x + width, clipX1_, clipX2);
  result.clipY2 := ClipI(result.y + height, clipY1_, clipY2);
end;

procedure TDrawPos.ClipRect(const child: TRect; var result: TDrawPos);
begin
  Clip(child.x, child.y, child.width, child.height, result);
end;

procedure TDrawPos.Line(x1, y1, x2, y2: integer);
begin
  SetViewPort(clipX1, clipY1, clipX2, clipY2, ClipOn);
  Graph.Line(
    x - clipX1 + x1,
    y - clipY1 + y1,
    x - clipX1 + x2,
    y - clipY1 + y2
  );
end;

procedure TDrawPos.Rectangle(x1, y1, x2, y2: integer);
begin
  SetViewPort(clipX1, clipY1, clipX2, clipY2, ClipOn);
  Graph.Rectangle(
    x - clipX1 + x1, 
    y - clipY1 + y1, 
    x - clipX1 + x2, 
    y - clipY1 + y2
  );
end;

procedure TDrawPos.Bar(x1, y1, x2, y2: integer);
begin
  SetViewPort(clipX1, clipY1, clipX2, clipY2, ClipOn);
  Graph.Bar(
    x - clipX1 + x1, 
    y - clipY1 + y1, 
    x - clipX1 + x2, 
    y - clipY1 + y2
  );
end;

procedure TDrawPos.OutTextXY(tx, ty: integer; text: string);
begin
  SetViewPort(clipX1, clipY1, clipX2, clipY2, ClipOn);
  Graph.OutTextXY(
    x - clipX1 + tx,
    y - clipY1 + ty,
    text
  );
end;

procedure WaitForVSync;
begin
  repeat
  until (Port[$3DA] and 8) <> 0;
end;

end.