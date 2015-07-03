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
    public static int GetMatchesCount(string input, string pattern)
    {
        MatchCollection matches = Regex.Matches(input, pattern, RegexOptions.IgnoreCase | RegexOptions.CultureInvariant | RegexOptions.Compiled);
        int count = 0;
        foreach (Match match in matches)
        {
            count++;
        }
        return count;
    }
}