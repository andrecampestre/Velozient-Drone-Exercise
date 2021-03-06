unit View.Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Memo.Types,
  FMX.StdCtrls, FMX.Edit, FMX.ScrollBox, FMX.Memo, FMX.Objects, FMX.Layouts,
  FMX.Controls.Presentation,
  System.Generics.Collections
  ;

type
  TDrone = record
    IdDrone: Integer;
    NameDrone: string;
    MaxWeight: Integer;
  end;

  TLocation = record
    IdLocation: Integer;
    NameLocation: string;
    PackageWeight: Integer;
    Loaded: Boolean;
  end;

  TDelivery = record
    IdDelivery: Integer;
    Drone: TDrone;
    Location: TLocation;
    Trip: Integer;
  end;

  TViewMain = class(TForm)
    pnlBottom: TPanel;
    Layout3: TLayout;
    Text3: TText;
    imgDelivery: TImage;
    mmDelivery: TMemo;
    Layout4: TLayout;
    bt_StartDelivery: TSpeedButton;
    pnlTop: TPanel;
    pnlLeft: TPanel;
    edtDroneNumbers: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    imgDrone: TImage;
    bt_AddDrone: TSpeedButton;
    Layout1: TLayout;
    Text1: TText;
    mmDrone: TMemo;
    pnlRight: TPanel;
    edtLocations: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    imgPackage: TImage;
    bt_AddLocation: TSpeedButton;
    Layout2: TLayout;
    Text2: TText;
    mmLocation: TMemo;
    StyleBook1: TStyleBook;
    procedure bt_AddDroneClick(Sender: TObject);
    procedure bt_AddLocationClick(Sender: TObject);
    procedure bt_StartDeliveryClick(Sender: TObject);
  private
    { Private declarations }
    FDrones: TList<TDrone>;
    FLocations: TList<TLocation>;
    function BuildRandomValues(const AValue1, AValue2 : string) : string;
    function OrderDroneByWeight(ADrones: TList<TDrone>): TList<TDrone>;
    function OrderLocationByWeight(ALocations: TList<TLocation>): TList<TLocation>;
  public
    { Public declarations }
  end;

var
  ViewMain: TViewMain;

const
  FCars =  'Suzuki;Ford;Honda;Hyundai;Jeep;Volkswagen;Mitsubishi;BMW;Mercedes-Benz;Lincoln;Lamborghini;Toyota;Nissan;Maserati;Fiat;Chysler';
  FColors = 'White;Black;Gray;Silver;Aquamarine;Pumpkim;Lime;Red;Blue;Brown;Green;Beige;Gold;Cyan;';

  FNames ='Maraya;Julia;Mary;Alisha;Suzane;Olivia;Shannon;Donna;Rachel;Jessica;Emma;Ava;Charlotte;Sophia;Amelia;Isabella;Mia;Evelyn;Harper;Allyson;Sarah;Meg;Debby';
  FSurNames ='Lake St;Hill St;Mamaroneck Ave;Central Ave;Fleetwood Ave;Second St;Washington St;Third St;First St;Fourth St;Park St;Fifth St;Main St;Sixth St;Oak St;Seventh St;Pine St;Maple St;Grand st;Elm St;View St; Cedar St';

implementation

uses
  Math,
  System.Generics.Defaults, FMX.Dialogs
  ;

{$R *.fmx}

procedure TViewMain.bt_AddDroneClick(Sender: TObject);
var
  I, lWeight: Integer;
  lLine: string;
  lDrone: TDrone;
begin
  FDrones := TList<TDrone>.Create;
  mmDrone.Lines.Clear;
  for I := 1 to StrToInt(edtDroneNumbers.Text) do
  begin
    Randomize;
    lWeight := RandomRange(1, 200);
    lLine := '[Drone #' + I.ToString + ' ' + BuildRandomValues(FColors, FCars) + ' | ' + lWeight.ToString + ' lbs]';
    mmDrone.Lines.Add(lLine);
    lDrone.IdDrone := I;
    lDrone.NameDrone := lLine;
    lDrone.MaxWeight := lWeight;
    FDrones.Add(lDrone);
  end;
end;

procedure TViewMain.bt_AddLocationClick(Sender: TObject);
var
  I, lWeight: Integer;
  lLine: string;
  lLocation: TLocation;
begin
  if Assigned(FLocations) then
    FLocations.DisposeOf;
  FLocations := TList<TLocation>.Create;
  mmLocation.Lines.Clear;
  for I := 1 to StrToInt(edtLocations.Text) do
  begin
    Randomize;
    lWeight := RandomRange(1, 20);
    lLine := '[Location #' + I.ToString + ' ' + BuildRandomValues(FNames, FSurNames) + ' | ' + lWeight.ToString + ' lbs]';
    mmLocation.Lines.Add(lLine);
    lLocation.IdLocation := I;
    lLocation.NameLocation := lLine;
    lLocation.PackageWeight := lWeight;
    lLocation.Loaded := False;
    FLocations.Add(lLocation);
  end;
end;

