unit effects;

{$mode objfpc}{$H+}

interface
uses
  Classes, SysUtils, Graphics, math;

procedure Image2Bitmap(var src:TBitmap);
procedure EffectLight(var source :TBitmap;value: integer);
procedure EffectContrast(var source :TBitmap;value: integer);
procedure EffectGamma(var source :TBitmap;value: double);
procedure EffectToneCurve(var source :TBitmap;LookUpTable : array of Byte);
procedure EffectNoise(var source :TBitmap;value: Byte);
procedure EffectMedian_Max(var source :TBitmap);
procedure EffectMedian_Mid(var source :TBitmap);
procedure EffectMedian_Min(var source :TBitmap);
procedure EffectHistogramEqualize(var source :TBitmap);
procedure EffectCustom(var source :TBitmap;maskbits:array of Smallint;divisor,addition:Byte);

procedure EffectCustom_Blur(var bmp :TBitmap);
procedure EffectCustom_Sharp(var bmp :TBitmap);

// [LookUpTable]
// Contrast improvement (コントラスト改善)
const LUT_1 : array [0..255] of Byte =(0,1,1,2,2,3,3,3,4,4,5,5,5,6,6,7,7,7,8,8,9,9,9,10,10,11,11,11,12,12,13,13,13,14,14,15,15,15,16,16,17,17,18,19,20,20,21,22,23,24,24,25,26,27,28,28,29,30,31,32,33,33,34,35,36,37,37,38,39,40,41,41,42,43,44,45,45,46,47,48,49,50,51,53,54,55,56,57,58,59,60,62,63,64,65,66,67,68,70,71,72,73,74,75,76,77,79,80,81,82,83,85,88,91,93,95,98,101,103,105,108,111,113,115,118,121,123,125,128,129,132,136,139,142,145,149,152,155,159,162,165,168,172,175,176,177,178,180,181,182,183,184,186,187,188,189,191,192,193,194,195,197,198,199,200,201,203,204,205,206,208,209,210,211,212,212,213,213,214,215,215,216,216,217,218,218,219,219,220,221,221,222,222,223,224,224,225,225,226,227,227,228,228,229,230,230,231,231,232,233,233,234,234,235,236,236,237,237,238,238,239,239,240,240,241,241,242,242,242,243,243,244,244,245,245,246,246,247,247,248,248,249,249,249,250,250,251,251,252,252,253,253,254,254,255,255);
// Emphasize brightness (明るさを強調)
const LUT_2 : array [0..255] of Byte =(0,1,3,5,6,8,10,12,14,16,17,19,21,23,25,26,28,30,32,34,36,37,39,41,43,45,47,48,50,52,54,56,57,59,61,63,65,67,68,70,72,73,74,76,77,79,80,81,83,84,85,87,88,90,91,92,94,95,97,98,99,101,102,103,105,106,108,109,110,112,113,114,116,117,119,120,121,123,124,126,127,128,130,131,132,134,135,137,138,139,141,142,144,145,146,148,149,150,152,153,155,156,157,158,159,159,160,161,162,162,163,164,165,165,166,167,168,168,169,170,171,171,172,173,174,174,175,176,177,177,178,179,180,180,181,182,183,183,184,185,186,186,187,188,189,189,190,191,192,192,193,194,195,195,196,197,198,198,199,200,201,201,202,203,204,204,205,206,207,207,208,209,210,210,211,212,213,214,214,215,215,216,216,217,217,218,218,219,219,220,220,221,222,222,223,223,224,224,225,225,226,226,227,227,228,228,229,229,230,231,231,232,232,233,233,234,234,235,235,236,236,237,237,238,239,239,240,240,241,241,242,242,243,243,244,244,245,245,246,246,247,248,248,249,249,250,250,251,251,252,252,253,253,254,254,255);
// Emphasize darkness (暗さを強調)
const LUT_3 : array [0..255] of Byte =(0,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,10,10,11,11,12,12,13,13,14,14,15,15,16,16,17,17,18,19,19,20,20,21,21,22,22,23,23,24,24,25,25,26,27,27,28,28,29,29,30,30,31,31,32,32,33,33,34,34,35,36,36,37,37,38,38,39,39,40,40,41,41,42,42,43,44,45,46,46,47,48,49,50,51,51,52,53,54,55,55,56,57,58,59,60,60,61,62,63,64,64,65,66,67,68,69,69,70,71,72,73,73,74,75,76,77,78,78,79,80,81,82,83,83,84,85,86,87,87,88,89,90,91,92,92,93,94,95,96,96,97,98,99,100,101,101,102,103,104,105,107,108,110,111,112,114,115,117,118,119,121,122,124,125,126,128,129,131,132,133,135,136,138,139,140,142,143,145,146,147,149,150,152,153,154,156,157,159,160,161,163,164,166,167,168,170,171,173,174,175,177,178,180,181,182,184,185,187,188,190,192,193,195,197,198,200,201,203,205,206,208,210,211,213,214,216,218,219,221,223,224,226,227,229,231,232,234,236,237,239,240,242,244,245,247,249,250,252,253,255);

