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
    public static int? IsMatchIndex(string input, string pattern)
    {
        Match match = Regex.Match(input, pattern, RegexOptions.IgnoreCase | RegexOptions.CultureInvariant | RegexOptions.Compiled);
        // Here we check the Match instance
        if (match.Success)
        {
            return match.Index;
        } 
        return null;
    }
}
