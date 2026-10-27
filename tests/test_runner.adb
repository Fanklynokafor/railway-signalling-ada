with Ada.Text_IO; use Ada.Text_IO;
with Interlocking; use Interlocking;

procedure Test_Runner is
   Checks : Natural := 0;

   procedure Check (Condition : Boolean; Label : String) is
   begin
      Checks := Checks + 1;
      if not Condition then
         Put_Line ("FAIL: " & Label);
         raise Program_Error with "test failed: " & Label;
      end if;
      Put_Line ("PASS: " & Label);
   end Check;
begin
   Reset;
   Check (Aspect (Main_Route) = Stop, "unset route stays at stop");
   Set_Point_Detection (Reverse_Position);
   Check (Request_Route (Main_Route) = Rejected_Point_Not_Detected,
          "wrong point position blocks route request");

   Reset;
   Set_Section (Junction, Unknown);
   Check (Request_Route (Main_Route) = Rejected_Section_Unknown,
          "unknown detection fails closed");
   Set_Section (Junction, Occupied);
   Check (Request_Route (Main_Route) = Rejected_Track_Not_Clear,
          "occupied track blocks route request");

   Reset;
   Set_Point_Failure (True);
   Check (Request_Route (Main_Route) = Rejected_Point_Failed,
          "point failure blocks route request");
   Check (Aspect (Main_Route) = Stop, "failed point cannot show proceed");

   Reset;
   Check (Move_Point (Normal) = Accepted, "point can be positioned while free");
   Check (Request_Route (Main_Route) = Accepted, "clear main route sets");
   Check (Aspect (Main_Route) = Proceed, "valid set route permits proceed");
   Check (Move_Point (Reverse_Position) = Rejected_Point_Locked,
          "route locks its required point position");
   Check (Request_Route (Diverging_Route) = Rejected_Conflicting_Route,
          "conflicting route is excluded");

   Set_Point_Failure (True);
   Check (Aspect (Main_Route) = Stop,
          "new point fault returns signal to stop");
   Check (View.Point_Locked, "fault does not release route point lock");
   Set_Point_Failure (False);
   Set_Section (Approach, Occupied);
   Check (Cancel_Route (Main_Route) = Rejected_Approach_Occupied,
          "approach occupancy retains route lock");
   Check (State (Main_Route) = Approach_Locked,
          "route records approach locking");
   Check (Aspect (Main_Route) = Stop,
          "cancelled approach-locked route displays stop");

   Set_Section (Approach, Clear);
   Check (Cancel_Route (Main_Route) = Accepted,
          "route releases after all detection is clear");
   Check (not View.Point_Locked, "point lock releases with route");
   Check (Cancel_Route (Main_Route) = Rejected_Route_Not_Set,
          "cannot cancel an unset route");
   Check (Move_Point (Point_Unknown) = Rejected_Point_Not_Detected,
          "unknown point command is rejected");

   Put_Line (Natural'Image (Checks) & " checks passed.");
end Test_Runner;
