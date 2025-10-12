unit Rect;

interface

type
  PRect = ^TRect;
  TRect = object
    x: integer;
    y: integer;
    width: integer;
    height: integer;

    procedure Assign(x_, y_, width_, height_: integer);
    function ContainsPoint(x_, y_: integer): boolean;
  end;

  TMargins = object
    left: integer;
    top: integer;
    right: integer;
    bottom: integer;
  end;

implementation

procedure TRect.Assign(x_, y_, width_, height_: integer);
begin
  x := x_;
  y := y_;
  width := width_;
  height := height_;
end;

function TRect.ContainsPoint(x_, y_: integer): boolean;
begin
  ContainsPoint := (
    (x_ >= x) and (x_ < x + width) and
    (y_ >= y) and (y_ < y + height)
  );
end;

end.