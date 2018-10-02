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

with Ada.Text_IO;

with GPR2.Path_Name;

procedure Main is

   use Ada;
   use GPR2;

   P1 : constant Path_Name.Object :=
          Path_Name.Create_File ("/dir1/dir2/toto");
   P2 : constant Path_Name.Object :=
          Path_Name.Create_File ("/dir1/dir2/dir3/toto");
   P3 : constant Path_Name.Object :=
          Path_Name.Create_File ("/dira/toto");
   P4 : constant Path_Name.Object :=
          Path_Name.Create_File ("/xyz");

   function Remove_Drive_Letter (Path : String) return String is
   begin
      if Path'Length > 2 and then not (Path (Path'First) in '/' | '\') then
         return Path (Path'First + 2 .. Path'Last);
      else
         return Path;
      end if;
   end Remove_Drive_Letter;

begin
   Text_IO.Put_Line
     ("1: " & Remove_Drive_Letter (P1.Common_Prefix (P2).Value));
   Text_IO.Put_Line
     ("2: " & Remove_Drive_Letter (P2.Common_Prefix (P3).Value));
   Text_IO.Put_Line
     ("3: " & Remove_Drive_Letter (P3.Common_Prefix (P3).Value));
   Text_IO.Put_Line
     ("4: " & Remove_Drive_Letter (P3.Common_Prefix (P4).Value));
end Main;