procedure TViewMain.bt_StartDeliveryClick(Sender: TObject);
var
  lDrones: TList<TDrone>;
  lLocations: TList<TLocation>;
  lDeliveries: TList<TDelivery>;
  lDelivery: TDelivery;
  lLine, lNameDrone, lLastDrone: string;
  I, J, lLoadedItems, lMaxWeight, lTrip, lLastTrip, lTotalLocations: Integer;
begin
  if (mmDrone.Lines.Count = 0) or (mmLocation.Lines.Count = 0) then
    raise Exception.Create('The drones and Locations list must not be empty.');
  lDrones := OrderDroneByWeight(FDrones);
  if FLocations.Count = 0 then
    bt_AddLocationClick(nil);
  lLocations := OrderLocationByWeight(FLocations);
  lDeliveries := TList<TDelivery>.Create;
  I := 0;
  lLoadedItems := 0;
  lTrip := 0;
  lTotalLocations := lLocations.Count;
  while not (lLoadedItems = lTotalLocations) do
  begin
    for I := 0 to lDrones.Count - 1 do
    begin
      lMaxWeight := lDrones[I].MaxWeight;
      for J := lLocations.Count - 1 downto 0 do
      begin
        if lLoadedItems = lTotalLocations then
          break;
        if lMaxWeight >= lLocations[J].PackageWeight then
        begin
          lDelivery.Drone.IdDrone := lDrones[I].IdDrone;
          lDelivery.Drone.NameDrone := lDrones[I].NameDrone;
          lDelivery.Location.IdLocation := lLocations[J].IdLocation;
          lDelivery.Location.NameLocation := lLocations[J].NameLocation;
          lDelivery.Location.PackageWeight := lLocations[J].PackageWeight;
          lDelivery.Location.Loaded := True;
          lDelivery.Trip := lTrip;
          lDeliveries.Add(lDelivery);
          Inc(lLoadedItems);
          lMaxWeight := lMaxWeight - lLocations[J].PackageWeight;
          lLocations.Delete(J);
        end
        else
          continue;
      end;
    end;
    Inc(lTrip);
  end;

  lDeliveries.Sort(
  TComparer<TDelivery>.Construct(
      function(const Left, Right: TDelivery): Integer
      begin
        if Left.Drone.NameDrone = Right.Drone.NameDrone then
        begin
          if Left.Trip = Right.Trip then
          begin
            Result := CompareText(Left.Location.NameLocation, Right.Location.NameLocation);
          end
          else
            Result := CompareValue(Left.Trip, Right.Trip);
        end
        else
          Result := CompareText(Left.Drone.NameDrone, Right.Drone.NameDrone);
      end
    )
  );

  mmDelivery.Lines.Clear;
  lLastDrone := '';
  lLastTrip := -1;
  for I := 0 to lDeliveries.Count - 1 do
  begin
    lNameDrone := lDeliveries[I].Drone.NameDrone;
    lTrip := lDeliveries[I].Trip;
    if lNameDrone <> lLastDrone then
    begin
      if mmDelivery.Lines.Count > 0 then
        mmDelivery.Lines.Add(Chr(13));
      lLine := lDeliveries[I].Drone.NameDrone;
      mmDelivery.Lines.Add(lLine);
      lLastDrone := lDeliveries[I].Drone.NameDrone;
      lLastTrip := -1;
    end;
    if lTrip <> lLastTrip then
    begin
      lLine := 'Trip #' + IntToStr(lDeliveries[I].Trip);
      mmDelivery.Lines.Add(lLine);
      lLastTrip := lDeliveries[I].Trip;
    end;
    lLine := lDeliveries[I].Location.NameLocation;
    mmDelivery.Lines.Add(lLine);
  end;
end;

function TViewMain.BuildRandomValues(const AValue1, AValue2: string): string;
var
  lRandomNumber, lRandomNumber2: Integer;
  lList : TStringList;
begin
  Randomize;
  lRandomNumber := RandomRange(1, 11);
  Randomize;
  lRandomNumber2 := RandomRange(1, 11);
  lList := TStringList.Create;
  try
    ExtractStrings([';'],[' '],PChar(AValue1), lList);
    Result := lList[lRandomNumber];
    lList.Clear;
    ExtractStrings([';'],[' '],PChar(AValue2), lList);
    Result := Result + ', ' + lList[lRandomNumber2];
  finally
    FreeAndNil(lList);
  end;
end;

function TViewMain.OrderDroneByWeight(ADrones: TList<TDrone>): TList<TDrone>;
var
  lDrones: TList<TDrone>;
begin
  lDrones := TList<TDrone>.Create;
  lDrones := ADrones;
  lDrones.Sort(
    TComparer<TDrone>.Construct(
      function(const Left, Right: TDrone): Integer
      begin
        Result := Right.MaxWeight - Left.MaxWeight;
      end
    )
  );
  Result := lDrones;
end;

function TViewMain.OrderLocationByWeight(
  ALocations: TList<TLocation>): TList<TLocation>;
var
  lLocations: TList<TLocation>;
begin
  lLocations := TList<TLocation>.Create;
  lLocations := ALocations;
  lLocations.Sort(
    TComparer<TLocation>.Construct(
      function(const Left, Right: TLocation): Integer
      begin
        Result := Right.PackageWeight - Left.PackageWeight;
      end
    )
  );
  Result := lLocations;
end;

end.
