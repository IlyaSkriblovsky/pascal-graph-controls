unit Parent;

interface
uses Control;

type
  PParent = ^TParent;
  TParent = object(TControl)
    public
      children: TControlIter;

      constructor Create;
      destructor Destroy;

      procedure AddChild(control: PControl);
      procedure RemoveChild(control: PControl);
  end;

implementation
uses Objects;

constructor TParent.Create;
begin
  children.Create;
end;

destructor TParent.Destroy;
begin
  children.Clear(true);
end;

procedure TParent.AddChild(control: PControl);
begin
  children.Add(control);
end;

procedure TParent.RemoveChild(control: PControl);
begin
  children.Remove(control, true);
end;

end.