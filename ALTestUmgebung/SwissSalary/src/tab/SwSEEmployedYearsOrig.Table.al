// table 50000 "SwSE Employed Years Orig"
// {
//     fields
//     {
//         field(1; "Employee No."; Code[10])
//         {
//             TableRelation = "SwS Employee";
//         }
//         field(5; "Date from"; Date)
//         {
//             NotBlank = true;
//             ClosingDates = false;

//             trigger OnValidate()
//             begin
//                 if not (PayrollSetup_g.Get()) then
//                     PayrollSetup_g.Init();

//                 if (PayrollSetup_g."Period Calc. Employed Years" <> 2) then begin
//                     Calculate;    //Alte Rechnung
//                 end else begin
//                     "Number of Periods" := CalculatePeriod(COMPANYNAME, "Date from", "Date to");
//                     CalculateYears(Rec);
//                 end;
//             end;
//         }
//         field(6; "Date to"; Date)
//         {
//             NotBlank = true;
//             ClosingDates = true;

//             trigger OnValidate()
//             begin
//                 if not (PayrollSetup_g.Get()) then
//                     PayrollSetup_g.Init();

//                 if (PayrollSetup_g."Period Calc. Employed Years" <> 2) then begin
//                     Calculate;    //Alte Rechnung
//                 end else begin
//                     "Number of Periods" := CalculatePeriod(COMPANYNAME, "Date from", "Date to");
//                     CalculateYears(Rec);
//                 end;
//             end;
//         }
//         field(10; "Employed Years calculated"; Decimal)
//         {
//             Editable = false;

//             trigger OnValidate()
//             begin
//                 if ((xRec."Employed Years" = xRec."Employed Years calculated") or ("Employed Years" = 0)) then
//                     "Employed Years" := "Employed Years calculated";
//             end;
//         }
//         field(11; "Employed Years"; Decimal)
//         {
//         }
//         field(50; "Number of all Periodes"; Integer)
//         {
//             Editable = false;
//             FieldClass = FlowField;
//             CalcFormula = count(Date where("Period Type" = field(Period), "Period Start" = field(filter("Filter"))));
//         }
//         field(53; "Number of entire Periods"; Integer)
//         {
//             Editable = false;
//             FieldClass = FlowField;
//             CalcFormula = count(Date where("Period Type" = field(Period), "Period Start" = field(filter("Filter for entire Periods")), "Period End" = field(filter("Filter for entire Periods"))));
//         }
//         field(55; "Number of Periods"; Decimal)
//         {
//             Editable = false;
//         }
//         field(60; Comments; Text[50])
//         {
//         }
//         field(100; Period; Option)
//         {
//             FieldClass = FlowFilter;
//             OptionMembers = Day,Week,Month,Quarter,Year;
//             OptionCaption = 'Day,Week,Month,Quarter,Year';
//         }
//         field(101; "Filter"; Text[30])
//         {
//             Editable = false;

//             trigger OnValidate()
//             begin
//                 Evaluate(Date_g, COPYSTR(Filter, STRPOS(Filter, '..') + 2));
//                 "Filter for entire Periods" := COPYSTR(Filter, 1, STRPOS(Filter, '..') + 1) + DFormat(CalcDate('<+1D>', Date_g));
//             end;
//         }
//         field(102; "Filter for entire Periods"; Text[50])
//         {
//             Editable = false;
//         }
//         field(50000; Days; Decimal)
//         {
//             Editable = false;

//             trigger OnValidate()
//             begin
//                 Days := CalcDays("Date from", "Date to");
//                 Years := ROUND(Days / 365, 0.00001);
//             end;
//         }
//         field(50001; Years; Decimal)
//         {
//             Editable = false;
//         }
//         field(50002; Excl; Boolean)
//         {
//         }
//     }

//     keys
//     {
//         key(PK; "Employee No.", "Date from")
//         {
//             Clustered = true;
//             SumIndexFields = "Employed Years";
//         }
//         key(Key2; "Employee No.", "Date to", Excl)
//         {
//             SumIndexFields = "Employed Years", Years, Days;
//         }
//     }

//     var
//         PayrollSetup_g: Record "SwS Payroll Setup";
//         Date_g: Date;
//         Txt001Lbl: Label 'Date to (%1) cannot be earlier than the Date from (%2)!';

