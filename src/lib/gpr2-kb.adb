------------------------------------------------------------------------------
--                                                                          --
--                           GPR2 PROJECT MANAGER                           --
--                                                                          --
--                    Copyright (C) 2019-2020, AdaCore                      --
--                                                                          --
-- This library is free software;  you can redistribute it and/or modify it --
-- under terms of the  GNU General Public License  as published by the Free --
-- Software  Foundation;  either version 3,  or (at your  option) any later --
-- version. This library is distributed in the hope that it will be useful, --
-- but WITHOUT ANY WARRANTY;  without even the implied warranty of MERCHAN- --
-- TABILITY or FITNESS FOR A PARTICULAR PURPOSE.                            --
--                                                                          --
-- As a special exception under Section 7 of GPL version 3, you are granted --
-- additional permissions described in the GCC Runtime Library Exception,   --
-- version 3.1, as published by the Free Software Foundation.               --
--                                                                          --
-- You should have received a copy of the GNU General Public License and    --
-- a copy of the GCC Runtime Library Exception along with this program;     --
-- see the files COPYING3 and COPYING.RUNTIME respectively.  If not, see    --
-- <http://www.gnu.org/licenses/>.                                          --
--                                                                          --
------------------------------------------------------------------------------

with GNATCOLL.VFS;
with GNATCOLL.VFS_Utils;

with GPR2.KB.Parsing;

package body GPR2.KB is

   function Query_Targets_Set
     (Self   : Object;
      Target : Name_Type) return Targets_Set_Id
     with Pre => Self.Is_Defined;
   --  Gets the target alias set id for a target, or Unknown_Targets_Set_Id if
   --  no such target is in the base.

   ---------
   -- Add --
   ---------

   procedure Add
     (Self     : in out Object;
      Flags    : Parsing_Flags;
      Location : GPR2.Path_Name.Object) is
   begin
      if Self.Parsed_Directories.Contains (Location) then
         --  Do not parse several times the same database directory
         return;
      end if;

      Self.Parsed_Directories.Append (Location);
      Parsing.Parse_Knowledge_Base (Self, Location, Flags);
   end Add;

   ---------
   -- Add --
   ---------

   procedure Add
     (Self    : in out Object;
      Flags   : Parsing_Flags;
      Content : Value_Not_Empty) is
   begin
      Parsing.Add (Self, Flags, Content);
   end Add;

   -------------------
   -- Configuration --
   -------------------

   function Configuration
     (Self     : Object;
      Settings : GPR2.Project.Configuration.Description_Set;
      Target   : Name_Type) return GPR2.Project.Configuration.Object is
   begin
      return GPR2.Project.Configuration.Undefined;
   end Configuration;

   ------------
   -- Create --
   ------------

   function Create
     (Flags      : Parsing_Flags := Targetset_Only_Flags;
      Default_KB : Boolean := True;
      Custom_KB  : GPR2.Path_Name.Set.Object := GPR2.Path_Name.Set.Empty_Set)
      return Object
   is
      Result : Object;
   begin
      if Default_KB then
         Result := Create_Default (Flags => Flags);
      else
         Result := Create_Empty;
      end if;

      for Location of Custom_KB loop
         Result.Add (Flags, Location);
      end loop;

      return Result;
   end Create;

   ------------
   -- Create --
   ------------

   function Create
     (Content : GPR2.Containers.Value_List;
      Flags   : Parsing_Flags) return Object
   is
      Result : Object := Create_Empty;
   begin
      for Cont of Content loop
         if Cont /= "" then
            Result.Add (Flags, Cont);
         end if;
      end loop;

      return Result;
   end Create;

   ------------
   -- Create --
   ------------

   function Create
     (Location : GPR2.Path_Name.Object;
      Flags   : Parsing_Flags) return Object
   is
      Result    : Object := Create_Empty;
   begin
      Result.Parsed_Directories.Append (Location);
      Parsing.Parse_Knowledge_Base (Result, Location, Flags);

      return Result;
   end Create;

   --------------------
   -- Create_Default --
   --------------------

   function Create_Default
     (Flags : Parsing_Flags) return Object
   is
      Ret : Object;
   begin
      Ret := Parsing.Parse_Default_Knowledge_Base (Flags);
      Ret.Is_Default := True;

      return Ret;
   end Create_Default;

   ------------------
   -- Create_Empty --
   ------------------

   function Create_Empty return Object
   is
      Result : Object;
   begin
      Result.Initialized := True;
      Result.Is_Default  := False;
      return Result;
   end Create_Empty;

   --------------------------------------
   -- Default_Knowledge_Base_Directory --
   --------------------------------------

   function Default_Location return GPR2.Path_Name.Object is
      use GNATCOLL.VFS;
      use GNATCOLL.VFS_Utils;

      GPRconfig : Filesystem_String_Access :=
                    Locate_Exec_On_Path ("gprconfig");
      Dir       : Virtual_File;
   begin
      if GPRconfig = null then
         return GPR2.Path_Name.Undefined;
      end if;

      Dir := Get_Parent (Create (Dir_Name (GPRconfig.all)));

      Free (GPRconfig);

      if Dir = No_File then
         raise Default_Location_Error;
      end if;

      Dir := Dir.Join ("share").Join ("gprconfig");

      return GPR2.Path_Name.Create_Directory
        (Optional_Name_Type (Dir.Display_Full_Name));
   end Default_Location;

   -------------------
   -- Fallback_List --
   -------------------

   function Fallback_List
     (Self   : Object;
      Target : Name_Type) return GPR2.Containers.Name_List
   is
      pragma Unreferenced (Self, Target);
      use GPR2.Containers.Name_Type_List;
   begin
      return Empty_Vector;
   end Fallback_List;

   -----------------------
   -- Normalized_Target --
   -----------------------

   function Normalized_Target
     (Self   : Object;
      Target : Name_Type) return Name_Type
   is
      Result : Target_Set_Description;
   begin
      Result := Targets_Set_Vectors.Element
        (Self.Targets_Sets, Self.Query_Targets_Set (Target));

      return Name_Type (To_String (Result.Name));
   exception
      when others =>
         return "unknown";
   end Normalized_Target;

   -----------------------
   -- Query_Targets_Set --
   -----------------------

   function Query_Targets_Set
     (Self   : Object;
      Target : Name_Type) return Targets_Set_Id
   is
      use Targets_Set_Vectors;
      use Target_Lists;

      Tgt : constant String := String (Target);
   begin
      if Target = "" then
         return All_Target_Sets;
      end if;

      for I in
        First_Index (Self.Targets_Sets) .. Last_Index (Self.Targets_Sets)
      loop
         declare
            Set : constant Target_Lists.List :=
                    Targets_Set_Vectors.Element
                      (Self.Targets_Sets, I).Patterns;
            C   : Target_Lists.Cursor := First (Set);
         begin
            while Has_Element (C) loop
               if GNAT.Regpat.Match
                 (Target_Lists.Element (C), Tgt) > Tgt'First - 1
               then
                  return I;
               end if;

               Next (C);
            end loop;
         end;
      end loop;

      return Unknown_Targets_Set;
   end Query_Targets_Set;

   -------------
   -- Release --
   -------------

   procedure Release (Self : in out Object) is
   begin
      null;
   end Release;

end GPR2.KB;
