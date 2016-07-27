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

with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

package body GPR2.Project.Attribute.Set is

   type Iterator is new Attribute_Iterator.Forward_Iterator with record
     Name  : Unbounded_String;
     Index : Unbounded_String;
     Set   : Object;
   end record;

   overriding function First
     (Iter : Iterator) return Cursor;

   overriding function Next
     (Iter : Iterator; Position : Cursor) return Cursor;

   function Is_Matching
     (Iter : Iterator'Class; Position : Cursor) return Boolean;
   --  Returns True if the current Position is matching the Iterator

   -----------
   -- Clear --
   -----------

   procedure Clear (Self : in out Object) is
   begin
      Self.Attributes.Clear;
      Self.Length := 0;
   end Clear;

   ------------------------
   -- Constant_Reference --
   ------------------------

   function Constant_Reference
     (Self     : aliased Object;
      Position : Cursor) return Constant_Reference_Type
   is
      pragma Unreferenced (Self);
   begin
      return Constant_Reference_Type'
        (Attribute =>
           Set_Attribute.Constant_Reference
             (Position.Set.all, Position.CA).Element);
   end Constant_Reference;

   --------------
   -- Contains --
   --------------

   function Contains
     (Self  : Object;
      Name  : Name_Type;
      Index : Value_Type := "") return Boolean
   is
      Position : constant Cursor := Self.Find (Name, Index);
   begin
      return Has_Element (Position);
   end Contains;

   -------------
   -- Element --
   -------------

   function Element (Position : Cursor) return Attribute.Object is
   begin
      return Set_Attribute.Element (Position.CA);
   end Element;

   function Element
     (Self  : Object;
      Name  : Name_Type;
      Index : Value_Type := "") return Attribute.Object
   is
      Position : constant Cursor := Self.Find (Name, Index);
   begin
      if Set_Attribute.Has_Element (Position.CA) then
         return Element (Position);
      else
         return Project.Attribute.Undefined;
      end if;
   end Element;

   ------------
   -- Filter --
   ------------

   function Filter
     (Self  : Object;
      Name  : Optional_Name_Type := "";
      Index : Value_Type := "") return Object is
   begin
      if Name = No_Name and then Index = No_Value then
         return Self;

      else
         declare
            Result : Object;
         begin
            for C in Self.Iterate (Name, Index) loop
               Result.Insert (Element (C));
            end loop;

            return Result;
         end;
      end if;
   end Filter;

   ----------
   -- Find --
   ----------

   function Find
     (Self  : Object;
      Name  : Name_Type;
      Index : Value_Type := "") return Cursor
   is
      Result : Cursor :=
                 (CM  => Self.Attributes.Find (Name_Type (Name)),
                  CA  => Set_Attribute.No_Element,
                  Set => null);
   begin
      if Set.Has_Element (Result.CM) then
         Result.Set := Self.Attributes.Constant_Reference (Result.CM).Element;
         Result.CA := Result.Set.Find (String (Index));
      end if;

      return Result;
   end Find;

   -----------
   -- First --
   -----------

   overriding function First (Iter : Iterator) return Cursor is
      Position : Cursor :=
                   (Iter.Set.Attributes.First,
                    CA  => Set_Attribute.No_Element,
                    Set => null);
   begin
      if Set.Has_Element (Position.CM) then
         Position.Set :=
           Iter.Set.Attributes.Constant_Reference (Position.CM).Element;
         Position.CA := Position.Set.First;
      end if;

      if not Is_Matching (Iter, Position) then
         return Next (Iter, Position);
      else
         return Position;
      end if;
   end First;

   -----------------
   -- Has_Element --
   -----------------

   function Has_Element (Position : Cursor) return Boolean is
   begin
      return Set_Attribute.Has_Element (Position.CA);
   end Has_Element;

   ------------
   -- Insert --
   ------------

   procedure Insert
     (Self : in out Object; Attribute : Project.Attribute.Object)
   is
      Position : constant Set.Cursor :=
                   Self.Attributes.Find (Name_Type (Attribute.Name));
   begin
      if Set.Has_Element (Position) then
         declare
            A : Set_Attribute.Map := Set.Element (Position);
         begin
            A.Insert  (To_String (Attribute.Index), Attribute);
            Self.Attributes.Replace_Element (Position, A);
         end;

      else
         declare
            A : Set_Attribute.Map;
         begin
            A.Insert (To_String (Attribute.Index), Attribute);
            Self.Attributes.Insert (Name_Type (Attribute.Name), A);
         end;
      end if;

      Self.Length := Self.Length + 1;
   end Insert;

   --------------
   -- Is_Empty --
   --------------

   function Is_Empty (Self : Object) return Boolean is
   begin
      return Self.Length = 0;
   end Is_Empty;

   -----------------
   -- Is_Matching --
   -----------------

   function Is_Matching
     (Iter : Iterator'Class; Position : Cursor) return Boolean
   is
      A     : constant Attribute.Object := Position.Set.all (Position.CA);
      Name  : constant Optional_Name_Type :=
                Optional_Name_Type (To_String (Iter.Name));
      Index : constant Value_Type := To_String (Iter.Index);
   begin
      return
        (Name = No_Name or else A.Name = Name_Type (Name))
        and then (Index = No_Value or else A.Index_Equal (Index));
   end Is_Matching;

   -------------
   -- Iterate --
   -------------

   function Iterate
     (Self  : Object;
      Name  : Optional_Name_Type := "";
      Index : Value_Type := "")
      return Attribute_Iterator.Forward_Iterator'Class is
   begin
      return It : Iterator do
         It.Set   := Self;
         It.Name  := To_Unbounded_String (String (Name));
         It.Index := To_Unbounded_String (String (Index));
      end return;
   end Iterate;

   ------------
   -- Length --
   ------------

   function Length (Self : Object) return Containers.Count_Type is
   begin
      return Self.Length;
   end Length;

   ----------
   -- Next --
   ----------

   overriding function Next
     (Iter : Iterator; Position : Cursor) return Cursor
   is

      procedure Next (Position : in out Cursor)
        with Post => Position'Old /= Position;
      --  Move Position to next element

      ----------
      -- Next --
      ----------

      procedure Next (Position : in out Cursor) is
      begin
         Position.CA := Set_Attribute.Next (Position.CA);

         if not Set_Attribute.Has_Element (Position.CA) then
            Position.CM := Set.Next (Position.CM);

            if Set.Has_Element (Position.CM) then
               Position.Set :=
                 Iter.Set.Attributes.Constant_Reference (Position.CM).Element;
               Position.CA := Position.Set.First;

            else
               Position.Set := null;
            end if;
         end if;
      end Next;

      Result : Cursor := Position;
   begin
      loop
         Next (Result);
         exit when not Has_Element (Result) or else Is_Matching (Iter, Result);
      end loop;

      return Result;
   end Next;

   ---------------
   -- Reference --
   ---------------

   function Reference
     (Self     : aliased in out Object;
      Position : Cursor) return Reference_Type
   is
      pragma Unreferenced (Self);
   begin
      return Reference_Type'
        (Attribute =>
           Set_Attribute.Reference (Position.Set.all, Position.CA).Element);
   end Reference;

end GPR2.Project.Attribute.Set;
