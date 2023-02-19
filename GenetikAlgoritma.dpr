program GenetikAlgoritma;

{$APPTYPE CONSOLE}

{$R *.res}

uses
    System.SysUtils
  , System.Math
  ;

const
  cNesilSayisi = 10;
  cGenUzunlugu = 25;

type
  TBirey = record
    Genler      : String[cGenUzunlugu];                 //  Alfanümerik harflerden oluşan gen dizisidir. Yani birden çok geni içerdiği için aslında bu bir Kromozom'dur.
    KaliteDuzeyi: Integer;                              //  Bu uygunluk değerlendirmesi sonucu ortaya çıkan bir puan. En kaliteli genlere sahip olanı bununla bulacağız.
  end;

var
  Nesiller    : Array [0 .. cNesilSayisi - 1] of TBirey;
  EnIyiBirey  : TBirey;                                 //  Bu aslında uygunluk puanı en yüksek olan bireyi ifade eder.
  Mutant      : TBirey;                                 //  Bu, en iyi bireyin değişime uğramış olan halini ifade eder.
  MelezBirey  : TBirey;                                 //  Bu ise en iyi birey ile mutasyona uğramış olan bireyin birleşmesinden elde edilir.
  I, J, L     : Integer;                                //  İteratörler, döngüler için, her yerde birdaha birdaha tanımlamamak için buraya ekledim.

/// <summary>
///  Sıradan genler üretir.
/// </summary>
function RandomGen: Char;
begin
  Randomize;
  Result := Chr( RandomRange(Ord('A'), Ord('Z') ) );
end;

/// <summary>
///  Kaliteli genler üretir.
/// </summary>
function RandomKaliteliGen: Char;
begin
  Randomize;
  Result := Chr( RandomRange(ord('Q'), Ord('Z') ) );
end;

/// <summary>
///  Yeni bir nesil oluşturur.
/// </summary>
procedure PopulasyonuOlustur;
begin
  Randomize;
  for I := 0 to cNesilSayisi - 1 do begin
      Nesiller[I].Genler := '';
      for J := 0 to cGenUzunlugu - 1 do begin
          Nesiller[I].Genler := Nesiller[I].Genler + RandomGen; // Sadece harfleri içerir.
      end;
  end;
end;

/// <summary>
///  Tek bir bireyin Genlerinin kalitesini ölçer.
/// </summary>
procedure BireyiDegerlendir(var aBirey: TBirey);
begin
  aBirey.KaliteDuzeyi := 0;
  for J := 1 to cGenUzunlugu do begin
      if aBirey.Genler[J] IN ['Q','W','X','Y','Z'] then Inc(aBirey.KaliteDuzeyi); // bu genleri kaliteli olarak değerlendiriyoruz ve buna göre uygunluk puanını artırıyoruz.
  end;
end;

/// <summary>
///  Tüm nesillerin Genlerinin kalitesini ölçer.
/// </summary>
procedure PopulasyonuDegerlendir;
begin
  for I := 0 to cNesilSayisi - 1 do
      BireyiDegerlendir( Nesiller[I] );
end;

/// <summary>
///  Popülasyondaki en kaliteli gene sahip olan ilk bireyi seçer.
/// </summary>
procedure EnIyiBireySec;
var
  EnIyiUygunluk : Integer;
begin
  EnIyiUygunluk := 0;
  for I := 0 to cNesilSayisi - 1 do begin
      if (Nesiller[I].KaliteDuzeyi > EnIyiUygunluk) then begin
          EnIyiUygunluk := Nesiller[I].KaliteDuzeyi;
          EnIyiBirey    := Nesiller[I];
      end;
  end;
end;

/// <summary>
///  Burada A ve B adlı iki tane ebeveyni birbiriyle çaprazlayıp genlerini birbirleriyle karıştırıyoruz
///  ve karşımıza çaprazlama sonucu melez bir birey çıkıyor.
/// </summary>
function Caprazla(const aAnne, aBaba: TBirey): TBirey;
var
  DogalSecilim  : Integer;
  Tmp           : TBirey;
