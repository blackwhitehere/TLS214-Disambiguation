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
    public static string RegexReplace(string input, string pattern, string replacement) //
    {
        //Regex r = new Regex("(?:" + i + "|(?<=['\"])s)", RegexOptions.IgnoreCase | RegexOptions.CultureInvariant | RegexOptions.Compiled);
        return Regex.Replace(input, pattern, replacement);
        //string output = Regex.Replace(input, "N.t", "NET");
    }
}
