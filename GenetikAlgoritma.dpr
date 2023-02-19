program GenetikAlgoritma;

{$APPTYPE CONSOLE}

{$R *.res}

uses
    System.SysUtils
  , System.Math
  ;

const
  cNesilSayisi    = 10;
  cGenUzunlugu    = 25;
  cMutasyonSayisi = 10;
  cKaliteliGenler : set of char = ['V','W','X','Y','Z'];

type
  TBirey = record
    Genler      : String[cGenUzunlugu];                 //  Alfanümerik harflerden oluşan gen dizisidir. Yani birden çok geni içerdiği için bu aslında bu bir Kromozom'dur.
    KaliteDuzeyi: Integer;                              //  Bu uygunluk değerlendirmesi sonucu ortaya çıkan bir puan. En kaliteli genlere sahip olanı bununla bulacağız.
  end;

var
  Nesiller    : Array [0 .. cNesilSayisi - 1] of TBirey;
  EnIyiBirey  : TBirey;                                 //  Bu aslında uygunluk puanı en yüksek olan bireyi ifade eder.
  Mutant      : TBirey;                                 //  Bu, en iyi bireyin değişime uğramış olan halini ifade eder.
  MelezBirey  : TBirey;                                 //  Bu ise en iyi birey ile mutasyona uğramış olan bireyin birleşmesinden elde edilir.
  I, J, L     : Integer;                                //  İteratörler, döngüler için, her yerde birdaha birdaha tanımlamamak için buraya ekledim.

/// <summary>
///  Bellekte Genlere yer açmak için kullanıyoruz. Bağlamsal açıdan konu ile alakası yok, sadece yardımcı bir metod.
/// </summary>
function BosKromozom: String;
begin
  Result := StringOfChar(' ', cGenUzunlugu);
end;

/// <summary>
///  Kodu kısaltmak adına yardımcı bir metod, konu bağlamı ile alakası yok.
/// </summary>
procedure Print(const aBirey: TBirey; const aString: String = '');
begin
  WriteLn(Format('%s - %d %s', [aBirey.Genler, aBirey.KaliteDuzeyi, aString.Trim]));
end;

/// <summary>
///  Sıradan genler üretir.
/// </summary>
function RandomGen: Char;
begin
  Randomize;
  Result := Chr( RandomRange(Ord('A'), Ord('Z') ) ); // Bu, kaliteli genleri de içeren ana gen havuzudur.
end;

/// <summary>
///  Sadece kaliteli genler üretir.
/// </summary>
function RandomKaliteliGen: Char;
begin
  Randomize;
  Result := Chr( RandomRange(ord('V'), Ord('Z') ) ); // Bunlar tüm genler içindeki en kaliteli olanlardır.
end;

/// <summary>
///  Yeni bir nesil oluşturur.
/// </summary>
procedure PopulasyonuOlustur;
begin
  Randomize;
  for I := 0 to cNesilSayisi - 1 do begin
      Nesiller[I].Genler := BosKromozom; // StringOfChar(' ', cGenUzunlugu);
      for J := 1 to cGenUzunlugu do begin
          Nesiller[I].Genler[J] := AnsiChar(RandomGen);
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
      if aBirey.Genler[J] IN cKaliteliGenler then begin
          aBirey.KaliteDuzeyi := aBirey.KaliteDuzeyi + 1; // bu genleri kaliteli olarak değerlendiriyoruz ve buna göre uygunluk puanını artırıyoruz.
      end;
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
  MaxKalite : Integer;
begin
  MaxKalite := 0;
  for I := 0 to cNesilSayisi - 1 do begin
      if (Nesiller[I].KaliteDuzeyi > MaxKalite) then begin
          MaxKalite   := Nesiller[I].KaliteDuzeyi;
          EnIyiBirey  := Nesiller[I];
      end;
  end;
end;

/// <summary>
///  Burada A ve B adlı iki tane ebeveyni birbiriyle çaprazlayıp genlerini birbirleriyle karıştırıyoruz
///  ve karşımıza çaprazlama sonucu melez bir birey çıkıyor.
///  Bunu yaparken her iki bireyde de en kaliteli genleri ilk önce seçmeyi tercih ediyoruz.
///  Devamında eğer her iki bireyin eşleşen genleri de kaliteli türden değil ise her döngüde bir anneden sonraki döngüde ise bir babadan gen alıyoruz.
///  Bu işlem bizim çaprazlama işlemimiz olmuş oluyor.
/// </summary>
function Caprazla(const aAnne, aBaba: TBirey): TBirey;
var
  DogalSecilim  : Integer;
  Tmp           : TBirey;
begin
  Result.Genler := BosKromozom; // StringOfChar(' ', cGenUzunlugu);
  Result.KaliteDuzeyi := 0;
  for J := 1 to cGenUzunlugu do begin
      if (aAnne.Genler[J] IN cKaliteliGenler) then Result.Genler[J] := aAnne.Genler[J] else // Annenin genleri kaliteli ise onu al
      if (aBaba.Genler[J] IN cKaliteliGenler) then Result.Genler[J] := aBaba.Genler[J] else // Babanın genleri kaliteli ise onu al
      begin
          // İkisi de kaliteli gen değil ise doğa senin adına karar versin.
          DogalSecilim := J Mod 2;
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
  // Kaliteli bir gen ile mutasyon yapıyoruz.
  Randomize;
  K := RandomRange(1, cGenUzunlugu);
  Birey.Genler[K] := AnsiChar(RandomKaliteliGen);

  // Sıradan bir gen ile mutasyon yapıyoruz.
  Randomize;
  K := RandomRange(1, cGenUzunlugu);
  Birey.Genler[K] := AnsiChar(RandomGen);
end;

// Genetik Algoritmamızın işleyişini gösteren ana kısım
begin
  try
    Writeln('Uygunluk Kuralı = "İçinde V,W,X,Y ve Z genlerini barındıran bireylerin kalitesi yüksektir."');

    Writeln('');
    Writeln('Popülasyon;'); // = nesil
    PopulasyonuOlustur;
    for I := 0 to cNesilSayisi - 1 do Print(Nesiller[I], ' ( ' + (I + 1).ToString + ' neslin kromozomu )');

    Writeln('');
    Writeln('Uygunluk Değerlendirmesi;');
    PopulasyonuDegerlendir;
    for I := 0 to cNesilSayisi - 1 do Print(Nesiller[I], ' ( ' + (I + 1).ToString + ' neslin gen bazındaki kalite seviyesi )');

    Writeln('');
    Writeln('En kaliteli birey;');
    EnIyiBireySec;
    Print(EnIyiBirey, '( En iyi bireyin genleri )');

    Writeln('');
    Writeln('Mutasyonlar;');
    Mutant := EnIyiBirey; // bu en iyi bireyden türetilmiş ve birazdan mutasyona uğrayacak olan başka bir birey...
    for L := 1 to cMutasyonSayisi do begin
        Mutasyon(Mutant);
        BireyiDegerlendir(Mutant);
        Print(Mutant, '( ' + L.ToString + '. mutasyon )');
    end;

    Writeln('');
    Writeln('Çaprazlama;');
    MelezBirey := Caprazla(Mutant, EnIyiBirey);
    BireyiDegerlendir(MelezBirey);
    Print(MelezBirey, '( Çaprazlanmış Melez Birey )');

  finally
    Readln;
  end;

end.