begin
  //Result := aAnne;
  Result.Genler := StringOfChar(' ', cGenUzunlugu);
  Result.KaliteDuzeyi := 0;
  for J := 1 to cGenUzunlugu do begin
      // Annenin genleri kaliteli ise onu al
      if (aAnne.Genler[J] IN ['Q','W','X','Y','Z']) then Result.Genler[J] := aAnne.Genler[J] else
      // Babanın genleri kaliteli ise onu al
      if (aBaba.Genler[J] IN ['Q','W','X','Y','Z']) then Result.Genler[J] := aBaba.Genler[J] else
      begin
          // İkisi de kaliteli gen değil ise doğa senin adına karar versin.
          //Randomize;
          DogalSecilim := J Mod 2;// RandomRange(0, 1);
          case DogalSecilim of
            0: Result.Genler[J] := aAnne.Genler[J];
            1: Result.Genler[J] := aBaba.Genler[J];
          end;
      end;
  end;
end;

/// <summary>
///  Kromozomun tamamında rastgele 2 adet geni değişime uğratmak için kullanıyoruz.
/// </summary>
procedure Mutasyon(var Birey: TBirey);
var
  K, Z: Integer;
  Gen: Char;
begin
  Randomize;
  // Kaliteli bir gen ile mutasyon yapıyoruz.
  K := RandomRange(1, cGenUzunlugu);
  Birey.Genler[K] := AnsiChar(RandomKaliteliGen);

  // Sıradan bir gen ile mutasyon yapıyoruz.
  K := RandomRange(1, cGenUzunlugu);
  Birey.Genler[K] := AnsiChar(RandomKaliteliGen); // veya (RandomGen);
end;

begin
  try
    Writeln('Uygunluk Kuralı = "İçinde q,w,x,y genleri barındıran bireylerin kalitesi yüksektir."');

    Writeln('Popülasyon;'); // = nesil
    PopulasyonuOlustur;
    for I := 0 to cNesilSayisi - 1 do Writeln(Nesiller[I].Genler + ' - ' + Nesiller[I].KaliteDuzeyi.ToString);

    PopulasyonuDegerlendir;
    Writeln('');
    Writeln('Uygunluk Değerlendirmesi;');
    for I := 0 to cNesilSayisi - 1 do Writeln(Nesiller[I].Genler + ' - ' + Nesiller[I].KaliteDuzeyi.ToString);

    EnIyiBireySec;
    Writeln('');
    Writeln('En iyi bireyin genleri: ');
    Writeln(EnIyiBirey.Genler + ' - ' + EnIyiBirey.KaliteDuzeyi.ToString);

    Mutant := EnIyiBirey; // bu en iyi bireyden türetilmiş ve birazdan mutasyona uğrayacak olan başka bir birey...

    Writeln('');
    Writeln('En iyi bireyi Mutasyona uğratıyoruz. Kromozomun Mutasyonlu halinde (sadece bir ~ iki) genin farklı olduğunu görmelisin) ');
    for L := 1 to 3 do begin
        Mutasyon(Mutant);
        BireyiDegerlendir(Mutant);
        Writeln(Mutant.Genler + ' - ' + Mutant.KaliteDuzeyi.ToString + ' ( ' + L.ToString + '. mutasyon )');
    end;

    Writeln('');
    Writeln('Mutant ile En iyi bireyi çaprazlıyoruz ve bu sayede en kaliteli genler her iki bireyde de baskın hale geliyor.');

    MelezBirey := Caprazla(Mutant, EnIyiBirey);

    BireyiDegerlendir(MelezBirey);
    Writeln(MelezBirey.Genler + ' - ' + MelezBirey.KaliteDuzeyi.ToString + ' ( Çaprazlanmış Melez Birey )');

  finally
    Readln;
  end;

end.
