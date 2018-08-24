//
unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ComCtrls, Spin, Buttons;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button4: TButton;
    Button3: TButton;
    Button5: TButton;
    Button8: TButton;
    Button7: TButton;
    Button10: TButton;
    Button6: TButton;
    Button9: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label2: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    Label22: TLabel;
    Label23: TLabel;
    Label24: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Memo1: TMemo;
    Memo2: TMemo;
    OpenDialog1: TOpenDialog;
    PageControl1: TPageControl;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    RadioButton3: TRadioButton;
    RadioButton4: TRadioButton;
    RadioButton5: TRadioButton;
    SaveDialog1: TSaveDialog;
    SelectDirectoryDialog1: TSelectDirectoryDialog;
    SpinEdit1: TSpinEdit;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    procedure Button10Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Label17Click(Sender: TObject);
    procedure Memo1Change(Sender: TObject);
    procedure Memo2Change(Sender: TObject);
  private

  public

  end;


  type
  // 8byte
  pMnistheader = ^TMnistheader;
  TMnistheader = packed record
    magic : Dword;  // magic number (MSB first)
    count : Dword;  // number of items
  end;

var
  Form1: TForm1;

implementation
uses
  unit2;

{$R *.lfm}

{ TForm1 }

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

function Wswap(value :Word):Word;
begin
 Result := (value and $00FF) shl 8;
 Result := Result+(value and $FF00) shr 8;
end;

function Dswap(value :Dword):Dword;
begin
 Result :=(value and $000000FF) shl 24;
 Result :=Result or ((value and $0000FF00) shl 8);
 Result :=Result or ((value and $00FF0000) shr 8);
 Result :=Result or ((value and $FF000000) shr 24);
end;

function Set255(value :Integer) : Byte;
begin
  if value>255 then
  begin
    Result := 255;
    exit;
    end
  else if  value < 0  then
  begin
    Result := 0;
    exit;
  end;
  Result := Byte(value);
end;

procedure ImageResize(src:TBitmap;size :Dword);
var
   bmp : TBitmap;
begin
   bmp := TBitmap.create;
   try
     bmp.Width  := size;
     bmp.height := size;
     bmp.Canvas.Brush.Color:= clWhite;
     bmp.Canvas.FillRect(0,0,size,size);
     bmp.Canvas.StretchDraw(Rect(0,0,size,size),src);
     src.Assign(bmp);
   finally
     bmp.free;
   end;
end;

procedure getLabelData(filename:string;list :TStringlist );
var
   i : integer;
   dummy : Word;
   stream : TMemoryStream;
   Mnistheader : TMnistheader =(magic:0;count:0);
begin
    stream := TMemoryStream.create;
    try
      stream.LoadFromFile(filename);
      if stream.Size < 8 then raise Exception.Create('error !') ;

      Stream.Read(Mnistheader,8);
      Mnistheader.magic:= Dswap(Mnistheader.magic);
      Mnistheader.count:= Dswap(Mnistheader.count);

      // normal
      if Mnistheader.magic = 2049 then
      begin
        for i:= 0 to Mnistheader.count-1 do
        begin
          list.add(Inttostr(stream.ReadByte));
        end;
      end

      // expansion
      else if Mnistheader.magic = 2050 then
      begin
        dummy := 0;
        for i:= 0 to Mnistheader.count-1 do
        begin
          stream.Read(dummy, 2);
          dummy := Wswap(dummy);
          list.add(Inttostr(dummy));
        end;
      end
      else
         raise Exception.Create('error !');
    finally
      stream.free;
    end;
end;

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

procedure TForm1.Button1Click(Sender: TObject);
begin
    if (Sender as TButton).Name = 'Button1' then
    begin
      if OpenDialog1.Execute then
      begin
         edit1.Text:= OpenDialog1.FileName;
      end;
    end
    else if  (Sender as TButton).Name = 'Button2' then
    begin
      if OpenDialog1.Execute then
      begin
         edit2.Text:= OpenDialog1.FileName;
      end;
    end
    else if  (Sender as TButton).Name = 'Button3' then
    begin
      if SelectDirectoryDialog1.Execute then
      begin
          edit3.Text := SelectDirectoryDialog1.FileName;
      end;
    end;

    if not (edit1.Text = '') and
       not (edit2.Text = '') and
       not (edit3.Text = '') then
      button4.Enabled := true
    else
      button4.Enabled := false
end;

// run "MNIST to IMAGE"
procedure TForm1.Button4Click(Sender: TObject);
var
   g : byte;
   i,x,y,Row,Col:integer;
   rows,columns : Dword;
   bmp : TBitmap;
   pic : TPicture;
   list: TStringList;
   ext : string;
   stream : TMemoryStream;
   Mnistheader : TMnistheader =(magic:0;count:0);