//     local procedure DFormat(Date_p: Date): Text[30]
//     begin
//         exit(Format(Date_p, 0));
//     end;

//     local procedure Calculate()
//     var
//         Start_l: Integer;
//         End_l: Integer;
//         EmployedYears_l: Record "SwS Employed Years";
//         DayBegin_l: Integer;
//         MonthBegin_l: Integer;
//         DayEnd_l: Integer;
//         MonthEnd_l: Integer;
//         Year_l: Integer;
//         YearEnd_l: Integer;
//         Amount_l: Decimal;
//         TempDate_l: Date;
//     begin

//         if (("Date from" <> 0D) and ("Date to" <> 0D)) then begin
//             Validate("Filter", DFormat("Date from") + '..' + DFormat("Date to"));

//             PayrollSetup_g.Get();
//             if (PayrollSetup_g."Period Type Employed Years" = PayrollSetup_g."Period Type Employed Years"::Abrechnungsperiode) then begin
//                 Start_l := Date2DMY("Date from", 3);
//                 End_l := Date2DMY("Date to", 3);

//                 DayBegin_l := Date2DMY("Date from", 1);
//                 MonthBegin_l := Date2DMY("Date from", 2);

//                 DayEnd_l := 31;
//                 MonthEnd_l := 12;

//                 for Year_l := Start_l to End_l do begin
//                     if (Year_l = End_l) then begin
//                         DayEnd_l := Date2DMY("Date to", 1);
//                         MonthEnd_l := Date2DMY("Date to", 2);
//                     end;

//                     EmployedYears_l.Init();
//                     EmployedYears_l."Date from" := DMY2Date(DayBegin_l, MonthBegin_l, Year_l);
//                     EmployedYears_l."Date to" := DMY2Date(DayEnd_l, MonthEnd_l, Year_l);
//                     EmployedYears_l."Date to" := (EmployedYears_l."Date to");

//                     EmployedYears_l.Validate("Filter", DFormat(EmployedYears_l."Date from") + '..' + DFormat(EmployedYears_l."Date to"));
//                     EmployedYears_l.Insert(FALSE);
//                     Amount_l := Amount_l + CalculateEmployedYears(EmployedYears_l);

//                     DayBegin_l := 1;
//                     MonthBegin_l := 1;
//                 end;
//             end else begin
//                 Start_l := Date2DMY("Date from", 3);
//                 End_l := Date2DMY("Date to", 3);

//                 DayBegin_l := Date2DMY("Date from", 1);
//                 MonthBegin_l := Date2DMY("Date from", 2);

//                 TempDate_l := CalcDate('<-1D>', CalcDate('<+1Y>', "Date from"));

//                 DayEnd_l := Date2DMY(TempDate_l, 1);
//                 MonthEnd_l := Date2DMY(TempDate_l, 2);

//                 // Neu für Schaltjahre
//                 if ((Date2DMY(TempDate_l, 1) = 28) and (Date2DMY(TempDate_l, 2) = 2) and (Date2DMY("Date from", 1) = 1) and (Date2DMY("Date from", 2) = 3)) then
//                     DayEnd_l += 1;                                                             // Bei Februar immer von 29 Tagen ausgehen

//                 Year_l := Start_l;

//                 repeat
//                     if ((DayEnd_l = 31) and (MonthEnd_l = 12)) then
//                         YearEnd_l := Year_l + 0
//                     else
//                         YearEnd_l := Year_l + 1;

//                     if (YearEnd_l > End_l) then
//                         YearEnd_l := End_l;

//                     EmployedYears_l.Init();
//                     EmployedYears_l."Date from" := CheckDate(DayBegin_l, MonthBegin_l, Year_l);
//                     EmployedYears_l."Date to" := CheckDate(DayEnd_l, MonthEnd_l, YearEnd_l);
//                     if (EmployedYears_l."Date to" < EmployedYears_l."Date from") then
//                         EmployedYears_l."Date to" := "Date to";

//                     if (EmployedYears_l."Date to" > "Date to") then
//                         EmployedYears_l."Date to" := "Date to";
//                     EmployedYears_l."Date to" := (EmployedYears_l."Date to");

//                     EmployedYears_l.Validate("Filter", DFormat(EmployedYears_l."Date from") + '..' + DFormat(EmployedYears_l."Date to"));
//                     EmployedYears_l.Insert(false);
//                     Amount_l := Amount_l + CalculateEmployedYears(EmployedYears_l);