type
  tagRGBTRIPLE = packed record
    rgbtBlue: Byte;
    rgbtGreen: Byte;
    rgbtRed: Byte;
  end;
  TRGBTriple = tagRGBTRIPLE;

type
  pRGBarray  = ^TRGBarray;
  TRGBarray  = array[0..0] of TRGBTriple;

type
  PPBits = ^TPBits;
  TPBits = array[0..0] of pRGBarray;

implementation

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

// Convert JPEG / PNG / GIF to BMP format
// If you do not do this, the image will be distorted by RawImage.Data or Scanline
//
// JPEG/PNG/GIFなどを内部的にBMP形式に変換する
// これを行わないとRawImage.DataやScanlineで画像が乱れる
procedure Image2Bitmap(var src:TBitmap);
var
   bmp : TBitmap;
begin
   bmp := TBitmap.create;
   try
     bmp.PixelFormat:= pf24bit;
     bmp.Width  := src.width;
     bmp.height := src.height;
     bmp.Canvas.Brush.Color:= clWhite;
     bmp.Canvas.FillRect(0,0,src.width,src.height);
     bmp.Canvas.StretchDraw(Rect(0,0,src.width,src.height),src);
     src.Assign(bmp);
   finally
     bmp.free;
   end;
end;

function Set255(value :Integer) : Byte;
begin
  if value>255 then
  begin
    Result := 255;
    exit;
    end
  else if value < 0 then
  begin
    Result := 0;
    exit;
  end;
  Result := Byte(value);
end;

function MyRandom(max:Byte;min:Byte): Byte;
begin
  result := trunc(((Random(999)/1000) * ((max + 1) - min)) + min);
end;

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

// value -255-255 (default:0)
procedure EffectLight(var source :TBitmap;value: integer);
var
  x,y: integer;
  dest : Tbitmap;
  SrcRow,DestRow : pRGBArray;
begin
  dest := TBitmap.create;

  dest.PixelFormat:= pf24bit;
  dest.Width:= source.width;
  dest.height:= source.height;

  try
    for y := 0 to dest.height-1 do
    begin
      SrcRow  := source.ScanLine[y];
      DestRow := dest.ScanLine[y];
      for x := 0 to dest.width-1 do
      begin
        DestRow^[x].rgbtBlue := set255(SrcRow^[x].rgbtBlue + value);
        DestRow^[x].rgbtGreen:= set255(SrcRow^[x].rgbtGreen + value);
        DestRow^[x].rgbtRed  := set255(SrcRow^[x].rgbtRed + value);
      end;
    end;
    source.Assign(dest);
  finally
    dest.free;
  end;
end;


// value -255-255  (default:0)
procedure EffectContrast(var source :TBitmap;value: integer);
var
  i,x,y: integer;
  dest : Tbitmap;
  LUT : array [0 ..255] of byte;
  SrcRow,DestRow : pRGBArray;
begin
  dest := TBitmap.create;
  dest.PixelFormat:= pf24bit;
  dest.Width:= source.width;
  dest.height:= source.height;

  for i:=0 to 255 do
  begin
    LUT[i] := set255(round((1+(value/255))*(i-128)+128));
  end;

  try
    for y := 0 to dest.height-1 do
    begin
      SrcRow  := source.ScanLine[y];
      DestRow := dest.ScanLine[y];
      for x := 0 to dest.width-1 do
      begin
        DestRow^[x].rgbtBlue := LUT[SrcRow^[x].rgbtBlue];
        DestRow^[x].rgbtGreen:= LUT[SrcRow^[x].rgbtGreen];
        DestRow^[x].rgbtRed  := LUT[SrcRow^[x].rgbtRed];
      end;
    end;
    source.Assign(dest);
  finally
    dest.free;
  end;
