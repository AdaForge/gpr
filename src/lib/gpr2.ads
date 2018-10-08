------------------------------------------------------------------------------
--                                                                          --
--                           GPR2 PROJECT MANAGER                           --
--                                                                          --
--         Copyright (C) 2016-2018, Free Software Foundation, Inc.          --
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
--
--  This is the root package of the GPR2 project support library. There is
--  different child units:
--
--     Parser
--        This child unit and all the children are for the low-level parsing
--        and support. This layer is based on the LangKit parser.
--
--     Project
--        This child unit and all the children are the high-level API to
--         work with projects. This is the end-user API.
--
--     Message
--        Messages (warnings, error,information) with source reference
--
--     Context
--        Context of a project
--
--     Builtin
--        The project's build-in implementation
--
--     Log
--        Set of messages
--
--     Source
--        Represent a source file
--
--     Source_Reference
--        Represent a source file reference (line, column).
--
--     Unit
--        A unit with its spec and possible bodies

package GPR2 is

   Project_Error : exception;
   --  Raised when an error occurs. This exception is raised with a minimal
   --  message but the actual messages are to be found in the Tree log
   --  messages.

   type Project_Kind is
     (K_Configuration, K_Abstract,
      K_Standard, K_Library, K_Aggregate, K_Aggregate_Library);

   subtype Aggregate_Kind
     is Project_Kind range K_Aggregate .. K_Aggregate_Library;

   function Image (Kind : Project_Kind) return String;
   --  Returns a human representation of kind value

   --
   --  Name / Value
   --

   type Optional_Name_Type is new String;

   No_Name : constant Optional_Name_Type;

   subtype Name_Type is Optional_Name_Type
     with Dynamic_Predicate => Name_Type'Length > 0;
   --  A non case sensitive name

   subtype Simple_Name is Name_Type
     with Dynamic_Predicate =>
       (for all C of Simple_Name => C not in '/' | '\');
   --  A simple name, non empty and without some characters not allowed in
   --  filenames for example.

   subtype Value_Type is String;

   subtype Value_Not_Empty is Value_Type
     with Dynamic_Predicate => Value_Not_Empty'Length > 0;

   overriding function "=" (Left, Right : Optional_Name_Type) return Boolean;
   overriding function "<" (Left, Right : Optional_Name_Type) return Boolean;

   No_Value : constant Value_Type;

   function Unquote (Str : Value_Type) return Value_Type with
     Post => (if Unquote'Result'Length >= 2
                and then
                 ((Str (Str'First) = ''' and then Str (Str'Last) = ''')
                  or else
                  (Str (Str'First) = '"' and then Str (Str'Last) = '"'))
              then
               Str (Str'First + 1 .. Str'Last - 1) = Unquote'Result);

   function Quote
     (Str        : Value_Type;
      Quote_With : Character := '"') return Value_Type
     with Post => Quote'Result'Length = Str'Length + 2
                    and then
                  ((Quote'Result (Quote'Result'First) = '''
                    and then Quote'Result (Quote'Result'Last) = ''')
                   or else
                     (Quote'Result (Quote'Result'First) = '"'
                      and then Quote'Result (Quote'Result'Last) = '"'));

   type Case_Sensitive_Name_Type is new String
     with Dynamic_Predicate => Case_Sensitive_Name_Type'Length > 0;
   --  A case sensitive name

   procedure Set_Debug (Enable : Boolean);
   --  Sets global debug flag's value

private

   No_Name  : constant Optional_Name_Type := "";
   No_Value : constant Value_Type := "";

   function Image (Kind : Project_Kind) return String is
     ((case Kind is
         when K_Standard          => "a standard",
         when K_Configuration     => "a configuration",
         when K_Abstract          => "an abstract",
         when K_Library           => "a library",
         when K_Aggregate         => "an aggregate",
         when K_Aggregate_Library => "an aggregate library") & " project");

   Debug : Boolean := False;

end GPR2;
