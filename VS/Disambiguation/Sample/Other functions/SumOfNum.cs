using System;
using Microsoft.SqlServer.Server;
using System.Text.RegularExpressions;

public partial class UserDefinedFunctions
{
    [SqlFunction]
    public static long SumOfNum(string input)
    {
        MatchCollection matches =  Regex.Matches(input, "[0-9]+", RegexOptions.Compiled);
        long sum = 0;
        long i = 0;
        foreach (Match match in matches)
        {
            if (match.Value.Length <= 16)
              {
                  i = Convert.ToInt64(match.Value);
                  sum = sum + i;
              }
        }
        return sum;
    }
}
