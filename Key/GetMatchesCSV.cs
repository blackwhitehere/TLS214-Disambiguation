using System.Text;
using System.Text.RegularExpressions;

public partial class UserDefinedFunctions
{
    [Microsoft.SqlServer.Server.SqlFunction]
    public static string GetMatchesCSV(string input, string pattern)
    {
        MatchCollection matches = Regex.Matches(input, pattern, RegexOptions.CultureInvariant | RegexOptions.Compiled);
        string hits = "";
        foreach (Match match in matches)
        {
            hits = hits + match.Value + ", ";
        }
        return hits;
    }
}