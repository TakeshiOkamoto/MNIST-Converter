unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls,effects;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button3: TButton;
    Button2: TButton;
    Edit1: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label17: TLabel;
    Label2: TLabel;
    Label4: TLabel;
    Memo1: TMemo;
    RadioButton2: TRadioButton;
    RadioButton3: TRadioButton;
    RadioButton5: TRadioButton;
    RadioButton6: TRadioButton;
    RadioButton7: TRadioButton;
    RadioButton4: TRadioButton;
    RadioButton1: TRadioButton;
    SelectDirectoryDialog1: TSelectDirectoryDialog;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Label17Click(Sender: TObject);
    procedure Memo1Change(Sender: TObject);
  private

  public

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

procedure Effect(var bmp :TBitmap;index:integer);
begin
   case index of
       // The first image is original
       0: ;
       1: EffectCustom_Blur(bmp);
       2: begin
            EffectCustom_Blur(bmp);
            EffectCustom_Blur(bmp);
          end;
       3: begin
            EffectCustom_Blur(bmp);
            EffectCustom_Blur(bmp);
            EffectCustom_Blur(bmp);
          end;
       4: EffectCustom_Sharp(bmp);
       5: begin
           EffectCustom_Sharp(bmp);
           EffectCustom_Sharp(bmp);
          end;
       6: EffectMedian_Max(bmp);
       7: EffectMedian_Mid(bmp);
       8: EffectMedian_Min(bmp);
       9: EffectHistogramEqualize(bmp);
      10: EffectNoise(bmp,70);
      11: EffectToneCurve(bmp,LUT_1);
      12: EffectToneCurve(bmp,LUT_2);
      13: EffectToneCurve(bmp,LUT_3);
      14: EffectLight(bmp,30);
      15: EffectLight(bmp,-30);
      16: EffectContrast(bmp,80);
      17: EffectContrast(bmp,-80);
      18: EffectGamma(bmp,0.5);
      19: EffectGamma(bmp,1.5);
  end;
end;

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

procedure TForm1.Button1Click(Sender: TObject);
var
  i,j,count:integer;
  bmp : TBitmap;
  lpic,spic : TPicture;
  filename,openExt,saveExt:String;
  filelist : TStringlist;
begin
  form1.Enabled:= false;
  form2.Show;

  count:=10;
  if(RadioButton2.Checked) then count:=30;
  if(RadioButton3.Checked) then count:=50;
  if(RadioButton4.Checked) then count:=70;

  saveExt:='.bmp';
  if(RadioButton5.Checked) then saveExt:='.jpg';
  if(RadioButton6.Checked) then saveExt:='.png';

  filelist := TStringlist.create;
  lpic := TPicture.create;
  spic := TPicture.create;
  try
    filelist.Assign(memo1.lines);
    form2.ProgressBar1.Max:= filelist.count-1;
    form2.ProgressBar1.Position := 0;
    form2.Caption:= 'processing ... ' +'0/' + inttostr(filelist.count) ;
    for i:=0 to filelist.count-1 do
    begin
      application.ProcessMessages;

      // 拡張子を除くファイル名を取得する
      filename := ExtractFileName(filelist[i]);
      openExt  := ExtractFileExt(filelist[i]);
      filename := StringReplace(filename,openExt,'',[rfReplaceAll]);

      // 一時用
      lpic.LoadFromFile(filelist[i]);
      bmp := TBitmap.create;
      try
        bmp.Assign(lpic.Bitmap);
        Image2Bitmap(bmp);
        lpic.Bitmap.Assign(bmp);
      finally
        bmp.free;
      end;

      bmp := TBitmap.create;
      try
        for j:=0 to count-1 do
        begin
          bmp.Assign(lpic.Bitmap);

          case j of
              0, 1, 2, 3, 4, 5, 6, 7, 8, 9,
             10,11,12,13,14,15,16,17,18,19: Effect(bmp, j);
             20,21,22,23,24,25,26,27: begin
                                       Effect(bmp, j - 19);
                                       EffectGamma(bmp,0.5);
                                      end;
             28,29,30,31,32,33,34,35: begin
                                       Effect(bmp, j - 27);
                                       EffectGamma(bmp,1.5);
                                      end;
             36,37,38,39,40,41,42,43: begin
                                       Effect(bmp, j - 35);
                                       EffectContrast(bmp,-80);
                                      end;
             44,45,46,47,48,49,50,51: begin
                                       Effect(bmp, j - 43);
                                       EffectContrast(bmp,80);
                                      end;
             52,53,54,55,56,57,58,59: begin
                                       Effect(bmp, j - 51);
                                       EffectLight(bmp,-30);
                                      end;
             60,61,62,63,64,65,66,67: begin
                                       Effect(bmp, j - 59);
                                       EffectLight(bmp,-30);
                                      end;
             68: begin
                   EffectCustom_Blur(bmp);
                   EffectCustom_Blur(bmp);
                   EffectMedian_Max(bmp);
                 end;
             69: begin
                   EffectCustom_Blur(bmp);
                   EffectCustom_Blur(bmp);
                   EffectMedian_Min(bmp);
                 end;
          end;

          // save
          spic.Assign(bmp);
          spic.SaveToFile(edit1.text + filename+'_' + format('%.3d',[j+1]) +saveExt);
        end;
      finally
        bmp.free;
      end;

      form2.Caption:= 'processing ... ' + inttostr(i) +'/' + inttostr(filelist.count) ;
      form2.ProgressBar1.Position:= i;
    end;

  finally
    lpic.free; spic.free;
    filelist.free;
    form2.Close;
    form1.Enabled:= true;
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  list : TStringList;
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

    if not (memo1.Text = '') and
       not (Edit1.Text = '') then
      button1.Enabled := true
    else
      button1.Enabled := false
  end;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  if SelectDirectoryDialog1.Execute then
  begin
    edit1.text := SelectDirectoryDialog1.FileName +'\';
    if not (memo1.Text = '') and
       not (Edit1.Text = '') then
      button1.Enabled := true
    else
      button1.Enabled := false
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin

end;

procedure TForm1.Memo1Change(Sender: TObject);
begin
  label2.Caption:= inttostr(memo1.lines.count);
  if not (memo1.Text = '') and
     not (Edit1.Text = '') then
    button1.Enabled := true
  else
    button1.Enabled := false
end;

procedure TForm1.Label17Click(Sender: TObject);
begin
  SysUtils.ExecuteProcess(('explorer.exe'), PChar('https://github.com/TakeshiOkamoto'), []);
end;

end.

