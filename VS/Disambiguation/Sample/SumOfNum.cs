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
    public static long SumOfNum(string s)
    {
        Regex r = new Regex("[0-9]+", RegexOptions.Compiled);
        long sum = 0;
        long i = 0;
        foreach (Match match in r.Matches(s))
        {
            if (match.Value.Length < 16)
            {
                i = Convert.ToInt64(match.Value);
                sum = sum + i;
            }           
        }
        return sum;
    }
}