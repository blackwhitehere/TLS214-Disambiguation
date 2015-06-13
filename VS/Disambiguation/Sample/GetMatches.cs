using System;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using Microsoft.SqlServer.Server;
using System.Text.RegularExpressions;
using System.Collections;
//db_developer
public partial class UserDefinedFunctions
{
    [SqlFunction(FillRowMethodName = "FillMatch", TableDefinition= "match_index int, match_length int, match_value nvarchar(max)")]
    public static IEnumerable GetMatches(string biblio, string pattern)
    {
        //add constraint to return only if pattern is found
        return Regex.Matches(biblio, pattern);
    }
    public static void FillMatch(object obj, out int index, out int length, out SqlChars value)
        {
        Match match = (Match)obj;
        index = match.Index;
        length = match.Length;
        value = new SqlChars(match.Value);
        }
}