end;

// value 0.01-2.0  (default:1.0)
procedure EffectGamma(var source :TBitmap;value: double);
var
  i,x,y: integer;
  dest : Tbitmap;
  LUT : array [0 ..255] of byte;
  SrcRow,DestRow : pRGBArray;
begin
  dest := TBitmap.create;
  dest.PixelFormat:= pf24bit;
  dest.Width:= source.width;
  dest.height:= source.height;

  for i:=0 to 255 do
  begin
    LUT[i] := set255(round(power(i / 255.0, 1.0 / value) * 255));
  end;

  try
    for y := 0 to dest.height-1 do
    begin
      SrcRow  := source.ScanLine[y];
      DestRow := dest.ScanLine[y];
      for x := 0 to dest.width-1 do
      begin
        DestRow^[x].rgbtBlue := LUT[SrcRow^[x].rgbtBlue];
        DestRow^[x].rgbtGreen:= LUT[SrcRow^[x].rgbtGreen];
        DestRow^[x].rgbtRed  := LUT[SrcRow^[x].rgbtRed];
      end;
    end;
    source.Assign(dest);
  finally
    dest.free;
  end;
end;

procedure EffectToneCurve(var source :TBitmap;LookUpTable : array of Byte);
var
  x,y : integer;
  dest : Tbitmap;
  SrcRow,DestRow : pRGBArray;
begin
  dest := TBitmap.create;
  dest.PixelFormat:= pf24bit;
  dest.Width:= source.width;
  dest.height:= source.height;

  try
    for y := 0 to dest.height-1 do
    begin
      SrcRow  := source.ScanLine[y];
      DestRow := dest.ScanLine[y];
      for x := 0 to dest.width-1 do
      begin
        DestRow^[x].rgbtBlue := LookUpTable[SrcRow^[x].rgbtBlue];
        DestRow^[x].rgbtGreen:= LookUpTable[SrcRow^[x].rgbtGreen];
        DestRow^[x].rgbtRed  := LookUpTable[SrcRow^[x].rgbtRed];
      end;
    end;
    source.Assign(dest);
  finally
    dest.free;
  end;
end;

// value 0-255
procedure EffectNoise(var source :TBitmap;value: Byte);
var
  x,y : integer;
  rnd :byte;
  dest : Tbitmap;
  SrcRow,DestRow : pRGBArray;
begin
  dest := TBitmap.create;
  dest.PixelFormat:= pf24bit;
  dest.Width:= source.width;
  dest.height:= source.height;

  try
    for y := 0 to dest.height-1 do
    begin
      SrcRow  := source.ScanLine[y];
      DestRow := dest.ScanLine[y];
      for x := 0 to dest.width-1 do
      begin
        rnd := Random(value);

        DestRow^[x].rgbtBlue := set255(SrcRow^[x].rgbtBlue + rnd);
        DestRow^[x].rgbtGreen:= set255(SrcRow^[x].rgbtGreen + rnd);
        DestRow^[x].rgbtRed  := set255(SrcRow^[x].rgbtRed + rnd);
      end;
    end;
    source.Assign(dest);
  finally
    dest.free;
  end;
end;

procedure EffectMedian_Max(var source :TBitmap);
var
  x,y,row,col,tx,ty: Integer;
  DestRow : pRGBArray;
  dest : TBitmap;
  SourceRows : PPBits ;
  rMax,gMax,bMax : Byte;