//                     Year_l := Year_l + 1;
//                 until (EmployedYears_l."Date to" = "Date to");
//             end;

//             Validate("Employed Years calculated", Amount_l);
//         end else begin
//             Validate("Filter", '010104..010103');
//         end;

//         // 15.08/14/PV/LL
//         // 22.10.12/PV/HH
//         Validate(Days);
//     end;

//     local procedure CalculateEmployedYears(EmployedYears_p: Record "SwS Employed Years") Amount_p: Decimal
//     begin
//         PayrollSetup_g.Get();
//         EmployedYears_p.SetRange(Period, PayrollSetup_g."Period Employed Years");
//         EmployedYears_p.CalcFields("Number of all Periodes", "Number of entire Periods");

//         if (PayrollSetup_g."Period Calc. Employed Years" = 0) then begin
//             if (EmployedYears_p."Number of all Periodes" >= PayrollSetup_g."Quantity Employed Years") then
//                 Amount_p := 1;
//         end else begin
//             if (EmployedYears_p."Number of entire Periods" >= PayrollSetup_g."Quantity Employed Years") then
//                 Amount_p := 1;
//         end;
//     end;

//     local procedure CheckDate(Day_p: Integer; Month_p: Integer; Year_p: Integer) Date_p: Date
//     var
//         Temp_l: Integer;
//     begin
//         Temp_l := Day_p;

//         if (Day_p > Date2DMY(CalcDate('<+1M-1D>', DMY2Date(1, Month_p, Year_p)), 1)) then   // Wenn Schaltjahr bzw. 29 Februar ungültig
//             Day_p -= 1;                                                          // dann - 1 Tag

//         if (Evaluate(Date_p, Format(Day_p) + '.' + Format(Month_p) + '.' + Format(Year_p))) then  // Datumsformat europäisch testen (konvertieren)
//             exit(Date_p);
//         if (Evaluate(Date_p, Format(Year_p) + '.' + Format(Month_p) + '.' + Format(Temp_l))) then  // Datumsformat amerikanisch testen (konvertieren)
//             exit(Date_p);

//         Date_p := DMY2Date(Date2DMY(CalcDate('<+1M-1D>', DMY2Date(1, Month_p, Year_p)), 1), Month_p, Year_p);  // Wenn keines funktioniert, dann letzter des Monats
//     end;

//     local procedure CalculatePeriod(CompanyName_p: Text[30]; From_p: Date; To_p: Date): Decimal
//     var
//         Date_l: Record Date;
//         Amount_l: Decimal;
//         Temp_l: Decimal;
//         Days_l: Decimal;
//         i: Integer;
//         LeapYear_l: Integer;
//         LeapYearDate_l: Date;
//     begin
//         PayrollSetup_g.ChangeCompany(CompanyName_p);
//         PayrollSetup_g.Get();
//         if ((From_p = 0D) or (To_p = 0D)) then
//             exit(0);
//         if (To_p < From_p) then
//             ERRor(Txt001Lbl, To_p, From_p);

//         // MAFA Part für Rechnung "ganze inkl. angebrochene" und "nur ganze"
//         if (PayrollSetup_g."Period Calc. Employed Years" <> 2) then begin
//             Date_l.SetRange("Period Type", PayrollSetup_g."Period Employed Years");
//             Date_l.SetRange("Period Start", From_p, To_p);
//             Amount_l := Date_l.Count();

//             if (PayrollSetup_g."Period Calc. Employed Years" = 1) then begin
//                 if ((Amount_l > 1) and (Date_l.Find('+'))) then begin
//                     if (NormalDate(Date_l."Period End")) > To_p then
//                         Amount_l -= 1;
//                 end;
//             end else begin
//                 if (Date_l.Find('-')) then
//                     Temp_l += Date_l."Period Start" - From_p;
//                 if (Date_l.Find('+')) then
//                     Temp_l += To_p - NormalDate(Date_l."Period End");

