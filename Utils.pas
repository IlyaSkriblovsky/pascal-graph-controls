unit Utils;

interface

function MinI(a, b: integer): integer;
function MaxI(a, b: integer): integer;
function ClipI(value, minValue, maxValue: integer): integer;

implementation

function MinI(a, b: integer): integer;
begin
  if a < b
  then MinI := a
  else MinI := b;
end;

function MaxI(a, b: integer): integer;
begin
  if a > b
  then MaxI := a
  else MaxI := b;
end;

function ClipI(value, minValue, maxValue: integer): integer;
begin
  if value < minValue
  then ClipI := minValue
  else if value > maxValue
       then ClipI := maxValue
       else ClipI := value;
end;

end.