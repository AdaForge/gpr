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

package GPR2.Source_Info.Parser.Registry is

   procedure Register (Parser : Object'Class);
   --  Register a source info parser

   function Exists (Language : Name_Type; Kind : Backend) return Boolean
     with Pre => Kind /= None;
   --  Returns True if the parser backend for Language if found. If Kind is
   --  Auto then True is returned if either an LI or Source parser exists.

   function Get
     (Language : Name_Type; Kind : Backend) return not null access Object'Class
     with Pre => Exists (Language, Kind);
   --  Get a parser for the given langugae and kind. If Kind if Auto then the
   --  LI based parser is returned and the Source based otherwise.

   procedure Clear_Cache;
   --  Clear cache for all registered parsers. While parsing it is possible for
   --  each parser to store in cache some information (Ada ALI parser does that
   --  as the same ALI constains information for possibly two units). After
   --  updating all the sources for a view one can clear the cache to free
   --  up the memory.

end GPR2.Source_Info.Parser.Registry;
