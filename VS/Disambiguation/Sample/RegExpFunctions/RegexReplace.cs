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
        Regex r = new Regex(pattern, options);
        return r.Replace(input, replacement);
        //string output = Regex.Replace(input, "N.t", "NET");
    }

}
