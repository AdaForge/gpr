------------------------------------------------------------------------------
--                                                                          --
--                           GPR2 PROJECT MANAGER                           --
--                                                                          --
--                       Copyright (C) 2019, AdaCore                        --
--                                                                          --
-- This is  free  software;  you can redistribute it and/or modify it under --
-- terms of the  GNU  General Public License as published by the Free Soft- --
-- ware  Foundation;  either version 3,  or (at your option) any later ver- --
-- sion.  This software is distributed in the hope  that it will be useful, --
-- but WITHOUT ANY WARRANTY;  without even the implied warranty of MERCHAN- --
-- TABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public --
-- License for more details.  You should have received  a copy of the  GNU  --
-- General Public License distributed with GNAT; see file  COPYING. If not, --
-- see <http://www.gnu.org/licenses/>.                                      --
--                                                                          --
------------------------------------------------------------------------------

with Ada.Strings.Unbounded;

with GPR2.Containers;

package body GPR2.Project.Typ is

   -----------
   -- Image --
   -----------

   overriding function Image
     (Self     : Object;
      Name_Len : Natural := 0) return String
   is
      use Ada.Strings.Unbounded;

      Name   : constant String := String (Self.Name.Text);
      Result : Unbounded_String := To_Unbounded_String ("type ");
   begin
      Append (Result, Name);

      if Name_Len > 0 and then Name'Length < Name_Len then
         Append (Result, (Name_Len - Name'Length) * ' ');
      end if;

      Append (Result, " is ");
      Append (Result, Containers.Image (Self.Values));

      Append (Result, ';');

      return To_String (Result);
   end Image;

end GPR2.Project.Typ;