begin
    if edit1.Text = '' then exit;
    if edit2.Text = '' then exit;
    if edit3.Text = '' then exit;

    edit3.Text := edit3.Text + '\';

    if(RadioButton3.Checked) then ext := '.jpg';
    if(RadioButton4.Checked) then ext := '.png';
    if(RadioButton5.Checked) then ext := '.bmp';

    list := TStringList.create;
    pic := TPicture.create;
    stream := TMemoryStream.create;
    PageControl1.Enabled:= false;
    try

      // label
      getLabelData(edit2.text,list);

      // image
      stream.LoadFromFile(edit1.text);
      if stream.Size < 8 then raise Exception.Create('error !') ;

      Stream.Read(Mnistheader,8);
      Mnistheader.magic:= Dswap(Mnistheader.magic);
      Mnistheader.count:= Dswap(Mnistheader.count);

      // image
      rows := 0; columns := 0;
      if Mnistheader.magic = 2051 then
      begin
          Stream.Read(rows,4);
          Stream.Read(columns,4);
          rows := Dswap(rows);
          columns := Dswap(columns);

          form2.Show;
          form2.ProgressBar1.Max:= Mnistheader.count-1;
          form2.ProgressBar1.Position := 0;
          form2.Caption:= 'processing ... ' +'0/' + inttostr(Mnistheader.count) ;
          for i:= 0 to Mnistheader.count-1 do
          begin
            Application.ProcessMessages;

            bmp := TBitmap.create;
            bmp.Width := columns;
            bmp.Height:= rows;
            bmp.PixelFormat := pf24bit;
            try
              // 24bit
              for y := 0 to rows-1 do
              begin
                Row:= (y * columns * 3);
                for x := 0 to columns-1 do
                begin
                  Col := Row + (x * 3);
                  g := Stream.ReadByte;
                  bmp.RawImage.Data[Col]   := g;
                  bmp.RawImage.Data[Col+1] := g;
                  bmp.RawImage.Data[Col+2] := g;
                end;
              end;
              pic.Bitmap.Assign(bmp);
              pic.SaveToFile(edit3.text + format('%.6d',[i])  +'-'+ list[i] + ext);
            finally
              bmp.free;
            end;

            form2.Caption:= 'processing ... ' + inttostr(i) +'/' + inttostr(Mnistheader.count) ;
            form2.ProgressBar1.Position:= i;
          end;
      end
      else
         raise Exception.Create('error !');
    finally
      list.free;
      pic.free;
      stream.free;
      form2.Close;
      PageControl1.Enabled:= true;
    end;
end;

procedure TForm1.Button5Click(Sender: TObject);
var
  list : TStringList;
begin
    if (Sender as TButton).Name = 'Button5' then
    begin
      if SelectDirectoryDialog1.Execute then
      begin
          list := TStringList.create;
          try
            FindAllFiles(list,SelectDirectoryDialog1.FileName, '*.jpg;*.jpeg;*.png;*.gif;*.bmp', false);
            //list.Sort;
            Memo1.Lines.Assign(list);
          finally
            list.free;
          end;
      end;
    end
    else if  (Sender as TButton).Name = 'Button6' then
    begin
      if SaveDialog1.Execute then
      begin
         Edit4.Text:= SaveDialog1.FileName;
      end;
    end;

    if not (memo1.Text = '') and
       not (Edit4.Text = '') then
      button7.Enabled := true
    else
      button7.Enabled := false
end;

// run "IMAGE to MNIST"
procedure TForm1.Button7Click(Sender: TObject);
var
  g : byte;
  raw : PByte;
  i,x,y,Row,Col:integer;
  list : TStringList;
  Picture : TPicture;
  dummy : Dword;
  Stream : TMemoryStream;
