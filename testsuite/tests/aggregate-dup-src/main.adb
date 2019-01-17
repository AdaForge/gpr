------------------------------------------------------------------------------
--                                                                          --
--                           GPR2 PROJECT MANAGER                           --
--                                                                          --
--            Copyright (C) 2017, Free Software Foundation, Inc.            --
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
with Ada.Strings.Fixed;

with GPR2.Context;
with GPR2.Log;
with GPR2.Message;
with GPR2.Project.Tree;

procedure Main is

   use Ada;
   use GPR2;
   use GPR2.Project;

   Prj : Project.Tree.Object;
   Ctx : Context.Object;

begin
   Project.Tree.Load (Prj, Create ("demo.gpr"), Ctx);

   Prj.Update_Sources;

exception
   when Project_Error =>

      Text_IO.Put_Line ("Messages found:");

      for C in Prj.Log_Messages.Iterate (False, True, True, True, True) loop
         declare
            use Ada.Strings;
            use Ada.Strings.Fixed;
            M   : constant Message.Object := Log.Element (C);
            Mes : constant String := M.Format;
            L   : constant Natural := Fixed.Index (Mes, "/aggregate-dup-src/");
         begin
            if L /= 0 then
               Text_IO.Put_Line
                 (Replace_Slice
                    (Mes,
                     Fixed.Index (Mes (1 .. L), """", Going => Backward) + 1,
                     L - 1,
                     "<path>"));
            else
               Text_IO.Put_Line (Mes);
            end if;
         end;
      end loop;
end Main;