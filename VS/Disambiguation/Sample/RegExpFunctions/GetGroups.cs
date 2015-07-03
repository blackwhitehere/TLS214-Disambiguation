using System.Text;
using System.Text.RegularExpressions;

public partial class UserDefinedFunctions
{
    [Microsoft.SqlServer.Server.SqlFunction]
    public static string GetGroups(string input, string pattern, int group_number)
    {
        MatchCollection matches = Regex.Matches(input, pattern, RegexOptions.IgnoreCase | RegexOptions.CultureInvariant | RegexOptions.Compiled);
        foreach (Match match in matches)
        {
            return match.Groups[group_number].Value;
        }
        return string.Empty;
    }
}