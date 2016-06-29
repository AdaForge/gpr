
------------------------------------------------------------------------------
--                                                                          --
--                            GPR PROJECT PARSER                            --
--                                                                          --
--            Copyright (C) 2015-2016, Free Software Foundation, Inc.       --
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

--  DO NOT EDIT THIS IS AN AUTOGENERATED FILE


--  This package defines subprograms whose only purpose it to be used from a
--  debugger. This is supposed to make developpers' life easier.

with GPR_Parser.AST;
use GPR_Parser.AST;
with GPR_Parser.Lexer;
use GPR_Parser.Lexer;
use GPR_Parser.Lexer.Token_Data_Handlers;

package GPR_Parser.Debug is

   procedure PN (Node : GPR_Node);
   --  "Print Node".  Shortcut for Put_Line (Node.Short_Image). This is useful
   --  because Short_Image takes an implicit accessibility level parameter,
   --  which is not convenient in GDB.

   procedure PT (Node : GPR_Node);
   --  "Print Tree". Shortcut for Node.Print. This is useful because Print is a
   --  dispatching primitive whereas these are difficult to call from GDB.
   --  Besides, it removes the Level parameter.

   procedure PTok (Node : GPR_Node; T : Token_Index);
   --  "Print Token". Print the data associated to the T token. Node must be in
   --  the same analysis unit as the token that T represents.

end GPR_Parser.Debug;