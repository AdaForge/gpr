------------------------------------------------------------------------------
--                                                                          --
--                           GPR2 PROJECT MANAGER                           --
--                                                                          --
--            Copyright (C) 2018, Free Software Foundation, Inc.            --
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

with Ada.Directories;

with GNAT.OS_Lib;

with GPR.Tempdir;
with GPR.Util;

package body GPR2.Path_Name is

   --  From old GPR

   function Temporary_Directory
     return String renames GPR.Tempdir.Temporary_Directory_Path;

   function Ensure_Directory
     (Path : String) return String renames GPR.Util.Ensure_Directory;

   -------------
   -- Compose --
   -------------

   function Compose
     (Self : Object; Name : Name_Type) return Object is
   begin
      return Create_File
        (Name_Type
           (Ensure_Directory (To_String (Self.As_Is)) & String (Name)));
   end Compose;

   ------------
   -- Create --
   ------------

   function Create (Name, Path_Name : Name_Type) return Object is
      use Ada;

      function "+"
        (Str : String) return Unbounded_String renames To_Unbounded_String;
   begin
      return Object'
        (As_Is     => +String (Name),
         Value     => +String (Path_Name),
         Base_Name => +Directories.Base_Name (String (Path_Name)),
         Dir_Name  => +Directories.Containing_Directory (String (Path_Name)));
   end Create;

   ----------------------
   -- Create_Directory --
   ----------------------

   function Create_Directory (Name : Name_Type) return Object is
      use Ada;
      use GNAT;

      function Ensure_Directory
        (Value : String) return String is
        (if Value (Value'Last) in '\' | '/'
         then Value & '.'
         else Value & OS_Lib.Directory_Separator & '.')
        with Post =>
          Ensure_Directory'Result (Ensure_Directory'Result'Last) = '.';

      function "+"
        (Str : String) return Unbounded_String renames To_Unbounded_String;

      N  : constant String := String (Name);
      NN : constant String := Ensure_Directory (OS_Lib.Normalize_Pathname (N));

   begin
      return Object'
        (As_Is     => +N,
         Value     => +NN,
         Base_Name => +Directories.Base_Name (N),
         Dir_Name  => +Directories.Containing_Directory (NN));
   end Create_Directory;

   -----------------
   -- Create_File --
   -----------------

   function Create_File (Name : Name_Type) return Object is
      use Ada;
      use GNAT;

      function "+"
        (Str : String) return Unbounded_String renames To_Unbounded_String;

      N : constant String := String (Name);
   begin
      return Object'
        (As_Is     => +N,
         Value     => +OS_Lib.Normalize_Pathname (N),
         Base_Name => +Directories.Base_Name (N),
         Dir_Name  => +Directories.Containing_Directory (N));
   end Create_File;

   -------------------------
   -- Temporary_Directory --
   -------------------------

   function Temporary_Directory return Object is
   begin
      return Create_Directory (Name_Type (String'(Temporary_Directory)));
   end Temporary_Directory;

   -----------
   -- Value --
   -----------

   function Value (Self : Object) return Full_Name is
   begin
      return To_String (Self.Value);
   end Value;

end GPR2.Path_Name;