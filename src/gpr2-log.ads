------------------------------------------------------------------------------
--                                                                          --
--                           GPR2 PROJECT MANAGER                           --
--                                                                          --
--            Copyright (C) 2016, Free Software Foundation, Inc.            --
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

--  This package is used to store the log messages (error/warning/information)
--  coming from the parser.

with Ada.Iterator_Interfaces;

with GPR2.Containers;
with GPR2.Message;

private with Ada.Containers.Vectors;

package GPR2.Log is

   use type Containers.Count_Type;
   use type Message.Object;

   type Object is tagged private
     with Constant_Indexing => Constant_Reference,
          Default_Iterator  => Iterate,
          Iterator_Element  => Message.Object;

   procedure Append
     (Self    : in out Object;
      Message : GPR2.Message.Object)
     with Post => Self.Count'Old + 1 = Self.Count;
   --  Insert a log message into the object

   function Count (Self : Object) return Containers.Count_Type
     with Post =>
       (if Self.Has_Element then Count'Result > 0 else Count'Result = 0);
   --  Returns the number of message in the log object

   function Is_Empty (Self : Object) return Boolean
     with Post => Self.Count > 0 xor Is_Empty'Result;
   --  Returns True if the log contains no message

   procedure Clear (Self : in out Object)
     with Post => Self.Count = 0;
   --  Removes all message from the log

   function Element
     (Self     : Object;
      Position : Positive) return GPR2.Message.Object
     with Pre => Containers.Count_Type (Position) <= Self.Count;
   --  Returns the message at the given position

   function Has_Element
     (Self        : Object;
      Information : Boolean := True;
      Warning     : Boolean := True;
      Error       : Boolean := True) return Boolean;
   --  Returns True if the log contains some information/warning/error
   --  depending on the value specified.

   --  Iterator

   type Cursor is private;

   No_Element : constant Cursor;

   function Element (Position : Cursor) return Message.Object
     with Post =>
       (if Has_Element (Position)
        then Element'Result /= Message.Undefined
        else Element'Result = Message.Undefined);

   function Has_Element (Position : Cursor) return Boolean;

   package Project_Iterator is
     new Ada.Iterator_Interfaces (Cursor, Has_Element);

   type Constant_Reference_Type
     (Message : not null access constant GPR2.Message.Object) is private
     with Implicit_Dereference => Message;

   function Constant_Reference
     (Self     : aliased in out Object;
      Position : Cursor) return Constant_Reference_Type;

   function Iterate
     (Self        : Object;
      Information : Boolean := True;
      Warning     : Boolean := True;
      Error       : Boolean := True)
      return Project_Iterator.Forward_Iterator'Class;
   --  Iterate over all log messages corresponding to the given Filter

private

   package Message_Set is
     new Ada.Containers.Vectors (Positive, Message.Object);

   type Object is tagged record
      Store : Message_Set.Vector;
   end record;

   type Cursor is record
      Store : Message_Set.Vector;
      P     : Natural;
   end record;

   No_Element : constant Cursor := (P => 0, Store => <>);

   type Constant_Reference_Type
     (Message : not null access constant GPR2.Message.Object) is null record;

end GPR2.Log;