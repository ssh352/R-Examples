# $Id: kinwrite.KinGUI.R 59 2010-07-28 12:29:15Z jranke $

# Copyright (C) 2008-2010 Johannes Ranke
# Contact: mkin-devel@lists.berlios.de

# This file is part of the R package kinfit

# kinfit is free software: you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.

# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
# details.

# You should have received a copy of the GNU General Public License along with
# this program. If not, see <http://www.gnu.org/licenses/>

kinwrite.KinGUI <- function(kinobject, file, comment=NA)
{
	sink(file)
	cat("Version:\t1.1\n")
	cat("Project:\t", kinobject$parent, "\n", sep = "")
	cat("Testsystem:\t", kinobject$type, "\n", sep = "")
	cat("Comment:\t", comment, "\n", sep = "")
	write.table(kinobject$data, sep = "\t", na = "NaN", 
                quote = FALSE, row.names = FALSE)
	sink()
}
