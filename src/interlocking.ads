package Interlocking is
   --  Small enums keep impossible spelling variants out of the demo API.
   --  They are not a substitute for a railway signalling data model.
   --  A deliberately small, deterministic model. These names are local to the
   --  demo layout; they do not describe a real railway installation.
   type Section_Id is (Approach, Junction, Platform, Overlap);
   type Section_State is (Clear, Occupied, Unknown);
   type Point_Position is (Normal, Reverse_Position, Point_Unknown);
   type Route_Id is (Main_Route, Diverging_Route);
   type Route_State is (Available, Set, Approach_Locked, Failed);
   type Signal_Aspect is (Stop, Proceed);
   type Section_Array is array (Section_Id) of Section_State;
   type Result_Code is
     (Accepted, Rejected_Track_Not_Clear, Rejected_Point_Not_Detected,
      Rejected_Point_Failed, Rejected_Point_Locked,
      Rejected_Conflicting_Route, Rejected_Route_Already_Set,
      Rejected_Route_Not_Set, Rejected_Approach_Occupied,
      Rejected_Section_Unknown);

   type Snapshot is record
      Sections : Section_Array;
      Point    : Point_Position;
      Point_Failed : Boolean;
      Point_Locked : Boolean;
      Main      : Route_State;
      Diverging : Route_State;
   end record;

   procedure Reset;
   procedure Set_Section (Section : Section_Id; State : Section_State);
   procedure Set_Point_Detection (Position : Point_Position);
   procedure Set_Point_Failure (Failed : Boolean);
   function Move_Point (Position : Point_Position) return Result_Code;
   function Request_Route (Route : Route_Id) return Result_Code;
   function Cancel_Route (Route : Route_Id) return Result_Code;
   function Aspect (Route : Route_Id) return Signal_Aspect;
   function State (Route : Route_Id) return Route_State;
   function View return Snapshot;
   function Image (Code : Result_Code) return String;
end Interlocking;