begin
  dest := TBitmap.create;
  dest.PixelFormat:= pf24bit;
  dest.Width:= source.width;
  dest.height:= source.height;

  GetMem(SourceRows, source.Height * SizeOf(pRGBArray));
  try
    for y := 0 to source.Height - 1 do  SourceRows^[y] := source.Scanline[y];

    for y := 0 To source.Height-1 do
    begin
         DestRow := dest.ScanLine[y];
         for x := 0 To source.Width-1 do
         begin
             rMax:=0; gMax:=0; bMax:=0;
             for ty:= -1 to 1 do
             begin
               for tx:= -1 to 1 do
               begin
                  // Y軸
                  if  (y+ ty ) > source.Height-1 then  row:=source.Height-1
                  else if y+(ty)< 0              then  row:=0
                  else                                 row:=y+(ty);
                   // X軸
                  if      x+(tx)> source.Width-1 then  col:=source.Width-1
                  else if x+(tx)< 0              then  col:=0
                  else                                 col:=x+(tx);

                  //  着目するピクセルで一番大きい濃度値を取得
                  if SourceRows^[row]^[col].rgbtBlue > bMax then
                    bMax := SourceRows^[row]^[col].rgbtBlue;

                  if SourceRows^[row]^[col].rgbtGreen > gMax then
                    gMax := SourceRows^[row]^[col].rgbtGreen;

                  if SourceRows^[row]^[col].rgbtRed > rMax then
                    rMax := SourceRows^[row]^[col].rgbtRed;
               end;
            end;
            DestRow^[x].rgbtRed   := rMax;
            DestRow^[x].rgbtGreen := gMax;
            DestRow^[x].rgbtBlue  := bMax;
         end;
    end;
    source.Assign(dest);
  finally
     FreeMem(SourceRows); SourceRows:=nil;
     dest.free;
  end;
end;

procedure EffectMedian_Mid(var source :TBitmap);
var
  x,y,row,col,tx,ty: Integer;
  DestRow : pRGBArray;
  dest : TBitmap;
  SourceRows : PPBits ;
  R,G,B : array [0..8] of Byte;
  i,j : Dword;
  wrk : Byte;
begin
  dest := TBitmap.create;
  dest.PixelFormat:= pf24bit;
  dest.Width:= source.width;
  dest.height:= source.height;

  GetMem(SourceRows, source.Height * SizeOf(pRGBArray));
  try
    for y := 0 to source.Height - 1 do  SourceRows^[y] := source.Scanline[y];

    for y := 0 To source.Height-1 do
    begin
         DestRow := dest.ScanLine[y];
         for x := 0 To source.Width-1 do
         begin
             i:=0;
             for ty:= -1 to 1 do
             begin
               for tx:= -1 to 1 do
               begin
                  // Y軸
                  if  (y+ ty ) > source.Height-1 then  row:=source.Height-1
                  else if y+(ty)< 0              then  row:=0
                  else                                 row:=y+(ty);
                   // X軸
                  if      x+(tx)> source.Width-1 then  col:=source.Width-1
                  else if x+(tx)< 0              then  col:=0
                  else                                 col:=x+(tx);

                  B[i]:=SourceRows^[row]^[col].rgbtBlue;
                  G[i]:=SourceRows^[row]^[col].rgbtGreen;
                  R[i]:=SourceRows^[row]^[col].rgbtRed;
                  inc(i);
               end;
            end;

            // sort
            for i := 9 -1 downto 0 do
            begin
               for j := 1 to i do
               begin
                 if R[j-1] > R[j] then
                 begin
                   wrk    := R[j];
                   R[j]   := R[j-1];
                   R[j-1] := wrk;
                 end;

                 if G[j-1] >G[j] then
                 begin
                   wrk    := G[j];
                   G[j]   := G[j-1];
                   G[j-1] := wrk;
                 end;

                 if B[j-1] >B[j] then
                 begin
                   wrk    := B[j];
                   B[j]   := B[j-1];
                   B[j-1] := wrk;
                 end;
               end;
             end;

             //  着目するピクセルの中間濃度値を取得
             DestRow^[x].rgbtRed   := R[4];
             DestRow^[x].rgbtGreen := G[4];
             DestRow^[x].rgbtBlue  := B[4];
         end;
    end;
    source.Assign(dest);
  finally
     FreeMem(SourceRows); SourceRows:=nil;
     dest.free;
  end;
end;

procedure EffectMedian_Min(var source :TBitmap);
var
  x,y,row,col,tx,ty: Integer;
  DestRow : pRGBArray;
  dest : TBitmap;
  SourceRows : PPBits ;
  rMin,gMin,bMin : Byte;
