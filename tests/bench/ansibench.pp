program Bench2;
{$APPTYPE CONSOLE}
{$H+}

uses
   sysutils,
   Windows;

const
 cTimes = 999999;
   Number1: array [0..19] of string = (
   'zero', 'one', 'two', 'three', 'four', 'five',
   'six', 'seven', 'eight', 'nine', 'ten', 'eleven',
   'twelve', 'thirteen', 'fourteen', 'fifteen', 'sixteen',
   'seventeen', 'eighteen', 'nineteen');
    Number9: array [0..9] of string = (
   '', ' one', ' two', ' three', ' four', ' five',
   ' six', ' seven', ' eight', ' nine');

   Number10: array [0..9] of string = (
   'zero', 'ten', 'twenty', 'thirty', 'fourty', 'fifty',
   'sixty', 'seventy', 'eighty', 'ninety');

var
   StartTick: Cardinal;

procedure StartLog(const Text: string; Count: Integer);
begin
   if Count > 0 then
       write(Text, ': ', Count, ' ... ')
   else
       write(Text, ' ... ');
   StartTick:= GetTickCount;
end;

procedure EndLog(const Text: string);
begin
   writeln(Text, ' done in ', (GetTickCount - StartTick) / 1000.0: 0: 3, ' sec');
end;

type
 TFastStringRec = record
   l: Cardinal;
   s: string;
 end;

procedure FS_Clear(var AFS: TFastStringRec); inline;
begin
 AFS.L:= 0;
 AFS.S:= '';
end;

procedure FS_Assign(var AFS: TFastStringRec; const s: string); inline;
begin
 AFS.l:= Length(s);
 SetLength(AFS.s, (AFS.l and not 63) + 64);
 if AFS.l > 0 then
   Move(s[1], AFS.s[1], AFS.l);
end;

procedure FS_Append(var AFS: TFastStringRec; const s: string); overload;
inline;
var
 L, ls: Cardinal;
begin
 ls:= Length(s);
 if ls > 0 then begin
   L:= AFS.l;
   AFS.l:= L + ls;
   SetLength(AFS.s, (AFS.l and not 63) + 64);
   Move(s[1], AFS.s[1 + L], ls);
 end;
end;

procedure FS_Append(var AFS, S: TFastStringRec); overload; inline;
var
 L: Cardinal;
begin
 if S.L > 0 then begin
   L:= AFS.l;
   AFS.l:= L + S.L;
   SetLength(AFS.s, (AFS.l and not 63) + 64);
   Move(S.S[1], AFS.S[1 + L], S.L);
 end;
end;

function FS_ToStr(var AFS: TFastStringRec): string; inline;
begin
 if AFS.L >  0 then begin
   SetLength(Result, AFS.L);
   Move(AFS.S[1], Result[1], AFS.L);
 end else
   Result:= '';
end;

procedure NumberToText_V1(out s: string; n: Integer);

 procedure TensToText(var s: TFastStringRec; dig: Integer);
 var
   x: Integer;
 begin
     if dig > 0 then begin
         if dig >= 20 then begin
           x:= dig mod 10;
           FS_Assign(s, Number10[dig div 10]);
             if x <> 0 then
              FS_Append(s, Number9[x]);
         end else begin
             FS_Assign(s, Number1[dig]);
         end;
     end else
       FS_Clear(s);
 end;

 procedure HundredsToText(var s: TFastStringRec; dig: Integer);
 var
     h, t: Integer;
     s1: TFastStringRec;
 begin
   if dig > 0 then begin
       t:= dig mod 100;
       h:= dig div 100;
       if h > 0 then begin
       TensToText(s, h);
         if t > 0 then begin
           FS_Append(s, ' houndred ');
         TensToText(s1, t);
         FS_Append(s, s1);
         end else
           FS_Append(s, ' houndred');
       end else
         TensToText(s, t);
     end else
       FS_Clear(s);
 end;

var
   dig, h: Integer;
   s0, s1: TFastStringRec;
