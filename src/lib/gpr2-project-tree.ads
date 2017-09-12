------------------------------------------------------------------------------
--                                                                          --
--                           GPR2 PROJECT MANAGER                           --
--                                                                          --
--         Copyright (C) 2016-2017, Free Software Foundation, Inc.          --
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

with Ada.Iterator_Interfaces;

with GPR2.Context;
with GPR2.Log;
with GPR2.Message;
with GPR2.Project.Configuration;
pragma Elaborate (GPR2.Project.Configuration);
--  Elaborate to avoid a circular dependency due to default Elaborate_Body
with GPR2.Project.View;

limited with GPR2.Unit;

private with Ada.Containers.Indefinite_Ordered_Maps;
private with GPR2.Project.Definition;

package GPR2.Project.Tree is

   use type GPR2.Context.Object;
   use type GPR2.Project.View.Object;
   use type Ada.Containers.Count_Type;

   type Object is tagged limited private
     with Constant_Indexing => Constant_Reference,
          Default_Iterator  => Iterate,
          Iterator_Element  => View.Object;

   subtype Project_Tree is Object;

   Undefined : constant Object;

   function "=" (Left, Right : Object) return Boolean;
   --  Returns True if Left and Right are the same tree

   procedure Load
     (Self     : in out Object;
      Filename : Path_Name_Type;
      Context  : GPR2.Context.Object;
      Config   : Configuration.Object := Configuration.Undefined);
   --  Load a root-project

   procedure Load_Configuration
     (Self     : in out Object;
      Filename : Path_Name_Type);
   --  Load a configuration project for this tree

   procedure Unload (Self : in out Object);
   --  Unload the tree and free all associated objects (projects, sources,
   --  etc...).

   function Root_Project (Self : Object) return View.Object
     with Pre  => Self /= Undefined,
          Post => Root_Project'Result /= View.Undefined;
   --  Returns the root project for the given tree

   function Has_Configuration_Project (Self : Object) return Boolean;
   --  Returns True if a configuration project is loaded on this tree

   function Configuration_Project (Self : Object) return View.Object
     with Pre => Self /= Undefined and then Self.Has_Configuration_Project;
   --  Returns the configuration project for the given tree

   function Has_Runtime_Project (Self : Object) return Boolean;
   --  Returns True if a configuration project is loaded on this tree

   function Runtime_Project (Self : Object) return View.Object
     with Pre => Self /= Undefined and then Self.Has_Runtime_Project;
   --  Returns the configuration project for the given tree

   function Target (Self : Object) return Name_Type;
   --  Return the target for the project tree

   function Runtime
     (Self : Object; Language : Name_Type) return Optional_Name_Type;
   --  Returns the runtime selected for the given language or the empty string
   --  if no specific runtime has been configured for this project tree.

   function View_For
     (Self : Object;
      Name : Name_Type;
      Ctx  : Context.Object) return View.Object;
   --  Returns the project's view in the tree which corresponds to project name
   --  and that is matching the context. The context is needed as in the tree
   --  the same project can have different views with different context (e.g.
   --  under an aggregate project which is redefining some external variables).
   --  Given the context we are not sure of the uniqueness of the view, but
   --  this doesn't matter as all views of the same project with the same
   --  context will have the exact same definition. Returns Undefined if the
   --  view was not found.

   function Has_Messages (Self : Object) return Boolean;
   --  Returns whether some messages are present for this project tree

   function Log_Messages (Self : Object) return not null access Log.Object
     with Post => not Self.Has_Messages or else Log_Messages'Result.Count > 0;
   --  Returns the Logs, this contains information, warning and error messages
   --  found while handling the project.

   procedure Append_Message
     (Self    : in out Object;
      Message : GPR2.Message.Object);
   --  Add new message into the Log of Self

   --  Context

   --  Note that the context of the project tree corresponds to the context of
   --  the root project view.

   function Has_Context (Self : Object) return Boolean
     with Pre  => Self /= Undefined;
   --  Returns True if the project tree has some context. If any of the project
   --  in the tree has some external variables then a context is present. A
   --  project without context is fully static has it does not reference any
   --  external (and so modifiable) variables.

   function Context (Self : Object) return Context.Object
     with Pre  => Self /= Undefined,
          Post => Self.Has_Context = (Context'Result /= GPR2.Context.Empty);
   --  Returns the Context for the given project tree

   procedure Set_Context
     (Self    : in out Object;
      Context : GPR2.Context.Object;
      Changed : access procedure (Project : View.Object) := null)
     with Pre  => Self /= Undefined,
          Post => Self.Context = Context;
   --  Set the context for the project tree. The callback Changed is called for
   --  any project view which is impacted by this change of context. That is,
   --  if the project view does reference directly or indirectly an external
   --  variable.

   --  Iterator

   type Cursor is private;

   No_Element : constant Cursor;

   function Element (Position : Cursor) return View.Object
     with Post =>
       (if Has_Element (Position)
        then Element'Result /= View.Undefined
        else Element'Result = View.Undefined);

   function Has_Element (Position : Cursor) return Boolean;

   package Project_Iterator is
     new Ada.Iterator_Interfaces (Cursor, Has_Element);

   function Is_Root (Position : Cursor) return Boolean;
   --  Returns True if the cursor is pointing to the root project

   type Constant_Reference_Type
     (View : not null access constant Project.View.Object) is private
     with Implicit_Dereference => View;

   function Constant_Reference
     (Self     : aliased Object;
      Position : Cursor) return Constant_Reference_Type;

   function Iterate
     (Self   : Object;
      Kind   : Iterator_Kind := I_Default;
      Filter : Project_Filter := F_Default)
      return Project_Iterator.Forward_Iterator'Class
     with Pre => Kind /= I_Invalid;
   --  Iterate over all project views in the tree given the iterator kind (only
   --  the project with or without imports) and the filter which can be used to
   --  iterate over only some specific projects (only the library projects for
   --  example).

   --  Unit/View

   procedure Record_View
     (Self   : in out Object;
      View   : GPR2.Project.View.Object;
      Source : Full_Path_Name;
      Unit   : Name_Type)
     with Pre => Self /= Undefined;
   --  Record the view in which unit is defined

   procedure Clear_View
     (Self : in out Object;
      Unit : GPR2.Unit.Object)
     with Pre => Self /= Undefined;
   --  Clear the view set for the given unit

   function Get_View
     (Self : Object;
      Unit : Name_Type) return Project.View.Object
     with Pre => Self /= Undefined;
   --  Get the view in which unit is defined, returns Undefined if the unit
   --  has not been found.

   function Get_View
     (Self   : Object;
      Source : Path_Name_Type) return Project.View.Object
     with Pre => Self /= Undefined;
   --  Get the view in which unit is defined, returns Undefined if the unit
   --  has not been found.

   procedure Update_Sources (Self : Object)
     with Pre => Self /= Undefined;
   --  Ensure that all views' sources are up-to-date. This is needed before
   --  computing the dependecies of a source in the project tree. This routine
   --  is called where needed and is there for internal use only.

private

   package Name_View is
     new Ada.Containers.Indefinite_Ordered_Maps (Name_Type, View.Object);
   --  Map to find in which view a unit/source is defined

   type Object is tagged limited record
      Self     : not null access Object := Object'Unchecked_Access;
      Root     : View.Object;
      Conf     : Configuration.Object;
      Runtime  : View.Object;
      Units    : Name_View.Map;
      Sources  : Name_View.Map;
      Messages : aliased Log.Object;
   end record;

   function "=" (Left, Right : Object) return Boolean
     is  (Left.Self = Right.Self);

   type Cursor is record
      Views   : Definition.Project_View_Store.Vector;
      Current : Positive;
      Root    : View.Object;
   end record;

   type Constant_Reference_Type
     (View : not null access constant Project.View.Object) is null record;

   Undefined  : constant Object :=
                  (Self     => <>,
                   Root     => View.Undefined,
                   Conf     => Configuration.Undefined,
                   Runtime  => View.Undefined,
                   Units    => <>,
                   Sources  => <>,
                   Messages => <>);

   No_Element : constant Cursor :=
                  (Definition.Project_View_Store.Empty_Vector,
                   1, View.Undefined);

end GPR2.Project.Tree;