begin
  dest := TBitmap.create;
  dest.PixelFormat:= pf24bit;
  dest.Width:= source.width;
  dest.height:= source.height;

  GetMem(SourceRows, source.Height * SizeOf(pRGBArray));
  try
    for y := 0 to source.Height - 1 do  SourceRows^[y] := source.Scanline[y];

    for y := 0 To source.Height-1 do
    begin
         DestRow := dest.ScanLine[y];
         for x := 0 To source.Width-1 do
         begin
             rMin:=255; gMin:=255; bMin:=255;
             for ty:= -1 to 1 do
             begin
               for tx:= -1 to 1 do
               begin
                  // Y軸
                  if  (y+ ty ) > source.Height-1 then  row:=source.Height-1
                  else if y+(ty)< 0              then  row:=0
                  else                                 row:=y+(ty);
                   // X軸
                  if      x+(tx)> source.Width-1 then  col:=source.Width-1
                  else if x+(tx)< 0              then  col:=0
                  else                                 col:=x+(tx);

                  // 着目するピクセルで一番小さい濃度値を取得
                  if SourceRows^[row]^[col].rgbtBlue < bMin then
                    bMin := SourceRows^[row]^[col].rgbtBlue;

                  if SourceRows^[row]^[col].rgbtGreen < gMin then
                    gMin := SourceRows^[row]^[col].rgbtGreen;

                  if SourceRows^[row]^[col].rgbtRed < rMin then
                    rMin := SourceRows^[row]^[col].rgbtRed;
               end;
            end;
            DestRow^[x].rgbtRed   := rMin;
            DestRow^[x].rgbtGreen := gMin;
            DestRow^[x].rgbtBlue  := bMin;
         end;
    end;
    source.Assign(dest);
  finally
     FreeMem(SourceRows); SourceRows:=nil;
     dest.free;
  end;
end;

procedure EffectHistogramEqualize(var source :TBitmap);
var
  i,x,y : Integer;
  dest : TBitmap;
  SrcRow,DestRow : pRGBArray;
  RGB_Count : array [0..255] of Dword;
  R_Table : array[0..255] of Byte;
  G_Table : array[0..255] of Byte;
  B_Table : array[0..255] of Byte;
  j,n,HistTotal : Dword;
begin
  dest := TBitmap.create;
  dest.PixelFormat:= pf24bit;
  dest.Width:= source.width;
  dest.height:= source.height;

  fillchar(RGB_Count, sizeof(RGB_Count),0);

  n := ((source.Width * source.Height) div 256) + 1;
  try
    for y := 0 to source.Height - 1 do
    begin
      SrcRow  := source.Scanline[y];
      for x := 0 to source.Width - 1 do
          Inc(RGB_count[( SrcRow^[x].rgbtBlue  +
                          SrcRow^[x].rgbtgreen+
                          SrcRow^[x].rgbtRed  ) div 3]);
    end;

    HistTotal :=0; j :=0;
    for i := 0 to 255 do
    begin
      HistTotal := HistTotal + RGB_count[i];
      j         := j+(HistTotal div n);
      HistTotal := HistTotal mod n ;
      R_Table[i]:= j;
    end;

    HistTotal :=0;  j:=0;
    for i := 0 to 255 do
    begin
      HistTotal  := HistTotal + RGB_count[i];
      j          := j+(HistTotal div n);
      HistTotal  := HistTotal mod n;
      G_Table[i] := j;
    end;

    HistTotal :=0; j :=0;
    for i := 0 to 255 do
    begin
      HistTotal  := HistTotal +RGB_count[i];
      j          := j+(HistTotal div n);
      HistTotal  := HistTotal mod n;
      B_Table[i] := j;
    end;

    for y := 0 to source.Height - 1 do
    begin
      SrcRow  := source.Scanline[y];
      DestRow := dest.Scanline[y];
      for x := 0 to source.Width - 1 do
      begin
         DestRow^[x].rgbtBlue  := R_Table[SrcRow^[x].rgbtBlue];
         DestRow^[x].rgbtGreen := G_Table[SrcRow^[x].rgbtGreen];
         DestRow^[x].rgbtRed   := B_Table[SrcRow^[x].rgbtRed];
      end;
    end;

    source.Assign(dest);
  finally
     dest.free;
  end;