begin
   if n > 0 then begin
       dig:= n div 1000;
       h:= n mod 1000;
       if dig > 0 then begin
         HundredsToText(s0, dig);
         if h > 0 then begin
       FS_Append(s0, ' thousand ');
             HundredsToText(s1, h);
       FS_Append(s0, s1);
         end else
           FS_Append(s0, ' thousand');
       end else
         HundredsToText(s0, h);
       s:= FS_ToStr(s0);
   end else
       s:= Number1[0];
end;


procedure NumberToText_V2(out s: string; n: Integer);

 procedure TensToText(out s: string; dig: Integer);
 var
   x: Integer;
 begin
     if dig > 0 then begin
         if dig >= 20 then begin
           x:= dig mod 10;
             if x <> 0 then begin
                 s:= Number10[dig div 10] + Number9[x]
             end else
               s:= Number10[dig div 10];
         end else begin
             s:= Number1[dig];
         end;
     end else
       s:= '';
 end;

 procedure HundredsToText(out s: string; dig: Integer);
 var
     h, t: Integer;
     s1: string;
 begin
   if dig > 0 then begin
       t:= dig mod 100;
       h:= dig div 100;
       if h > 0 then begin
       TensToText(s, h);
         if t > 0 then begin
           s:= s + ' houndred ';
         TensToText(s1, t);
         s:= s + s1;
         end else
           s:= s + ' houndred';
       end else
         TensToText(s, t);
     end else
       s:= '';
 end;

var
   dig, h: Integer;
   s1: string;
begin
   if n > 0 then begin
       dig:= n div 1000;
       h:= n mod 1000;
       if dig > 0 then begin
         HundredsToText(s, dig);
         if h > 0 then begin
       s:= s + ' thousand ';
             HundredsToText(s1, h);
       s:= s + s1;
         end else
           s:= s + ' thousand';
       end else
         HundredsToText(s, h);
   end else
       s:= Number1[0];
end;

function NumberToText_V3(n: Integer): string;

   function TensToText(dig: Integer): string;
 var
   x: Integer;
 begin
     if dig > 0 then begin
         if dig >= 20 then begin
           x:= dig mod 10;
             if x <> 0 then begin
                 Result:= Number10[dig div 10] + Number9[x]
             end else
               Result:= Number10[dig div 10];
         end else begin
             Result:= Number1[dig];
         end;
     end else
       Result:= '';
 end;

   function HundredsToText(dig: Integer): string;
 var
     h, t: Integer;
 begin
   if dig > 0 then begin
       t:= dig mod 100;
       h:= dig div 100;
       if h > 0 then begin
         if t > 0 then
           Result:= TensToText(h) + ' houndred ' + TensToText(t)
         else
           Result:= TensToText(h) + ' houndred';
       end else
         Result:= TensToText(t);
     end else
       Result:= '';
 end;

var
   dig, h: Integer;
begin
   if n > 0 then begin
       dig:= n div 1000;
       h:= n mod 1000;
       if dig > 0 then begin
         if h > 0 then
       Result:= HundredsToText(dig) + ' thousand ' + HundredsToText(h)
         else
           Result:= HundredsToText(dig) + ' thousand';
       end else
         Result:= HundredsToText(h);
   end else
       Result:= Number1[0];
end;

procedure Test1;
var
   i: Integer;
   s: string;
begin
   StartLog('Test 1', cTimes + 1);
   for i:= 0 to cTimes do begin
     NumberToText_V1(s, i);
   end;
   EndLog('');
end;

procedure Test2;
var
   i: Integer;
   s: string;
begin
   StartLog('Test 2', cTimes + 1);
   for i:= 0 to cTimes do begin
     NumberToText_V2(s, i);
   end;
   EndLog('');
end;

procedure Test3;
var
   i: Integer;
   s: string;
begin
   StartLog('Test 3', cTimes + 1);
   for i:= 0 to cTimes do begin
     s:= NumberToText_V3(i);
   end;
   EndLog('');
end;

procedure Benchmark;
begin
   Test1;
   Test2;
   Test3;
end;

begin
   Benchmark;
end.

