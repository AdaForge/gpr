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

--  This unit represent a unit object. This is useful for unit based language
--  like Ada. Note that we associate a spec with multiple bodies as we can
--  have a main body and a set of separate source.

with GPR2.Project.Source.Set;

package GPR2.Unit is

   use type Project.Source.Object;

   type Object is tagged private;

   function Create
     (Spec   : Project.Source.Object;
      Bodies : Project.Source.Set.Object) return Object;
   --  Constructor for a Unit object

   function Spec (Self : Object) return Project.Source.Object;
   --  Returns the Spec

   function Bodies (Self : Object) return Project.Source.Set.Object;
   --  Returns all bodies

   procedure Update_Spec
     (Self : in out Object; Source : Project.Source.Object)
     with Pre => Self.Spec = Project.Source.Undefined;
   --  Set unit spec

   procedure Update_Bodies
     (Self : in out Object; Source : Project.Source.Object);
   --  Set or append unit's body

private

   type Object is tagged record
      Spec   : Project.Source.Object;
      Bodies : Project.Source.Set.Object;
   end record;

   function Spec
     (Self : Object) return Project.Source.Object is (Self.Spec);

   function Bodies
     (Self : Object) return Project.Source.Set.Object is (Self.Bodies);

end GPR2.Unit;
