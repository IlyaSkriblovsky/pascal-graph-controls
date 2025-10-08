unit Mouse;

interface

type
  MouseState = record
    x: integer;
    y: integer;
    left: boolean;
    middle: boolean;
    right: boolean;
  end;

procedure ShowCursor(show: boolean);
procedure GetMouseState(var state: MouseState);

implementation
uses Dos;

procedure ShowCursor(show: boolean);
var
  r: Registers;
begin
  if show
  then r.ax := 1
  else r.ax := 2;
  Intr($33, r);
end;

procedure GetMouseState(var state: MouseState);
var
  r: Registers;
begin
  r.AX := $3;
  Intr($33, r);
  state.x := r.CX;
  state.y := r.DX;
  state.left := (r.BX and 1) <> 0;
  state.middle := (r.BX and 2) <> 0;
  state.right := (r.BX and 4) <> 0;
end;


end.