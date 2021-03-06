using System;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using Microsoft.SqlServer.Server;
using System.Collections.Generic;
using System.Text;
using System.Text.RegularExpressions;

public partial class UserDefinedFunctions
{
    [Microsoft.SqlServer.Server.SqlFunction]
    public static string RegexReplace(string input, string pattern, string replacement)
    {
        RegexOptions options = RegexOptions.CultureInvariant | RegexOptions.Compiled;
        return Regex.Replace(input, pattern, replacement, options);
        //string output = Regex.Replace(input, "N.t", "NET");
    }

}
