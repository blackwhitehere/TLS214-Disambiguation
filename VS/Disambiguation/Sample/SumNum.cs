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
    [SqlFunction]
    public static int SumOfNum(string s)
    {
        Regex r = new Regex("[0-9]+", RegexOptions.Compiled);
        int sum = 0;
        int i = 0;
        foreach (Match match in r.Matches(s))
        {
            i = Convert.ToInt32(match.Value);
            sum = sum + i;
        }
        return sum;
    }
}
