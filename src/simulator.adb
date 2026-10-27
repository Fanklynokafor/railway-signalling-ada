with Ada.Text_IO; use Ada.Text_IO;
with Interlocking; use Interlocking;

procedure Simulator is
   Result : Result_Code;
begin
   Reset;
   Put_Line ("Railway signalling interlocking simulation");
   Put_Line ("Prototype only — no operational authority");
   Put_Line ("Initial signal: " & Signal_Aspect'Image (Aspect (Main_Route)));

   Result := Move_Point (Normal);
   Put_Line ("Set point for main route: " & Image (Result));
   Result := Request_Route (Main_Route);
   Put_Line ("Request main route: " & Image (Result));
   Put_Line ("Main signal: " & Signal_Aspect'Image (Aspect (Main_Route)));

   Set_Section (Approach, Occupied);
   Result := Cancel_Route (Main_Route);
   Put_Line ("Cancel while approach occupied: " & Image (Result));
   Put_Line ("Main signal after cancellation request: " &
             Signal_Aspect'Image (Aspect (Main_Route)));
end Simulator;
