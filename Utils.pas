unit Utils;

interface

function MaxI(a, b: integer): integer;

implementation

function MaxI(a, b: integer): integer;
begin
  if a > b
  then MaxI := a
  else MaxI := b;
end;

end.