begin
  PageControl1.Enabled := false;

  list := TStringList.Create;
  Picture := TPicture.create;
  Stream := TMemoryStream.create;
  try
    list.Assign(Memo1.Lines);

    // MNIST header
    dummy := Dswap(2051);
    Stream.Write(dummy ,4);
    dummy := Dswap(list.count);
    Stream.Write(dummy ,4);
    dummy := Dswap(SpinEdit1.Value);
    Stream.Write(dummy ,4);
    dummy := Dswap(SpinEdit1.Value);
    Stream.Write(dummy ,4);

    form2.Show;
    form2.ProgressBar1.Max:= list.count-1;
    form2.ProgressBar1.Position := 0;
    form2.Caption:= 'processing ... ' +'0/' + inttostr(list.count) ;

    // *** Black & White
    if RadioButton1.Checked then
    begin
      for i:=0 to list.count-1 do
      begin
         Application.ProcessMessages;

         // resize
         Picture.LoadFromFile(list[i]);
         ImageResize(Picture.Bitmap,SpinEdit1.Value);

         raw := Picture.Bitmap.RawImage.Data;

         // raw
         for y := 0 to Picture.Bitmap.Height-1 do
         begin
           Row:= (y * Picture.Bitmap.Width * 3);
           for x := 0 to Picture.Bitmap.Width-1 do
           begin
             Col := Row + (x * 3);

             // this is not good
             if (raw[Col] > 128) then
               Stream.WriteByte(255)
             else
               Stream.WriteByte(0)
           end;
         end;
         form2.Caption:= 'processing ... ' + inttostr(i) +'/' + inttostr(list.count) ;
         form2.ProgressBar1.Position:= i;
      end;
    end

    // *** Grayscale
    else
    begin
      for i:=0 to list.count-1 do
      begin
         Application.ProcessMessages;

         // resize
         Picture.LoadFromFile(list[i]);
         ImageResize(Picture.Bitmap,SpinEdit1.Value);
         raw := Picture.Bitmap.RawImage.Data;

         // raw
         for y := 0 to Picture.Bitmap.Height-1 do
         begin
           Row:= (y * Picture.Bitmap.Width * 3);
           for x := 0 to Picture.Bitmap.Width-1 do
           begin
             Col := Row + (x * 3);
             raw := Picture.Bitmap.RawImage.Data;
             g := set255(round(raw[Col]   * 0.289 +
                               raw[Col+1] * 0.586 +
                               raw[Col+2] * 0.114 ));
             Stream.WriteByte(g) ;
           end;
         end;
         form2.Caption:= 'processing ... ' + inttostr(i) +'/' + inttostr(list.count) ;
         form2.ProgressBar1.Position:= i;
      end;
    end;

    Stream.SaveToFile(Edit4.Text);
  finally
    list.Free;
    Picture.free;
    Stream.free;
    form2.Close;
    PageControl1.Enabled := true;
  end;
end;

procedure TForm1.Button8Click(Sender: TObject);
begin
    if (Sender as TButton).Name = 'Button8' then
    begin
      if OpenDialog1.Execute then
      begin
        try
          memo2.Lines.LoadFromFile(OpenDialog1.FileName);
        finally
        end;
      end;
    end
    else if (Sender as TButton).Name = 'Button9' then
    begin
      if SaveDialog1.Execute then
      begin
         Edit5.Text:= SaveDialog1.FileName;
      end;
    end;

    if not (memo2.Text = '') and
       not (Edit5.Text = '') then
      button10.Enabled := true
    else
      button10.Enabled := false
end;

// run "LABEL to MNIST"
procedure TForm1.Button10Click(Sender: TObject);
var
  i :integer;
  normal : Byte;
  expansion :Word;
  dummy : Dword;
  list  : TStringList;
  expansionFlg : boolean;
  stream : TMemoryStream;
begin
  list := TStringList.create;
  stream := TMemoryStream.create;
  try
    list.Assign(Memo2.Lines);

    // Confirm extension style
    expansionFlg := false;
    for i:=0 to list.count-1 do
    begin
      if (strtoint(Trim(list[i])) >= 256) then
      begin
         expansionFlg := true;
         break;
      end;
    end;

    // extension
    if expansionFlg then
    begin
      dummy := Dswap(2050);
      stream.WriteBuffer(dummy, 4);
      dummy := Dswap(list.count);
      stream.WriteBuffer(dummy, 4);

      for i:=0 to list.count-1 do
      begin
        expansion := Wswap(strtoint(Trim(list[i])));
        stream.WriteBuffer(expansion, 2);
      end;
    end

    // normal
    else
    begin
      dummy := Dswap(2049);
      stream.WriteBuffer(dummy, 4);
      dummy := Dswap(list.count);
      stream.WriteBuffer(dummy, 4);

      for i:=0 to list.count-1 do
      begin
        normal := strtoint(Trim(list[i]));
        stream.WriteBuffer(normal, 1);
      end;
    end;

    Stream.SaveToFile(Edit5.text);
  finally
    list.free;
    stream.free;
  end;
end;

procedure TForm1.Label17Click(Sender: TObject);
begin
    SysUtils.ExecuteProcess(('explorer.exe'), PChar('https://github.com/TakeshiOkamoto'), []);
end;

procedure TForm1.Memo1Change(Sender: TObject);
begin
  Label19.Caption:= inttostr(Memo1.Lines.count);
  if not (memo1.Text = '') and
    not (Edit4.Text = '') then
    button7.Enabled := true
  else
    button7.Enabled := false
end;

procedure TForm1.Memo2Change(Sender: TObject);
begin
  Label21.Caption:= inttostr(Memo2.Lines.count);
  if not (memo2.Text = '') and
    not (Edit5.Text = '') then
    button10.Enabled := true
  else
    button10.Enabled := false
end;


end.