//                 case (PayrollSetup_g."Period Employed Years") of
//                     0:
//                         Amount_l += Temp_l;
//                     1:
//                         Amount_l += Temp_l / 7;
//                     2:
//                         Amount_l += Temp_l / 30.416;
//                     3:
//                         Amount_l += Temp_l / 91.25;
//                     4:
//                         Amount_l += Temp_l / 365;
//                 end;
//             end;
//         end else begin                                                      // THHE neu für Rechnungen pro Rata - Immer in Tagen
//             Date_l.SetRange("Period Type", 0);
//             Date_l.SetRange("Period Start", From_p, To_p);

//             Days_l := Date_l.Count();

//             //Schleife zum herausfinden der Schaltjahre innerhalb der Periode
//             For i := Date2DMY(From_p, 3) TO Date2DMY(To_p, 3) DO begin
//                 LeapYearDate_l := CalcDate('<+CM>', DMY2Date(1, 2, i));              //Monatsende des Februars
//                 if ((LeapYearDate_l >= From_p) and (LeapYearDate_l <= To_p)) then begin
//                     if (Date2DMY(LeapYearDate_l, 1) = 29) then                         //Wenn Februar 29ten hat
//                         LeapYear_l += 1;
//                 end;
//             end;

//             Days_l -= LeapYear_l;                                                //Schaltjahre werden abgezogen
//             Amount_l := Days_l / 365 * 12;

//             if (Date_l.Find('-')) then
//                 Temp_l += Date_l."Period Start" - From_p;
//             if (Date_l.Find('+')) then
//                 Temp_l += To_p - NorMALDATE(Date_l."Period End");

//             CASE PayrollSetup_g."Period Employed Years" OF
//                 0:
//                     Amount_l += Temp_l;
//                 1:
//                     Amount_l += Temp_l / 7;              // 365 / 52
//                 2:
//                     Amount_l += Temp_l / 30.416;         // 365 / 12
//                 3:
//                     Amount_l += Temp_l / 91.25;          // 365 / 4
//                 4:
//                     Amount_l += Temp_l / 365;
//             end;
//         end;

//         exit(Amount_l);
//     end;

//     local procedure CalculateYears(var EmployedYears_p: Record "SwS Employed Years")
//     begin
//         PayrollSetup_g.Get();
//         CASE PayrollSetup_g."Period Calc. Employed Years" OF
//             0:
//                 EmployedYears_p.Validate("Employed Years calculated", ROUND(EmployedYears_p."Number of Periods" / PayrollSetup_g."Quantity Employed Years", 1, '<'));
//             1:
//                 EmployedYears_p.Validate("Employed Years calculated", ROUND(EmployedYears_p."Number of Periods" / PayrollSetup_g."Quantity Employed Years", 1, '<'));
//             2:
//                 EmployedYears_p.Validate("Employed Years calculated", EmployedYears_p."Number of Periods" / 12);
//         end;
//     end;

//     local procedure Recalculate()
//     var
//         EmployedYears_l: Record "SwS Employed Years";
//     begin
//         if (not PayrollSetup_g.Get()) then
//             PayrollSetup_g.Init();

//         EmployedYears_l.Reset();

//         if (EmployedYears_l.Find('-')) then begin
//             repeat
//                 EmployedYears_l.Validate("Date to");
//                 EmployedYears_l.MODifY(TRUE);
//             until (EmployedYears_l.Next() = 0);
//         end;
//     end;

//     local procedure CalcDays(From_p: Date; Until_p: Date): Integer
//     var
//         Days_l: Integer;
//     begin
//         if (Until_p = 0D) then
//             Until_p := WorKDATE;

//         if (From_p >= Until_p) then
//             exit(0)
//         else
//             exit((Until_p - From_p) - CalcLeapDays(From_p, Until_p) + 1);
//     end;

//     local procedure CalcLeapDays(From_p: Date; Until_p: Date) Days_p: Integer
//     var
//         UltimoFeb_l: Date;
//     begin
//         Days_p := 0;

//         repeat
//             UltimoFeb_l := DMY2Date(1, 2, Date2DMY(From_p, 3));
//             UltimoFeb_l := CalcDate('+LM', UltimoFeb_l);

//             if ((Date2DMY(UltimoFeb_l, 1) = 29) and (From_p <= UltimoFeb_l) and (Until_p >= UltimoFeb_l)) then
//                 Days_p := Days_p + 1;

//             From_p := DMY2Date(1, 1, Date2DMY(From_p, 3) + 1);
//         until (From_p >= Until_p);
//     end;
// }
