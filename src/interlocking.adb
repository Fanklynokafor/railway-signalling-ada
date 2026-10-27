package body Interlocking is
   Sections : Section_Array := (others => Clear);
   Detected_Point : Point_Position := Normal;
   Point_Failed : Boolean := False;
   Point_Locked : Boolean := False;
   Main_State : Route_State := Available;
   Diverging_State : Route_State := Available;

   function State (Route : Route_Id) return Route_State is
   begin
      if Route = Main_Route then
         return Main_State;
      else
         return Diverging_State;
      end if;
   end State;

   procedure Set_Route_State (Route : Route_Id; Value : Route_State) is
   begin
      if Route = Main_Route then
         Main_State := Value;
      else
         Diverging_State := Value;
      end if;
   end Set_Route_State;

   function Required_Point (Route : Route_Id) return Point_Position is
     (if Route = Main_Route then Normal else Reverse_Position);

   function Route_Sections_Clear (Route : Route_Id) return Result_Code is
      pragma Unreferenced (Route);
   begin
      --  Both illustrative routes share the approach, junction and overlap.
      --  The destination section differs. Fail closed on unknown detection.
      for Section in Section_Id loop
         if Sections (Section) = Unknown then
            return Rejected_Section_Unknown;
         elsif Sections (Section) = Occupied then
            return Rejected_Track_Not_Clear;
         end if;
      end loop;
      return Accepted;
   end Route_Sections_Clear;

   procedure Reset is
   begin
      Sections := (others => Clear);
      Detected_Point := Normal;
      Point_Failed := False;
      Point_Locked := False;
      Main_State := Available;
      Diverging_State := Available;
   end Reset;

   procedure Set_Section (Section : Section_Id; State : Section_State) is
   begin
      Sections (Section) := State;
   end Set_Section;

   procedure Set_Point_Detection (Position : Point_Position) is
   begin
      --  Sensor input is separate from the point command. Unknown is an
      --  explicit unsafe observation, not a convenient default.
      Detected_Point := Position;
   end Set_Point_Detection;

   procedure Set_Point_Failure (Failed : Boolean) is
   begin
      Point_Failed := Failed;
   end Set_Point_Failure;

   function Move_Point (Position : Point_Position) return Result_Code is
   begin
      if Point_Failed then
         return Rejected_Point_Failed;
      elsif Point_Locked then
         return Rejected_Point_Locked;
      elsif Position = Point_Unknown then
         return Rejected_Point_Not_Detected;
      else
         --  The simulator abstracts motor travel as instantaneous; a real
         --  controller would command movement and await independent proof.
         Detected_Point := Position;
         return Accepted;
      end if;
   end Move_Point;

   function Request_Route (Route : Route_Id) return Result_Code is
      Track_Result : Result_Code;
   begin
      if State (Route) /= Available then
         return Rejected_Route_Already_Set;
      elsif State (if Route = Main_Route then Diverging_Route else Main_Route)
        /= Available
      then
         return Rejected_Conflicting_Route;
      elsif Point_Failed then
         return Rejected_Point_Failed;
      elsif Detected_Point = Point_Unknown
        or else Detected_Point /= Required_Point (Route)
      then
         return Rejected_Point_Not_Detected;
      end if;

      Track_Result := Route_Sections_Clear (Route);
      if Track_Result /= Accepted then
         return Track_Result;
      end if;

      Point_Locked := True;
      Set_Route_State (Route, Set);
      return Accepted;
   end Request_Route;

   function Cancel_Route (Route : Route_Id) return Result_Code is
   begin
      if State (Route) = Available then
         return Rejected_Route_Not_Set;
      elsif Sections (Approach) = Unknown then
         return Rejected_Section_Unknown;
      elsif Sections (Approach) = Occupied then
         --  Keep the route and point locked if a train is approaching. This
         --  prototype intentionally has no timer-based approach-lock release.
         Set_Route_State (Route, Approach_Locked);
         return Rejected_Approach_Occupied;
      elsif Sections (Junction) = Occupied or else Sections (Overlap) = Occupied
        or else Sections (Platform) = Occupied
      then
         return Rejected_Track_Not_Clear;
      elsif Sections (Junction) = Unknown or else Sections (Overlap) = Unknown
        or else Sections (Platform) = Unknown
      then
         return Rejected_Section_Unknown;
      else
         Set_Route_State (Route, Available);
         Point_Locked := False;
         return Accepted;
      end if;
   end Cancel_Route;

   function Aspect (Route : Route_Id) return Signal_Aspect is
   begin
      --  A signal displays proceed only while its route is set and every
      --  required safety condition remains demonstrably valid.
      if State (Route) = Set
        and then not Point_Failed
        and then Detected_Point = Required_Point (Route)
        and then Route_Sections_Clear (Route) = Accepted
      then
         return Proceed;
      else
         return Stop;
      end if;
   end Aspect;

   function View return Snapshot is
   begin
      return (Sections => Sections, Point => Detected_Point,
              Point_Failed => Point_Failed, Point_Locked => Point_Locked,
              Main => Main_State, Diverging => Diverging_State);
   end View;

   function Image (Code : Result_Code) return String is
   begin
      case Code is
         when Accepted => return "accepted";
         when Rejected_Track_Not_Clear => return "track not clear";
         when Rejected_Point_Not_Detected => return "required point position not detected";
         when Rejected_Point_Failed => return "point failure";
         when Rejected_Point_Locked => return "point locked by a route";
         when Rejected_Conflicting_Route => return "conflicting route already set";
         when Rejected_Route_Already_Set => return "route is not available";
         when Rejected_Route_Not_Set => return "route is not set";
         when Rejected_Approach_Occupied => return "approach occupied; route remains locked";
         when Rejected_Section_Unknown => return "train detection unknown";
      end case;
   end Image;
end Interlocking;
