------------------------------------------------------------------------------
--                                                                          --
--                           GPR2 PROJECT MANAGER                           --
--                                                                          --
--                     Copyright (C) 2019-2020, AdaCore                     --
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

with Ada.Directories;
with Ada.Strings.Fixed;
with Ada.Text_IO;

with GPR2.Unit;
with GPR2.Context;
with GPR2.Path_Name;
with GPR2.Project.Source.Artifact;
with GPR2.Project.Source.Set;
with GPR2.Project.View;
with GPR2.Project.Tree;
with GPR2.Source;
with GPR2.Source_Info.Parser.Ada_Language;

with U3;

procedure Main is

   use Ada;
   use GPR2;
   use GPR2.Project;

   procedure Check (Project_Name : Name_Type);
   --  Do check the given project's sources

   procedure Output_Filename (Filename : Path_Name.Full_Name);
   --  Remove the leading tmp directory

   -----------
   -- Check --
   -----------

   procedure Check (Project_Name : Name_Type) is
      Prj  : Project.Tree.Object;
      Ctx  : Context.Object;
      View : Project.View.Object;
   begin
      Project.Tree.Load (Prj, Create (Project_Name), Ctx);

      View := Prj.Root_Project;
      Text_IO.Put_Line ("Project: " & String (View.Name));

      for Source of View.Sources loop
         declare
            S : constant GPR2.Source.Object := Source.Source;
            D : Path_Name.Object;
         begin
            Output_Filename (S.Path_Name.Value);

            Text_IO.Set_Col (20);
            Text_IO.Put ("   language: " & String (S.Language));

            if S.Has_Units then
               for K in Source_Info.Unit_Index range 1 .. 5 loop
                  if S.Has_Unit_At (K) then
                     Text_IO.Set_Col (40);
                     Text_IO.Put ("Kind: "
                                  & GPR2.Unit.Library_Unit_Type'Image (S.Kind (K)));
                     Text_IO.Put_Line ("   unit: " & String (S.Unit_Name (K)));
                     if Source.Artifacts.Has_Dependency (Integer (K)) then
                        D := Source.Artifacts.Dependency (Integer (K));
                        if D.Exists then
                           Text_IO.Set_Col (40);
                           Text_IO.Put_Line
                             ("deps: " & String (D.Simple_Name));
                           Directories.Delete_File (D.Value);
                        end if;
                     end if;
                  end if;
               end loop;
            end if;
         end;
      end loop;
   end Check;

   ---------------------
   -- Output_Filename --
   ---------------------

   procedure Output_Filename (Filename : Path_Name.Full_Name) is
      I : constant Positive := Strings.Fixed.Index (Filename, "source-ali");
   begin
      Text_IO.Put (" > " & Filename (I + 8 .. Filename'Last));
   end Output_Filename;

begin
   U3;
   for J in Boolean loop
      Check ("source_ali.gpr");
   end loop;
end Main;