end;

// 5x5
procedure EffectCustom(var source :TBitmap;maskbits:array of Smallint;divisor,addition:Byte);
var
  dest : TBitmap;
  SourceRows : PPBits;
  DestRow    : pRGBArray;
  height,width  : Integer;
  row,col,r,g,b,x,y,tx,ty,iMask: Integer;
begin

  dest := TBitmap.Create;
  dest.PixelFormat:= pf24bit;
  dest.Width := source.width;
  dest.height := source.height;
  width := source.width -1;
  height := source.height -1;

  GetMem(SourceRows, source.Height * SizeOf(pRGBArray));
  try
    for y:= 0 to source.Height - 1 do
      SourceRows^[y] := source.Scanline[y];

    for y := 0 To height do
    begin
      DestRow:= dest.ScanLine[y];
      for x := 0 To width do
      begin
        // 5x5
        r:=0; g:=0; b:=0; iMask:=0;
        for ty:= -2 to 2 do
        begin
          for tx:= -2 to 2 do
          begin

            // Y軸
            if y+(ty) > height then row:= height
            else if y+(ty) < 0 then row:= 0
            else                    row:= y+(ty);

            // X軸
            if x+(tx) > width then  col:= width
            else if x+(tx)< 0 then  col:= 0
            else                    col:= x+(tx);

            r := r + (SourceRows^[row]^[col].rgbtRed   * MaskBits[iMask]);
            g := g + (SourceRows^[row]^[col].rgbtGreen * MaskBits[iMask]);
            b := b + (SourceRows^[row]^[col].rgbtBlue  * MaskBits[iMask]);
            inc(iMask);
          end;
        end;

        DestRow^[x].rgbtRed   := Set255((R div Divisor)+ Addition);
        DestRow^[x].rgbtGreen := Set255((G div Divisor)+ Addition);
        DestRow^[x].rgbtBlue  := Set255((B div Divisor)+ Addition);
      end;
    end;
    source.Assign(dest);
  finally
    FreeMem(SourceRows); SourceRows:=nil;
    dest.Free;
  end;
end;

procedure EffectCustom_Blur(var bmp :TBitmap);
var
 maskBits : array [0..24] of SmallInt;
 divisor,addition,i:integer;
begin
  for i:= 0 to 24 do  maskBits[i]:=0;
  divisor := 1; addition := 0;

  // ぼかし(強)
  MaskBits[0]  := 0;    MaskBits[1]  :=1 ;  MaskBits[2]  :=2;   MaskBits[3]  := 1;   MaskBits[4]  := 0;
  MaskBits[5]  := 1;    MaskBits[6]  :=2 ;  MaskBits[7]  :=4;   MaskBits[8]  := 2;   MaskBits[9]  := 1;
  MaskBits[10] := 2;    MaskBits[11] :=4 ;  MaskBits[12] :=8;   MaskBits[13] := 4;   MaskBits[14] := 2;
  MaskBits[15] := 1;    MaskBits[16] :=2 ;  MaskBits[17] :=4;   MaskBits[18] := 2;   MaskBits[19] := 1;
  MaskBits[20] := 0;    MaskBits[21] :=1 ;  MaskBits[22] :=2;   MaskBits[23] := 1;   MaskBits[24] := 0;

  Divisor := 48;
  EffectCustom(bmp,maskBits,divisor,addition);
end;

procedure EffectCustom_Sharp(var bmp :TBitmap);
var
 maskBits : array [0..24] of SmallInt;
 divisor,addition,i:integer;
begin
  for i:= 0 to 24 do  maskBits[i]:=0;
  divisor := 1; addition := 0;

  // シャープ(強)
  MaskBits[6]  := -1 ;    MaskBits[7]  := -1;  MaskBits[8]  := -1 ;
  MaskBits[11] := -1 ;    MaskBits[12] := 12;  MaskBits[13] := -1 ;
  MaskBits[16] := -1 ;    MaskBits[17] := -1;  MaskBits[18] := -1 ;

  Divisor := 4;
  EffectCustom(bmp,maskBits,divisor,addition);
end;

end.

