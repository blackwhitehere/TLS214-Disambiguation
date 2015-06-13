using System;
using Microsoft.SqlServer.Server;
using System.Text.RegularExpressions;


public partial class UserDefinedFunctions
{
    [SqlFunction]
    public static string SpecialCharacterRemover(string s)
    {
        Regex t = new Regex("(?:[^a-z0-9 ]|(?<=['\"])s)", RegexOptions.IgnoreCase | RegexOptions.CultureInvariant | RegexOptions.Compiled);
        //Regex t2 = new Regex("^None$", RegexOptions.CultureInvariant | RegexOptions.Compiled);
        //list
        return t.Replace(s, String.Empty);
        // if (type == 2)  dummy=t2.Replace(s, String.Empty);
        //return dummy;
    }
}
